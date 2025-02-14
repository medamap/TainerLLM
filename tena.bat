@echo off
SET OLLAMA_CONTAINER=ollama_container
SET PROXY_CONTAINER=proxy_server

:: 引数がない場合はヘルプを表示
IF "%1"=="" (
    echo TainerLLM - Docker 管理バッチ
    echo.
    echo 使い方:
    echo   tena.bat build   - プロキシを先にビルドし、Ollama をプロキシ経由でビルド
    echo   tena.bat up      - プロキシと Ollama のコンテナを起動
    echo   tena.bat down    - プロキシと Ollama のコンテナを停止
    echo   tena.bat shell   - Ollama のコンテナ内の bash に入る
    echo   tena.bat proxy   - プロキシのログを表示
    exit /b
)

:: プロキシをビルド
IF "%1"=="build" (
    echo [1/2] プロキシをビルド中...
    docker-compose build %PROXY_CONTAINER%
    
    echo [2/2] プロキシを起動中...
    docker-compose up -d %PROXY_CONTAINER%

    echo [*] 30秒待機してプロキシが完全に起動するのを待ちます...
    timeout /t 30 /nobreak

    echo [*] Ollama をプロキシ経由でビルド中...
    docker-compose build %OLLAMA_CONTAINER%
    exit /b
)

:: コンテナを起動
IF "%1"=="up" (
    echo [1/3] プロキシを起動中...
    docker-compose up -d %PROXY_CONTAINER%
    echo [2/3] 30秒待機してプロキシが完全に起動するのを待ちます...
    timeout /t 30 /nobreak
    echo [3/3] ollama コンテナを起動中...
    docker-compose up -d %OLLAMA_CONTAINER%
    exit /b
)

:: コンテナを停止
IF "%1"=="down" (
    echo コンテナを停止中...
    docker-compose down
    exit /b
)

:: Ollama のコンテナ内でシェルを開く
IF "%1"=="shell" (
    echo Ollama コンテナ内の bash に入ります...
    docker exec -it %OLLAMA_CONTAINER% /bin/bash
    exit /b
)

:: プロキシのログを確認
IF "%1"=="proxy" (
    echo プロキシのログを表示します...
    docker logs %PROXY_CONTAINER% --tail 50 -f
    exit /b
)

:: 不明なコマンド
echo エラー: 不明なコマンド "%1"
echo tena.bat を引数なしで実行するとヘルプを表示します。
exit /b 1
