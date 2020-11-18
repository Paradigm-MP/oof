-- This file is where changes to existing superglobals (either in platform API or Lua itself) can be added via overloading
-- This allows us to change the behavior of these superglobals while keeping our code's vocabulary simple. It also makes refactoring much simpler in some cases.
-- adds print(), tostring(), and type() support for the object-oriented structure

-- TODO: move IsTest somewhere else, in some sort of config file
IsTest = true

