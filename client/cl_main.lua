CreateThread(function()
    for key, v in pairs(config.Interactions) do
        print("Placed: "..tostring(v.name))
        exports.ox_target:addBoxZone({
            coords = v.location,
            name = key,
            size = vector3(2,2,2),
            options = {
                {
                    label = v.name,
                    icon = v.icon,
                    onSelect = function()
                        client.HandleInteraction(v)
                    end
                }
            }
        })
    end
end)