#!/bin/bash

# Configurable variables
SSH_HOSTS=(username@hostname username@another-hostname username@third-example-hostname)
CHUNK_SIZE=8

## You don't have to edit anything below this line

FILE=$1
LOCAL_BLENDER=${2:-blender}

tiles=($(seq 0 63))
declare -A MACHINES=( [local]=true )
for i in "${SSH_HOSTS[@]}"; do
    MACHINES[$i]=true
done

# Check requirements
if [[ ! -e /usr/bin/sshfs || ! -e /usr/bin/convert ]]; then
    echo "$(tput setaf 1)This script requires sshfs and ImageMagick$(tput sgr0)"
    exit 1;
fi

# Prepare machines
rm -rf rendering rendering_local
mkdir rendering_local
for host in "${!MACHINES[@]}"; do
    if [ $host = "local" ]; then
        continue
    fi
    echo "$(tput setaf 2)$host: create rendering dir$(tput sgr0)"
    ssh -qt $host "mkdir -p ~/rendering"
    echo "$(tput setaf 2)$host: mount sshfs$(tput sgr0)"
    mkdir -p rendering_$host
    sshfs -o uid=$(id -u $USER) $host:rendering rendering_$host
    echo "$(tput setaf 2)$host: copy necessary files$(tput sgr0)"
    cp eager.py $FILE rendering_$host/
done

while [ -n "$tiles" ]; do

    for host in "${!MACHINES[@]}"; do
        if [ "${MACHINES[$host]}" = true ]; then
            range=(${tiles[@]:0:$CHUNK_SIZE})

            first=${range[0]}
            last=${range[-1]}
            last=$((last+1))
            echo "$(tput setaf 4)$host: run blender with tiles range $first-$last $(tput sgr0)"
            if [ "$host" = "local" ]; then
                OUTPUT_DIR=$(realpath rendering_local) TILES_RANGE=$first:$last $LOCAL_BLENDER -b $FILE -E CYCLES -F PNG -t 0 -P eager.py 2>&1 > /dev/null &
            else
                ssh -qt -t $host "TILES_RANGE=$first:$last blender -b rendering/$FILE -E CYCLES -F PNG -t 0 -P rendering/eager.py" 2>&1 > /dev/null &
            fi
            MACHINES[$host]=$!

            tiles=(${tiles[@]:$CHUNK_SIZE})
        else
            if [ ! -e /proc/${MACHINES[$host]} ]; then
                echo "$(tput setaf 3)$host: finished chunk$(tput sgr0)"
                MACHINES[$host]=true
            fi
        fi
    done
    sleep 0.1
done

wait

echo "$(tput setaf 2)Rendering finished. Get tiles from remote$(tput sgr0)"
for host in "${!MACHINES[@]}"; do
    if [ $host = "local" ]; then
        continue
    fi
    mv rendering_$host/rendered_tile_tmp_* rendering_local/
    fusermount -u rendering_$host
    rm -r rendering_$host
done

echo "$(tput setaf 2)Composing image$(tput sgr0)"
cd rendering_local
convert rendered_tile_tmp_* -flatten ../$(basename "$FILE" .blend)_rendered_final.png
rm rendered_tile_tmp_*
cd ..

if [ -e /usr/bin/feh ]; then
    feh $(basename "$FILE" .blend)_rendered_final.png &
fi
