
input {
    file {
        type => "mysql_error"
        path => "/var/lib/mysql/mysql.err"
        codec => "plain"
    }

    exec {
        type => "mysql_statements"
        command => "env GEM_PATH='/usr/local/bundle' /usr/bin/ruby /performance_schema_statements.rb -Hmysql -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD"
        interval => 10
        codec => "json_lines"
    }
}

filter {
    mutate {
      replace => ["host", "ple15_docker_local"]
    }

    if [type] == "mysql_statements" {

        #clone {
        # clones => "mysql_statements_metrics"
        #  add_tag => [ "graphite" ]
        #}

        #metrics {
        #  meter => [ "%{host}.mysql_statements.rows" ]
        #  add_tag => [ "graphite" ]
        #}
    }

    #if [type] == "mysql_error" {
    #    multiline {
    #    what => previous
    #    pattern => '^\s'
    #}

    #grok {
    #    patterns_dir => '{{ logstash_patterns_dir }}'
    #    pattern => '%{MYSQL_ERROR_LOG}'
    #}
}

output {
  rabbitmq {
    host => "demostack-RabbitMQ-14C2Q14SI4W9C-727330852.us-west-2.elb.amazonaws.com"
    password => "q_z-Mk%BTX"
    exchange => "logstash"
    exchange_type => "direct"
    port => 5671
    ssl => true
    user => "logstash_external"
    verify_ssl => false
    debug => true
  }

  if [type] == "mysql_statements" {
  #if "graphite" in [tags] {
    stdout {
      codec => graphite {
        metrics => {
          "%{host}.mysql_statements.rows_examined" => "%{ROWS_EXAMINED}"
          "%{host}.mysql_statements.rows_sent" => "%{ROWS_SENT}"
        }
        fields_are_metrics => true
        metrics_format => "mysql_statements.*"
        exclude_metrics => ["DIGEST", "SCHEMA", "^OBJECT"]
        include_metrics => ["[A-Z_]+"]
      }
    }
    rabbitmq {
      host => "demostack-RabbitMQ-14C2Q14SI4W9C-727330852.us-west-2.elb.amazonaws.com"
      password => "%qz-sl+X_k"
      exchange => "statsd"
      exchange_type => "topic"
      vhost => "/statsd"
      port => 5671
      ssl => true
      user => "statsd"
      verify_ssl => false
      debug => true
      codec => graphite {
        #metrics => {
        #  "%{host}.mysql_statements.rows_examined" => "%{ROWS_EXAMINED}"
        #  "%{host}.mysql_statements.rows_sent" => "%{ROWS_SENT}"
        #}
        fields_are_metrics => true
        metrics_format => "mysql_statements.*"
        exclude_metrics => ["DIGEST", "SCHEMA", "^OBJECT", "EVENT_NAME"]
        include_metrics => ["[A-Z_]+"]
      }
    }
  }
}


#logstash:
#  rabbitmq:
#    host: demostack-RabbitMQ-14C2Q14SI4W9C-727330852.us-west-2.elb.amazonaws.com
#    password: "q_z-Mk%BTX"
#  inputs:
#    file: [{"type":"mysql_error", "path":"/var/log/mysql/error.log" }]
##    exec: [{"type":"mysql_statements", "interval": 10, "codec":"json_lines", "command":"env GEM_PATH='/opt/sensu/embedded/lib/ruby/gems/2.0.0' /opt/sensu/embedded/bin/ruby /opt/opviz/chef-cookbooks/opviz-client/files/default/logstash_plugins/performance_schema_statements.rb -i /opt/logstash/.my.cnf" }]
#  filters: []
# groups: 'logstash,mysql'
#  mysql:
#    user: logstash
#    password: logger