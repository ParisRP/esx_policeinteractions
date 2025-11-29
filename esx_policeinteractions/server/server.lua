local function GetPlayer(source)
    return exports.ox_core:GetPlayer(source)
end

-- Vérifier si le joueur est police
local function IsPlayerPolice(source)
    local player = GetPlayer(source)
    return player and player.groups and player.groups.police
end

-- Événement pour menotter un joueur
RegisterServerEvent('policeinteractions:handcufftargetid')
AddEventHandler('policeinteractions:handcufftargetid', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    
    if not IsPlayerPolice(_source) then
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Handcuff Without Police Job!'):format(_source))
        return
    end

    TriggerClientEvent('policeinteractions:targetcloseplayer', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('policeinteractions:player', _source)
end)

-- Événement pour enlever les menottes
RegisterServerEvent('policeinteractions:allunlockcuff')
AddEventHandler('policeinteractions:allunlockcuff', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    
    if not IsPlayerPolice(_source) then
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Unhandcuff Without Police Job!'):format(_source))
        return
    end

    TriggerClientEvent('policeinteractions:getuncuffed', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('policeinteractions:douncuffing', _source)
    exports.ox_inventory:AddItem(_source, 'handcuff', 1)
end)

-- Événement pour enlever les entraves
RegisterServerEvent('policeinteractions:feetunlockcuff')
AddEventHandler('policeinteractions:feetunlockcuff', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    
    if not IsPlayerPolice(_source) then
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Unlegcuff Without Police Job!'):format(_source))
        return
    end

    TriggerClientEvent('policeinteractions:getuncuffed', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('policeinteractions:douncuffing', _source)
    exports.ox_inventory:AddItem(_source, 'footcuff', 1)
end)

-- Événement pour arrêter un joueur
RegisterServerEvent('policeinteractions:requestarrest')
AddEventHandler('policeinteractions:requestarrest', function(targetid, playerheading, playerCoords, playerlocation)
    local _source = source
    
    if not IsPlayerPolice(_source) then
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Arrest Without Police Job!'):format(_source))
        return
    end

    TriggerClientEvent('policeinteractions:getarrested', targetid, playerheading, playerCoords, playerlocation)
    TriggerClientEvent('policeinteractions:doarrested', _source)
end)

-- Événement pour utiliser des menottes
RegisterServerEvent("policeinteractions:removehandcuff")
AddEventHandler("policeinteractions:removehandcuff", function()
    local _source = source
    
    if not IsPlayerPolice(_source) then
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Use Handcuff Without Police Job!'):format(_source))
        return
    end

    local count = exports.ox_inventory:GetItem(_source, 'handcuff', nil, true)
    
    if count and count >= 1 then
        exports.ox_inventory:RemoveItem(_source, 'handcuff', 1)
        TriggerClientEvent('policeinteractions:re', _source)
    else
        TriggerClientEvent('policeinteractions:uncuff', _source)
    end
end)

-- Événement pour utiliser des entraves
RegisterServerEvent("policeinteractions:removefeetcuff")
AddEventHandler("policeinteractions:removefeetcuff", function()
    local _source = source
    
    if not IsPlayerPolice(_source) then
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Use Footcuff Without Police Job!'):format(_source))
        return
    end

    local count = exports.ox_inventory:GetItem(_source, 'footcuff', nil, true)
    
    if count and count >= 1 then
        exports.ox_inventory:RemoveItem(_source, 'footcuff', 1)
        TriggerClientEvent('policeinteractions:ft', _source)
    else
        TriggerClientEvent('policeinteractions:uncufffeet', _source)
    end
end)

-- Événement pour escorter un joueur
RegisterServerEvent('policeinteractions:attachPlayer')
AddEventHandler('policeinteractions:attachPlayer', function(who, anim)
    local _source = source
    
    if not IsPlayerPolice(_source) then
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Escort Without Police Job!'):format(_source))
        return
    end

    TriggerClientEvent('policeinteractions:doAnimation', _source, anim)
    TriggerClientEvent('policeinteractions:getDragged', who, _source, anim)
end)

-- Événement pour mettre un joueur dans un véhicule
RegisterNetEvent('policeinteractions:putInVehicle')
AddEventHandler('policeinteractions:putInVehicle', function(target)
    local _source = source

    if not IsPlayerPolice(_source) then
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Put In Vehicle Without Police Job!'):format(_source))
        return
    end

    TriggerClientEvent('policeinteractions:putInVehicle', target)
end)

-- Événement pour sortir un joueur d'un véhicule
RegisterNetEvent('policeinteractions:OutVehicle')
AddEventHandler('policeinteractions:OutVehicle', function(target)
    local _source = source

    if not IsPlayerPolice(_source) then
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Take Out Vehicle Without Police Job!'):format(_source))
        return
    end

    TriggerClientEvent('policeinteractions:OutVehicle', target)
end)

-- Événement pour fouiller un joueur
RegisterNetEvent('policeinteractions:sech')
AddEventHandler('policeinteractions:sech', function(target)
    local _source = source

    if not IsPlayerPolice(_source) then
        print(('[^3WARNING^7] Player ^5%s^7 Attempted To Search Without Police Job!'):format(_source))
        return
    end

    TriggerClientEvent('policeinteractions:sech', target)
end)

-- Log when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('^2[policeinteractions]^7 Police Interactions script started successfully')
    end
end)
