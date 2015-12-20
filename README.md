# Eager Rendering
Distributed network rendering for Blender 3D.  
The script will automatically prepare tiles for your scene and perform rendering on local and remote machines.

## How it works
Python script for Blender `eager.py` generates tiles for rendering using [render border](http://wiki.blender.org/index.php/User:Fade/Doc:2.6/Manual/3D_interaction/Navigating/Camera_View#Render_Border).  
Once called `eager.sh` is automatically selecting number of non-rendered tiles and perform rendering on machine that's not running render task. When rendering of all the tiles finishes, the final image composes from local and remote tiles.  
See the screencast:

[![asciicast](https://asciinema.org/a/dxohal000hrij9wsxzr5lzwbk.png)](https://asciinema.org/a/dxohal000hrij9wsxzr5lzwbk)

## Setup and run
1. Clone the repo
2. Copy `eager.sh` and `eager.py` files into directory contains your `.blend` file
3. Fill `SSH_HOST` variable with your remote username@host
3. Run:  
`./eager.sh <blend file> [path to blender executable]`

Default blender executable is `blender` (i.e. blender installed on your system via package manager).

I recommend setup key-based ssh authenticatiom without passphrase to remote host (or at least use `ssh-agent` if you want passphrase) to run script smoothly without typing ssh credentials every time.
