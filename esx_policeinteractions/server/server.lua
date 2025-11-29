-- server.lua
local function GetPlayer(source)
    return exports.ox_core:GetPlayer(source)
end

RegisterServerEvent('esx_policeinteractions:handcufftargetid')
AddEventHandler('esx_policeinteractions:handcufftargetid', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    TriggerClientEvent('esx_policeinteractions:targetcloseplayer', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('esx_policeinteractions:player', _source)
end)

RegisterServerEvent('esx_policeinteractions:allunlockcuff')
AddEventHandler('esx_policeinteractions:allunlockcuff', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    local player = GetPlayer(_source)

    TriggerClientEvent('esx_policeinteractions:getuncuffed', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('esx_policeinteractions:douncuffing', _source)
    exports.ox_inventory:AddItem(_source, 'handcuff', 1)
end)

RegisterServerEvent('esx_policeinteractions:feetunlockcuff')
AddEventHandler('esx_policeinteractions:feetunlockcuff', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    local player = GetPlayer(_source)

    TriggerClientEvent('esx_policeinteractions:getuncuffed', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('esx_policeinteractions:douncuffing', _source)
    exports.ox_inventory:AddItem(_source, 'footcuff', 1)
end)

RegisterServerEvent('esx_policeinteractions:requestarrest')
AddEventHandler('esx_policeinteractions:requestarrest', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    TriggerClientEvent('esx_policeinteractions:getarrested', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('esx_policeinteractions:doarrested', _source)
end)

RegisterServerEvent("esx_policeinteractions:removehandcuff")
AddEventHandler("esx_policeinteractions:removehandcuff", function(Target)
    local _source = source
    local count = exports.ox_inventory:GetItem(_source, 'handcuff', nil, true)
    
    if count >= 1 then
        exports.ox_inventory:RemoveItem(_source, 'handcuff', 1)
        TriggerClientEvent('esx_policeinteractions:re', _source)
    else
        TriggerClientEvent('esx_policeinteractions:uncuff', _source)
    end
end)

RegisterServerEvent("esx_policeinteractions:removefeetcuff")
AddEventHandler("esx_policeinteractions:removefeetcuff", function(Target)
    local _source = source
    local count = exports.ox_inventory:GetItem(_source, 'footcuff', nil, true)
    
    if count >= 1 then
        exports.ox_inventory:RemoveItem(_source, 'footcuff', 1)
        TriggerClientEvent('esx_policeinteractions:ft', _source)
    else
        TriggerClientEvent('esx_policeinteractions:uncufffeet', _source)
    end
end)

RegisterServerEvent('esx_policeinteractions:attachPlayer', function(who, anim)
    local _source = source
    TriggerClientEvent('esx_policeinteractions:doAnimation', _source, anim)
    TriggerClientEvent('esx_policeinteractions:getDragged', who, _source, anim)
end)

RegisterNetEvent('esx_policeinteractions:putInVehicle')
AddEventHandler('esx_policeinteractions:putInVehicle', function(target)
    local _source = source
    local player = GetPlayer(_source)

    if player.getGroup() == 'police' then
        TriggerClientEvent('esx_policeinteractions:putInVehicle', target)
    end
end)

RegisterNetEvent('esx_policeinteractions:OutVehicle')
AddEventHandler('esx_policeinteractions:OutVehicle', function(target)
    local _source = source
    local player = GetPlayer(_source)

    if player.getGroup() == 'police' then
        TriggerClientEvent('esx_policeinteractions:OutVehicle', target)
    else
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit Dragging Out Of Vehicle!'):format(_source))
    end
end)

RegisterNetEvent('esx_policeinteractions:sech')
AddEventHandler('esx_policeinteractions:sech', function(target)
    local _source = source
    local player = GetPlayer(_source)

    if player.getGroup() == 'police' then
        TriggerClientEvent('esx_policeinteractions:sech', target)
    else
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit Dragging Out Of Vehicle!'):format(_source))
    end
end)