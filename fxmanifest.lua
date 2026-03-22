fx_version "cerulean"
game "gta5"
lua54 "yes"

name "Extra Map Tiles"
description "Adds extra tiles with textures on the minimap and pause menu map beyond the default game limit."
author "L1CKS"
version "2.1.0"

client_scripts {
  "client.lua",
  "scaleforms.lua",
}

shared_scripts {
  "config.lua"
}

files {
  "stream/*.ytd",
  "stream/minimap_main_map.gfx"
}
