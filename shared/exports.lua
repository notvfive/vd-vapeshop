--[[
    VD-Vapeshop Exports
    Exports for other scripts to interact with the vapeshop system
]]

local exports = {}

--[[
    Check if a player owns a vapeshop
    @param source number - Player source
    @return boolean - True if player owns a vapeshop
]]
exports('DoesPlayerOwnVapeshop', function(source)
    return server.DoesPlayerOwnVapeshop(source)
end)

--[[
    Get a player's vapeshop business balance
    @param source number - Player source
    @return number - Business balance amount
]]
exports('GetVapeshopBalance', function(source)
    return server.GetVapeshopBalance(source)
end)

--[[
    Add money to a player's vapeshop business balance
    @param source number - Player source
    @param amount number - Amount to add
    @return boolean - Success status
]]
exports('AddVapeshopBalance', function(source, amount)
    return server.AddVapeshopBalance(source, amount)
end)

--[[
    Remove money from a player's vapeshop business balance
    @param source number - Player source
    @param amount number - Amount to remove
    @return boolean - Success status
]]
exports('RemoveVapeshopBalance', function(source, amount)
    return server.RemoveVapeshopBalance(source, amount)
end)

--[[
    Set a player's vapeshop business balance to a specific amount
    @param source number - Player source
    @param amount number - Amount to set
    @return boolean - Success status
]]
exports('SetVapeshopBalance', function(source, amount)
    return server.SetVapeshopBalance(source, amount)
end)

--[[
    Get a player's vapeshop stock data
    @param source number - Player source
    @return table - Stock data with vape names and quantities
]]
exports('GetPlayerVapeshopStock', function(source)
    return server.GetPlayerVapeshopStock(source)
end)

--[[
    Add vapes to a player's vapeshop stock
    @param source number - Player source
    @param vapeName string - Name of the vape to add
    @param quantity number - Quantity to add
    @return boolean - Success status
]]
exports('AddVapeshopStock', function(source, vapeName, quantity)
    local citizenid = getCitizenId(source)
    if not citizenid then return false end
    
    if not server.DoesPlayerOwnVapeshop(source) then return false end
    
    local stock = server.GetPlayerVapeshopStock(source)
    if not stock then return false end
    
    -- Find existing vape or create new entry
    local found = false
    for _, vape in pairs(stock) do
        if vape.name:lower() == vapeName:lower() then
            vape.count = vape.count + quantity
            found = true
            break
        end
    end
    
    if not found then
        table.insert(stock, {
            name = vapeName,
            count = quantity
        })
    end
    
    -- Update database
    local success, result = pcall(function()
        return mysql:update("UPDATE vd_vapeshop SET stock_data = ? WHERE citizenid = ?", { json.encode(stock), citizenid })
    end)
    
    return success
end)

--[[
    Remove vapes from a player's vapeshop stock
    @param source number - Player source
    @param vapeName string - Name of the vape to remove
    @param quantity number - Quantity to remove
    @return boolean - Success status
]]
exports('RemoveVapeshopStock', function(source, vapeName, quantity)
    local citizenid = getCitizenId(source)
    if not citizenid then return false end
    
    if not server.DoesPlayerOwnVapeshop(source) then return false end
    
    local stock = server.GetPlayerVapeshopStock(source)
    if not stock then return false end
    
    -- Find and remove vapes
    for i, vape in pairs(stock) do
        if vape.name:lower() == vapeName:lower() then
            vape.count = math.max(0, vape.count - quantity)
            
            -- Remove entry if count reaches 0
            if vape.count <= 0 then
                table.remove(stock, i)
            end
            break
        end
    end
    
    -- Update database
    local success, result = pcall(function()
        return mysql:update("UPDATE vd_vapeshop SET stock_data = ? WHERE citizenid = ?", { json.encode(stock), citizenid })
    end)
    
    return success
end)

--[[
    Get vape configuration by name
    @param vapeName string - Name of the vape
    @return table - Vape configuration or nil if not found
]]
exports('GetVapeConfig', function(vapeName)
    for _, vape in pairs(config.Vapes) do
        if vape.name:lower() == vapeName:lower() then
            return vape
        end
    end
    return nil
end)

--[[
    Get all vape configurations
    @return table - All vape configurations
]]
exports('GetAllVapeConfigs', function()
    return config.Vapes
end)

--[[
    Check if a player can afford a vapeshop
    @param source number - Player source
    @return boolean - True if player can afford it
]]
exports('CanAffordVapeshop', function(source)
    return server.CanAffordVapeshop(source)
end)

--[[
    Purchase a vapeshop for a player (bypasses normal purchase flow)
    @param source number - Player source
    @return boolean, string - Success status and message
]]
exports('PurchaseVapeshop', function(source)
    return server.PurchaseVapeshop(source)
end)

--[[
    Get vapeshop statistics for a player
    @param source number - Player source
    @return table - Statistics including balance, stock count, total value
]]
exports('GetVapeshopStats', function(source)
    if not server.DoesPlayerOwnVapeshop(source) then
        return nil
    end
    
    local balance = server.GetVapeshopBalance(source)
    local stock = server.GetPlayerVapeshopStock(source)
    
    local totalStock = 0
    local totalValue = 0
    
    if stock then
        for _, vape in pairs(stock) do
            totalStock = totalStock + vape.count
            local vapeConfig = exports['vd-vapeshop']:GetVapeConfig(vape.name)
            if vapeConfig then
                totalValue = totalValue + (vape.count * vapeConfig.price)
            end
        end
    end
    
    return {
        balance = balance,
        totalStock = totalStock,
        totalValue = totalValue,
        stockItems = stock or {}
    }
end)

--[[
    Force a random sale for a player's vapeshop
    @param source number - Player source
    @return boolean, string - Success status and message
]]
exports('ForceRandomSale', function(source)
    return server.ProcessRandomSale(source)
end)

--[[
    Get all vapeshop owners (for admin purposes)
    @return table - List of citizenids who own vapeshops
]]
exports('GetAllVapeshopOwners', function()
    local success, result = pcall(function()
        return mysql:query("SELECT citizenid FROM vd_vapeshop")
    end)
    
    if success and result then
        local owners = {}
        for _, row in pairs(result) do
            table.insert(owners, row.citizenid)
        end
        return owners
    end
    
    return {}
end)

--[[
    Get vapeshop data by citizenid (for admin purposes)
    @param citizenid string - Citizen ID
    @return table - Vapeshop data or nil
]]
exports('GetVapeshopByCitizenId', function(citizenid)
    local success, result = pcall(function()
        return mysql:query("SELECT * FROM vd_vapeshop WHERE citizenid = ?", { citizenid })
    end)
    
    if success and result and #result > 0 then
        local data = result[1]
        data.stock_data = json.decode(data.stock_data or "{}")
        return data
    end
    
    return nil
end)

return exports
