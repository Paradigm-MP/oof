MySQLWrapper = class()


function MySQLWrapper:__init()

    MySQL.ready(function ()
        self:Ready()
    end)
    
end

function MySQLWrapper:Ready()
    self.ready = true
    Events:Fire("mysql/Ready") -- Let other modules know that MySQL is ready
    print(Colors.Console.Green .. "MySQL ready!" .. Colors.Console.Default)
end

-- SQL.Execute("UPDATE player SET name=@name WHERE id=@id", {['@id'] = 10, ['@name'] = 'foo'}, function(data) end)
function MySQLWrapper:Execute(query, params, callback)
    MySQL.Async.execute(query, params, function(rowsChanged)
        if callback then
            callback(rowsChanged)
        end
    end)
end

-- SELECT ... where id=@id ... (see above)
function MySQLWrapper:Fetch(query, params, callback)
    MySQL.Async.fetchAll(query, params, function(data)
        callback(data)
    end)
end

SQL = MySQLWrapper()