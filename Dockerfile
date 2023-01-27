FROM ruby:3.1.1-alpine as builder
ENV APP_PATH /var/app
ENV BUNDLE_VERSION 2.2.28
ENV BUNDLE_PATH /usr/local/bundle/gems
ENV TMP_PATH /tmp/
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_PORT 3000
# install dependencies for application
RUN apk -U add --no-cache \
    build-base \
    git \
    && rm -rf /var/cache/apk/* \
    && mkdir -p $APP_PATH
RUN gem install bundler --version "$BUNDLE_VERSION" && \
    rm -rf $GEM_HOME/cache/*
COPY / $APP_PATH
# navigate to app directory
WORKDIR $APP_PATH
RUN bundle check || bundle install


FROM ruby:3.1.1-alpine as final-image
LABEL "owner"="rameshcreations"
LABEL version="1.0"
ENV BUNDLE_PATH /usr/local/bundle/gems
RUN addgroup -S app -g 1000  && adduser -S app -u 1000 -G app -h /var/app
# Switch to this user
USER app
# We'll install the app in this directory
WORKDIR /var/app
# Copy over gems from the dependencies stage
COPY --from=builder --chown=app:app /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder --chown=app:app /var/app ./
EXPOSE 3000
# Launch the server
ENTRYPOINT ["./docker-entrypoint.sh"]