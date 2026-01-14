
config = {}
config.scaleform_minimap_main_map = "minimap_main_map"  -- Do not modify
config.scaleform_minimap = "minimap"    -- Do not modify
config.offset = 0.1    -- Small overlap between adjacent tiles to hide seams

-- Removes the blur effect applied on the edges of the minimap
-- See forum post for more details: https://forum.cfx.re/t/extra-map-tiles-v2-add-extra-textured-tiles-on-the-pause-menu-map-and-minimap-new-and-revamped-version/5344181
config.remove_blur = false
config.radar_masks = "radar_masks"


--[[
    Tile configuration table. Each tile is defined by a *unique* numerical key and contains
    the following fields:
    - x_offset: The number of tiles away from the origin point on the X axis
    - y_offset: The number of tiles away from the origin point on the Y axis
    - txd: The texture dictionary name for the tile
    - txn: The texture name for the tile
    
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

    --[1] = {x_offset = -1, y_offset = 0, txd = "minimap_sea_0_-1", txn = "minimap_sea_0_-1"},
    --[2] = {x_offset = -1, y_offset = 1, txd = "minimap_sea_1_-1", txn = "minimap_sea_1_-1"},
    [3] = {x_offset = -1, y_offset = 2, txd = "minimap_sea_2_-1", txn = "minimap_sea_2_-1"},
    [4] = {x_offset = 2, y_offset = 2, txd = "cayo_perico", txn = "minimap_sea_4_4"},
    [5] = {x_offset = 1, y_offset = 3, txd = "cayo_perico", txn = "minimap_sea_5_3"},
    [6] = {x_offset = 2, y_offset = 3, txd = "cayo_perico", txn = "minimap_sea_5_4"},
    [7] = {x_offset = 0, y_offset = -1, txd = "roxwood", txn = "minimap_sea_-1_0"},
}
