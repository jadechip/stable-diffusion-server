#!/bin/bash

cd /sd

if [[ -z $WEBUI_ARGS ]]; then
    launch_message="entrypoint.sh: Launching server..."
else
    launch_message="entrypoint.sh: Launching server with arguments ${WEBUI_ARGS}"
fi

if [[ -z $WEBUI_RELAUNCH || $WEBUI_RELAUNCH == "true" ]]; then
    n=0
    while true; do

        echo $launch_message
        if (( $n > 0 )); then
            echo "Relaunch count: ${n}"
        fi
        conda run -n "ldm" python -u server.py $WEBUI_ARGS
        echo "entrypoint.sh: Process is ending. Relaunching in 0.5s..."
        ((n++))
        sleep 0.5
    done
else
    echo $launch_message
    conda run -n "ldm" python -u server.py $WEBUI_ARGS
fi
