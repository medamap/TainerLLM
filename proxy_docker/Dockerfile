FROM ubuntu:latest

# 必要なツールをインストール
RUN apt-get update && apt-get install -y \
    squid && \
    rm -rf /var/lib/apt/lists/*

# Squid 設定をコピー
COPY squid.conf /etc/squid/squid.conf

# キャッシュ用ディレクトリを作成
RUN mkdir -p /var/spool/squid && \
    chown -R proxy:proxy /var/spool/squid && \
    squid -z

# Squid を起動
CMD ["sh", "-c", "rm -rf /run/squid && mkdir -p /run/squid && squid -z && squid -N -d 1"]
