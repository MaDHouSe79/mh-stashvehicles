--[[ ===================================================== ]] --
--[[               MH Parking V2 by MaDHouSe79             ]] --
--[[ ===================================================== ]] --
Framework, TriggerCallback, OnPlayerLoaded, OnPlayerUnload = nil, nil, nil, nil
OnJobUpdate, isLoggedIn, PlayerData, SetDuty = nil, false, {}, nil
if GetResourceState("es_extended") ~= 'missing' then
    Framework = exports['es_extended']:getSharedObject()
    TriggerCallback = Framework.TriggerServerCallback
    OnPlayerLoaded = 'esx:playerLoaded'
    OnPlayerUnload = 'esx:playerUnLoaded'
    OnJobUpdate = 'esx:setJob'
    SetDuty = ''
    function GetPlayerData() TriggerCallback('esx:getPlayerData', function(data) PlayerData = data end) return PlayerData end
elseif GetResourceState("qb-core") ~= 'missing' then
    Framework = exports['qb-core']:GetCoreObject()
    TriggerCallback = Framework.Functions.TriggerCallback
    OnPlayerLoaded = 'QBCore:Client:OnPlayerLoaded'
    OnPlayerUnload = 'QBCore:Client:OnPlayerUnload'
    OnJobUpdate = 'QBCore:Client:OnJobUpdate'
    SetDuty = 'QBCore:Client:SetDuty'
    function GetPlayerData() return Framework.Functions.GetPlayerData() end
    RegisterNetEvent('QBCore:Player:SetPlayerData', function(data) PlayerData = data end)
    RegisterNetEvent('QBCore:Client:UpdateObject', function() Framework = exports['qb-core']:GetCoreObject() end)
end

function Notify(message, type, length)
    if GetResourceState("ox_lib") ~= 'missing' then
        lib.notify({title = "MH Stash Vehicles", description = message, type = type})
    else
        if GetResourceState("qb-core") ~= 'missing' then
            Framework.Functions.Notify({text = "MH Stash Vehicles", caption = message}, type, length)
        end
    end
end

function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(1)
    end
end