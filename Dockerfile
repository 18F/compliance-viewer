FROM ruby:2.3.1
RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
RUN gem update bundler
RUN bundle update

RUN apt-get update
RUN wget -qO- https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install nodejs -y

ADD package.json /app/package.json
RUN npm install
