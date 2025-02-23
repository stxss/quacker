FROM ruby:3.2

WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  git \
  && rm -rf /var/lib/apt/lists/*

# Install bundler and gems
RUN gem install bundler

# Copy Gemfile first for caching layer optimization
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# Copy the entire app
COPY . .

# Ensure permissions are correct
RUN chown -R root:root /app

# Precompile Bootsnap cache
RUN bundle exec bootsnap precompile --gemfile || echo "Bootsnap precompile failed"

# Set default command
CMD ["rails", "server", "-b", "0.0.0.0"]