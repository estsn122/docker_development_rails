FROM ruby:2.6.6

# パッケージ関連の処理
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee \
    /etc/apt/sources.list.d/yarn.list
RUN apt update && apt install yarn
RUN apt-get install -y vim

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install
