FROM ruby:2.4.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /certificate_authority
WORKDIR /certificate_authority
ADD Gemfile /certificate_authority/Gemfile
ADD Gemfile.lock /certificate_authority/Gemfile.lock
RUN bundle install
RUN mv /certificate_authority/config/database.docker.yml \
      /certificate_authority/config/database.yml
ADD . /certificate_authority
