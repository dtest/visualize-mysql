#!/usr/bin/ruby
# Author: Derek Downey
# performance_schema_statements.rb - Grab statements from performance schema to be grok'd/filtered by logstash

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'optparse'
require 'mysql2'
require 'inifile'
require 'json'

# Performance schema should be enabled, and the events_statements_* consumers as well. An example my.cnf:
# [mysqld]
# *snip*
# performance_schema=ON
# performance_schema_consumer_events_statements_history=ON
# performance_schema-consumer_events_statements_history_long=ON
# *snip
#
# Or at runtime if performance_schema is enabled:
#  UPDATE performance_schema.setup_consumers SET ENABLED='YES' WHERE NAME LIKE 'events_statements_%';


options = {:ini => nil}

parser = OptionParser.new do|opts|
  opts.banner = "Usage: performance_schema_statements.rb [options]"
  opts.on('-i', '--ini inifile', 'inifile') do |inifile|
    options[:ini] = inifile;
  end

  opts.on('-u', '--user user', 'User') do |db_user|
    options[:db_user] = db_user;
  end

  opts.on('-p', '--password password', 'Password') do |db_password|
    options[:db_password] = db_password;
  end

  opts.on('-S', '--socket socket', 'Socket') do |socket|
    options[:socket] = socket;
  end

  opts.on('-H', '--host host', 'Host') do |host|
    options[:host] = host;
  end

  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end

parser.parse!

# Set appropriate connection options
if options[:ini]
  ini = IniFile.load(options[:ini])
  section = ini['client']
  options[:db_user] = section['user']
  options[:db_password] = section['password']
  options[:socket] = section['socket']
  options[:host] = section['host']
end

$client = Mysql2::Client.new(:username => options[:db_user], :password => options[:db_password], :host => options[:host], :socket => options[:socket])
## Everything uppercase gets sent to graphite

def mysql_query (query)
  results = $client.query(query)

  results.each do |row|
    puts row.to_json
  end
end

# Statements
mysql_query("SELECT \"ps_statements\" AS log_type,
  thread_id, event_id, event_name AS statement_event, digest, digest_text, current_schema, object_schema, object_type, object_name,
  mysql_errno, returned_sqlstate, TIMER_WAIT, LOCK_TIME, ERRORS, WARNINGS, ROWS_AFFECTED, ROWS_SENT, ROWS_EXAMINED,
  CREATED_TMP_DISK_TABLES, CREATED_TMP_TABLES, SELECT_FULL_JOIN, SELECT_FULL_RANGE_JOIN, SELECT_RANGE, SELECT_RANGE_CHECK,
  SELECT_SCAN, SORT_MERGE_PASSES, SORT_RANGE, SORT_ROWS, SORT_SCAN, if(((NO_GOOD_INDEX_USED > 0) or (NO_INDEX_USED > 0)),'1','0') NO_INDEX_USED
FROM performance_schema.events_statements_history AS history
WHERE DATE_FORMAT(DATE_SUB(NOW(),INTERVAL (
    SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE variable_name='UPTIME')-TIMER_START*10e-13 second),'%Y-%m-%d %T') >= DATE_SUB(NOW(), INTERVAL 10 SECOND)"
)

# Waits

mysql_query("SELECT \"ps_waits\" AS log_type,
  thread_id, event_id, event_name AS wait_event, object_schema, object_name, index_name, object_type, operation,
  TIMER_WAIT AS WAITS_LATENCY, SPINS, NUMBER_OF_BYTES
FROM performance_schema.events_waits_history
WHERE DATE_FORMAT(DATE_SUB(NOW(),INTERVAL (SELECT VARIABLE_VALUE FROM information_schema.global_status WHERE variable_name='UPTIME')-TIMER_START*10e-13 second),'%Y-%m-%d %T') >= DATE_SUB(NOW(), INTERVAL 10 SECOND);")

# Performance Schema Memory usage
mysql_query("SELECT \"ps_memory_usage\" AS log_type,
 event_name, current_alloc, high_alloc
FROM sys.x$memory_global_by_current_bytes AS mem_usage"
)

# Performance Schema lost events
mysql_query("select \"ps_lost_events\" AS log_type, `VARIABLE_NAME` AS `lost_variable`, `VARIABLE_VALUE` AS `lost_value`
FROM `performance_schema`.`global_status` where `VARIABLE_NAME` like 'perf%lost'")

# Performance Schema metadata_locks
mysql_query("SELECT \"ps_metadata_locks\" AS log_type,
  OBJECT_SCHEMA AS mdl_schema, OBJECT_NAME AS mdl_name, OWNER_THREAD_ID AS thread_id, OWNER_EVENT_ID AS event_id,
  LOCK_STATUS AS mdl_status
  FROM performance_schema.metadata_locks WHERE OBJECT_NAME != 'metadata_locks'")


# Clean up connection
$client.close;
