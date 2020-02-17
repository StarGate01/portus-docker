FROM ruby:2.6.2-alpine as builder
ENV RACK_ENV=production RAILS_ENV=production NODE_ENV=production \
    GOROOT=/usr/lib/go GOPATH=/root/go/packages GEM_HOME=/srv/Portus/vendor GEM_PATH=/srv/Portus/vendor \
    PORTUS_KEY_PATH=ap PORTUS_SECRET_KEY_BASE=ap PORTUS_PASSWORD=ap INCLUDE_ASSETS_GROUP=yes
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$GOPATH/src/openSUSE/portusctl/bin:$GEM_HOME/bin:/srv/Portus/bin

WORKDIR $GOPATH
RUN apk add --no-cache ca-certificates git bash npm yarn tzdata openssl-dev \
        openldap-dev curl-dev mariadb-dev postgresql-dev make musl-dev go g++ && \
    go get github.com/tools/godep && \
    git clone https://github.com/openSUSE/portusctl.git src/openSUSE/portusctl && \
    cd src/openSUSE/portusctl && godep restore && go build -o bin/portusctl *.go
ARG REPO_URL=https://github.com/SUSE/Portus.git 
ARG REPO_TAG=v2.5
RUN git clone --branch ${REPO_TAG} ${REPO_URL} /srv/Portus && \
    cd /srv/Portus && git rev-parse --short HEAD > /srv/Portus/VERSION && rm -rf /srv/Portus/.git 
WORKDIR /srv/Portus
ARG VERSION_STRING=v2.5
ENV PORTUS_VERSION="${VERSION_STRING}"
RUN yarn install --production=false && \
    bundle install --without test development --with assets --path ./vendor/bundle && \
    gem install bundler -v 1.17.3 -i ./vendor/bundle/ruby/2.6.0 -n ./vendor/bundle/ruby/2.6.0/bin && \
    ln -s bundler ./vendor/bundle/ruby/2.6.0/bin/bundler.ruby2.6 && \
    ./bin/bundle exec rake portus:assets:compile && \
    rm -r ./vendor/bundle/ruby/2.6.0/cache/*


FROM ruby:2.6.2-alpine
ENV RACK_ENV=production RAILS_ENV=production NODE_ENV=production \
    GEM_HOME=/srv/Portus/vendor GEM_PATH=/srv/Portus/vendor PATH=$PATH:/srv/Portus/vendor/bin:/srv/Portus/bin

RUN apk add --no-cache ca-certificates openssl bash openldap-clients curl \
    mariadb-client postgresql-client tzdata

ARG VERSION_STRING=v2.5
ENV PORTUS_VERSION="${VERSION_STRING}"
COPY --from=builder /srv/Portus/app /srv/Portus/bin /srv/Portus/.ruby-version \
    /srv/Portus/Gemfile /srv/Portus/Gemfile.lock /srv/Portus/Guardfile /srv/Portus/Rakefile \
    /srv/Portus/VERSION /srv/Portus/db /srv/Portus/lib /srv/Portus/package.json \
    /srv/Portus/public /srv/Portus/tmp /srv/Portus/vendor /srv/Portus/docker /srv/Portus/yarn.lock /srv/Portus/

EXPOSE 3000
ENTRYPOINT ["/bin/bash", "/srv/Portus/docker/init"]