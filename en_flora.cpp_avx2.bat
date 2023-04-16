@ECHO OFF
chcp 65001
SET /A THREADS=%NUMBER_OF_PROCESSORS%
title flora.cpp
:start

    if not exist "main.exe" (
        echo the source files do not exist
        echo download...
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/llama-master-3173a62-bin-win-avx2-x64.zip' -OutFile 'llama-master-3173a62-bin-win-avx2-x64.zip'"
        echo dezipping ...
        powershell -command "Expand-Archive llama-master-3173a62-bin-win-avx2-x64.zip ."
        echo completed
        echo .
    )

    echo Please select a model :
    echo 1. ggml-alpaca-7b-q4.bin - alpaca
    echo 2. ggml-vicuna-13b-4bit.bin - vicuna
    set /p choix="Choice : "
    if %choix% equ 1 (
        set MODEL=ggml-alpaca-7b-q4.bin
    ) else if %choix% equ 2 (
        set MODEL=ggml-vicuna-13b-4bit.bin
    ) else (
        echo Invalid choice.
        goto start
    )
    cls

    REM checks if the file already exists
    if not exist %MODEL% (
        REM if the file does not exist, download it
	    echo The model is not on your computer, down
        echo Downloading the model...
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/%MODEL%' -OutFile '%MODEL%'"
	    echo Download complete.
        cls
    )

    if not exist "settings.json" (
        REM if the file does not exist, download it
	    echo "settings.json" is not present on your computer, down
        echo Download settings...
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/settings.json' -OutFile 'settings.json'"
	    echo Download complete.
    )

    set "json_file=settings.json"

    for /f "tokens=2 delims=:," %%a in ('type "%json_file%" ^| findstr /c:"color"') do set "color=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_file%" ^| findstr /c:"temp"') do set "temp=%%a"

    REM runs the program with the selected model
    main.exe -t %THREADS% --temp %temp% -i --interactive-first --color -c %color% -n -1 --ignore-eos --repeat_penalty 1.2 --instruct -m %MODEL%
    pause
    goto start
