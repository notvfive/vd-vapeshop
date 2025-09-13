--[[
    VD-Vapeshop Exports
    Exports for other scripts to interact with the vapeshop system
]]

local QBCore = exports['qb-core']:GetCoreObject()
local mysql = exports.oxmysql

-- Helper function to get citizen ID
local function getCitizenId(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return nil end
    return player.PlayerData.citizenid
end

--[[
    Check if a player owns a vapeshop
    @param source number - Player source
    @return boolean - True if player owns a vapeshop
]]
exports('DoesPlayerOwnVapeshop', function(source)
    local citizenid = getCitizenId(source)
    if not citizenid then
        return false
    end

    local result = mysql:querySync(
        'SELECT 1 FROM vd_vapeshop WHERE citizenid = ?',
        { citizenid }
    )

    if result and #result > 0 then
        return true
    else
        return false
    end
end)

--[[
    Get a player's vapeshop business balance
    @param source number - Player source
    @return number - Business balance amount
]]
exports('GetVapeshopBalance', function(source)
    local citizenid = getCitizenId(source)
    if not citizenid then return 0 end

    local result = mysql:querySync(
        'SELECT balance FROM vd_vapeshop WHERE citizenid = ?',
        { citizenid }
    )

    if result and #result > 0 then
        return result[1].balance or 0
    else
        return 0
    end
end)

--[[
    Add money to a player's vapeshop business balance
    @param source number - Player source
    @param amount number - Amount to add
    @return boolean - Success status
]]
exports('AddVapeshopBalance', function(source, amount)
    local citizenid = getCitizenId(source)
    if not citizenid then return false end

    if not exports['vd-vapeshop']:DoesPlayerOwnVapeshop(source) then return false end

    -- Check if adding amount would exceed max balance
    local currentBalance = exports['vd-vapeshop']:GetVapeshopBalance(source)
    if (currentBalance + amount) > config.MaxBusinessBalance then
        return false
    end

    local success, result = pcall(function()
        return mysql:update("UPDATE vd_vapeshop SET balance = balance + ? WHERE citizenid = ?", { amount, citizenid })
    end)

    return success
end)

--[[
    Remove money from a player's vapeshop business balance
    @param source number - Player source
    @param amount number - Amount to remove
    @return boolean - Success status
]]
exports('RemoveVapeshopBalance', function(source, amount)
    local citizenid = getCitizenId(source)
    if not citizenid then return false end

    if not exports['vd-vapeshop']:DoesPlayerOwnVapeshop(source) then return false end

    local currentBalance = exports['vd-vapeshop']:GetVapeshopBalance(source)
    if currentBalance < amount then return false end

    local success, result = pcall(function()
        return mysql:update("UPDATE vd_vapeshop SET balance = balance - ? WHERE citizenid = ?", { amount, citizenid })
    end)

    return success
end)

--[[
    Set a player's vapeshop business balance to a specific amount
    @param source number - Player source
    @param amount number - Amount to set
    @return boolean - Success status
]]
exports('SetVapeshopBalance', function(source, amount)
    local citizenid = getCitizenId(source)
    if not citizenid then return false end

    if not exports['vd-vapeshop']:DoesPlayerOwnVapeshop(source) then return false end

    local success, result = pcall(function()
        return mysql:update("UPDATE vd_vapeshop SET balance = ? WHERE citizenid = ?", { amount, citizenid })
    end)

    return success
end)

--[[
    Get a player's vapeshop stock data
    @param source number - Player source
    @return table - Stock data with vape names and quantities
]]
exports('GetPlayerVapeshopStock', function(source)
    local citizenid = getCitizenId(source)
    if not citizenid then return {} end

    if not exports['vd-vapeshop']:DoesPlayerOwnVapeshop(source) then return {} end

    local result = mysql:querySync('SELECT stock_data FROM vd_vapeshop WHERE citizenid = ?', {citizenid })
    if result and #result > 0 then
        local stockData = result[1].stock_data
        if type(stockData) == "string" then
            return json.decode(stockData) or {}
        else
            return stockData or {}
        end
    else
        return {}
    end
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
    
    if not exports['vd-vapeshop']:DoesPlayerOwnVapeshop(source) then return false end
    
    local stock = exports['vd-vapeshop']:GetPlayerVapeshopStock(source)
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
    
    if not exports['vd-vapeshop']:DoesPlayerOwnVapeshop(source) then return false end
    
    local stock = exports['vd-vapeshop']:GetPlayerVapeshopStock(source)
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
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return false end

    local currency = config.Currency
    local amount = config.ShopPrice

    if currency == "cash" then
        return (player.PlayerData.money.cash or 0) >= amount
    elseif currency == "bank" then
        return (player.PlayerData.money.bank or 0) >= amount
    else
        return false
    end
end)

--[[
    Purchase a vapeshop for a player (bypasses normal purchase flow)
    @param source number - Player source
    @return boolean, string - Success status and message
]]
exports('PurchaseVapeshop', function(source)
    local player = QBCore.Functions.GetPlayer(source)
    local cid = getCitizenId(source)
    if not player or not cid then return false, "Failed to get player object." end

    if exports['vd-vapeshop']:DoesPlayerOwnVapeshop(source) == true then return false, "You already own a vapeshop." end

    if not exports['vd-vapeshop']:CanAffordVapeshop(source) then return false, "You cannot afford a vapeshop ( $"..tostring(config.ShopPrice).." )" end

    local success, result = pcall(function()
        return mysql:insert("INSERT INTO vd_vapeshop (citizenid, balance, stock_data) VALUES (?, ?, ?)", { cid, config.StartingBalance, "{}" })
    end)

    if success then
        local amount = config.ShopPrice
        local currency = config.Currency
        
        if currency == "cash" then
            player.Functions.RemoveMoney("cash", amount, "purchase-vapeshop")
        elseif currency == "bank" then
            player.Functions.RemoveMoney("bank", amount, "purchase-vapeshop")
        end
        
        print("^2[VD-Vapeshop] "..cid.." purchased a vapeshop for $"..amount)
        return true, "Successfully purchased vapeshop for $"..tostring(config.ShopPrice)
    else
        print("^1[VD-Vapeshop] Failed to purchase vapeshop for "..cid..": "..tostring(result))
        return false, "Failed to purchase vapeshop."
    end
end)

--[[
    Get vapeshop statistics for a player
    @param source number - Player source
    @return table - Statistics including balance, stock count, total value
]]
exports('GetVapeshopStats', function(source)
    if not exports['vd-vapeshop']:DoesPlayerOwnVapeshop(source) then
        return nil
    end
    
    local balance = exports['vd-vapeshop']:GetVapeshopBalance(source)
    local stock = exports['vd-vapeshop']:GetPlayerVapeshopStock(source)
    
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
    if not exports['vd-vapeshop']:DoesPlayerOwnVapeshop(source) then return false, "Player doesn't own a vapeshop" end

    local stock = exports['vd-vapeshop']:GetPlayerVapeshopStock(source)
    if not stock or #stock == 0 then return false, "No stock available" end

    local availableVapes = {}
    for _, vape in pairs(stock) do
        if vape.count and vape.count > 0 then
            table.insert(availableVapes, vape)
        end
    end

    if #availableVapes == 0 then return false, "No vapes in stock" end

    local randomVape = availableVapes[math.random(1, #availableVapes)]
    local vapeConfig = nil

    for _, v in ipairs(config.Vapes) do
        if v.name and v.name:lower() == randomVape.name:lower() then
            vapeConfig = v
            break
        end
    end

    if not vapeConfig then return false, "Vape config not found" end

    local salePrice = vapeConfig.price
    local quantitySold = math.random(config.MinSaleQuantity, math.min(config.MaxSaleQuantity, randomVape.count))

    local newStock = {}
    for _, vape in pairs(stock) do
        if vape.name:lower() == randomVape.name:lower() then
            local newCount = vape.count - quantitySold
            if newCount > 0 then
                table.insert(newStock, {
                    name = vape.name,
                    count = newCount
                })
            end
        else
            table.insert(newStock, vape)
        end
    end

    local citizenid = getCitizenId(source)
    local success, result = pcall(function()
        return mysql:update("UPDATE vd_vapeshop SET stock_data = ? WHERE citizenid = ?", { json.encode(newStock), citizenid })
    end)

    if not success then return false, "Failed to update stock" end

    local totalEarnings = salePrice * quantitySold
    if not exports['vd-vapeshop']:AddVapeshopBalance(source, totalEarnings) then
        return false, "Failed to add earnings to balance"
    end

    local message = string.format("Sold %d %s for $%d", quantitySold, randomVape.name, totalEarnings)
    print("^2[VD-Vapeshop] "..citizenid.." "..message)
    
    return true, message
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
