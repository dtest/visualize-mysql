FROM pblittle/docker-logstash

RUN apt-get update && apt-get install -y autoconf bison make gcc ruby ruby-dev libmysqlclient-dev --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# install things globally, for great justice
ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH

COPY Gemfile /

RUN gem install bundler \
  && bundle config --global path "$GEM_HOME" \
  && bundle config --global bin "$GEM_HOME/bin" \
  && bundle install

RUN mkdir -p /opt/logstash/conf.d/
COPY server.conf.rb /opt/logstash/conf.d/server.conf

VOLUME /opt/logstash/scripts
# COPY scripts /opt/logstash/scripts