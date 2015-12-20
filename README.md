# Eager Rendering
Distributed network rendering for Blender 3D.  
The script will automatically prepare tiles for your scene and perform rendering on local and remote machines.

## How it works
Python script for Blender `eager.py` will generate tiles for rendering using [render border](http://wiki.blender.org/index.php/User:Fade/Doc:2.6/Manual/3D_interaction/Navigating/Camera_View#Render_Border).  
When you run `eager.sh` it will automatically select number of non-rendered tiles and perform rendering on machine that's not running render task. When all the tiles will be rendered, the final image will be composed.  
See the screencast:

## Setup and run
1. Clone the repo
2. Copy `eager.sh` and `eager.py` files into directory contains your `.blend` file
3. Fill `SSH_HOST` variable with your remote username@host
3. Run:  
`./eager.sh <blend file> [path to blender executable]`

Default blender executable is `blender` (i.e. blender installed on your system via package manager).

I recommend setup key-based ssh authenticatiom without passphrase to remote host (or at least use `ssh-agent` if you want passphrase) to run script smoothly without typing ssh credentials every time.
