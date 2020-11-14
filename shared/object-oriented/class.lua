__collect_inits = true
__init_list = {}

function class(...)
    -- "cls" is the new class (not the instance, the actual class table / class metadata)
    local cls, bases = {}, {...}

    cls.__class_instance = true

    -- copy base class contents into the new class
    --print("-------------------------------------------------")
    --print("base stuff:")
    for i, base in ipairs(bases) do
        -- base is a table
        for name, value in pairs(base) do
            cls[name] = value
        end
    end
    
    -- set the class's __index, and start filling an "is_a" table that contains this class and all of its bases
    -- so you can do an "instance of" check using my_instance.is_a[MyClass]
    cls.__index, cls.is_a = cls, {[cls] = true}
    for i, base in ipairs(bases) do
        for c in pairs(base.is_a) do
            cls.is_a[c] = true
        end
        cls.is_a[base] = true
    end

    -- the class's __call metamethod (when you are actually creating the instance)
    setmetatable(cls, {__call = function (c, ...)
        local instance = setmetatable({}, c)
        -- run the init method if it's there
        local init = instance.__init

        -- this overrides the class's :tostring because the class() function is called
        -- each time a new class instance is created,
        -- while the class method is created only once on load.
        -- therefore it gets overriden when the instance is created
        if not instance.tostring then -- if the class doesnt have a :tostring() method, add one that spits out a warning if it gets called
            instance.tostring = function() return "API Warning: called tostring on a class instance when :tostring() was not implemented" end
        end

        if init then
            local args = {...}
            if __collect_inits then
                table.insert(__init_list, {instance, generate_init_function(instance, args)})
            else
                generate_init_function(instance, args)()
            end
        end

        return instance
    end})

    -- return the new class table, that's ready to be filled with methods
    return cls
end

-- returns a function that runs a class instance init
function generate_init_function(class_instance, args)
    return
    function()
        class_instance.__init(class_instance, unpack(args))
    end
end