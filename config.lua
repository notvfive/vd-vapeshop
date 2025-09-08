config = {}

config.Interactions = {
    --- Icons from : https://fontawesome.com/
    Purchase = {
        name = "Purchase",
        event = "vd-vapeshop:client:PurchaseShop",
        location = vector3(416.6877, -217.5833, 59.9104),
        icon = "fa-regular fa-building"
    },
    Shopmanage = {
        name = "Manage Shop",
        event = "vd-vapeshop:client:Shopmanage",
        location = vector3(413.8383, -216.4820, 59.9104),
        icon = "fa-solid fa-laptop"
    }
}

config.Currency = "cash" --[[
    NOTE: This currency setting fuckin only applies to the initial vapeshop purchase
    All other purchases (vape shipments, etc.) use the business balance
    
    business = Takes money from the business balance (for initial purchase only)
    bank = Take money from your bank account (for initial purchase only)
    cash = Takes money from your inventory (for initial purchase only)
]]

config.ShopPrice = 50000
config.PurchaseCooldown = 30 -- Seconds between vape shipment purchases
config.SalesCheckInterval = 30000 -- How often to check for sales (milliseconds)
config.SalesChance = 6 -- 1 in X chance for a sale each check (lower = more frequent)
config.MinSaleQuantity = 1 -- Minimum vapes sold per sale
config.MaxSaleQuantity = 3 -- Maximum vapes sold per sale
config.StartingBalance = 33 -- Starting business balance for new vapeshops (Default $0, Because fuck em')
config.MaxBusinessBalance = 999999999 -- Maximum business balance (prevents overflow)

config.Vapes = {
    --[[
        Base from: shipment price / shipment vapecount = base price
    ]]
    
    {
        name = "Basic Vape",
        price = 650,
        shipment = {
            vapecount = 15,
            price = 7500
        }
    },
    {
        name = "Mint Breeze Vape",
        price = 700,
        shipment = {
            vapecount = 20,
            price = 14000
        }
    },
    {
        name = "Blueberry Chill Vape",
        price = 850,
        shipment = {
            vapecount = 18,
            price = 16000
        }
    },
    {
        name = "Mango Burst Vape",
        price = 950,
        shipment = {
            vapecount = 22,
            price = 20000
        }
    },
    {
        name = "Watermelon Ice Vape",
        price = 1100,
        shipment = {
            vapecount = 25,
            price = 24000
        }
    },
    {
        name = "Premium Gold Vape",
        price = 1500,
        shipment = {
            vapecount = 30,
            price = 42000
        }
    },
}


--[[
Happy vaping you fucking addicts.
Did you know vaping has been medically linked to permanent and irreversable lung cancer,
Unlike ciggies where if you stop your lungs get better, your lungs wont get better even if you 
were to stop vaping.

Fucking fiends.
]]