# # syntax = docker/dockerfile:1

# # Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
FROM ruby:3.2.2-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    RAILS_MASTER_KEY="${RAILS_MASTER_KEY}" \
    RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    PATH="${PATH}:/home/ruby/.local/bin:/node_modules/.bin"

# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl wget git libvips bash bash-completion libffi-dev libpq-dev tzdata postgresql pkg-config && \
    apt-get clean && \
    mkdir /node_modules && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man /var/cache/apt/archives

RUN bash -c "set -o pipefail && apt-get update \
    && apt-get install -y ca-certificates curl gnupg \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main' | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install nodejs -y"


RUN apt-get remove -y cmdtest && \
    apt-get remove -y yarn && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y yarn

RUN yarn add esbuild
RUN yarn add tailwind

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY --chown=ruby:ruby package.json *yarn* ./
RUN yarn install --ignore-engines

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

COPY --chown=rails:rails bin/ ./bin
RUN chmod 0755 bin/*

RUN yarn
RUN yarn add esbuild
RUN yarn add tailwind

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
 RUN if [ "${RAILS_ENV}" != "development" ]; then \
     SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile; fi

# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl default-mysql-client libsqlite3-0 libvips postgresql-client redis && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# add jemalloc
RUN apt-get update && apt-get install libjemalloc2 && rm -rf /var/lib/apt/lists/*
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# # Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp public
USER rails:rails

COPY --chown=rails:rails bin/ ./bin
RUN chmod 0755 bin/*

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000

CMD ["bin/rails", "server" ]
