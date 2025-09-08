client = {}

function client.HandleInteraction(interaction)
    if interaction == config.Interactions.Purchase then
        TriggerServerEvent('vd-vapeshop:server:PurchaseVapeshop')
    end

    if interaction == config.Interactions.Shopmanage then
    end
end