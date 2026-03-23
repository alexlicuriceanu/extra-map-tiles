-- get the keys of a table.
-- @param t The table to get the keys from.
-- @return keys A sorted table containing the keys of the input table.
function get_keys(t)
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
function load_texture_dictionaries(texture_dictionaries)
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
function load_scaleform(scaleform_name)
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