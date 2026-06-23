# ベースとなるRubyのバージョン
FROM ruby:3.2.10

# SQLite3や必要なパッケージをインストールする
RUN apt-get update -qq && apt-get install -y build-essential sqlite3 libsqlite3-dev

# コンテナの中に「app」という作業ディレクトリを作る
RUN mkdir /app
WORKDIR /app

# Gemfileを先にコピーしてインストール（ここを分けるのが爆速化のコツ）
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install

# アプリのコードを全部コンテナの中にコピー
COPY . /app

# おまじないファイル（entrypoint.sh）をセット
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# ブラウザからアクセスできるように3000番ポートを開ける
EXPOSE 3000

# サーバー起動のコマンド
CMD ["rails", "server", "-b", "0.0.0.0"]