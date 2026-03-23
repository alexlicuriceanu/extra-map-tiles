-- export function: shows the specified tiles on the pause menu map.
-- @param tile_names A table containing the names of the tiles to show.
function export_show_tiles(tile_names)
    if tile_names == nil then
        return
    end

    for _, tile_name in ipairs(tile_names) do
        local tile = {
            name = tostring(tile_name),
            alpha = 100,
        }

        set_tile_alpha(scaleform_minimap_main_map_handle, tile)
        config.tiles[tile_name].visible = true
    end

    refresh_minimap()
    extend_pause_menu_map_bounds()
end

-- export function: hides the specified tiles on the pause menu map.
-- @param tile_names A table containing the names of the tiles to hide.
function export_hide_tiles(tile_names)
    if tile_names == nil then
        return
    end

    for _, tile_name in ipairs(tile_names) do
        local tile = {
            name = tostring(tile_name),
            alpha = 0
        }

        set_tile_alpha(scaleform_minimap_main_map_handle, tile)
        config.tiles[tile_name].visible = false
    end

    refresh_minimap()
    extend_pause_menu_map_bounds()
end

-- export function: checks if a specific tile is visible on the pause menu map.
-- @param tile_name The name of the tile to check.
-- @return is_visible True if the tile is visible, false otherwise.
function export_is_tile_visible(tile_name)
    local tile_config = config.tiles[tile_name]
    if not tile_config then
        return false
    end

    local alpha = tonumber(tile_config.alpha)
    return alpha > 0 or (tile_config.visible == true)
end

-- export function: refreshes the minimap to apply changes.
function export_refresh_minimap()
    refresh_minimap()
end

-- export function: gets the names of all configured tiles.
-- @return A table containing the names of all configured tiles.
function export_get_tile_names()
    return get_keys(config.tiles)
end

-- export function: sets the rotation of a specific tile on the pause menu map.
-- @param tile_name The name of the tile to rotate.
-- @param rotation The rotation in degrees (0-360) to set for the tile.
function export_set_tile_rotation(tile_name, rotation)
    if tile_name == nil or rotation == nil then
        return
    end

    local tile = {
        name = tostring(tile_name),
        rotation = tonumber(rotation or 0.0)
    }

    set_tile_rotation(scaleform_minimap_main_map_handle, tile)
    config.tiles[tile_name].rotation = tonumber(rotation or 0.0)
end

-- export function: sets the alpha (opacity) of a specific tile on the pause menu map.
-- @param tile_name The name of the tile to set the alpha for.
-- @param alpha The alpha value (0-100) to set for the tile.
function export_set_tile_alpha(tile_name, alpha)
    if tile_name == nil or alpha == nil then
        return
    end

    _alpha = math.floor(tonumber(alpha) or 100)
    _alpha = math.max(0, math.min(100, _alpha))

    local tile = {
        name = tostring(tile_name),
        alpha = _alpha
    }

    set_tile_alpha(scaleform_minimap_main_map_handle, tile)
    config.tiles[tile_name].alpha = _alpha
end

-- export function: sets the scale of a specific tile on the pause menu map.
-- @param tile_name The name of the tile to set the scale for.
-- @param x_scale The horizontal scale factor (1.0 = original size) to set for the tile.
-- @param y_scale The vertical scale factor (1.0 = original size) to set for the tile.
function export_set_tile_scale(tile_name, x_scale, y_scale)
    if tile_name == nil or x_scale == nil or y_scale == nil then
        return
    end

    local tile = {
        name = tostring(tile_name),
        width = tonumber(x_scale) * tile_size,
        height = tonumber(y_scale) * tile_size
    }

    set_tile_scale(scaleform_minimap_main_map_handle, tile)
    config.tiles[tile_name].x_scale = tonumber(x_scale)
    config.tiles[tile_name].y_scale = tonumber(y_scale)
end

-- export function: gets the rotation of a specific tile from the configuration.
-- @param tile_name The name of the tile to get the rotation for.
-- @return The rotation of the tile in degrees (0-360), or nil if the tile does not exist.
function export_get_tile_rotation(tile_name)
    local tile_config = config.tiles[tile_name]
    if not tile_config then
        return nil
    end

    return tonumber(tile_config.rotation) or 0.0
end

-- export function: gets the alpha (opacity) of a specific tile from the configuration.
-- @param tile_name The name of the tile to get the alpha for.
-- @return The alpha value of the tile (0-100), or nil if the tile does not exist.
function export_get_tile_alpha(tile_name)
    local tile_config = config.tiles[tile_name]
    if not tile_config then
        return nil
    end

    return tonumber(tile_config.alpha) or 100
end

-- export function: gets the scale of a specific tile from the configuration.
-- @param tile_name The name of the tile to get the scale for.
-- @return x_scale The horizontal scale factor of the tile, or nil if the tile does not exist.
-- @return y_scale The vertical scale factor of the tile, or nil if the tile does not exist.
function export_get_tile_scale(tile_name)
    local tile_config = config.tiles[tile_name]
    if not tile_config then
        return nil, nil
    end

    return tonumber(tile_config.x_scale) or 1.0, tonumber(tile_config.y_scale) or 1.0
end

exports("show_tiles", export_show_tiles)
exports("hide_tiles", export_hide_tiles)
exports("is_tile_visible", export_is_tile_visible)
exports("refresh_minimap", export_refresh_minimap)
exports("get_tile_names", export_get_tile_names)
exports("set_tile_rotation", export_set_tile_rotation)
exports("set_tile_alpha", export_set_tile_alpha)
exports("set_tile_scale", export_set_tile_scale)
exports("get_tile_rotation", export_get_tile_rotation)
exports("get_tile_alpha", export_get_tile_alpha)
exports("get_tile_scale", export_get_tile_scale)