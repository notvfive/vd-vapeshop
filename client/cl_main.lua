CreateThread(function()
    local blip = AddBlipForCoord(config.Blip.location.x, config.Blip.location.y, config.Blip.location.z)
    SetBlipSprite(blip, config.Blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, config.Blip.scale)
    SetBlipColour(blip, config.Blip.colour)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(config.Blip.label)
    EndTextCommandSetBlipName(blip)
    
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