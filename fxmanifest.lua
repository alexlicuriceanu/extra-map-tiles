fx_version "cerulean"
game "gta5"
lua54 "yes"

name "Extra Map Tiles"
description "Adds extra tiles with textures on the minimap and pause menu map beyond the default game limit."
author "L1CKS"
version "3.0.0"

client_scripts {
  "utils.lua",
  "client.lua",
  "scaleforms.lua",
  "exports.lua",
}

shared_scripts {
  "config.lua"
}

files {
  "stream/*.ytd",
  "stream/minimap_main_map.gfx"
}
