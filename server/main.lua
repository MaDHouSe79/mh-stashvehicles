local function CleanUpDatabase()
    local result = MySQL.query.await('SELECT * FROM stached_vehicles')
    for _, data in pairs(result) do
        local time = MySQL.scalar.await("SELECT DATEDIFF(NOW(), `last_updated`) FROM `stached_vehicles` WHERE id = ?",{data.id})
        if time >= SV_Config.MaxStoredDays then MySQL.Async.execute('DELETE FROM stached_vehicles WHERE plate = ? LIMIT 1', {data.plate}) end
    end
end
AddEventHandler('onResourceStart', function(resource) if resource == GetCurrentResourceName() then CleanUpDatabase() end end)

CreateCallback("mh-stashvehicles:server:GetVehicles", function(source, cb)
    local vehicles = {}
    local result = MySQL.query.await('SELECT * FROM stached_vehicles')
    for _k, v in pairs(result) do vehicles[#vehicles + 1] = { vehicle = v.vehicle, hash= v.hash, plate = v.plate, mods = v.mods, garage=v.garage} end
    if vehicles then cb(vehicles) else cb(nil) end
end)

CreateCallback("mh-stashvehicles:server:Save", function(source, cb, data)
    local src = source
    local Player = GetPlayer(src)
    local isSaved = false
    if Player then
        local payment = SV_Config.StorePayment
        if not SV_Config.UsePayment then payment = 0 end
        if Player.Functions.GetMoney(SV_Config.MoneyType) >= SV_Config.StorePayment then
            local citizenid = GetCitizenId(src)
            local count = MySQL.query.await('SELECT * FROM stached_vehicles WHERE citizenid = ? AND garage = ?', {citizenid, data.garage})
            if #count < SV_Config.ParkLimitPerGarage then
                local vehicles = MySQL.query.await('SELECT * FROM stached_vehicles WHERE plate = ? LIMIT 1', {data.plate})
                local found = false
                for _, v in pairs(vehicles) do if v.plate == data.plate then found = true end end
                if not found then
                    if payment >= 1 then Player.Functions.RemoveMoney(SV_Config.MoneyType, payment) end
                    MySQL.Async.execute("INSERT INTO stached_vehicles (garage, citizenid, plate, vehicle, hash, mods) VALUES (?, ? , ?, ?, ?, ?)", {data.garage, citizenid, data.plate, data.vehicle, data.hash, json.encode(data.mods)})
                    isSaved = true
                else
                    Notify(src, Lang:t('already_stored'))
                end
            elseif #count >= SV_Config.ParkLimitPerGarage then
                Notify(src, Lang:t('limit_reached'))
            end
        else
            if payment >= 1 then Notify(src, Lang:t('no_money', {amount = payment})) end
        end
    end
    cb(isSaved)
end)

CreateCallback("mh-stashvehicles:server:Delete", function(source, cb, plate)
    local src = source
    local Player = GetPlayer(src)
    local isDeleted = false
    local vehicle = nil
    if Player then
        local citizenid = GetCitizenId(src)
        vehicle = MySQL.query.await('SELECT * FROM stached_vehicles WHERE plate = ? LIMIT 1', {plate})[1]
        if vehicle.citizenid ~= citizenid then
            Notify(src, Lang:t('not_your_vehicle'))
        else
            if vehicle.plate == plate then
                MySQL.Async.execute('DELETE FROM stached_vehicles WHERE plate = ? LIMIT 1', {plate})
                isDeleted = true
            end
        end
    end
    cb(isDeleted, vehicle)
end)

CreateCallback("mh-stashvehicles:server:onjoin", function(source, cb)
    cb(SV_Config)
end)

CreateThread(function()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `stached_vehicles` (
            `id` int(10) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
            `plate` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
            `vehicle` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
            `hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
            `mods` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
            `garage` int(15) DEFAULT 0,
            `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`id`) USING BTREE
        ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;
    ]])
end)