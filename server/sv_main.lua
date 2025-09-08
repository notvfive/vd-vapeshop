local QBCore = exports['qb-core']:GetCoreObject()

server.InitTable()

RegisterNetEvent('vd-vapeshop:server:PurchaseVapeshop', function()
    local success = server.PurchaseVapeshop(source)
    if success then
        TriggerClientEvent('ox_lib:notify', source, {
            title = "Vapeshop",
            type = "success",
            description = "Successfully purchased vapeshop for $"..tostring(config.ShopPrice)
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = "Vapeshop",
            type = "error",
            description = "Failed to purchase vapeshop"
        })
    end
    return
end)

-- Unused as of now, might use later idfk the plans on this script
-- lib.callback.register('vd-vapeshop:server:PurchaseVapeshop', function(source)
--     local success = server.PurchaseVapeshop(source)
--     if success then
--         TriggerClientEvent('ox_lib:notify', source, {
--             title = "Vapeshop",
--             type = "success",
--             description = "Successfully purchased vapeshop for $"..tostring(config.ShopPrice)
--         })
--     else
--         TriggerClientEvent('ox_lib:notify', source, {
--             title = "Vapeshop",
--             type = "error",
--             description = "Failed to purchase vapeshop"
--         })
--     end
-- end)