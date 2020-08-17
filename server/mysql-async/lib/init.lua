AddEventHandler('onServerResourceStart', function (resource)
    if resource == GetCurrentResourceName() then
        exports[GetCurrentResourceName()]:mysql_configure()

        Citizen.CreateThread(function ()
            Citizen.Wait(0)
            TriggerEvent('onMySQLReady')
        end)
    end
end)


