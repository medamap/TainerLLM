@echo off
SET OLLAMA_CONTAINER=ollama_container
SET PROXY_CONTAINER=proxy_server

:: �������Ȃ��ꍇ�̓w���v��\��
IF "%1"=="" (
    echo TainerLLM - Docker �Ǘ��o�b�`
    echo.
    echo �g����:
    echo   tena.bat build   - �v���L�V���Ƀr���h���AOllama ���v���L�V�o�R�Ńr���h
    echo   tena.bat up      - �v���L�V�� Ollama �̃R���e�i���N��
    echo   tena.bat down    - �v���L�V�� Ollama �̃R���e�i���~
    echo   tena.bat shell   - Ollama �̃R���e�i���� bash �ɓ���
    echo   tena.bat proxy   - �v���L�V�̃��O��\��
    exit /b
)

:: �v���L�V���r���h
IF "%1"=="build" (
    echo [1/2] �v���L�V���r���h��...
    docker-compose build %PROXY_CONTAINER%
    
    echo [2/2] �v���L�V���N����...
    docker-compose up -d %PROXY_CONTAINER%

    echo [*] 30�b�ҋ@���ăv���L�V�����S�ɋN������̂�҂��܂�...
    timeout /t 30 /nobreak

    echo [*] Ollama ���v���L�V�o�R�Ńr���h��...
    docker-compose build %OLLAMA_CONTAINER%
    exit /b
)

:: �R���e�i���N��
IF "%1"=="up" (
    echo [1/3] �v���L�V���N����...
    docker-compose up -d %PROXY_CONTAINER%
    echo [2/3] 30�b�ҋ@���ăv���L�V�����S�ɋN������̂�҂��܂�...
    timeout /t 30 /nobreak
    echo [3/3] ollama �R���e�i���N����...
    docker-compose up -d %OLLAMA_CONTAINER%
    exit /b
)

:: �R���e�i���~
IF "%1"=="down" (
    echo �R���e�i���~��...
    docker-compose down
    exit /b
)

:: Ollama �̃R���e�i���ŃV�F�����J��
IF "%1"=="shell" (
    echo Ollama �R���e�i���� bash �ɓ���܂�...
    docker exec -it %OLLAMA_CONTAINER% /bin/bash
    exit /b
)

:: �v���L�V�̃��O���m�F
IF "%1"=="proxy" (
    echo �v���L�V�̃��O��\�����܂�...
    docker logs %PROXY_CONTAINER% --tail 50 -f
    exit /b
)

:: �s���ȃR�}���h
echo �G���[: �s���ȃR�}���h "%1"
echo tena.bat �������Ȃ��Ŏ��s����ƃw���v��\�����܂��B
exit /b 1
