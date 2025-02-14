#!/bin/bash
set -e  # エラー発生時は即終了

# ユーザーのホームディレクトリを利用
STATE_FILE="$HOME/.ollama/entrypoint.state"
MODEL_DIR="$HOME/.ollama"
MODEL_NAME="neoAI-8B-Chat-v0.1-Q6_K"
MODEL_FILE="$MODEL_DIR/$MODEL_NAME.gguf"
MODEL_RAW_FILE="$MODEL_DIR/$MODEL_NAME"
MODEL_URL="https://huggingface.co/mradermacher/Llama-3-neoAI-8B-Chat-v0.1-GGUF/resolve/main/Llama-3-neoAI-8B-Chat-v0.1.Q6_K.gguf"

# SIGTERM/SIGINT を受けたときのクリーンアップ処理（Docker停止対策）
function cleanup {
    echo "🛑 SIGTERM 受信！プロセスを終了します..."
    pkill -SIGTERM aria2c || true  # aria2c の終了（プロセスがなければ無視）
    pkill -SIGTERM ollama || true  # Ollama サーバーの終了
    exit 0
}

trap cleanup SIGTERM SIGINT

echo "=== TainerLLM 起動 ==="
mkdir -p "$MODEL_DIR"

# ステートファイルがなければ初期化
if [ ! -f "$STATE_FILE" ]; then
    echo "unknown" > "$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")
echo "現在の状態: $STATE"

# まず、モデル登録前に ollama サーバーをバックグラウンドで起動
echo "Ollama サーバーを起動します..."
ollama serve &
SERVER_PID=$!
# サーバー起動待ち（必要に応じて待ち時間は調整してください）
sleep 5

# 既にモデルのインストールが完了している場合は処理をスキップ
if [ "$STATE" = "modelcomplete" ]; then
    echo "モデルはすでにインストール済みです。"
else
    # モデルファイルが存在しない、または状態が "downloaded" でも "failed" でもない場合はダウンロード
    if [ ! -f "$MODEL_FILE" ] || { [ "$STATE" != "downloaded" ] && [ "$STATE" != "failed" ]; }; then
        echo "downloading" > "$STATE_FILE"
        echo "モデルが見つからないため、ダウンロードを開始します..."
        STATE=$(cat "$STATE_FILE")
        echo "現在の状態: $STATE"
    
        aria2c -x 16 -s 16 -k 1M --file-allocation=none -d "$MODEL_DIR" -o "$MODEL_NAME" "$MODEL_URL" || {
            echo "ダウンロードに失敗しました。"
            exit 1
        }
    
        echo "ダウンロード完了: $MODEL_RAW_FILE"
    
        # ダウンロードしたファイルをモデルファイルとしてリネーム
        if [ -f "$MODEL_RAW_FILE" ] && [ ! -f "$MODEL_FILE" ]; then
            mv "$MODEL_RAW_FILE" "$MODEL_FILE"
        fi
    
        if [ ! -f "$MODEL_FILE" ]; then
            echo "エラー: モデルファイルが見つかりません！"
            exit 1
        fi
    
        echo "downloaded" > "$STATE_FILE"
        STATE=$(cat "$STATE_FILE")
        echo "現在の状態: $STATE"
    fi
    
    # 状態が "downloaded" または "failed" の場合、モデルの登録を試みる
    if [ "$STATE" = "downloaded" ] || [ "$STATE" = "failed" ]; then
        # 修正: Modelfile.txt の内容に正しいファイル名を指定
        echo "FROM ./$MODEL_NAME.gguf" > "$MODEL_DIR/Modelfile.txt"
    
        echo "Ollama にモデルを登録中..."
        if ollama create "$MODEL_NAME" -f "$MODEL_DIR/Modelfile.txt"; then
            echo "modelcomplete" > "$STATE_FILE"
            STATE=$(cat "$STATE_FILE")
            echo "現在の状態: $STATE"
        else
            echo "モデルのインストールに失敗しました。"
            echo "failed" > "$STATE_FILE"
            STATE=$(cat "$STATE_FILE")
            echo "現在の状態: $STATE"
            exit 1
        fi
    fi
fi

echo "Ollama モデルが準備完了！"

# サーバープロセスの終了を待って、コンテナが終了しないようにする
wait $SERVER_PID
