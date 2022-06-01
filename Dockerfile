FROM ruby:3.1.2-alpine

RUN apk update && apk add build-base git tzdata postgresql-dev

ENV USER="app"
ENV GEM_HOME="/usr/local/bundle"
ENV PATH=$GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH

RUN addgroup \
  --gid 5000 \
  $USER

RUN adduser \
  --disabled-password \
  --gecos "" \
  --ingroup $USER \
  --uid 5000 \
  $USER

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  BUNDLE_FORCE_RUBY_PLATFORM=1 \
  BUNDLER_VERSION=${BUNDLER_VERSION:-2.3.8}

ENV HOME /app
ENV PATH $HOME/bin:$PATH

RUN gem update --system && \
  gem install bundler -v $BUNDLER_VERSION

RUN mkdir -p $HOME \
  && mkdir -p $HOME/tmp/sockets \
  && mkdir -p $HOME/tmp/pids

WORKDIR $HOME

COPY . $HOME

RUN bundle install
RUN chown -R $USER:$USER $HOME
USER $USER_ID
