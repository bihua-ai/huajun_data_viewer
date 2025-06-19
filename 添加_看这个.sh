#!/bin/bash

for dir in */ ; do
    if [ -d "$dir" ]; then
        cp -f "看这个_模板.sh" "$dir"/看这个.sh
        sudo chmod +x "$dir"/看这个.sh
    fi
done
