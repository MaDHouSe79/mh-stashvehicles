SV_Config = {}
SV_Config.Vehicles = Vehicles                                 -- Do not change this.
--
SV_Config.UseBlips = false                                    -- Default false, you can use it but than everybody know where the garages are.
SV_Config.FuelScript = "LegacyFuel"                           -- Fuel system
SV_Config.InventoryImagesFolder = "qb-inventory/html/images/" -- Base images folder
SV_Config.GarageInteractDistance = 3.0                        -- Menu interact distance
SV_Config.ParkLimitPerGarage = 2                              -- Don't set this to high, keep it as low as posible.
--
SV_Config.UsePayment = false                                  -- When true player need to play cash to store a vehicle.
SV_Config.MoneySign = "$"                                     -- Use $ or € 
SV_Config.MoneyType = 'cash'                                  -- Default cash but you can use black_money aswell if you use mh-cashasitem
SV_Config.StorePayment = 1000                                 -- Payment amount 
SV_Config.MaxStoredDays = 5                                   -- When a player does not interact longer than this amount of days, this vehicle will be automatically deleted.
--
SV_Config.IngoreJobs = {
    ['leo'] = true,
    ['ems'] = true,
    ['mechanic'] = true,
}
--
SV_Config.StashLocations = {
    {
        coords = vector3(-25.5228, -1427.0597, 30.4820),          -- Location of the garage
        spawn = vector4(-25.1015, -1436.1057, 30.4749, 180.9227), -- Spawnpoint for the garage
        scale = 3,0                                               -- Radius where you can interact with the menu
    },
    {
        coords = vector3(-27.3867, -1493.4955, 30.1846),
        spawn = vector4(-27.3867, -1493.4955, 30.1846, 139.8771),
        scale = 3,0
    },
    {
        coords = vector3(1968.5634, 3821.8318, 32.2194),
        spawn = vector4(1977.1984, 3827.3494, 32.1933, 301.2354),
        scale = 3,0
    },
    {
        coords = vector3(758.6945, -1865.6864, 28.8821),
        spawn = vector4(758.6945, -1865.6864, 28.8821, 265.1734),
        scale = 3,0
    },
}
