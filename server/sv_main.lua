local QBCore = exports['qb-core']:GetCoreObject()

server.InitTable()

RegisterNetEvent('vd-vapeshop:server:PurchaseVapeshop', function()
    local playerSource = source
    if not playerSource then return end
    
    local player = QBCore.Functions.GetPlayer(playerSource)
    if not player then return end
    
    local success, msg = server.PurchaseVapeshop(playerSource)
    if success then
        TriggerClientEvent('ox_lib:notify', playerSource, {
            title = "Vapeshop",
            type = "success",
            description = msg
        })
    else
        TriggerClientEvent('ox_lib:notify', playerSource, {
            title = "Vapeshop",
            type = "error",
            description = msg
        })
    end
end)