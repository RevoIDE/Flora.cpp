@ECHO OFF
chcp 65001
SET /A THREADS=%NUMBER_OF_PROCESSORS%
title flora.cpp
:start

if not exist "settings.json" (
        REM si le fichier n'existe pas, télécharge-le
	    echo settings file is not present on your computer
        echo downloading...
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/settings.json' -OutFile 'settings.json'"
	    echo download complete
        echo -----------------------------------------
    )
    
    set "json_file=settings.json"

    for /f "tokens=2 delims=:," %%a in ('type "%json_file%" ^| findstr /c:"color"') do set "color=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_file%" ^| findstr /c:"temp"') do set "temp=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_file%" ^| findstr /c:"lang"') do set "lang=%%a"

    if %lang%=="en" (
        echo the selected language is English
        set json_lang_file=lang\en.json
    ) else if %lang%=="fr" (
        echo la langue sélectionnée est le français
        set json_lang_file=lang\fr.json
    ) else (
        echo an error occurred
        set json_lang_file=lang\en.json
    )

    set "lang_folder=lang"

    if not exist "%cd%\%lang_folder%" (
        mkdir %lang_folder%
        cd %lang_folder%
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/lang/en.json' -OutFile 'en.json'"
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/lang/fr.json' -OutFile 'fr.json'"
        echo download complete
        cd ../
        echo -----------------------------------------
    )

    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:sourcefiles') do set "lang_sourcefiles=%%~a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:download') do set "lang_download=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:dezipping') do set "lang_dezipping=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:completed') do set "lang_completed=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:error') do set "lang_error=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:model') do set "lang_model=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:choice') do set "lang_choice_m=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:invalid_c') do set "lang_invalid_c=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:model_d') do set "lang_model_d=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:downloading_m') do set "lang_downloading_m=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:download_c') do set "lang_download_c=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:sett_down') do set "lang_sett_down=%%a"
    for /f "tokens=2 delims=:," %%a in ('type "%json_lang_file%" ^| findstr /c:download_sett') do set "lang_download_sett=%%a"

    set lang_sourcefiles=%lang_sourcefiles:"=%
    set lang_download=%lang_download:"=%
    set lang_dezipping=%lang_dezipping:"=%
    set lang_completed=%lang_completed:"=%
    set lang_error=%lang_error:"=%
    set lang_model=%lang_model:"=%
    set lang_choice_m=%lang_choice_m:"=%
    set lang_invalid_c=%lang_invalid_c:"=%
    set lang_model_d=%lang_model_d:"=%
    set lang_downloading_m=%lang_downloading_m:"=%
    set lang_download_c=%lang_download_c:"=%
    set lang_sett_down=%lang_sett_down:"=%
    set lang_download_sett=%lang_download_sett:"=%

    if not exist "main.exe" (
        echo %lang_sourcefiles%
        echo %lang_download%
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/llama-master-3173a62-bin-win-avx2-x64.zip' -OutFile 'llama-master-3173a62-bin-win-avx2-x64.zip'"
        echo %lang_dezipping%
        powershell -command "Expand-Archive llama-master-3173a62-bin-win-avx2-x64.zip ."
        echo %lang_completed%
        echo -----------------------------------------
    )

    echo %lang_model%
    echo 1. ggml-alpaca-7b-q4.bin - alpaca
    echo 2. ggml-vicuna-13b-4bit.bin - vicuna
    set /p choix="%lang_choice_m%"
    if %choix% equ 1 (
        set MODEL=ggml-alpaca-7b-q4.bin
    ) else if %choix% equ 2 (
        set MODEL=ggml-vicuna-13b-4bit.bin
    ) else (
        echo %invalid_c%
        goto start
    )
    echo -----------------------------------------

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
