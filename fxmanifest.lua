fx_version 'cerulean'
game 'gta5'

name "vd-vapeshop"
description "Vapeshop bro"
author "notvfive"
version "1.0"
lua54 'yes'

shared_scripts {
	'@ox_lib/init.lua',
	-- 'shared/*.lua',
	'config.lua'
}

client_scripts {
	'shared/client.lua',
	'client/*.lua'
}

server_scripts {
	'shared/server.lua',
	'server/*.lua',
}

dependencies {
    'qb-core',
    'ox_lib',
    'ox_target',
	'oxmysql'
}

ui_page 'index.html'

files {
	'web/index.html',
	'web/style.css',
	'web/script.js',
	'web/images/*.png',
}