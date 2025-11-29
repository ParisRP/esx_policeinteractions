fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'TonyKFC.interactions'
version '1.0.0'

client_scripts {
    '@ox_lib/init.lua',
    'locales/*.lua',
    'client/locales.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@ox_lib/init.lua',
    'locales/*.lua',
    'server/main.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
}

dependencies {
    'oxmysql',
    'ox_lib',
    'ox_inventory',
    'ox_core'
}
