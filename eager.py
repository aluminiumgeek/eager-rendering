import os
import bpy

x_tiles = 8
y_tiles = 8

total = x_tiles * y_tiles
tiles = []
count = 0
for j in range(x_tiles):
    for i in range(y_tiles):
        tiles.append((count, i, j))
        count += 1

hostname = os.uname()[1]
directory = os.getenv('OUTPUT_DIR', os.path.dirname(os.path.realpath(__file__)))
tiles_range = os.getenv('TILES_RANGE', '0:{}'.format(total)).split(':')
tile_from, tile_to = tuple(map(int, tiles_range))

bpy.context.scene.render.use_border = True

for i, current_x, current_y in tiles[tile_from:tile_to]:
    print("{}: rendering {}/{}".format(hostname, i + 1, total))

    min_x = current_x / x_tiles
    max_x = (current_x + 1) / x_tiles
    min_y = 1 - (current_y + 1) / y_tiles
    max_y = 1 - current_y / y_tiles

    # info = ("min_x: {}, max_x: {}\n"
    #        "min_y: {}, max_y: {}")
    # print(info.format(min_x, max_x, min_y, max_y))

    bpy.context.scene.render.border_min_x = min_x
    bpy.context.scene.render.border_max_x = max_x
    bpy.context.scene.render.border_min_y = min_y
    bpy.context.scene.render.border_max_y = max_y

    bpy.ops.render.render()
    bpy.data.images["Render Result"].save_render('{}/rendered_tile_tmp_{}.png'.format(directory, i + 1))
