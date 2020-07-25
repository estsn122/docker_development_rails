# README

## 概要
Dockerでrailsを開発する際の参考プロジェクトです
- rails6
- mysql

## 手順

### 手順1
下記4ファイルを準備する  
- Dockerfile
```
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
```

- Gemfile 
```
source 'https://rubygems.org'
gem 'rails', '~> 6'
```

- Gemfile.lock
(空ファイル)

- docker-compose.yml
```
version: '3'
services:
  db:
    image: mysql:5.7
    environment:
      MYSQL_USER: root
      MYSQL_ROOT_PASSWORD: password
    ports:
      - "3306:3306"
    volumes:
      - ./db/volumes/mysql:/var/lib/mysql
  web:
    build: .
    command: /bin/sh
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    depends_on:
      - db
    tty: true
```

### 手順2
下記コマンドでイメージの作成
```
$ docker-compose build --no-cache web
```

### 手順3

次のコマンドでコンテナを起動
```
$ docker-compose up
```
 
別のターミナルで、下記コマンドでコンテナ内に入る
```
$ docker-compose exec web bash
```

### 手順4

コンテナ内で
```
rails new . -d mysql --skip-test-unit --force
```
を行い、
.gitignoreファイルに
```
/db/volumes
```
を追記  
※`rails new`したタイミングでコミットせず、.gitignoreファイルに追記してからコミットすること

### 手順5

DBで、テーブルの作成を行う  

database.ymlを次のように編集
```
-  password:
-  host: localhost
+  password: password
+  host: db
```
その後、コンテナ内で
```
$ rails db:create
```

### 手順6

```
rails s -b 0.0.0.0
```

