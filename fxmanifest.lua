fx_version 'cerulean'
game 'gta5'
author 'MaDHouSe79'
description 'MH Stash Stolen Vehicles'
version '1.0.0'
repository 'https://github.com/MaDHouSe79/mh-stashvehicles'

shared_scripts {
    '@ox_lib/init.lua',
	'shared/locale.lua',
	'locales/en.lua',
	'locales/*.lua',
    'shared/functions.lua',
    'shared/vehicles.lua',
}
client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/cl_core.lua',
    'client/main.lua',
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_config.lua',
    'server/sv_core.lua',
    'server/main.lua',
    'server/update.lua'
}
dependencies { 'oxmysql', 'ox_lib' }

lua54 'yes'
