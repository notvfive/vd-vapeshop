CreateThread(function()
    for i,v in pairs(config.Interactions) do
        exports.ox_target:addBoxZone({
            coords = v.location,
            name = i,
            size = vector3(0.2, 0.2, 0.2),
            options = {
                label = v.name
            }
        })
    end
end)

for i,v in pairs(config.Interactions) do
    RegisterNetEvent(v.event, function()
        client.HandleInteraction(v)
    end)
end