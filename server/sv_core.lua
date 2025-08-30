--[[ ===================================================== ]] --
--[[               MH Parking V2 by MaDHouSe79             ]] --
--[[ ===================================================== ]] --
Framework, CreateCallback, AddCommand = nil, nil, nil
if GetResourceState("es_extended") ~= 'missing' then
    SV_Config.Framework = 'esx'
    Framework = exports['es_extended']:getSharedObject()
    CreateCallback = Framework.RegisterServerCallback
    function GetPlayer(source) return Framework.GetPlayerFromId(source) end
    function GetJob(source) return Framework.GetPlayerFromId(source).job end
    function GetCitizenId(src) local xPlayer = GetPlayer(src) return xPlayer.identifier end
    function GetCitizenFullname(src) local xPlayer = GetPlayer(src) return xPlayer.name end
elseif GetResourceState("qb-core") ~= 'missing' then
    SV_Config.Framework = 'qb'
    Framework = exports['qb-core']:GetCoreObject()
    CreateCallback = Framework.Functions.CreateCallback
    function GetPlayer(source) return Framework.Functions.GetPlayer(source) end
    function GetJob(source) return Framework.Functions.GetPlayer(source).PlayerData.job end
    function GetPlayerDataByCitizenId(citizenid) return Framework.Functions.GetPlayerByCitizenId(citizenid) or Framework.Functions.GetOfflinePlayerByCitizenId(citizenid) end
    function GetCitizenId(src) local xPlayer = GetPlayer(src) return xPlayer.PlayerData.citizenid end
    function GetCitizenFullname(src) local xPlayer = GetPlayer(src) return xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname end
end

function Notify(src, message, type, length)
    if GetResourceState("ox_lib") ~= 'missing' then
        lib.notify(src, {title = "MH Stash Vehicles", description = message, type = type})
    else
        if GetResourceState("qb-core") ~= 'missing' then
            Framework.Functions.Notify(src, {text = "MH Stash Vehicles", caption = message}, type, length)
        end
    end
end