-- creates a tile based on the provided configuration.
-- @param scaleform_handle The handle of the scaleform to draw the tile on.
-- @param tile The configuration table for the tile.
function draw_tile(scaleform_handle, tile)
    BeginScaleformMovieMethod(scaleform_handle, "DRAW_TEXTURE")
    PushScaleformMovieFunctionParameterString(tile.name) 
    PushScaleformMovieFunctionParameterString(tile.txd) 
    PushScaleformMovieFunctionParameterString(tile.txn)
    PushScaleformMovieFunctionParameterFloat(tile.x)
    PushScaleformMovieFunctionParameterFloat(tile.y)
    PushScaleformMovieFunctionParameterFloat(tile.width)
    PushScaleformMovieFunctionParameterFloat(tile.height)
    PushScaleformMovieFunctionParameterBool(tile.centered or false)
    PushScaleformMovieFunctionParameterInt(math.floor(tile.alpha or 100))
    PushScaleformMovieFunctionParameterFloat(tonumber(tile.rotation) or 0.0)
    EndScaleformMovieMethod()
end

-- sets the alpha value of a tile.
-- @param scaleform_handle The handle of the scaleform to set the tile alpha on.
-- @param tile The configuration table for the tile.
-- @param alpha The alpha value to set for the tile (0-100).
function set_tile_alpha(scaleform_handle, tile)
    BeginScaleformMovieMethod(scaleform_handle, "SET_TILE_ALPHA")
    PushScaleformMovieFunctionParameterString(tostring(tile.name)) 
    PushScaleformMovieFunctionParameterInt(math.floor(tile.alpha or 100))
    EndScaleformMovieMethod()
end

-- sets the rotation of a tile.
-- @param scaleform_handle The handle of the scaleform.
-- @param tile_name The name (id) of the tile.
-- @param rotation The rotation in degrees (0-360).
function set_tile_rotation(scaleform_handle, tile)
    BeginScaleformMovieMethod(scaleform_handle, "SET_TILE_ROTATION")
    PushScaleformMovieFunctionParameterString(tostring(tile.name)) 
    PushScaleformMovieFunctionParameterFloat(tonumber(tile.rotation) or 0.0)
    EndScaleformMovieMethod()
end

-- sets the scale of a tile.
-- @param scaleform_handle The handle of the scaleform.
-- @param tile_name The name (id) of the tile.
-- @param x_scale The horizontal scale factor (1.0 = original size).
-- @param y_scale The vertical scale factor (1.0 = original size).
function set_tile_scale(scaleform_handle, tile)
    BeginScaleformMovieMethod(scaleform_handle, "SET_TILE_DIMENSIONS")
    PushScaleformMovieFunctionParameterString(tostring(tile.name)) 
    PushScaleformMovieFunctionParameterFloat(tonumber(tile.width))
    PushScaleformMovieFunctionParameterFloat(tonumber(tile.height))
    EndScaleformMovieMethod()
end