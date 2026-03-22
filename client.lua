-- minimap.ymt constants
local vBitmapTileSizeX = 4500.0
local vBitmapTileSizeY = 4500.0
local vBitmapStartX = -4140.0
local vBitmapStartY = 8400.0

-- global variables
local dummy_blips = {}
local scaleform_minimap_main_map_handle = nil

-- get the keys of a table.
-- @param t The table to get the keys from.
-- @return keys A sorted table containing the keys of the input table.
local function get_keys(t)
  local keys = {}

  for key, _ in pairs(t) do
    table.insert(keys, key)
  end

  table.sort(keys)
  return keys
end


-- loads the texture dictionaries specified in the configuration file.
-- @param texture_dictionaries Table containing the tiles configuration.
-- @return loaded_texture_dictionaries A table containing the names loaded texture dictionaries.
local function load_texture_dictionaries(texture_dictionaries)
    local loaded_texture_dictionaries = {}

    print("Requesting texture dictionaries")

    for _, tile in pairs(texture_dictionaries) do
        if tile.txd then
            RequestStreamedTextureDict(tile.txd)
            while not HasStreamedTextureDictLoaded(tile.txd) do
                Citizen.Wait(0)
            end

            table.insert(loaded_texture_dictionaries, tile.txd)
        end
    end

    print("Texture dictionaries loaded successfully")
    return loaded_texture_dictionaries
end


-- requests and loads a scaleform file.
-- @param scaleform_name The name of the scaleform file to load.
-- @return scaleform_handle The handle of the loaded scaleform.
local function load_scaleform(scaleform_name)
    print("Requesting " .. scaleform_name .. " scaleform")

    local scaleform_handle = RequestScaleformMovie(scaleform_name)
    while not HasScaleformMovieLoaded(scaleform_handle) do
        Citizen.Wait(0)
    end

    print("Scaleform " .. scaleform_name .. " loaded successfully")
    return scaleform_handle
end

-- refreshes the minimap by loading the minimap.gfx scaleform.
local function refresh_minimap()
    -- Load the minimap.gfx scaleform to fix minimap rendering on first load
    scaleform_minimap_handle = load_scaleform(config.scaleform_minimap)
    SetBigmapActive(true, false)
    Citizen.Wait(0)
    SetBigmapActive(false, false)

    -- Reset the scaleform handle (now pointing to minimap.gfx) to nil
    scaleform_minimap_handle = SetScaleformMovieAsNoLongerNeeded(scaleform_minimap_handle)
    scaleform_minimap_handle = nil
end


-- create an invisible blip at the specified coordinates.
-- @param x The x coordinate of the blip.
-- @param y The y coordinate of the blip.
-- @return The handle of the created blip.
local function create_dummy_blip(x, y)
    local dummy_blip = AddBlipForCoord(x, y, 1.0)
    SetBlipDisplay(dummy_blip, 4)
    SetBlipAlpha(dummy_blip, 0)

    return dummy_blip
end


-- "hack" the pause menu map bounds by creating dummy blips
-- at the corners of the furthest tiles.
local function extend_pause_menu_map_bounds()
    for _, blip in ipairs(dummy_blips) do
        RemoveBlip(blip)
    end
    dummy_blips = {}
    
    local keys = get_keys(config.tiles)
    if #keys == 0 then
        return
    end

    local x_min_offset = 1e5
    local x_max_offset = -1e5
    local y_min_offset = 1e5
    local y_max_offset = -1e5
    local found = false

    for i = 1, #keys do
        local tile = config.tiles[keys[i]]
        local alpha = tonumber(tile.alpha)

        if alpha <= 0 then
            goto continue
        end

        if tile.x_offset then
            x_min_offset = math.min(x_min_offset, tile.x_offset)
            x_max_offset = math.max(x_max_offset, tile.x_offset)
        end

        if tile.y_offset then
            y_min_offset = math.min(y_min_offset, tile.y_offset)
            y_max_offset = math.max(y_max_offset, tile.y_offset)
        end

        found = true
        ::continue::
    end

    if not found then
        return
    end

    local x_min = vBitmapStartX + x_min_offset * vBitmapTileSizeX
    local x_max = vBitmapStartX + x_max_offset * vBitmapTileSizeX + vBitmapTileSizeX
    local y_min = vBitmapStartY - y_min_offset * vBitmapTileSizeY
    local y_max = vBitmapStartY - y_max_offset * vBitmapTileSizeY - vBitmapTileSizeY

    table.insert(dummy_blips, create_dummy_blip(x_min, y_min))
    table.insert(dummy_blips, create_dummy_blip(x_max, y_max))
end



-- creates a tile based on the provided configuration.
-- @param scaleform_handle The handle of the scaleform to draw the tile on.
-- @param tile The configuration table for the tile.
local function draw_tile(scaleform_handle, tile)
    BeginScaleformMovieMethod(scaleform_handle, "DRAW_TEXTURE")
    PushScaleformMovieFunctionParameterString(tile.name) 
    PushScaleformMovieFunctionParameterString(tile.txd) 
    PushScaleformMovieFunctionParameterString(tile.txn)
    PushScaleformMovieFunctionParameterFloat(tile.x)
    PushScaleformMovieFunctionParameterFloat(tile.y)
    PushScaleformMovieFunctionParameterInt(tile.x_scale)
    PushScaleformMovieFunctionParameterInt(tile.y_scale)
    PushScaleformMovieFunctionParameterFloat(tile.width)
    PushScaleformMovieFunctionParameterFloat(tile.height)
    PushScaleformMovieFunctionParameterBool(tile.centered or false) -- The new boolean!
    EndScaleformMovieMethod()
end


-- sets the alpha value of a tile.
-- @param scaleform_handle The handle of the scaleform to set the tile alpha on.
-- @param tile The configuration table for the tile.
-- @param alpha The alpha value to set for the tile (0-100).
local function set_tile_alpha(scaleform_handle, tile, alpha)
    BeginScaleformMovieMethod(scaleform_handle, "SET_TILE_ALPHA")
    PushScaleformMovieFunctionParameterString(tile.name) 
    PushScaleformMovieFunctionParameterInt(math.floor(alpha))
    EndScaleformMovieMethod()
end

-- sets the rotation of a tile.
-- @param scaleform_handle The handle of the scaleform.
-- @param tile_name The name (id) of the tile.
-- @param rotation The rotation in degrees (0-360).
local function set_tile_rotation(scaleform_handle, tile_name, rotation)
    BeginScaleformMovieMethod(scaleform_handle, "SET_TILE_ROTATION")
    PushScaleformMovieFunctionParameterString(tostring(tile_name)) 
    PushScaleformMovieFunctionParameterFloat(tonumber(rotation) or 0.0)
    EndScaleformMovieMethod()
end


-- export function: shows the specified tiles on the pause menu map.
-- @param tile_names A table containing the names of the tiles to show.
local function export_show_tiles(tile_names)
    if tile_names == nil then
        return
    end

    for _, tile_name in ipairs(tile_names) do
        local tile = {
            name = tostring(tile_name),
        }

        set_tile_alpha(scaleform_minimap_main_map_handle, tile, 100)
        config.tiles[tile_name].alpha = 100
    end

    refresh_minimap()
    extend_pause_menu_map_bounds()
end


-- export function: hides the specified tiles on the pause menu map.
-- @param tile_names A table containing the names of the tiles to hide.
local function export_hide_tiles(tile_names)
    if tile_names == nil then
        return
    end

    for _, tile_name in ipairs(tile_names) do
        local tile = {
            name = tostring(tile_name),
        }

        set_tile_alpha(scaleform_minimap_main_map_handle, tile, 0)
        config.tiles[tile_name].alpha = 0
    end

    refresh_minimap()
    extend_pause_menu_map_bounds()
end


-- export function: checks if a specific tile is visible on the pause menu map.
-- @param tile_name The name of the tile to check.
-- @return is_visible True if the tile is visible, false otherwise.
local function export_is_tile_visible(tile_name)
    local tile_config = config.tiles[tile_name]
    if not tile_config then
        return false
    end

    local alpha = tonumber(tile_config.alpha)
    return alpha > 0
end


-- export function: refreshes the minimap to apply changes.
local function export_refresh_minimap()
    refresh_minimap()
end


exports("show_tiles", export_show_tiles)
exports("hide_tiles", export_hide_tiles)
exports("is_tile_visible", export_is_tile_visible)
exports("refresh_minimap", export_refresh_minimap)


Citizen.CreateThread(function()
    -- Set up alphas
    for _, tile_name in ipairs(get_keys(config.tiles)) do
        if config.tiles[tile_name].visible == nil then
            config.tiles[tile_name].alpha = 100
        else 
            if config.tiles[tile_name].visible then
                config.tiles[tile_name].alpha = 100
            else
                config.tiles[tile_name].alpha = 0
            end
        end
    end

    -- Load texture dictionaries and main map scaleform
    local loaded_texture_dictionaries = load_texture_dictionaries(config.tiles)
    scaleform_minimap_main_map_handle = load_scaleform(config.scaleform_minimap_main_map)

    -- Clean any leftover textures in the main map scaleform
    BeginScaleformMovieMethod(scaleform_minimap_main_map_handle, "CLEAR_TEXTURES")
    EndScaleformMovieMethod()

    -- Set up general scaleform parameters
    local x_scale = 100
    local y_scale = 100
    local x_origin = 864.0
    local y_origin = 1440.0

    local world_width = 9216
    local world_height = 15360.002
    local scaleform_mc_width = 1728.0
    local scaleform_mc_height = 2880.0

    local scale_factor = world_width / scaleform_mc_width

    local x_offset = 360 / scale_factor
    local y_offset = 600 / scale_factor

    x_origin_game = x_origin
    y_origin_game = y_origin

    x_origin = x_origin + x_offset
    y_origin = y_origin + y_offset
    local tile_size = vBitmapTileSizeX / scale_factor

    x_origin = x_origin - tile_size
    y_origin = y_origin - 2 * tile_size

    -- Draw the extra tiles
    for _, tile_name in ipairs(get_keys(config.tiles)) do
        local tile_config = config.tiles[tile_name]
        
        if tile_config then
            local x = x_origin + (tile_config.x_offset or 0) * tile_size
            local y = y_origin + (tile_config.y_offset or 0) * tile_size

            print(x_origin, y_origin)
            if tile_config.x then
                x = x_origin_game + tile_config.x / scale_factor
            end

            if tile_config.y then
                y = y_origin_game - tile_config.y / scale_factor
            end

            if tile_config.x_offset then
                if tile_config.x_offset > 0 then
                    x = x - (config.offset * (tile_config.x_offset or 0))
                elseif tile_config.x_offset < 0 then
                    --x = x - (2 * config.offset * (tile_config.x_offset or 0))
                    x = x - (config.offset * (tile_config.x_offset or 0))
                end
            end

            if tile_config.y_offset then
                if tile_config.y_offset > 0 then
                    y = y - (config.offset * (tile_config.y_offset or 0))
                elseif tile_config.y_offset < 0 then
                    y = y - (config.offset * (tile_config.y_offset or 0))
                end
            end

            local _width = nil
            local _height = nil

            if tile_config.x_scale then
                _width = tile_size * tile_config.x_scale
            end

            if tile_config.y_scale then
                _height = tile_size * tile_config.y_scale
            end

            local tile = {
                name = tostring(tile_name),
                txd = tile_config.txd,
                txn = tile_config.txn,
                x = x,
                y = y,
                x_scale = x_scale,
                y_scale = y_scale,
                width = _width or tile_size,
                height = _height or tile_size,
                centered = tile_config.centered or false -- Read from your config
            }

            local rotation = tile_config.rotation or 0.0
            draw_tile(scaleform_minimap_main_map_handle, tile)
            set_tile_alpha(scaleform_minimap_main_map_handle, tile, tile_config.alpha)
            set_tile_rotation(scaleform_minimap_main_map_handle, tile_name, rotation)
        end
    end

    -- Reset the scaleform handle (now pointing to minimap_main_map.gfx) to nil
    -- scaleform_handle = SetScaleformMovieAsNoLongerNeeded(scaleform_handle)
    -- scaleform_handle = nil

    -- Fix minimap rendering on first load
    refresh_minimap()

    -- Clean up loaded texture dictionaries
    for _, texture_dict in ipairs(loaded_texture_dictionaries) do
        if HasStreamedTextureDictLoaded(texture_dict) then
            SetStreamedTextureDictAsNoLongerNeeded(texture_dict)
        end
    end

    -- Extend the pause menu map bounds by creating dummy blips
    extend_pause_menu_map_bounds()

    if config.remove_blur then
        RequestStreamedTextureDict(config.radar_masks)
        while not HasStreamedTextureDictLoaded(config.radar_masks) do
            Citizen.Wait(0)
        end

        AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "radar_masks", "radarmasksm")
        AddReplaceTexture("platform:/textures/graphics", "radarmasklg", "radar_masks", "radarmasklg")

        Citizen.Wait(500)

        SetBigmapActive(true, false)
        Citizen.Wait(0)
        SetBigmapActive(false, false)

        DisplayRadar(true)

        if HasStreamedTextureDictLoaded(config.radar_masks) then
            SetStreamedTextureDictAsNoLongerNeeded(config.radar_masks)
        end
    end
end)
