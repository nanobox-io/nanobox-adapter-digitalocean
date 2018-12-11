FROM ruby:2.3

# setup the app dir
RUN mkdir /app
WORKDIR /app

# # install necessary packages      
RUN apt-get update && \
    apt-get install -y \
      # build tools
      build-essential \
      # git 
      git

# bundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install
