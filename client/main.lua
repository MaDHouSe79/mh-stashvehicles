local config, PlayerData, newZones, blips = {}, {}, {}, {}
local isLoggedIn, inZone, listen = false, false, false

local function DeleteAllBlips()
    for k, v in pairs(blips) do
        if DoesBlipExist(v) then
            RemoveBlip(v)
        end
    end
end

local function CreateGarageBlip(coords)
    if config.UseBlips then
        local blip = AddBlipForCoord(coords)
        SetBlipHighDetail(blip, true)
        SetBlipSprite(blip, 524)
        SetBlipScale(blip, 0.5)
        SetBlipColour(blip, 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Lang:t('garage_stash_blip'))
        EndTextCommandSetBlipName(blip)
        blips[#blips + 1] = blip
    end
end

local function SpawnClear(coords, radius)
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(PlayerPedId())
    end
    local vehicles = GetGamePool('CVehicle')
    local closeVeh = {}
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)
        if distance <= radius then
            closeVeh[#closeVeh + 1] = vehicles[i]
        end
    end
    if #closeVeh > 0 then return false end
    return true
end

local function getClosestGarageId()
    local coords = GetEntityCoords(PlayerPedId())
    for k, zone in pairs(config.StashLocations) do
        if #(zone.coords - coords) < config.GarageInteractDistance then
            return k
        end
    end
    return nil
end

local function GetVehicles()
    if isLoggedIn then
        local closestGarage = getClosestGarageId()
        if inZone and closestGarage ~= nil then
            TriggerCallback("mh-stashvehicles:server:GetVehicles", function(vehicles)
                local menu = {{ header = Lang:t('vehicle_storage'), isMenuHeader = true}}
                if IsPedInAnyVehicle(PlayerPedId()) then
                    menu[#menu + 1] = {
                        header = Lang:t('park_vehicle'),
                            params = {
                            event = 'mh-stashvehicles:client:storeVehicle',
                            args = {garage = closestGarage}
                        },
                    }
                else
                    if #vehicles >= 1 then
                        for k, vehicle in pairs(vehicles) do
                            if vehicle.garage == closestGarage then
                                local imageLocation = exports['mh-vehicleimages']:GetImage(vehicle.vehicle)
                                menu[#menu + 1] = {
                                    header = vehicle.vehicle,
                                    icon = imageLocation,
                                    txt = "",
                                    params = {
                                        event = 'mh-stashvehicles:client:takeOutVehicle',
                                        args = {
                                            vehicle = vehicle.vehicle,
                                            plate = vehicle.plate,
                                            fuel = vehicle.fuel,
                                            body = vehicle.body,
                                            engine = vehicle.engine,
                                            garage = vehicle.garage
                                        },
                                    },
                                }
                            end
                        end
                    end
                end
                menu[#menu + 1] = {header = Lang:t('close'), params = {event = ''}}
                exports['qb-menu']:openMenu(menu)
            end)
        end
    end
end

local function Take(data)
    local spawnLocation = vector3(config.StashLocations[data.garage].spawn.x, config.StashLocations[data.garage].spawn.y, config.StashLocations[data.garage].spawn.z)
    local spawnHeading = config.StashLocations[data.garage].spawn.w
    if spawnLocation then
        if not SpawnClear(spawnLocation, 5.0) then
            Notify(Lang:t('area_obstructed'), 'error', 5000)
        else
            TriggerCallback("mh-stashvehicles:server:Delete", function(isDeleted, _vehicle)
                if isDeleted then
                    LoadModel(_vehicle.vehicle)
                    local vehicle = CreateVehicle(_vehicle.vehicle, spawnLocation.x, spawnLocation.y, spawnLocation.z, spawnLocation.w, true)
                    SetEntityAsMissionEntity(vehicle, true, true)
                    RequestCollisionAtCoord(spawnLocation.x, spawnLocation.y, spawnLocation.z)
                    SetVehicleOnGroundProperly(vehicle)
                    SetVehicleProperties(vehicle, _vehicle.mods)
                    SetVehicleNumberPlateText(vehicle, _vehicle.plate)
                    SetEntityHeading(vehicle, spawnHeading)
                    SetVehRadioStation(vehicle,'OFF')
                    SetVehicleDirtLevel(vehicle, 0)
                    SetVehicleDoorsLocked(vehicle, 0)
                    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', _vehicle.plate)
                    TriggerServerEvent('mh-stashvehicles:server:Delete', _vehicle.plate)
                    exports['qb-menu']:closeMenu()
                    exports[config.FuelScript]:SetFuel(vehicle, 100.0)
                end
            end, data.plate)
        end
    end
end

local function Store()
    local veh = GetVehiclePedIsIn(PlayerPedId())
    local props = GetVehicleProperties(veh)
    local model = config.Vehicles[(GetEntityModel(veh))].name:lower()
    local hash = GetHashKey(model)
    local plate = GetPlate(veh)
    local garage = getClosestGarageId()
    if garage ~= nil then
        local data = {mods = props, plate = plate, vehicle = model, hash = hash, garage = garage}
        SetEntityAsMissionEntity(veh, true, true)
        TriggerCallback("mh-stashvehicles:server:Save", function(isSaved)
            if isSaved then
                SetVehicleEngineOn(veh, false, false, true)
                TaskLeaveVehicle(PlayerPedId(), veh, 1)
                while IsPedInAnyVehicle(PlayerPedId(), false) do Wait(100) end
                RequestAnimSet("anim@mp_player_intmenu@key_fob@")
                TaskPlayAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false)
                Wait(500)
                ClearPedTasks(PlayerPedId())
                SetVehicleLights(veh, 2)
                Wait(150)
                SetVehicleLights(veh, 0)
                Wait(150)
                SetVehicleLights(veh, 2)
                Wait(150)
                SetVehicleLights(veh, 0)
                TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
                Wait(1000)
                DeleteEntity(veh)
            end
        end, data)
    end
end

local function listenForControl()
    if listen then return end
    CreateThread(function()
        listen = true
        while listen do
            if IsControlJustPressed(0, 38) then -- E
                exports['qb-core']:KeyPressed()
                TriggerEvent('mh-stashvehicles:client:getVehicles')
                listen = false
                break
            end
            Wait(0)
        end
    end)
end

local function LoadZone(zones)
    CreateThread(function()
        if isLoggedIn then
            if PlayerData.job.type ~= nil and not config.IngoreJobs[PlayerData.job.type] then
                for k, zone in pairs(zones) do
                    CreateGarageBlip(zone.coords)
                    newZones[#newZones + 1] = CircleZone:Create(vector3(zone.coords.x, zone.coords.y, zone.coords.z), zone.scale, {useZ = true, debugPoly = false})
                end
                local combo = ComboZone:Create(newZones, {name = 'RandomZOneName', debugPoly = false})
                combo:onPlayerInOut(function(isPointInside, _, zone)
                    if isPointInside then
                        if not inZone then
                            inZone = true
                            exports['qb-core']:DrawText(Lang:t('press_open_garage'))
                        end
                        listenForControl()
                    else
                        if inZone then
                            inZone = false
                            listen = false
                            exports['qb-core']:HideText()
                        end
                    end
                end)
            end
        end
    end)
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerCallback("mh-stashvehicles:server:onjoin", function(data)
            config = data
            Wait(10)
            PlayerData = Framework.Functions.GetPlayerData()
            isLoggedIn = true
            LoadZone(config.StashLocations)
        end)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerData = {}
        isLoggedIn = false
        if config.UseBlips then DeleteAllBlips() end
    end
end)

AddEventHandler(OnPlayerLoaded, function()
    TriggerCallback("mh-stashvehicles:server:onjoin", function(data)
        PlayerData = Framework.Functions.GetPlayerData()
        isLoggedIn = true
        config = data
        LoadZone(config.StashLocations)
    end)
end)

RegisterNetEvent(OnPlayerUnload, function()
    PlayerData = {}
    isLoggedIn = false
    if config.UseBlips then DeleteAllBlips() end
end)

RegisterNetEvent(SetDuty, function(onduty)
    PlayerData.job.onduty = onduty
end)

RegisterNetEvent(OnJobUpdate, function(job)
    PlayerData.job = job
end)

RegisterNetEvent('mh-stashvehicles:client:takeOutVehicle', function(data)
    if not IsPedInAnyVehicle(PlayerPedId()) then Take(data) end
end)

RegisterNetEvent('mh-stashvehicles:client:storeVehicle', function(data)
    if IsPedInAnyVehicle(PlayerPedId()) then Store() end
end)

RegisterNetEvent('mh-stashvehicles:client:getVehicles', function()
    GetVehicles()
end)