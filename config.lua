config = {}
config.scaleform_minimap_main_map = "minimap_main_map"  -- Do not modify
config.scaleform_minimap = "minimap"    -- Do not modify
config.offset = 0.1    -- Small overlap between adjacent tiles to hide seams

-- Removes the blur effect applied on the edges of the minimap
-- See forum post for more details: https://forum.cfx.re/t/extra-map-tiles-v2-add-extra-textured-tiles-on-the-pause-menu-map-and-minimap-new-and-revamped-version/5344181
config.remove_blur = true
config.radar_masks = "radar_masks"


--[[
    Tile configuration table. Each tile is defined by a *unique* numerical key and contains
    the following fields:
    - x_offset: The number of tiles away from the origin point on the X axis
    - y_offset: The number of tiles away from the origin point on the Y axis
    - txd: The texture dictionary name for the tile
    - txn: The texture name for the tile
    - visible (optional): Boolean value indicating whether the tile is visible by default. If omitted, the tile is visible by default.
    
    The mentioned origin point is the top left corner of the pause menu map (aka top left
    corner of minimap_sea_0_0), with everything else being in relation to it.
        - The X axis runs horizontally, with positive values going to the right and negative values
          going to the left of the origin point.
        - The Y axis runs vertically, and is inverted, with positive values going down and negative values going up.

    See forum post for images and more details: https://forum.cfx.re/t/extra-map-tiles-v2-add-extra-textured-tiles-on-the-pause-menu-map-and-minimap-new-and-revamped-version/5344181
    [*] You can safely use the restart command in-game to reload the resource and apply changes to the tiles on the fly.
    There is no need to restart the server or the client for the changes to take effect.
]]
config.tiles = {

    -- 2 example tiles in the south-east of the main map
    [1] = {x_offset = 2, y_offset = 1, txd = "extra_tiles_blue", txn = "tile_1", x_scale = 2.0, y_scale = 2.0},
    [2] = {x_offset = 2, y_offset = 2, txd = "extra_tiles_blue", txn = "tile_2", rotation = 90.0},

    -- 4 example tiles in the north-west of the main map 
    [3] = {x_offset = -1, y_offset = -1, txd = "extra_tiles_green_1", txn = "tile_3", visible = true},
    [4] = {x_offset = 0, y_offset = -1, txd = "extra_tiles_green_1", txn = "tile_4", visible = false},
    [5] = {x_offset = -1, y_offset = 0, txd = "extra_tiles_green_2", txn = "tile_5"},
    [6] = {x_offset = -1, y_offset = 1, txd = "extra_tiles_green_2", txn = "tile_6"},
}
