fx_version 'bodacious'
game 'gta5'
lua54 'yes'

author 'yunglean_#4171'
description 'geomining'
version '1.0.0'

server_scripts {'@oxmysql/lib/MySQL.lua','config.lua','src/server.lua'}
client_scripts {'config.lua','src/client.lua'}

ui_page "nui/index.html"

files {
    'nui/index.html',
    'nui/script.js',
    'nui/style.css',
    'nui/images/*.png'
}

shared_script '@es_extended/imports.lua'