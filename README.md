# Eager Rendering
Distributed network rendering for Blender 3D.  
The script will automatically prepare tiles for your scene and perform rendering on local and remote machines.

## How it works
`eager.py` is used by Blender built-in Python interpreter internally. This script generates tiles for rendering using [render border](http://wiki.blender.org/index.php/User:Fade/Doc:2.6/Manual/3D_interaction/Navigating/Camera_View#Render_Border).  
The `eager.sh` script does its best to distribute non-rendered tiles across local and remote machines for rendering. Once all the tiles are ready, the final image composes from local and remote tiles.  
See the screencast:

[![asciicast](https://asciinema.org/a/dxohal000hrij9wsxzr5lzwbk.png)](https://asciinema.org/a/dxohal000hrij9wsxzr5lzwbk)

## Setup and run
1. Install requirements:  
`sudo aptitude install sshfs imagemagick feh`
2. Clone the repo
3. Copy `eager.sh` and `eager.py` files into directory contains your `.blend` file
4. Fill `SSH_HOST` variable in `eager.sh` with your remote username@host. Be sure remote host has blender installed.
5. Run:  
`./eager.sh <blend file> [path to blender executable]`

Default blender executable is `blender` (i.e. blender installed on your system via package manager).

I suggest you setup key-based ssh authentication without passphrase (or at least use `ssh-agent`) to run script smoothly without typing ssh credentials every time.
