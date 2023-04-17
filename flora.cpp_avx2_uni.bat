@ECHO OFF
chcp 65001
SET /A THREADS=%NUMBER_OF_PROCESSORS%
title flora.cpp
:start

    if not exist "settings.json" (
        echo 1. en
        echo 2. fr
        set /p choix= "Choice :"
        if %choix% equ 1 (
            set lang=en
        ) else if %choix% equ 2 (
            set lang=fr
        ) else (
            echo %lang_invalid_c%
            goto start
        )
        cls

            set "json_file=settings.json"

        for /f "tokens=2 delims=:," %%a in ('type "%json_file%" ^| findstr /c:"color"') do set "color=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_file%" ^| findstr /c:"temp"') do set "temp=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_file%" ^| findstr /c:"lang"') do set "lang=%%a"

        if %lang% equ "en" (
            echo la langue séléctionnée est l'anglais
            set "json_lang_file=lang/en.json"
        ) else if %lang% equ "fr" (
            echo la langue séléctionnée est le français
            set "json_lang_file=lang/fr.json"
        ) else (
            echo an error was occured
            set "json_lang_file=lang/en.json"
        )

        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"sourcefiles"') do set "lang_sourcefiles=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"download"') do set "lang_download=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"dezipping"') do set "lang_dezipping=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"completed"') do set "lang_completed=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"error"') do set "lang_error=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"model"') do set "lang_model=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"choice"') do set "lang_choice=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"invalid_c"') do set "lang_invalid_c=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"model_d"') do set "lang_model_d=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"downloading_m"') do set "lang_downloading_m=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"download_c"') do set "lang_download_c=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"sett_down"') do set "lang_sett_down=%%a"
        for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:"download_sett"') do set "lang_download_sett=%%a"
        
        REM si le fichier n'existe pas, télécharge-le
	    echo "settings.json" is not present on your computer
        echo Downloading settings...
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/settings.json' -OutFile 'settings.json'"
	    echo Download complete
    )

    if not exist "main.exe" (
        echo %lang_sourcefiles%
        echo %lang_download%
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/llama-master-3173a62-bin-win-avx2-x64.zip' -OutFile 'llama-master-3173a62-bin-win-avx2-x64.zip'"
        echo %lang_dezipping%
        powershell -command "Expand-Archive llama-master-3173a62-bin-win-avx2-x64.zip ."
        echo %lang_completed%
        echo .
    )

    echo %lang_model%
    echo 1. ggml-alpaca-7b-q4.bin - alpaca
    echo 2. ggml-vicuna-13b-4bit.bin - vicuna
    set /p choix=%lang_choice%
    if %choix% equ 1 (
        set MODEL=ggml-alpaca-7b-q4.bin
    ) else if %choix% equ 2 (
        set MODEL=ggml-vicuna-13b-4bit.bin
    ) else (
        echo %lang_invalid_c%
        goto start
    )
    cls

    REM vérifie si le fichier existe déjà
    if not exist %MODEL% (
        REM si le fichier n'existe pas, télécharge-le
	    echo %lang_model_d%
        echo %lang_downloading_m%
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/%MODEL%' -OutFile '%MODEL%'"
	    echo %lang_download_c%
        cls
    )

    REM exécute le programme avec le modèle sélectionné
    main.exe -t %THREADS% --temp %temp% -i --interactive-first --color -c %color% -n -1 --ignore-eos --repeat_penalty 1.2 --instruct -m %MODEL%
    pause
    goto start
