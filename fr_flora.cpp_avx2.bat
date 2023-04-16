@ECHO OFF
chcp 65001
SET /A THREADS=%NUMBER_OF_PROCESSORS%
title flora.cpp
:start

    if not exist "main.exe" (
        echo les fichiers sources n'existent pas
        echo téléchargement...
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/llama-master-3173a62-bin-win-avx2-x64.zip' -OutFile 'llama-master-3173a62-bin-win-avx2-x64.zip'"
        echo dezipping ...
        powershell -command "Expand-Archive llama-master-3173a62-bin-win-avx2-x64.zip ."
        echo terminé
        echo .
    )

    echo Veuillez choisir un modèle :
    echo 1. ggml-alpaca-7b-q4.bin - alpaca
    echo 2. ggml-vicuna-13b-4bit.bin - vicuna
    set /p choix="Choix : "
    if %choix% equ 1 (
        set MODEL=ggml-alpaca-7b-q4.bin
    ) else if %choix% equ 2 (
        set MODEL=ggml-vicuna-13b-4bit.bin
    ) else (
        echo Choix invalide.
        goto start
    )
    cls

    REM vérifie si le fichier existe déjà
    if not exist %MODEL% (
        REM si le fichier n'existe pas, télécharge-le
	    echo Le modèle n'est pas présent sur votre ordinateur, down
        echo Téléchargement du modèle...
        powershell -Command "Invoke-WebRequest 'http://view.florahub.fr/models/%MODEL%' -OutFile '%MODEL%'"
	echo Téléchargement terminé.
    cls
    )

    REM exécute le programme avec le modèle sélectionné
    main.exe -t %THREADS% --temp 1 -i --interactive-first --color -c 2048 -n -1 --ignore-eos --repeat_penalty 1.2 --instruct -m %MODEL%
    pause
    goto start