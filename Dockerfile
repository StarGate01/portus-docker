FROM ruby:2.6

ENV RACK_ENV="production"
ENV RAILS_ENV="production"

EXPOSE 3000

RUN apt-get update && \
    apt-get install -y --no-install-recommends nodejs ldap-utils curl default-mysql-client
# RUN gem uninstall -i /usr/local/lib/ruby/gems/2.3.0 rake

COPY ./Portus /srv/Portus
RUN mkdir -p /srv/Portus/log && cd /srv/Portus && bundle install

RUN cp -f /srv/Portus/docker/init /init && chmod +x /init
ENTRYPOINT ["/bin/sh","/init"]
