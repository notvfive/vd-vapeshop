local QBCore = exports['qb-core']:GetCoreObject()
local purchaseCooldowns = {}

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

RegisterNetEvent('vd-vapeshop:server:PurchaseVapeShipment', function(vape)
    local playerSource = source
    if not playerSource then return end
    
    local player = QBCore.Functions.GetPlayer(playerSource)
    if not player then return end
    
    local currentTime = os.time()
    if purchaseCooldowns[playerSource] and (currentTime - purchaseCooldowns[playerSource]) < config.PurchaseCooldown then
        local remainingTime = config.PurchaseCooldown - (currentTime - purchaseCooldowns[playerSource])
        TriggerClientEvent('ox_lib:notify', playerSource, {
            title = "Vapeshop",
            type = "error",
            description = "Please wait " .. remainingTime .. " seconds before purchasing another shipment."
        })
        return
    end
    
    local success, msg = server.PurchaseVapeShipment(playerSource, vape)
    if success then
        purchaseCooldowns[playerSource] = currentTime
        
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

RegisterNetEvent('vd-vapeshop:server:DepositMoney', function(moneytype, amount)
    local playerSource = source
    if not playerSource then return end
    
    local player = QBCore.Functions.GetPlayer(playerSource)
    if not player then return end
    
    local success, msg = server.DepositMoneyToBusiness(playerSource, moneytype, amount)
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

RegisterNetEvent('vd-vapeshop:server:WithdrawMoney', function(moneytype, amount)
    local playerSource = source
    if not playerSource then return end
    
    local player = QBCore.Functions.GetPlayer(playerSource)
    if not player then return end
    
    local success, msg = server.WithdrawMoneyFromBusiness(playerSource, moneytype, amount)
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

CreateThread(function()
    while true do
        Wait(config.SalesCheckInterval) -- check config if u want to change it cuz
        
        local players = QBCore.Functions.GetQBPlayers()
        for playerId, player in pairs(players) do
            if server.DoesPlayerOwnVapeshop(playerId) then
                if math.random(1, config.SalesChance) == 1 then
                    local success, message = server.ProcessRandomSale(playerId)
                    if success then
                        TriggerClientEvent('ox_lib:notify', playerId, {
                            title = "Vapeshop Sale",
                            type = "success",
                            description = message
                        })
                    end
                end
            end
        end
    end
end)


QBCore.Functions.CreateCallback('vd-vapeshop:server:DoesPlayerOwnVapeshop', function(source, cb)
    local ownsVapeshop = server.DoesPlayerOwnVapeshop(source)
    cb(ownsVapeshop == true)
end)

QBCore.Functions.CreateCallback('vd-vapeshop:server:GetPlayerVapeshopStock', function(source, cb)
    local stock = server.GetPlayerVapeshopStock(source)
    cb(stock)
end)

QBCore.Functions.CreateCallback('vd-vapeshop:server:GetVapeshopBalance', function(source, cb)
    local balance = server.GetVapeshopBalance(source)
    cb(balance)
end)

AddEventHandler('playerDropped', function()
    local playerSource = source
    if purchaseCooldowns[playerSource] then
        purchaseCooldowns[playerSource] = nil
    end
end)