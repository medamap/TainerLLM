#!/bin/bash

set -e  # エラーが発生したら即終了

# デバッグモードが有効なら set -x
if [[ "$DEBUG" == "1" ]]; then
    set -x
fi

STATE_FILE="$HOME/.ollama/entrypoint.state"
MODEL_NAME="neoAI-8B-Chat-v0.1-Q6_K"

if [ -f "$STATE_FILE" ]; then
    STATE=$(cat "$STATE_FILE")
else
    echo "⚠ ステートファイルが見つかりません。セットアップを確認してください。"
    exit 1
fi

function show_help {
    echo "使い方: execollama.sh [コマンド]"
    echo "  run <番号>    - 指定した番号のモデルを実行"
    echo "  list          - インストール済みモデルをリストアップ"
    echo "  server        - モデルをサーバーモードで起動"
    echo "  stop          - 実行中の Ollama サーバーを停止"
}

if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

if [ "$STATE" != "modelcomplete" ]; then
    echo "⚠ まだ Ollama のセットアップ中です（状態: $STATE）"
    exit 1
fi

case "$1" in
    run)
        if [ -z "$2" ]; then
            echo "モデル番号を指定してください。"
            exit 1
        fi
        MODEL_LIST=$(ollama list | awk 'NR>1 {print NR-1 " " $1}')
        SELECTED_MODEL=$(echo "$MODEL_LIST" | awk -v num="$2" '$1 == num {print $2}')
        if [ -z "$SELECTED_MODEL" ]; then
            echo "⚠ 指定された番号のモデルが見つかりません。"
            exit 1
        fi
        echo "🚀 モデル $SELECTED_MODEL を実行します..."
        ollama run "$SELECTED_MODEL"
        ;;
    list)
        echo "📜 インストール済みモデル一覧"
        ollama list
        ;;
    server)
        echo "🚀 Ollama サーバーモードを起動します..."
        ollama serve
        ;;
    stop)
        echo "🛑 Ollama サーバーを停止します..."
        pkill -f "ollama"
        ;;
    *)
        show_help
        exit 1
        ;;
esac
