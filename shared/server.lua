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


--- Helper: get citizenid from a source
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
    if not citizenid then return nil end

    local exists = mysql.scalar.await(
        'SELECT 1 FROM vd_vapeshop WHERE citizenid = ?',
        { citizenid }
    )

    return exists ~= nil
end

--- Get player's vapeshop balance
--- @param source number
--- @return number balance Returns 0 if the player doesn't own a vapeshop or doesn't exist
function server.GetVapeshopBalance(source)
    local citizenid = getCitizenId(source)
    if not citizenid then return 0 end

    local balance = mysql.scalar.await(
        'SELECT balance FROM vd_vapeshop WHERE citizenid = ?',
        { citizenid }
    )

    return balance or 0
end

--[[
--- Check if player can afford vapeshop
--- @param source number
--- @return boolean canAfford
function server.CanAffordVapeshop(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    if config.Currency == "cash" then
        if Player.money.cash >= config.ShopPrice then
            return true
        else
            return false
        end
    elseif config.Currency == "bank" then
        if Player.money.bank >= config.ShopPrice then
            return true
        else
            return false
        end
    else
        return false
    end

    return false
end
]]

--- Check if player can afford vapeshop
--- @param source number
--- @return boolean canAfford
function server.CanAffordVapeshop(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return false end

    local currency = config.Currency
    local amount = config.ShopPrice

    if currency == "cash" then
        return (player.money.cash or 0) >= amount
    elseif currency == "bank" then
        return (player.money.bank or 0) >= amount
    else
        return false
    end
end

--- Purchase vapeshop
--- @param source number The player's server ID
--- @return boolean success Returns true if it was bought, false if not
function server.PurchaseVapeshop(source)
    local player = QBCore.Functions.GetPlayer(source)
    local cid = getCitizenId(source)
    if not player or not cid then return false end

    if server.DoesPlayerOwnVapeshop(source) then return false end

    if not server.CanAffordVapeshop(source) then return false end

    local success, result = pcall(function()
        return mysql.insert.await("INSERT INTO vd_vapeshop (citizenid) VALUES (?)", { cid })
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
        return true
    else
        print("^1[VD-Vapeshop] Failed to purchase vapeshop for "..cid..": "..tostring(result))
        return false
    end
end