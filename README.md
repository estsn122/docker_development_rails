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

## 不明点

元々Dockerファイルは次のようにして実行しようとしてたが、  
`rails new`をしてからの`bundle`コマンドでpermission errorが起こり、上手く行かなかった。

Dockerfile
```
FROM ruby:2.6.6

# ユーザー作成
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID devel
RUN useradd -u $UID -g devel -m devel
RUN echo "devel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# パッケージ関連の処理
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee \
    /etc/apt/sources.list.d/yarn.list
RUN apt update && apt install yarn
RUN apt-get install -y vim

RUN mkdir /app && chown devel /app
WORKDIR /app

COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

USER devel
```

調べても解決方法がよくわからなかったというのと、以下の理由によりとりあえずrootユーザーで行った。
- ここのユーザー作成の手順は必ずしも必要とは思えなかった
- 参考書(パーフェクトRoR)に、開発環境ではパーミッションが複雑だからと、rootユーザーで起動する方法を紹介していた
- 知人もrootユーザーで良いのではと言っていた

Rails6実践ガイドではユーザー作成して問題なくできているので、もし解決したい場合は参考に  
ただし、mysqlではなくpostgresqlで行っている。



