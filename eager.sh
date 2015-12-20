#!/bin/bash

# Configurable variables
SSH_HOST=user@hostname
CHUNK_SIZE=8
CHUNK_SIZE_REMOTE=16

## You don't have to edit anything below this line

FILE=$1
LOCAL_BLENDER=${2:-blender}

tiles=($(seq 0 63))
local_pid=true
remote_pid=true

# Check requirements
if [[ ! -e /usr/bin/sshfs || ! -e /usr/bin/convert ]] ; then
    echo "$(tput setaf 1)This script requires sshfs and ImageMagick$(tput sgr0)"
    exit 1;
fi

rm -rf rendering rendering_local
mkdir rendering rendering_local
echo "$(tput setaf 2)Create rendering dir on remote$(tput sgr0)"
ssh -qt $SSH_HOST "mkdir -p ~/rendering"
echo "$(tput setaf 2)Mount sshfs$(tput sgr0)"
sshfs -o uid=$(id -u $USER) $SSH_HOST:rendering rendering
echo "$(tput setaf 2)Copy necessary files$(tput sgr0)"
cp eager.py $FILE rendering/

while [ -n "$tiles" ]; do
    if [ "$local_pid" = true ] ; then
        range=(${tiles[@]:0:$CHUNK_SIZE})

        first=${range[0]}
        last=${range[-1]}
        last=$((last+1))
        echo "$(tput setaf 3)Run blender on local. Tiles range $first-$last $(tput sgr0)"
        OUTPUT_DIR=$(realpath rendering_local) TILES_RANGE=$first:$last $LOCAL_BLENDER -b $FILE -E CYCLES -F PNG -t 0 -P eager.py 2>&1 > /dev/null &
        local_pid=$!

        tiles=(${tiles[@]:$CHUNK_SIZE})
    fi

    if [ "$remote_pid" = true ] ; then
        range=(${tiles[@]:0:$CHUNK_SIZE_REMOTE})

        first=${range[0]}
        last=${range[-1]}
        last=$((last+1))
        echo "$(tput setaf 4)Run blender on remote. Tiles range $first-$last$(tput sgr0)"
        ssh -qt -t $SSH_HOST "TILES_RANGE=$first:$last blender -b rendering/$FILE -E CYCLES -F PNG -t 0 -P rendering/eager.py" 2>&1 > /dev/null &
        remote_pid=$!

        tiles=(${tiles[@]:$CHUNK_SIZE_REMOTE})
    fi

    if [ ! -e /proc/$local_pid ] ; then
        echo "$(tput setaf 3)Local blender finished chunk$(tput sgr0)"
        local_pid=true
    fi

    if [ ! -e /proc/$remote_pid ] ; then
        echo "$(tput setaf 4)Remote blender finished chunk$(tput sgr0)"
        remote_pid=true
    fi
    
    sleep 0.1
done

wait

echo "$(tput setaf 2)Rendering finished. Get tiles from remote$(tput sgr0)"
mv rendering/rendered_tile_tmp_* rendering_local/
echo "$(tput setaf 2)Composing image$(tput sgr0)"
cd rendering_local
convert rendered_tile_tmp_* -flatten ../$(basename "$FILE" .blend)_rendered_final.png
rm rendered_tile_tmp_*
cd ..

fusermount -u rendering

if [ -e /usr/bin/feh ] ; then
  feh $(basename "$FILE" .blend)_rendered_final.png &
fi
