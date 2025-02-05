fx_version "adamant"
game "gta5"

author "Melonnes Fivem Stuff https://discord.gg/YmesHZwnhR"
description "Fraktionladen mit Raub und Geldwäsche"

client_script {
    "client/client.lua"
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "server/server.lua"
}

shared_scripts {
    "config.lua"
}

ui_page 'html/ui.html'

files {
  'html/*',
  'html/css/*'
}
