fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/logo.png'
}

shared_script {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}
