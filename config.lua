config = {}

config.InteractionLocation = vector3(0, 0, 0)

config.Currency = "business" --[[
    business = Takes money from the business balance
    bank = Take money from your bank account
    cash = Takes money from your inventory
]]

config.ShopPrice = 50000

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