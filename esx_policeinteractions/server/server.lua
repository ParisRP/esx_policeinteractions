local function GetPlayer(source)
    return exports.ox_core:GetPlayer(source)
end

RegisterServerEvent('policeinteractions:handcufftargetid')
AddEventHandler('policeinteractions:handcufftargetid', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    TriggerClientEvent('policeinteractions:targetcloseplayer', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('policeinteractions:player', _source)
end)

RegisterServerEvent('policeinteractions:allunlockcuff')
AddEventHandler('policeinteractions:allunlockcuff', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    local player = GetPlayer(_source)

    TriggerClientEvent('policeinteractions:getuncuffed', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('policeinteractions:douncuffing', _source)
    exports.ox_inventory:AddItem(_source, 'handcuff', 1)
end)

RegisterServerEvent('policeinteractions:feetunlockcuff')
AddEventHandler('policeinteractions:feetunlockcuff', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    local player = GetPlayer(_source)

    TriggerClientEvent('policeinteractions:getuncuffed', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('policeinteractions:douncuffing', _source)
    exports.ox_inventory:AddItem(_source, 'footcuff', 1)
end)

RegisterServerEvent('policeinteractions:requestarrest')
AddEventHandler('policeinteractions:requestarrest', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    TriggerClientEvent('policeinteractions:getarrested', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('policeinteractions:doarrested', _source)
end)

RegisterServerEvent("policeinteractions:removehandcuff")
AddEventHandler("policeinteractions:removehandcuff", function()
    local _source = source
    local count = exports.ox_inventory:GetItem(_source, 'handcuff', nil, true)
    
    if count and count >= 1 then
        exports.ox_inventory:RemoveItem(_source, 'handcuff', 1)
        TriggerClientEvent('policeinteractions:re', _source)
    else
        TriggerClientEvent('policeinteractions:uncuff', _source)
    end
end)

RegisterServerEvent("policeinteractions:removefeetcuff")
AddEventHandler("policeinteractions:removefeetcuff", function()
    local _source = source
    local count = exports.ox_inventory:GetItem(_source, 'footcuff', nil, true)
    
    if count and count >= 1 then
        exports.ox_inventory:RemoveItem(_source, 'footcuff', 1)
        TriggerClientEvent('policeinteractions:ft', _source)
    else
        TriggerClientEvent('policeinteractions:uncufffeet', _source)
    end
end)

RegisterServerEvent('policeinteractions:attachPlayer')
AddEventHandler('policeinteractions:attachPlayer', function(who, anim)
    local _source = source
    TriggerClientEvent('policeinteractions:doAnimation', _source, anim)
    TriggerClientEvent('policeinteractions:getDragged', who, _source, anim)
end)

RegisterNetEvent('policeinteractions:putInVehicle')
AddEventHandler('policeinteractions:putInVehicle', function(target)
    local _source = source
    local player = GetPlayer(_source)

    if player and player.groups and player.groups.police then
        TriggerClientEvent('policeinteractions:putInVehicle', target)
    else
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit Put In Vehicle!'):format(_source))
    end
end)

RegisterNetEvent('policeinteractions:OutVehicle')
AddEventHandler('policeinteractions:OutVehicle', function(target)
    local _source = source
    local player = GetPlayer(_source)

    if player and player.groups and player.groups.police then
        TriggerClientEvent('policeinteractions:OutVehicle', target)
    else
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit Dragging Out Of Vehicle!'):format(_source))
    end
end)

RegisterNetEvent('policeinteractions:sech')
AddEventHandler('policeinteractions:sech', function(target)
    local _source = source
    local player = GetPlayer(_source)

    if player and player.groups and player.groups.police then
        TriggerClientEvent('policeinteractions:sech', target)
    else
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit Search!'):format(_source))
    end
end)
