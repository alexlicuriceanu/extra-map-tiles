fx_version "cerulean"
game "gta5"
lua54 "yes"

name "Extra Map Tiles Revamped"
description "Adds extra tiles with textures on the minimap and pause menu map beyond the default game limit."
author "L1CKS"
version "2.0.0"

client_scripts {
  "client.lua"
}

shared_scripts {
  "config.lua"
}

escrow_ignore {
  "config.lua",
}

files {
  "stream/*.ytd",
  "stream/minimap_main_map.gfx"
}