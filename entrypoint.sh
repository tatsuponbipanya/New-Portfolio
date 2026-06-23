#!/bin/bash
set -e

# サーバーの幽霊（server.pid）が残っていたら削除する
rm -f /app/tmp/pids/server.pid

# そのあとにメインのコマンド（rails sなど）を実行
exec "$@"