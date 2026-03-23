-- minimap.ymt constants
local vBitmapTileSizeX = 4500.0
local vBitmapTileSizeY = 4500.0
local vBitmapStartX = -4140.0
local vBitmapStartY = 8400.0

-- global variables
local dummy_blips = {}
scaleform_minimap_main_map_handle = nil

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
function extend_pause_menu_map_bounds()
    -- Clean up existing blips
    for _, blip in ipairs(dummy_blips) do
        RemoveBlip(blip)
    end
    dummy_blips = {}
    
    local keys = get_keys(config.tiles)
    if #keys == 0 then
        return
    end

    -- Use infinity to track absolute min/max
    local global_x_min = math.huge
    local global_x_max = -math.huge
    local global_y_min = math.huge
    local global_y_max = -math.huge
    local found = false

    local scale_factor = 9216 / 1728.0

    for i = 1, #keys do
        local tile_config = config.tiles[keys[i]]
        local alpha = tonumber(tile_config.alpha) or 100

        -- Skip hidden tiles
        if tile_config.visible == false or alpha <= 0 then
            goto continue
        end

        -- Determine origin: top left or center depending on config
        local origin_x = vBitmapStartX + (tile_config.x_offset or 0) * vBitmapTileSizeX
        local origin_y = vBitmapStartY - (tile_config.y_offset or 0) * vBitmapTileSizeY

        -- Override with explicit game coordinates if provided
        if tile_config.x then
            origin_x = tile_config.x
        end
        if tile_config.y then
            origin_y = tile_config.y
        end

        -- Dimensions
        local width = vBitmapTileSizeX * math.abs(tonumber(tile_config.x_scale) or 1.0)
        local height = vBitmapTileSizeY * math.abs(tonumber(tile_config.y_scale) or 1.0)

        -- Unrotated corners in local tile space
        local corners = {}
        if tile_config.centered then
            -- Origin is center
            corners = {
                { x = -width / 2, y = height / 2 }, -- Top left
                { x = width / 2, y = height / 2 },  -- Top right
                { x = -width / 2, y = -height / 2 },    -- Bottom left
                { x = width / 2, y = -height / 2 }  -- Bottom right
            }
        else
            -- Origin is top left
            corners = {
                { x = 0, y = 0 },   -- Top left
                { x = width, y = 0 },   -- Top right
                { x = 0, y = -height },  -- Bottom left
                { x = width, y = -height }  -- Bottom right
            }
        end

        -- Rotate and translate to world space
        local rad = math.rad(-(tile_config.rotation or 0.0))
        local cos_theta = math.cos(rad)
        local sin_theta = math.sin(rad)

        for _, corner in ipairs(corners) do
            -- Apply the rotation matrix
            local rot_x = corner.x * cos_theta - corner.y * sin_theta
            local rot_y = corner.x * sin_theta + corner.y * cos_theta

            -- Translate to game world coordinates
            local world_x = origin_x + rot_x
            local world_y = origin_y + rot_y

            -- Expand the global bounding box
            global_x_min = math.min(global_x_min, world_x)
            global_x_max = math.max(global_x_max, world_x)
            global_y_min = math.min(global_y_min, world_y)
            global_y_max = math.max(global_y_max, world_y)
        end

        found = true
        ::continue::
    end

    if not found then
        return
    end

    -- Bounding box can be defined just by 2 corners
    table.insert(dummy_blips, create_dummy_blip(global_x_min, global_y_min))
    table.insert(dummy_blips, create_dummy_blip(global_x_max, global_y_max))
end


Citizen.CreateThread(function()
    -- Set up fields for each tile in the configuration
    for tile_name, tile_config in pairs(config.tiles) do
        config.tiles[tile_name].x_offset = 1.0 * (tile_config.x_offset or 0)
        config.tiles[tile_name].y_offset = 1.0 * (tile_config.y_offset or 0)
        config.tiles[tile_name].x_scale = 1.0 * (tile_config.x_scale or 1.0)
        config.tiles[tile_name].y_scale = 1.0 * (tile_config.y_scale or 1.0)
        config.tiles[tile_name].alpha = math.floor(tonumber(tile_config.alpha) or 100)
        config.tiles[tile_name].rotation = tile_config.rotation or 0.0
        config.tiles[tile_name].centered = tile_config.centered or false
        config.tiles[tile_name].visible = tile_config.visible and config.tiles[tile_name].alpha > 0
    end


    -- Load texture dictionaries and main map scaleform
    local loaded_texture_dictionaries = load_texture_dictionaries(config.tiles)
    scaleform_minimap_main_map_handle = load_scaleform(config.scaleform_minimap_main_map)

    -- Clean any leftover textures in the main map scaleform
    BeginScaleformMovieMethod(scaleform_minimap_main_map_handle, "CLEAR_TEXTURES")
    EndScaleformMovieMethod()

    -- Set up general scaleform parameters
    -- DO NOT MODIFY
    local scaleform_x_origin = 864.0
    local scaleform_y_origin = 1440.0
    local scaleform_mc_width = 1728.0
    local scaleform_mc_height = 2880.0

    local world_width = 9216
    local world_height = 15360.002
    

    local scale_factor = world_width / scaleform_mc_width

    local x_offset = 360 / scale_factor
    local y_offset = 600 / scale_factor

    scaleform_x_origin_game = scaleform_x_origin
    scaleform_y_origin_game = scaleform_y_origin

    scaleform_x_origin = scaleform_x_origin + x_offset
    scaleform_y_origin = scaleform_y_origin + y_offset
    tile_size = vBitmapTileSizeX / scale_factor

    scaleform_x_origin = scaleform_x_origin - tile_size
    scaleform_y_origin = scaleform_y_origin - 2 * tile_size
    -- END DO NOT MODIFY

    -- Draw the extra tiles
    for _, tile_name in ipairs(get_keys(config.tiles)) do
        local tile_config = config.tiles[tile_name]
        
        if tile_config then

            -- Compute position based on offsets
            local scaleform_x = scaleform_x_origin + (tile_config.x_offset or 0) * tile_size
            local scaleform_y = scaleform_y_origin + (tile_config.y_offset or 0) * tile_size

            -- Convert tile XY from game units to scaleform units if in XY mode
            if tile_config.x then
                scaleform_x = scaleform_x_origin_game + tile_config.x / scale_factor
            end

            if tile_config.y then
                scaleform_y = scaleform_y_origin_game - tile_config.y / scale_factor
            end

            -- Apply small offset to overlap tiles and prevent gaps
            if tile_config.x_offset then
                scaleform_x = scaleform_x - (config.offset * tile_config.x_offset)
            end
            
            if tile_config.y_offset then
                scaleform_y = scaleform_y - (config.offset * (tile_config.y_offset or 0))
            end

            -- Calculate the final width and height of the tile on the scaleform, using the scale factors
            local scaleform_width = tile_size * (math.abs(tile_config.x_scale) or 1.0)
            local scaleform_height = tile_size * (math.abs(tile_config.y_scale) or 1.0)
            local draw_alpha = tile_config.visible == false and 0 or (tile_config.alpha or 100)

            local tile = {
                name = tostring(tile_name),
                txd = tile_config.txd,
                txn = tile_config.txn,
                x = scaleform_x,
                y = scaleform_y,
                width = scaleform_width,
                height = scaleform_height,
                centered = tile_config.centered or false,
                alpha = draw_alpha,
                rotation = 1.0 * (tile_config.rotation or 0.0),
            }

            draw_tile(scaleform_minimap_main_map_handle, tile)
        end
    end

    -- Reset the scaleform handle (now pointing to minimap_main_map.gfx) to nil
    -- scaleform_handle = SetScaleformMovieAsNoLongerNeeded(scaleform_handle)
    -- scaleform_handle = nil

    -- Wait for the minimap to render before doing anything else
    while not IsMinimapRendering() do
        Citizen.Wait(0)
    end

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
