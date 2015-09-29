
input {
  exec {
    type => "mysql_statements"
    command => "env GEM_PATH='/usr/local/bundle' /usr/bin/ruby /opt/logstash/scripts/performance_schema.rb -Hmysql -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD"
    interval => 10
    codec => "json_lines"
  }
}

filter {
  mutate {
    replace => ["host", "ple15_docker_local"]
  }

  if [log_type] == "ps_metadata_locks" {
    metrics {
      meter => ["MDL_EVENTS"]
      ignore_older_than => 10
    }
  }
}

output {
  elasticsearch_http {
      host => "es"
      port => "9200"
  }

  graphite {
    host => "graphite"
    fields_are_metrics => true
    metrics_format => "performance_schema.*"
    include_metrics => ["^[A-Z_]+"]
  }

  stdout {
    codec => graphite {
      fields_are_metrics => true
      metrics_format => "performance_schema.*"
      include_metrics => ["^[A-Z]+"]
    }
  }

}
