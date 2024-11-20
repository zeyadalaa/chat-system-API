# Use official Ruby image
FROM ruby:3.3.6

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && apt-get install -y curl gnupg

# Add NodeSource repository and install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && apt-get install -y nodejs

# Install other dependencies
RUN apt-get install -y \
  build-essential \
  libpq-dev \
  libvips-dev \
  libmagickwand-dev

# Copy Gemfile and Gemfile.lock
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

# Install Gems
RUN bundle install

# Copy the rest of the application code
COPY . /app


# Expose the port your app runs on

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
EXPOSE 3000
