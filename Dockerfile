FROM ruby:2.6.2-alpine
ARG REPO_URL="https://github.com/SUSE/Portus.git"
ARG REPO_TAG="v2.5"
ARG VERSION_STRING="v2.5"

ENV RACK_ENV=production RAILS_ENV=production NODE_ENV=production \
    GOROOT=/usr/lib/go GOPATH=/root/go/packages GEM_HOME=/srv/Portus/vendor/bundle/ruby/2.6.0 \
    PORTUS_KEY_PATH=ap PORTUS_SECRET_KEY_BASE=ap PORTUS_PASSWORD=ap INCLUDE_ASSETS_GROUP=yes \
    PORTUS_VERSION="${VERSION_STRING}"
ENV GEM_PATH=$GEM_HOME PATH=$PATH:$GOROOT/bin:$GOPATH/bin:$GOPATH/src/openSUSE/portusctl/bin:$GEM_HOME/bin

WORKDIR $GOPATH
RUN apk add --no-cache ca-certificates git bash npm yarn tzdata openssl-dev \
        openldap-dev curl-dev mariadb-dev postgresql-dev make musl-dev go g++ && \
    go get github.com/tools/godep && \
    git clone https://github.com/openSUSE/portusctl.git src/openSUSE/portusctl && \
    cd src/openSUSE/portusctl && godep restore && go build -o /usr/bin/portusctl *.go && \
    cd / && rm -rf /root/go && echo "Cloning ${REPO_URL}#${REPO_URL}" && \
    cd /srv && git clone -b "${REPO_TAG}" "${REPO_URL}" Portus && \
    cd Portus && git rev-parse --short HEAD > VERSION && rm -rf .git && \
    yarn install --production=false && \
    bundle install --without test development --with assets --path ./vendor/bundle && \
    gem install bundler -v 1.17.3 -i ./vendor/bundle/ruby/2.6.0 -n ./vendor/bundle/ruby/2.6.0/bin && \
    ln -s bundler ./vendor/bundle/ruby/2.6.0/bin/bundler.ruby2.6 && \
    ./bin/bundle exec rake portus:assets:compile && \
    rm -r ./vendor/bundle/ruby/2.6.0/cache/* && \
    rm -rf ./node_modules && \
    apk del yarn go

EXPOSE 3000
ENTRYPOINT ["/bin/bash", "/srv/Portus/docker/init"]