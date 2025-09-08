# VD-Vapeshop

[![Join Discord](https://img.shields.io/badge/Join%20Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/HzmPyDrVUS)

A comprehensive vapeshop system for QBCore with business management, stock tracking, and automated sales.

## Features

- **Business Management**: Purchase and manage your own vapeshop
- **Stock System**: Track vape inventory with visual NUI dashboard
- **Automated Sales**: Random NPC sales generate passive income
- **Business Balance**: Separate business funds from personal money
- **Purchase Cooldowns**: Prevent spam purchasing
- **Configurable Settings**: Easy customization through config file
- **Export System**: API for other scripts to interact with vapeshops

## Installation

1. Place the `vd-vapeshop` folder in your `resources` directory
2. Add `ensure vd-vapeshop` to your `server.cfg`
3. Configure settings in `config.lua`
4. Restart your server

## Configuration

### Basic Settings

```lua
config.ShopPrice = 50000 -- Initial vapeshop purchase price
config.Currency = "cash" -- Currency for initial purchase (cash/bank)
config.StartingBalance = 33 -- Starting business balance for new shops
config.MaxBusinessBalance = 999999999 -- Maximum business balance (prevents overflow)
```

### Purchase Cooldown

```lua
config.PurchaseCooldown = 30 -- Seconds between vape shipment purchases
```

### Sales System

```lua
config.SalesCheckInterval = 30000 -- How often to check for sales (milliseconds)
config.SalesChance = 6 -- 1 in X chance for a sale each check
config.MinSaleQuantity = 1 -- Minimum vapes sold per sale
config.MaxSaleQuantity = 3 -- Maximum vapes sold per sale
```

### Blip Settings

```lua
config.Blip = {
    label = "Vapeshop Business",
    sprite = 140,
    colour = 3,
    scale = 1.0,
    location = vector3(416.6877, -217.5833, 59.9104)
}
```

### Vape Configuration

The script includes 6 different vape types:

```lua
config.Vapes = {
    {
        name = "Basic Vape",
        price = 650,
        shipment = { vapecount = 15, price = 7500 }
    },
    {
        name = "Mint Breeze Vape", 
        price = 700,
        shipment = { vapecount = 20, price = 14000 }
    },
    {
        name = "Blueberry Chill Vape",
        price = 850, 
        shipment = { vapecount = 18, price = 16000 }
    },
    {
        name = "Mango Burst Vape",
        price = 950,
        shipment = { vapecount = 22, price = 20000 }
    },
    {
        name = "Watermelon Ice Vape",
        price = 1100,
        shipment = { vapecount = 25, price = 24000 }
    },
    {
        name = "Premium Gold Vape",
        price = 1500,
        shipment = { vapecount = 30, price = 42000 }
    }
}
```

## Usage

### For Players

1. **Purchase a Vapeshop**: Go to the vapeshop location and interact with "Purchase"
2. **Manage Your Shop**: Use "Manage Shop" to open the dashboard
3. **Buy Shipments**: Purchase vape shipments using your business balance
4. **Monitor Sales**: Watch your stock and balance grow from automated sales
5. **Withdraw/Deposit**: Manage money between personal and business accounts

### For Developers

The script provides a comprehensive export system for other scripts to interact with vapeshops.

## Exports API

### Player Ownership & Balance

#### `DoesPlayerOwnVapeshop(source)`
- **Description**: Check if a player owns a vapeshop
- **Parameters**: `source` (number) - Player source ID
- **Returns**: `boolean` - True if player owns a vapeshop

#### `GetVapeshopBalance(source)`
- **Description**: Get a player's vapeshop business balance
- **Parameters**: `source` (number) - Player source ID
- **Returns**: `number` - Business balance amount

#### `AddVapeshopBalance(source, amount)`
- **Description**: Add money to a player's vapeshop business balance
- **Parameters**: `source` (number), `amount` (number)
- **Returns**: `boolean` - Success status

#### `RemoveVapeshopBalance(source, amount)`
- **Description**: Remove money from a player's vapeshop business balance
- **Parameters**: `source` (number), `amount` (number)
- **Returns**: `boolean` - Success status

#### `SetVapeshopBalance(source, amount)`
- **Description**: Set a player's vapeshop business balance to a specific amount
- **Parameters**: `source` (number), `amount` (number)
- **Returns**: `boolean` - Success status

### Stock Management

#### `GetPlayerVapeshopStock(source)`
- **Description**: Get a player's vapeshop stock data
- **Parameters**: `source` (number) - Player source ID
- **Returns**: `table` - Stock data with vape names and quantities

#### `AddVapeshopStock(source, vapeName, quantity)`
- **Description**: Add vapes to a player's vapeshop stock
- **Parameters**: `source` (number), `vapeName` (string), `quantity` (number)
- **Returns**: `boolean` - Success status

#### `RemoveVapeshopStock(source, vapeName, quantity)`
- **Description**: Remove vapes from a player's vapeshop stock
- **Parameters**: `source` (number), `vapeName` (string), `quantity` (number)
- **Returns**: `boolean` - Success status

### Vape Configuration

#### `GetVapeConfig(vapeName)`
- **Description**: Get vape configuration by name
- **Parameters**: `vapeName` (string) - Name of the vape
- **Returns**: `table` - Vape configuration or nil if not found

#### `GetAllVapeConfigs()`
- **Description**: Get all vape configurations
- **Returns**: `table` - All vape configurations

### Shop Management

#### `CanAffordVapeshop(source)`
- **Description**: Check if a player can afford a vapeshop
- **Parameters**: `source` (number) - Player source ID
- **Returns**: `boolean` - True if player can afford it

#### `PurchaseVapeshop(source)`
- **Description**: Purchase a vapeshop for a player (bypasses normal purchase flow)
- **Parameters**: `source` (number) - Player source ID
- **Returns**: `boolean, string` - Success status and message

### Statistics & Admin

#### `GetVapeshopStats(source)`
- **Description**: Get vapeshop statistics for a player
- **Parameters**: `source` (number) - Player source ID
- **Returns**: `table` - Statistics including balance, stock count, total value

#### `ForceRandomSale(source)`
- **Description**: Force a random sale for a player's vapeshop
- **Parameters**: `source` (number) - Player source ID
- **Returns**: `boolean, string` - Success status and message

#### `GetAllVapeshopOwners()`
- **Description**: Get all vapeshop owners (for admin purposes)
- **Returns**: `table` - List of citizenids who own vapeshops

#### `GetVapeshopByCitizenId(citizenid)`
- **Description**: Get vapeshop data by citizenid (for admin purposes)
- **Parameters**: `citizenid` (string) - Citizen ID
- **Returns**: `table` - Vapeshop data or nil

## Export Usage Examples

### Basic Stock Management
```lua
-- Add 5 Basic Vapes to player's stock
local success = exports['vd-vapeshop']:AddVapeshopStock(source, "Basic Vape", 5)

-- Remove 2 Premium Gold Vapes from player's stock
local success = exports['vd-vapeshop']:RemoveVapeshopStock(source, "Premium Gold Vape", 2)
```

### Balance Management
```lua
-- Add $1000 to player's business balance
local success = exports['vd-vapeshop']:AddVapeshopBalance(source, 1000)

-- Check if player has enough balance
local balance = exports['vd-vapeshop']:GetVapeshopBalance(source)
if balance >= 5000 then
    -- Player has enough money
end
```

### Admin Functions
```lua
-- Get all vapeshop owners
local owners = exports['vd-vapeshop']:GetAllVapeshopOwners()

-- Get specific player's vapeshop data
local vapeshopData = exports['vd-vapeshop']:GetVapeshopByCitizenId("ABC12345")

-- Force a sale for a player
local success, message = exports['vd-vapeshop']:ForceRandomSale(source)
```

### Statistics
```lua
-- Get comprehensive stats for a player
local stats = exports['vd-vapeshop']:GetVapeshopStats(source)
if stats then
    print("Balance: $" .. stats.balance)
    print("Total Stock: " .. stats.totalStock)
    print("Total Value: $" .. stats.totalValue)
end
```

## Dependencies

- `qb-core`
- `ox_lib`
- `ox_target`
- `oxmysql`

## Database

The script automatically creates a `vd_vapeshop` table with the following structure:
- `citizenid` (VARCHAR) - Player's citizen ID
- `balance` (INT) - Business balance
- `stock_data` (TEXT) - JSON encoded stock data

## Notes

- All exports return `false` or `nil` if the player doesn't own a vapeshop (where applicable)
- Stock operations automatically update the database
- Balance operations include validation to prevent negative balances
- All exports are server-side only
- Make sure to handle errors appropriately in your scripts

## Support

For issues or questions, please check the configuration and ensure all dependencies are properly installed.