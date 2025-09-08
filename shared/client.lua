local QBCore = exports['qb-core']:GetCoreObject()
client = {}

function client.HandleInteraction(interaction)
    if interaction == config.Interactions.Purchase then
        TriggerServerEvent('vd-vapeshop:server:PurchaseVapeshop')
    end

    if interaction == config.Interactions.Shopmanage then
        client.OpenDashboard()
    end
end

function client.OpenDashboard()
    print("^2[VD-Vapeshop] Opening dashboard...")
    QBCore.Functions.TriggerCallback('vd-vapeshop:server:DoesPlayerOwnVapeshop', function(ownsVapeshop)
        print("^2[VD-Vapeshop] Player owns vapeshop: " .. tostring(ownsVapeshop))
        if ownsVapeshop then
            SetNuiFocus(true, true)
            SendNUIMessage({
                type = 'openDashboard'
            })
            print("^2[VD-Vapeshop] NUI message sent")
        else
            exports.ox_lib:notify({
                title = "Vapeshop",
                type = "error",
                description = "You don't own a vapeshop!"
            })
        end
    end)
end

RegisterNUICallback('closeDashboard', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('getStockData', function(data, cb)
    QBCore.Functions.TriggerCallback('vd-vapeshop:server:GetPlayerVapeshopStock', function(stock)
        cb({
            success = true,
            stock = stock
        })
    end)
end)

RegisterNUICallback('getShipmentsData', function(data, cb)
    cb({
        success = true,
        vapes = config.Vapes
    })
end)

RegisterNUICallback('getBalance', function(data, cb)
    QBCore.Functions.TriggerCallback('vd-vapeshop:server:GetVapeshopBalance', function(balance)
        cb({
            success = true,
            balance = balance
        })
    end)
end)

RegisterNUICallback('purchaseShipment', function(data, cb)
    TriggerServerEvent('vd-vapeshop:server:PurchaseVapeShipment', data.vape)
    cb('ok')
end)

RegisterNUICallback('depositMoney', function(data, cb)
    TriggerServerEvent('vd-vapeshop:server:DepositMoney', data.type, data.amount)
    cb('ok')
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    TriggerServerEvent('vd-vapeshop:server:WithdrawMoney', data.type, data.amount)
    cb('ok')
end)
