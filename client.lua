-- minimap.ymt constants
local vBitmapTileSizeX = 4500.0
local vBitmapTileSizeY = 4500.0
local vBitmapStartX = -4140.0
local vBitmapStartY = 8400.0

-- global variables
local dummy_blips = {}
local scaleform_minimap_main_map_handle = nil

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

Citizen.CreateThread(function()
    -- Set up alphas
    for _, tile_name in ipairs(get_keys(config.tiles)) do
        local tile_config = config.tiles[tile_name]
        
        -- Only calculate alpha based on 'visible' if the user didn't explicitly set an alpha
        if tile_config.alpha == nil then
            if tile_config.visible == nil then
                tile_config.alpha = 100
            else 
                if tile_config.visible then
                    tile_config.alpha = 100
                else
                    tile_config.alpha = 0
                end
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

    -- START DO NOT MODIFY
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
    tile_size = vBitmapTileSizeX / scale_factor

    x_origin = x_origin - tile_size
    y_origin = y_origin - 2 * tile_size
    -- END DO NOT MODIFY

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

            local x_scale = tile_size
            local y_scale = tile_size

            if tile_config.x_scale then
                x_scale = tile_size * math.abs(tile_config.x_scale)
            end

            if tile_config.y_scale then
                y_scale = tile_size * math.abs(tile_config.y_scale)
            end

            local tile = {
                name = tostring(tile_name),
                txd = tile_config.txd,
                txn = tile_config.txn,
                x = x,
                y = y,
                width = x_scale or tile_size,
                height = y_scale or tile_size,
                centered = tile_config.centered or false,
                alpha = tile_config.alpha or 100,
                rotation = tile_config.rotation or 0.0,
            }

            local rotation = tile_config.rotation or 0.0
            draw_tile(scaleform_minimap_main_map_handle, tile)
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


    test_tile = {
        name = "2",
        width = tile_size * 1.5,
        height = tile_size * 2.5,
        alpha = 30,
        rotation = 45.0,
    }
    set_tile_scale(scaleform_minimap_main_map_handle, test_tile)
    set_tile_rotation(scaleform_minimap_main_map_handle, test_tile)
    set_tile_alpha(scaleform_minimap_main_map_handle, test_tile)

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
