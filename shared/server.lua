local QBCore = exports['qb-core']:GetCoreObject()
local mysql = exports.oxmysql

server = {}

function server.InitTable()
    mysql:query([[
        CREATE TABLE IF NOT EXISTS `vd_vapeshop` (
            `citizenid` VARCHAR(50) NOT NULL,
            `balance` INT NOT NULL DEFAULT 0,
            `stock_data` JSON NOT NULL,
            PRIMARY KEY (`citizenid`)
        )
        COLLATE='utf8_general_ci'
        ;
    ]])

    print("^2[VD-Vapehop] Initialized table!")
end


--- @param source number
--- @return string|nil citizenid or nil if player not found
local function getCitizenId(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return nil end
    return player.PlayerData.citizenid
end

--- Check if a player owns a vapeshop
--- @param source number
--- @return boolean|nil True if player owns a vapeshop, false if not, nil if player doesn't exist
function server.DoesPlayerOwnVapeshop(source)
    local citizenid = getCitizenId(source)
    if not citizenid then
        return nil
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
end

--- Get player's vapeshop balance
--- @param source number
--- @return number balance Returns 0 if the player doesn't own a vapeshop or doesn't exist
function server.GetVapeshopBalance(source)
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
end

--- Check if player can afford vapeshop
--- @param source number
--- @return boolean canAfford
function server.CanAffordVapeshop(source)
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
end

--- Purchase vapeshop
--- @param source number The player's server ID
--- @return boolean success Returns true if it was bought, false if not
--- @return string message Returns success or error message
function server.PurchaseVapeshop(source)
    local player = QBCore.Functions.GetPlayer(source)
    local cid = getCitizenId(source)
    if not player or not cid then return false, "Failed to get player object." end

    if server.DoesPlayerOwnVapeshop(source) == true then return false, "You already own a vapeshop." end

    if not server.CanAffordVapeshop(source) then return false, "You cannot afford a vapeshop ( $"..tostring(config.ShopPrice).." )" end

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
end

--- Get a players vapeshop total stock
--- @param source number
--- @return table data Returns a table: { vapename = x, amount = x }, Returns empty table if no stock data
function server.GetPlayerVapeshopStock(source)
    local citizenid = getCitizenId(source)
    if not citizenid then return {} end

    if not server.DoesPlayerOwnVapeshop(source) then return {} end

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
end

--- Get player vapeshop vape count
--- @param source number The players ID
--- @param vape string The vape you want to get the count of
--- @return number vapecount
function server.GetPlayerVapeshopVapeStock(source, vape)
    local result = server.GetPlayerVapeshopStock(source)
    if not result or result == {} then return 0 end

    local count = 0
    for i,v in pairs(result) do
        if v:lower() == vape:lower() then
            count = v.count
        end
    end

    return count
end

--- Can afford vape shipment
--- @param source number
--- @param vape string
--- @return boolean canAfford
function server.CanAffordVapeShipment(source, vape)
    if not server.DoesPlayerOwnVapeshop(source) then return false end

    local vapeLower = vape:lower()

    local vapeConfig = nil
    for _, v in ipairs(config.Vapes) do
        if v.name and v.name:lower() == vapeLower then
            vapeConfig = v
            break
        end
    end

    if not vapeConfig or not vapeConfig.shipment or not vapeConfig.shipment.price then
        return false
    end

    local shipmentCost = vapeConfig.shipment.price
    local businessBalance = server.GetVapeshopBalance(source)

    return businessBalance >= shipmentCost
end

--- Add money to vapeshop business balance
--- @param source number
--- @param amount number
--- @return boolean success
function server.AddVapeshopBalance(source, amount)
    local citizenid = getCitizenId(source)
    if not citizenid then return false end

    if not server.DoesPlayerOwnVapeshop(source) then return false end

    -- Check if adding amount would exceed max balance
    local currentBalance = server.GetVapeshopBalance(source)
    if (currentBalance + amount) > config.MaxBusinessBalance then
        return false
    end

    local success, result = pcall(function()
        return mysql:update("UPDATE vd_vapeshop SET balance = balance + ? WHERE citizenid = ?", { amount, citizenid })
    end)

    return success
end

--- Remove money from vapeshop business balance
--- @param source number
--- @param amount number
--- @return boolean success
function server.RemoveVapeshopBalance(source, amount)
    local citizenid = getCitizenId(source)
    if not citizenid then return false end

    if not server.DoesPlayerOwnVapeshop(source) then return false end

    local currentBalance = server.GetVapeshopBalance(source)
    if currentBalance < amount then return false end

    local success, result = pcall(function()
        return mysql:update("UPDATE vd_vapeshop SET balance = balance - ? WHERE citizenid = ?", { amount, citizenid })
    end)

    return success
end

--- Set vapeshop business balance to a specific amount
--- @param source number
--- @param amount number
--- @return boolean success
function server.SetVapeshopBalance(source, amount)
    local citizenid = getCitizenId(source)
    if not citizenid then return false end

    if not server.DoesPlayerOwnVapeshop(source) then return false end

    local success, result = pcall(function()
        return mysql:update("UPDATE vd_vapeshop SET balance = ? WHERE citizenid = ?", { amount, citizenid })
    end)

    return success
end

--- Process a random sale for a vapeshop owner
--- @param source number
--- @return boolean success
--- @return string message
function server.ProcessRandomSale(source)
    if not server.DoesPlayerOwnVapeshop(source) then return false, "Player doesn't own a vapeshop" end

    local stock = server.GetPlayerVapeshopStock(source)
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
    local quantitySold = math.random(config.MinSaleQuantity, math.min(config.MaxSaleQuantity, randomVape.count)) -- Configurable sale quantities

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
    if not server.AddVapeshopBalance(source, totalEarnings) then
        return false, "Failed to add earnings to balance"
    end

    local message = string.format("Sold %d %s for $%d", quantitySold, randomVape.name, totalEarnings)
    print("^2[VD-Vapeshop] "..citizenid.." "..message)
    
    return true, message
end

--- Purchase vape shipment
--- @param source number The players ID
--- @param vape string The vape you want to buy a shipment of
--- @return boolean success Returns true if it was bought, false if not
--- @return string message Returns success or error message
function server.PurchaseVapeShipment(source, vape)
    local cid = getCitizenId(source)
    if not cid then return false, "Failed to get player object." end

    if not server.DoesPlayerOwnVapeshop(source) then return false, "You don't own a vapeshop." end

    local vapeLower = vape:lower()
    local vapeConfig = nil
    for _, v in ipairs(config.Vapes) do
        if v.name and v.name:lower() == vapeLower then
            vapeConfig = v
            break
        end
    end

    if not vapeConfig or not vapeConfig.shipment then
        return false, "Invalid vape type."
    end

    if not server.CanAffordVapeShipment(source, vape) then
        return false, "Insufficient business balance for this shipment."
    end

    local shipmentCost = vapeConfig.shipment.price
    local shipmentCount = vapeConfig.shipment.vapecount

    if not server.RemoveVapeshopBalance(source, shipmentCost) then
        return false, "Failed to process payment."
    end

    local currentStock = server.GetPlayerVapeshopStock(source)
    local stockData = currentStock or {}
    
    local found = false
    for i, v in pairs(stockData) do
        if v.name and v.name:lower() == vapeLower then
            v.count = (v.count or 0) + shipmentCount
            found = true
            break
        end
    end
    
    if not found then
        table.insert(stockData, {
            name = vapeConfig.name,
            count = shipmentCount
        })
    end

    local success, result = pcall(function()
        return mysql:update("UPDATE vd_vapeshop SET stock_data = ? WHERE citizenid = ?", { json.encode(stockData), cid })
    end)

    if success then
        print("^2[VD-Vapeshop] "..cid.." purchased "..shipmentCount.." "..vapeConfig.name.." for $"..shipmentCost)
        return true, "Successfully purchased "..shipmentCount.." "..vapeConfig.name.." for $"..shipmentCost
    else
        server.AddVapeshopBalance(source, shipmentCost)
        print("^1[VD-Vapeshop] Failed to update stock for "..cid..": "..tostring(result))
        return false, "Failed to update stock."
    end
end

--- Deposit money into the vapeshop
--- @param source number
--- @param moneytype string
--- @param amount number
--- @return boolean success
--- @return string message
function server.DepositMoneyToBusiness(source, moneytype, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return false, "Player not found" end

    if not server.DoesPlayerOwnVapeshop(source) then return false, "You don't own a vapeshop" end

    if not amount or amount <= 0 then return false, "Invalid amount" end

    local playerMoney = 0
    if moneytype == "cash" then
        playerMoney = player.PlayerData.money.cash or 0
    elseif moneytype == "bank" then
        playerMoney = player.PlayerData.money.bank or 0
    else
        return false, "Invalid money type"
    end

    if playerMoney < amount then
        return false, "Insufficient funds"
    end

    local success = player.Functions.RemoveMoney(moneytype, amount, "deposit-to-vapeshop")
    if not success then
        return false, "Failed to remove money from player"
    end

    if not server.AddVapeshopBalance(source, amount) then
        player.Functions.AddMoney(moneytype, amount, "vapeshop-deposit-refund")
        return false, "Failed to add money to business balance"
    end

    local citizenid = getCitizenId(source)
    print("^2[VD-Vapeshop] "..citizenid.." deposited $"..amount.." from "..moneytype.." to business balance")
    
    return true, "Successfully deposited $"..amount.." to business balance"
end

--- Withdraw money from the vapeshop business balance
--- @param source number
--- @param moneytype string
--- @param amount number
--- @return boolean success
--- @return string message
function server.WithdrawMoneyFromBusiness(source, moneytype, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return false, "Player not found" end

    if not server.DoesPlayerOwnVapeshop(source) then return false, "You don't own a vapeshop" end

    if not amount or amount <= 0 then return false, "Invalid amount" end

    local businessBalance = server.GetVapeshopBalance(source)
    if businessBalance < amount then
        return false, "Insufficient business balance"
    end

    if moneytype ~= "cash" and moneytype ~= "bank" then
        return false, "Invalid money type"
    end

    if not server.RemoveVapeshopBalance(source, amount) then
        return false, "Failed to remove money from business balance"
    end

    local success = player.Functions.AddMoney(moneytype, amount, "withdraw-from-vapeshop")
    if not success then
        server.AddVapeshopBalance(source, amount)
        return false, "Failed to add money to player"
    end

    local citizenid = getCitizenId(source)
    print("^2[VD-Vapeshop] "..citizenid.." withdrew $"..amount.." from business balance to "..moneytype)
    
    return true, "Successfully withdrew $"..amount.." to your "..moneytype
end