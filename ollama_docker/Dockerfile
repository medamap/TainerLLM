### GPU 対応 ollama コンテナ用 Dockerfile ###
FROM nvidia/cuda:12.2.2-devel-ubuntu22.04

# Build 時に渡されたプロキシの値を設定する
ARG http_proxy
ARG https_proxy
ENV http_proxy=${http_proxy}
ENV https_proxy=${https_proxy}
ENV HTTP_PROXY=${http_proxy}
ENV HTTPS_PROXY=${https_proxy}

# 必要なツールをインストール（プロキシ経由）
RUN apt-get update && apt-get install -y \
    curl \
    aria2 \
    unzip \
    locales \
    fonts-noto-cjk \
    sudo && \
    rm -rf /var/lib/apt/lists/*

# Ollama のインストール
RUN curl -fsSL https://ollama.com/install.sh | sh

# ロケール設定
RUN locale-gen ja_JP.UTF-8 && \
    update-locale LANG=ja_JP.UTF-8 && \
    echo "export LANG=ja_JP.UTF-8" >> /etc/profile

# tainer ユーザーを作成し、sudo 権限を付与（root 権限で実行）
RUN useradd -m -s /bin/bash tainer && \
    echo "tainer:tainer" | chpasswd && \
    adduser tainer sudo

# entrypoint.sh と execollama.sh を /usr/local/bin にコピー（root で実行）
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY execollama.sh /usr/local/bin/execollama.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/execollama.sh

# tainer ユーザーに切り替え
USER tainer
WORKDIR /home/tainer

# tainer ユーザー環境で entrypoint.sh を実行
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
