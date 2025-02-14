#!/bin/bash
set -e  # エラーが発生したら即終了
set -x  # 実行コマンドを表示（デバッグ用）

echo "🛠 Squid 初期化スクリプト開始..."

# 既存の Squid プロセスを完全停止
if pgrep squid; then
    echo "🛑 既存の Squid プロセスを停止中..."
    pkill squid
    sleep 2
fi

# Squid の PID ファイルを削除
rm -rf /run/squid /var/run/squid /run/squid.pid

# キャッシュディレクトリを再作成・権限設定
echo "📂 Squid キャッシュディレクトリを作成..."
mkdir -p /var/spool/squid
chown -R proxy:proxy /var/spool/squid

# Squid キャッシュの初期化（`-z` を実行）
echo "🛠 Squid キャッシュを初期化中..."
squid -z || {
    echo "⚠ キャッシュディレクトリの初期化に失敗しました！"
    exit 1
}
sleep 3

# ★ ここで、squid -z によって起動したプロセスが残っている可能性があるため、明示的に終了する
echo "🛑 初期化で起動した Squid プロセスを停止します..."
pkill squid || true
rm -f /run/squid.pid

# Squid をフォアグラウンドで起動
echo "🚀 Squid を起動します..."
exec squid -N -d 1
