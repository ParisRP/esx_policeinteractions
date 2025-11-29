local ox_inventory = exports.ox_inventory
local playerLoaded = false
local playerGroups = {}

-- Variables locales
local isEscorting = false 
local isAttached = false
local Tonyhandecuff = false
local Tonyfeetcuff = false
local cuffObj = nil
local dragnotify = nil
local sechde = false

-- Événements OX Core
RegisterNetEvent('ox:playerLoaded', function()
    playerLoaded = true
    local player = exports.ox_core:GetPlayer()
    if player then
        playerGroups = player.groups or {}
    end
    print('^2[policeinteractions]^7 Player loaded')
end)

RegisterNetEvent('ox:playerLogout', function()
    playerLoaded = false
    playerGroups = {}
    print('^2[policeinteractions]^7 Player logged out')
end)

RegisterNetEvent('ox:setGroup', function(group, grade)
    playerGroups[group] = grade
end)

-- Fonction pour obtenir le joueur le plus proche
function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerCoords = GetEntityCoords(cache.ped)

    for i = 1, #players do
        local target = players[i]
        if target ~= cache.playerId then
            local targetCoords = GetEntityCoords(GetPlayerPed(target))
            local distance = #(playerCoords - targetCoords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = target
                closestDistance = distance
            end
        end
    end

    if closestPlayer ~= -1 then
        return GetPlayerServerId(closestPlayer), closestDistance
    end
    return -1, -1
end

-- Fonctions d'animation
function loadanimdict(dictname)
    if not HasAnimDictLoaded(dictname) then
        RequestAnimDict(dictname) 
        while not HasAnimDictLoaded(dictname) do 
            Wait(1)
        end
    end
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

-- Interactions police
local policeinteractions = {
    {
        name = 'policeinteractions:handcuff',
        event = 'policeinteractions:handcuff',
        icon = 'fa-solid fa-handcuffs',
        label = TranslateCap('HandCuff_uncuff'), 
        canInteract = function(entity, distance, coords, name, bone)
            return not IsEntityDead(entity) and playerGroups.police and distance <= 2.0
        end
    },
    {
        name = 'policeinteractions:feetcuff',
        event = 'policeinteractions:feetcuff',
        icon = 'fa-solid fa-handcuffs',
        label = TranslateCap('FeetCuff_uncuff'), 
        canInteract = function(entity, distance, coords, name, bone)
            return not IsEntityDead(entity) and playerGroups.police and distance <= 2.0
        end
    },
    {
        name = 'policeinteractions:escort',
        event = 'policeinteractions:escort',
        icon = 'fa-solid fa-hand',
        label = TranslateCap('Darg'), 
        canInteract = function(entity, distance, coords, name, bone)
            return not IsEntityDead(entity) and playerGroups.police and distance <= 2.0
        end
    },
    {
        name = 'policeinteractions:sechce',
        event = 'policeinteractions:sechce',
        icon = 'fa-solid fa-magnifying-glass',
        label = TranslateCap('Sechce'), 
        canInteract = function(entity, distance, coords, name, bone)
            return not IsEntityDead(entity) and playerGroups.police and distance <= 2.0
        end
    },
    {
        name = 'policeinteractions:putInVehiclece',
        event = 'policeinteractions:putInVehiclece',
        icon = 'fa-regular fa-square-plus', 
        label = TranslateCap('PutInVehiclece'), 
        canInteract = function(entity, distance, coords, name, bone)
            return not IsEntityDead(entity) and playerGroups.police and distance <= 2.0
        end
    } 
}

local policecarinteractions = {
    {
        name = 'policeinteractions:OutVehiclece',
        event = 'policeinteractions:OutVehiclece',
        icon = 'fa-regular fa-square-minus',
        label = TranslateCap('OutVehiclece'), 
        canInteract = function(entity, distance, coords, name, bone)
            return playerGroups.police and distance <= 5.0
        end
    }
}

-- Ajouter les options de target
CreateThread(function()
    while not playerLoaded do
        Wait(1000)
    end
    
    exports.ox_target:addGlobalPlayer(policeinteractions)
    exports.ox_target:addGlobalVehicle(policecarinteractions)
    print('^2[policeinteractions]^7 Target interactions loaded')
end)

-- Événements pour les menottes
RegisterNetEvent('policeinteractions:handcuff')
AddEventHandler('policeinteractions:handcuff', function()
    local target, distance = GetClosestPlayer()
    if target and distance <= 2.0 then
        TriggerServerEvent('policeinteractions:removehandcuff')
    else
        lib.notify({
            title = 'Error',
            description = TranslateCap('no_player_nearby'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('policeinteractions:re')
AddEventHandler('policeinteractions:re', function()
    local target, distance = GetClosestPlayer()
    local playerheading = GetEntityHeading(cache.ped)
    local playerlocation = GetEntityForwardVector(cache.ped)
    local playerCoords = GetEntityCoords(cache.ped)
    
    if target and distance <= 2.0 then
        TriggerServerEvent('policeinteractions:handcufftargetid', target, playerheading, playerCoords, playerlocation)
        lib.notify({
            title = 'Success',
            description = TranslateCap('handcuff_applied'),
            type = 'success'
        })
    end
end)

RegisterNetEvent('policeinteractions:targetcloseplayer')
AddEventHandler('policeinteractions:targetcloseplayer', function(playerheading, playercoords, playerlocation)
    local playerPed = cache.ped
    SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)  

    local coords = GetEntityCoords(playerPed)
    local hash = `p_cs_cuffs_02_s`
    
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do 
            Wait(0) 
        end
    end

    cuffObj = CreateObject(hash, coords, true, false)
    AttachEntityToEntity(cuffObj, playerPed, GetPedBoneIndex(playerPed, 60309), -0.058, 0.005, 0.090, 290.0, 95.0, 120.0, true, false, false, false, 0, true)

    local x, y, z = table.unpack(playercoords + playerlocation * 1.0)
    SetEntityCoords(playerPed, x, y, z)
    SetEntityHeading(playerPed, playerheading)
    
    Wait(250)
    loadanimdict('mp_arrest_paired')
    TaskPlayAnim(playerPed, 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 3750, 2, 0, 0, 0, 0)
    Wait(3760)
    
    Tonyhandecuff = true
    LoadAnimDict('anim@move_m@prisoner_cuffed')
    TaskPlayAnim(playerPed, 'anim@move_m@prisoner_cuffed', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
    
    DisplayRadar(false)
    SetEnableHandcuffs(playerPed, true)
    DisablePlayerFiring(playerPed, true)
    SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true) 
    SetPedCanPlayGestureAnims(playerPed, false)

    lib.notify({
        title = 'Info',
        description = TranslateCap('handcuff_applied'),
        type = 'inform'
    })
end)

RegisterNetEvent('policeinteractions:player')
AddEventHandler('policeinteractions:player', function()
    Wait(250)
    loadanimdict('mp_arrest_paired')
    TaskPlayAnim(cache.ped, 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8, 3750, 2, 0, 0, 0, 0)
    Wait(3000)
end)

-- Événements pour enlever les menottes
RegisterNetEvent('policeinteractions:uncuff')
AddEventHandler('policeinteractions:uncuff', function()
    local target, distance = GetClosestPlayer()
    local playerheading = GetEntityHeading(cache.ped)
    local playerlocation = GetEntityForwardVector(cache.ped)
    local playerCoords = GetEntityCoords(cache.ped)
    
    if target and distance <= 2.0 then
        TriggerServerEvent('policeinteractions:allunlockcuff', target, playerheading, playerCoords, playerlocation)
    else
        lib.notify({
            title = 'Error',
            description = TranslateCap('no_player_nearby'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('policeinteractions:uncufffeet')
AddEventHandler('policeinteractions:uncufffeet', function()
    local target, distance = GetClosestPlayer()
    local playerheading = GetEntityHeading(cache.ped)
    local playerlocation = GetEntityForwardVector(cache.ped)
    local playerCoords = GetEntityCoords(cache.ped)
    
    if target and distance <= 2.0 then
        TriggerServerEvent('policeinteractions:feetunlockcuff', target, playerheading, playerCoords, playerlocation)
    else
        lib.notify({
            title = 'Error',
            description = TranslateCap('no_player_nearby'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('policeinteractions:douncuffing')
AddEventHandler('policeinteractions:douncuffing', function()
    Wait(250)
    loadanimdict('mp_arresting')
    TaskPlayAnim(cache.ped, 'mp_arresting', 'a_uncuff', 8.0, -8, -1, 2, 0, 0, 0, 0)
    Wait(5500)
    ClearPedTasks(cache.ped)
    
    lib.notify({
        title = 'Success',
        description = TranslateCap('handcuff_removed'),
        type = 'success'
    })
end)

RegisterNetEvent('policeinteractions:getuncuffed')
AddEventHandler('policeinteractions:getuncuffed', function(playerheading, playercoords, playerlocation)
    local x, y, z = table.unpack(playercoords + playerlocation * 1.0)
    SetEntityCoords(cache.ped, x, y, z)
    SetEntityHeading(cache.ped, playerheading)
    
    Wait(250)
    loadanimdict('mp_arresting')
    TaskPlayAnim(cache.ped, 'mp_arresting', 'b_uncuff', 8.0, -8, -1, 2, 0, 0, 0, 0)
    Wait(5500)
    
    Tonyfeetcuff = false
    Tonyhandecuff = false
    ClearPedTasks(cache.ped)
    DisplayRadar(true)
    
    SetEnableHandcuffs(cache.ped, false)
    DisablePlayerFiring(cache.ped, false)
    SetPedCanPlayGestureAnims(cache.ped, true)

    if cuffObj then
        DeleteEntity(cuffObj)
        cuffObj = nil
    end

    lib.notify({
        title = 'Info',
        description = TranslateCap('handcuff_removed'),
        type = 'inform'
    })
end)

-- Événements pour les entraves
RegisterNetEvent('policeinteractions:feetcuff')
AddEventHandler('policeinteractions:feetcuff', function()
    local target, distance = GetClosestPlayer()
    if target and distance <= 2.0 then
        TriggerServerEvent('policeinteractions:removefeetcuff')
    else
        lib.notify({
            title = 'Error',
            description = TranslateCap('no_player_nearby'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('policeinteractions:ft')
AddEventHandler('policeinteractions:ft', function()
    local target, distance = GetClosestPlayer()
    local playerheading = GetEntityHeading(cache.ped)
    local playerlocation = GetEntityForwardVector(cache.ped)
    local playerCoords = GetEntityCoords(cache.ped)
    
    if target and distance <= 2.0 then
        TriggerServerEvent('policeinteractions:requestarrest', target, playerheading, playerCoords, playerlocation)
        lib.notify({
            title = 'Success',
            description = TranslateCap('legcuff_applied'),
            type = 'success'
        })
    end
end)

RegisterNetEvent('policeinteractions:getarrested')
AddEventHandler('policeinteractions:getarrested', function(playerheading, playercoords, playerlocation)
    local playerPed = cache.ped
    SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)

    local x, y, z = table.unpack(playercoords + playerlocation * 1.0)
    SetEntityCoords(playerPed, x, y, z)
    SetEntityHeading(playerPed, playerheading)
    
    Wait(250)
    loadanimdict('mp_arrest_paired')
    TaskPlayAnim(playerPed, 'mp_arrest_paired', 'crook_p2_back_right', 8.0, -8, 3750, 2, 0, 0, 0, 0)
    Wait(3760)
    
    Tonyfeetcuff = true
    loadanimdict('mp_arresting')
    TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
    
    DisplayRadar(false)
    SetEnableHandcuffs(playerPed, true)
    DisablePlayerFiring(playerPed, true)
    SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)  
    SetPedCanPlayGestureAnims(playerPed, false)

    local coords = GetEntityCoords(playerPed)
    local hash = `p_cs_cuffs_02_s`
    
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do 
            Wait(0) 
        end
    end

    cuffObj = CreateObject(hash, coords, true, false)
    AttachEntityToEntity(cuffObj, playerPed, GetPedBoneIndex(playerPed, 60309), -0.055, 0.06, 0.04, 265.0, 155.0, 80.0, true, false, false, false, 0, true)

    lib.notify({
        title = 'Info',
        description = TranslateCap('legcuff_applied'),
        type = 'inform'
    })
end)

RegisterNetEvent('policeinteractions:doarrested')
AddEventHandler('policeinteractions:doarrested', function()
    Wait(250)
    loadanimdict('mp_arrest_paired')
    TaskPlayAnim(cache.ped, 'mp_arrest_paired', 'cop_p2_back_right', 8.0, -8, 3750, 2, 0, 0, 0, 0)
    Wait(3000)
end)

-- Système d'escorte
CreateThread(function()
    while true do
        local sleep = 1000
        if isEscorting and not dragnotify then
            sleep = 0
            lib.showTextUI(TranslateCap('StopDargging'), {icon = 'hand'})
            
            if IsControlJustPressed(0, 47) then -- G key
                dragnotify = true
                lib.hideTextUI()
                local closestPlayer = GetClosestPlayer()
                if closestPlayer then
                    TriggerServerEvent('policeinteractions:attachPlayer', closestPlayer, 'escort')
                end
                lib.notify({
                    title = 'Info',
                    description = TranslateCap('escort_stopped'),
                    type = 'inform'
                })
            end
        elseif dragnotify then
            Wait(1000)
            lib.hideTextUI()
            dragnotify = nil
        end
        Wait(sleep)
    end
end)

-- Désactivation des contrôles quand menotté
CreateThread(function()
    while true do
        local sleep = 1000

        if Tonyfeetcuff or Tonyhandecuff then
            sleep = 0
            DisableControlAction(0, 1, true) -- Disable pan
            DisableControlAction(0, 2, true) -- Disable tilt
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 263, true) -- Melee Attack 1
            DisableControlAction(0, 45, true) -- Reload
            DisableControlAction(0, 22, true) -- Jump
            DisableControlAction(0, 44, true) -- Cover
            DisableControlAction(0, 37, true) -- Select Weapon
            DisableControlAction(0, 23, true) -- Also 'enter'?
            DisableControlAction(0, 288, true) -- Disable phone
            DisableControlAction(0, 289, true) -- Inventory
            DisableControlAction(0, 170, true) -- Animations
            DisableControlAction(0, 167, true) -- Job
            DisableControlAction(0, 0, true) -- Disable changing view
            DisableControlAction(0, 26, true) -- Disable looking behind
            DisableControlAction(0, 73, true) -- Disable clearing animation
            DisableControlAction(2, 199, true) -- Disable pause screen
            DisableControlAction(0, 59, true) -- Disable steering in vehicle
            DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
            DisableControlAction(0, 72, true) -- Disable reversing in vehicle
            DisableControlAction(2, 36, true) -- Disable going stealth
            DisableControlAction(0, 47, true) -- Disable weapon
            DisableControlAction(0, 264, true) -- Disable melee
            DisableControlAction(0, 257, true) -- Disable melee
            DisableControlAction(0, 140, true) -- Disable melee
            DisableControlAction(0, 141, true) -- Disable melee
            DisableControlAction(0, 142, true) -- Disable melee
            DisableControlAction(0, 143, true) -- Disable melee
            DisableControlAction(0, 75, true) -- Disable exit vehicle
            DisableControlAction(27, 75, true) -- Disable exit vehicle

            if Tonyfeetcuff then
                DisableControlAction(0, 32, true) -- W
                DisableControlAction(0, 34, true) -- A
                DisableControlAction(0, 31, true) -- S 
                DisableControlAction(0, 30, true) -- D
            end

            -- Assurer que les animations continuent de jouer
            if Tonyfeetcuff and IsEntityPlayingAnim(cache.ped, 'mp_arresting', 'idle', 3) ~= 1 then
                LoadAnimDict('mp_arresting')
                TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
            end

            if Tonyhandecuff and IsEntityPlayingAnim(cache.ped, 'anim@move_m@prisoner_cuffed', 'idle', 3) ~= 1 then
                LoadAnimDict('anim@move_m@prisoner_cuffed')
                TaskPlayAnim(cache.ped, 'anim@move_m@prisoner_cuffed', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
            end
        end
        Wait(sleep)
    end
end)

-- Commandes d'escorte
RegisterNetEvent('policeinteractions:escort')
AddEventHandler('policeinteractions:escort', function()
    local closestPlayer = GetClosestPlayer()
    if closestPlayer then
        TriggerServerEvent('policeinteractions:attachPlayer', closestPlayer, 'escort')
        lib.notify({
            title = 'Info',
            description = TranslateCap('being_escorted'),
            type = 'inform'
        })
    else
        lib.notify({
            title = 'Error',
            description = TranslateCap('no_player_nearby'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('policeinteractions:doAnimation')
AddEventHandler('policeinteractions:doAnimation', function(anim)
    if anim == 'escort' then
        if isEscorting then
            ClearPedTasks(cache.ped)
            isEscorting = false
        else
            isEscorting = true
            LoadAnimDict('amb@world_human_drinking@coffee@male@base')
            TaskPlayAnim(cache.ped, 'amb@world_human_drinking@coffee@male@base', 'base', 8.0, -8, -1, 51, 0, false, false, false)
        end
    end
end)

RegisterNetEvent('policeinteractions:getDragged')
AddEventHandler('policeinteractions:getDragged', function(entToAttach, anim)
    local curAttachedPed = GetPlayerPed(GetPlayerFromServerId(entToAttach))
   
    if anim == 'escort' then
        if not isAttached then
            ClearPedTasks(cache.ped)
            isAttached = true
            LoadAnimDict('mp_arresting')
            LoadAnimDict('move_m@generic_variations@walk')
            TaskPlayAnim(cache.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
            AttachEntityToEntity(cache.ped, curAttachedPed, 1816, 0.25, 0.49, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            amBeingEscorted(curAttachedPed)
        else
            isAttached = false
            DetachEntity(cache.ped)
            ClearPedTasks(cache.ped)
        end
    end
end)

function amBeingEscorted(entID)
    CreateThread(function()
        while isAttached do
            Wait(0)
            local speed = GetEntitySpeed(entID)
            if speed > 1 then
                if IsEntityPlayingAnim(cache.ped, 'move_m@generic_variations@walk', 'walk_b', 3) ~= 1 then
                    TaskPlayAnim(cache.ped, 'move_m@generic_variations@walk', 'walk_b', 8.0, -8, -1, 0, 0, false, false, false)
                end
            end
        end
    end)
end

-- Système de fouille
RegisterNetEvent('policeinteractions:sechce')
AddEventHandler('policeinteractions:sechce', function()
    local closestPlayer = GetClosestPlayer()
    
    if closestPlayer then
        if lib.progressBar({
            duration = 5000,
            label = TranslateCap('searching_player'),
            useWhileDead = false,
            canCancel = true,
            disable = { car = true },
            anim = {
                dict = 'anim@gangops@facility@servers@bodysearch@',
                clip = 'player_search'
            },
        }) then
            OpenBodySearchMenu(closestPlayer)
            TriggerServerEvent('policeinteractions:sech', closestPlayer)
            lib.notify({
                title = 'Success',
                description = TranslateCap('player_searched'),
                type = 'success'
            })
        end
    else
        lib.notify({
            title = 'Error',
            description = TranslateCap('no_player_nearby'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('policeinteractions:sech')
AddEventHandler('policeinteractions:sech', function()
    sechde = true
    loadanimdict('missminuteman_1ig_2')
    TaskPlayAnim(cache.ped, 'missminuteman_1ig_2', 'handsup_base', 8.0, -8, 3750, 2, 0, 0, 0, 0)
    Wait(3000)
    sechde = false
end)

function OpenBodySearchMenu(player)
    exports.ox_inventory:openInventory('player', player)
end

-- Interactions véhicule
RegisterNetEvent('policeinteractions:putInVehiclece')
AddEventHandler('policeinteractions:putInVehiclece', function()
    local closestPlayer = GetClosestPlayer()
    if closestPlayer then
        TriggerServerEvent('policeinteractions:putInVehicle', closestPlayer)
    else
        lib.notify({
            title = 'Error',
            description = TranslateCap('no_player_nearby'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('policeinteractions:putInVehicle')
AddEventHandler('policeinteractions:putInVehicle', function()
    local playerPed = cache.ped
    local vehicle, distance = GetClosestVehicle()

    if vehicle and distance < 5 then
        local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

        for i = maxSeats - 1, 0, -1 do
            if IsVehicleSeatFree(vehicle, i) then
                freeSeat = i
                break
            end
        end

        if freeSeat then
            TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
        else
            lib.notify({
                title = 'Error',
                description = TranslateCap('no_free_seats'),
                type = 'error'
            })
        end
    else
        lib.notify({
            title = 'Error',
            description = TranslateCap('no_vehicle_nearby'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('policeinteractions:OutVehiclece')
AddEventHandler('policeinteractions:OutVehiclece', function()
    local closestPlayer = GetClosestPlayer()
    if closestPlayer then
        TriggerServerEvent('policeinteractions:OutVehicle', closestPlayer)
    else
        lib.notify({
            title = 'Error',
            description = TranslateCap('no_player_nearby'),
            type = 'error'
        })
    end
end)

RegisterNetEvent('policeinteractions:OutVehicle')
AddEventHandler('policeinteractions:OutVehicle', function()
    if IsPedSittingInAnyVehicle(cache.ped) then
        local vehicle = GetVehiclePedIsIn(cache.ped, false)
        TaskLeaveVehicle(cache.ped, vehicle, 64)
    end
end)

-- Fonction utilitaire pour obtenir le véhicule le plus proche
function GetClosestVehicle()
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    local playerCoords = GetEntityCoords(cache.ped)

    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local distance = #(playerCoords - GetEntityCoords(vehicle))

        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicle
            closestDistance = distance
        end
    end

    return closestVehicle, closestDistance
end

-- Nettoyage quand la resource s'arrête
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if cuffObj then
            DeleteEntity(cuffObj)
        end
        lib.hideTextUI()
        print('^2[policeinteractions]^7 Resource stopped - cleaned up')
    end
end)

-- Log quand le client est prêt
CreateThread(function()
    while not playerLoaded do
        Wait(1000)
    end
    print('^2[policeinteractions]^7 Client script started successfully')
end)
