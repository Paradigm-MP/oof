ui_page 'oof/client/ui/index.html'

client_scripts {
    -- OOF module, nothing should precede this module

    -- Uncomment ONE of these depending on the game this is running on
    --'oof/shared/game/IsRedM.lua',
    --'oof/shared/game/IsFiveM.lua',

    'oof/shared/lua-overloads/*.lua',
    'oof/shared/lua-additions/*.lua',
    'oof/shared/object-oriented/class.lua', -- no class instances on initial frame before this file
    'oof/shared/object-oriented/shGetterSetter.lua', -- getter_setter, getter_setter_encrypted
    'oof/shared/object-oriented/shObjectOrientedUtilities.lua', -- is_class_instance
    'oof/shared/standalone-data-structures/*', -- Enum, IdPool
    'oof/shared/math/*.lua',
    '**/shared/enums/*Enum.lua', -- load all Enums
    '**/client/enums/*Enum.lua',
    'oof/shared/events/*.lua', -- Events class
    'oof/client/network/*.lua', -- Network class
    'oof/shared/value-storage/*.lua', -- ValueStorage class
    'oof/client/typecheck/*.lua', -- TypeCheck class
    'oof/client/asset-requester/*.lua',
    'oof/shared/timer/*.lua', -- Timer class
    'oof/shared/xml/*.lua', -- XML class
    'oof/shared/csv/*.lua', -- CSV class
    'oof/client/entity/*.lua', -- Entity class
    'oof/client/player/cPlayer.lua',
    'oof/client/player/cPlayers.lua',
    'oof/client/player/cPlayerManager.lua',
    'oof/client/ped/*.lua', -- Ped class
    'oof/client/physics/*.lua',
    'oof/client/localplayer/*.lua', -- LocalPlayer class
    'oof/shared/color/*.lua',
    'oof/client/render/*.lua',
    'oof/client/camera/*.lua', -- Camera class
    'oof/client/blip/*.lua', -- Blip class
    'oof/client/object/*.lua', -- Object, ObjectManager classes
    'oof/client/ScreenEffects.lua',
    'oof/client/world/*.lua', -- World class
    'oof/client/sound/*.lua', -- Sound class
    'oof/client/light/*.lua', -- Light class
    'oof/client/particle-effect/*.lua', -- ParticleEffect class
    'oof/client/anim-post-fx/*.lua', -- AnimPostFX class
    'oof/client/volume/*.lua', -- Volume class
    'oof/client/explosion/*.lua', -- Explosion class
    'oof/client/pause-menu/*.lua', -- PauseMenu class
    'oof/client/hud/*.lua', -- HUD class
    'oof/client/keypress/*.lua',
    'oof/client/prompt/*.lua', -- Prompt class
    'oof/client/map/*.lua', -- Imap/Ipl class
    'oof/client/marker/*.lua', -- Marker class
    'oof/client/water/*.lua', -- Water class
    'oof/client/apitest.lua',
    'oof/client/localplayer_behaviors/*.lua',
    'oof/client/weapons/*.lua',
    'oof/client/ui/ui.lua',

    -- Add other modules here (client and shared)

    -- LOAD LAST
    'oof/shared/object-oriented/LOAD_ABSOLUTELY_LAST.lua'
}

server_scripts {
    -- OOF module, nothing should precede this module
    
    -- Uncomment ONE of these depending on the game this is running on
    --'oof/shared/game/IsRedM.lua',
    --'oof/shared/game/IsFiveM.lua',

    'oof/server/sConfig.lua',
    'oof/shared/lua-overloads/*.lua',
    'oof/shared/lua-additions/*.lua',
    'oof/shared/object-oriented/class.lua', -- no class instances on initial frame before this file
    'oof/shared/object-oriented/shGetterSetter.lua',
    'oof/shared/object-oriented/shObjectOrientedUtilities.lua', -- is_class_instance function
    'oof/shared/math/*.lua',
    'oof/shared/standalone-data-structures/*', -- Enum, IdPool
    '**/shared/enums/*Enum.lua', -- load all the enums from all the modules
    '**/server/enums/*Enum.lua',
    'oof/shared/color/*.lua',
    'oof/shared/events/*.lua', -- Events class
    'oof/server/network/*.lua', -- Network class
    'oof/server/json/*.lua', -- JsonOOF, JsonUtils class
    -- mysql enabler
    'oof/server/mysql-async/MySQLAsync.net.dll',
    'oof/server/mysql-async/lib/init.lua',
    'oof/server/mysql-async/lib/MySQL.lua',
    -- mysql wrapper
    'oof/server/mysql/MySQL.lua',
    'oof/server/key-value-store/*.lua',
    'oof/shared/value-storage/*.lua', -- ValueStorage class
    'oof/shared/timer/*.lua', -- Timer class
    'oof/shared/xml/*.lua', -- XML class
    'oof/shared/csv/*.lua', -- CSV class
    'oof/server/fs-additions/*.lua', -- Directory/file exists helper functions
    'oof/server/player/sPlayer.lua', -- Player class
    'oof/server/player/sPlayers.lua', -- Players class
    'oof/server/player/sPlayerManager.lua', -- PlayerManager class
    'oof/server/entity/sEntity.lua', -- Entity class
    'oof/server/ped/sPed.lua', -- Ped class
    'oof/server/world/*.lua', -- World class

    -- Add other modules here (server and shared)

    -- Load last
    'oof/shared/object-oriented/LOAD_ABSOLUTELY_LAST.lua'
}

files {
    -- general ui
    'oof/client/ui/reset.css',
    'oof/client/ui/jquery.js',
    'oof/client/ui/events.js',
    'oof/client/ui/index.html'
    -- Add files that you need here, like html/css/js for UI
}

fx_version 'adamant'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'