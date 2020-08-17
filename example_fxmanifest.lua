ui_page 'ui/index.html'

client_scripts {
    -- api module, nothing should precede this module
    'napi/shared/overloads.lua',
    'napi/shared/utilities/*.lua',
    'napi/shared/object-oriented/class.lua', -- no class instances on initial frame before this file
    'napi/shared/object-oriented/shGetterSetter.lua', -- getter_setter, getter_setter_encrypted
    'napi/shared/standalone-data-structures/*', -- Enum, IdPool
    'napi/shared/math/*.lua',
    '**/shared/enums/*Enum.lua', -- load all Enums
    '**/client/enums/*Enum.lua',
    'napi/shared/Events.lua',
    'napi/client/cNetwork.lua',
    'napi/shared/ValueStorage.lua',
    'napi/client/TypeCheck.lua',
    'napi/client/AssetRequester.lua',
    'napi/shared/Timer.lua',
    'napi/client/cEntity.lua',
    'napi/client/cPlayer.lua',
    'napi/client/cPlayers.lua',
    'napi/client/cPlayerManager.lua',
    'napi/client/Ped.lua',
    'napi/client/Physics.lua',
    'napi/client/LocalPlayer.lua',
    'napi/shared/Color.lua',
    'napi/client/Render.lua',
    'napi/client/Camera.lua',
    'napi/client/ObjectManager.lua',
    'napi/client/Object.lua',
    'napi/client/ScreenEffects.lua',
    'napi/client/World.lua',
    'napi/client/Sound.lua',
    'napi/client/Light.lua',
    'napi/client/ParticleEffect.lua',
    'napi/client/Filter.lua',
    'napi/client/Explosion.lua',
    'napi/client/PauseMenu.lua',
    'napi/client/Hud.lua',
    'napi/client/Keypress.lua',
    'napi/client/Prompt.lua',
    'napi/client/Imap.lua',
    'napi/client/Marker.lua',
    'napi/client/Texture.lua',
    'napi/client/apitest.lua',
    'napi/client/localplayer_behaviors/*.lua',
    'napi/client/weapons/*.lua',

    -- Add other modules here (client and shared)

    -- LOAD LAST
    'napi/shared/object-oriented/LOAD_ABSOLUTELY_LAST.lua'
}

server_scripts {
    -- api module, nothing should precede this module
    'napi/server/sConfig.lua',
    'napi/shared/overloads.lua', -- load order position does not matter because this is non-class code
    'napi/shared/utilities/*.lua',
    'napi/shared/object-oriented/class.lua', -- no class instances on initial frame before this file
    'napi/shared/object-oriented/shGetterSetter.lua',
    'napi/shared/math/*.lua',
    'napi/shared/standalone-data-structures/*', -- Enum, IdPool
    '**/shared/enums/*Enum.lua', -- load all the enums from all the modules
    '**/server/enums/*Enum.lua',
    'napi/shared/Color.lua',
    'napi/shared/Events.lua',
    'napi/server/sNetwork.lua',
    -- mysql enabler
    'napi/server/mysql-async/MySQLAsync.net.dll',
    'napi/server/mysql-async/lib/init.lua',
    'napi/server/mysql-async/lib/MySQL.lua',
    -- mysql wrapper
    'napi/server/MySQL.lua',
    'napi/shared/ValueStorage.lua',
    'napi/shared/Timer.lua',
    'napi/server/sPlayer.lua',
    'napi/server/sPlayers.lua',
    'napi/server/sPlayerManager.lua',
    'napi/server/sWorld.lua',
    'napi/server/JSONUtils.lua',

    -- Add other modules here (server and shared)

    -- Load last
    'napi/shared/object-oriented/LOAD_ABSOLUTELY_LAST.lua'
}

files {
    -- Add files that you need here, like html/css/js for UI
}

fx_version 'adamant'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'