Locales = {}

Locales['en'] = {
    -- Police Interactions
    ['HandCuff_uncuff'] = 'Handcuff / Uncuff',
    ['FeetCuff_uncuff'] = 'Legcuff / Unlegcuff',
    ['Darg'] = 'Escort',
    ['Sechce'] = 'Search',
    ['PutInVehiclece'] = 'Put in Vehicle',  
    ['OutVehiclece'] = 'Take out Vehicle',
    ['StopDargging'] = '[G] - Stop Escorting',
    ['searching'] = 'Searching',
    
    -- Notifications
    ['no_player_nearby'] = 'No player nearby',
    ['no_vehicle_nearby'] = 'No vehicle nearby',
    ['no_free_seats'] = 'No free seats in vehicle',
    ['not_police'] = 'You are not a police officer',
    ['handcuff_applied'] = 'Handcuffs applied',
    ['handcuff_removed'] = 'Handcuffs removed',
    ['legcuff_applied'] = 'Legcuffs applied',
    ['legcuff_removed'] = 'Legcuffs removed',
    ['being_escorted'] = 'You are being escorted',
    ['escort_stopped'] = 'Escort stopped',
    ['player_searched'] = 'Player searched',
    
    -- Progress Bars
    ['searching_player'] = 'Searching player',
    ['applying_handcuffs'] = 'Applying handcuffs',
    ['removing_handcuffs'] = 'Removing handcuffs',
    
    -- Inventory Items
    ['handcuff_item'] = 'Handcuffs',
    ['handcuff_description'] = 'Used to restrain suspects',
    ['footcuff_item'] = 'Legcuffs',
    ['footcuff_description'] = 'Used to restrain suspects legs',
}

Locales['fr'] = {
    -- Police Interactions
    ['HandCuff_uncuff'] = 'Menotter / Démenotter',
    ['FeetCuff_uncuff'] = 'Entraver / Désentraver',
    ['Darg'] = 'Escorter',
    ['Sechce'] = 'Fouiller',
    ['PutInVehiclece'] = 'Mettre dans le véhicule',  
    ['OutVehiclece'] = 'Sortir du véhicule',
    ['StopDargging'] = '[G] - Arrêter l\'escorte',
    ['searching'] = 'Fouille en cours',
    
    -- Notifications
    ['no_player_nearby'] = 'Aucun joueur à proximité',
    ['no_vehicle_nearby'] = 'Aucun véhicule à proximité',
    ['no_free_seats'] = 'Aucune place libre dans le véhicule',
    ['not_police'] = 'Vous n\'êtes pas policier',
    ['handcuff_applied'] = 'Menottes appliquées',
    ['handcuff_removed'] = 'Menottes retirées',
    ['legcuff_applied'] = 'Entraves appliquées',
    ['legcuff_removed'] = 'Entraves retirées',
    ['being_escorted'] = 'Vous êtes escorté',
    ['escort_stopped'] = 'Escorte arrêtée',
    ['player_searched'] = 'Joueur fouillé',
    
    -- Progress Bars
    ['searching_player'] = 'Fouille du joueur',
    ['applying_handcuffs'] = 'Pose des menottes',
    ['removing_handcuffs'] = 'Retrait des menottes',
}

Locales['es'] = {
    -- Police Interactions
    ['HandCuff_uncuff'] = 'Esposar / Desesposar',
    ['FeetCuff_uncuff'] = 'Esposas de tobillo / Quitar',
    ['Darg'] = 'Escoltar',
    ['Sechce'] = 'Registrar',
    ['PutInVehiclece'] = 'Meter en vehículo',  
    ['OutVehiclece'] = 'Sacar del vehículo',
    ['StopDargging'] = '[G] - Dejar de escoltar',
    ['searching'] = 'Registrando',
    
    -- Notifications
    ['no_player_nearby'] = 'No hay jugadores cerca',
    ['no_vehicle_nearby'] = 'No hay vehículos cerca',
    ['no_free_seats'] = 'No hay asientos libres en el vehículo',
    ['not_police'] = 'No eres policía',
    ['handcuff_applied'] = 'Esposas aplicadas',
    ['handcuff_removed'] = 'Esposas removidas',
    ['legcuff_applied'] = 'Esposas de tobillo aplicadas',
    ['legcuff_removed'] = 'Esposas de tobillo removidas',
    ['being_escorted'] = 'Estás siendo escoltado',
    ['escort_stopped'] = 'Escolta detenida',
    ['player_searched'] = 'Jugador registrado',
    
    -- Progress Bars
    ['searching_player'] = 'Registrando jugador',
    ['applying_handcuffs'] = 'Aplicando esposas',
    ['removing_handcuffs'] = 'Removiendo esposas',
}

-- Système de gestion des locales
local LocaleSystem = {}

function LocaleSystem:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    
    self.currentLocale = 'en'
    self.locales = Locales
    
    return instance
end

function LocaleSystem:setLocale(locale)
    if self.locales[locale] then
        self.currentLocale = locale
        print(('^2[policeinteractions]^7 Locale set to: %s'):format(locale))
    else
        print(('^3[WARNING]^7 Locale "%s" not found, using default "en"'):format(locale))
        self.currentLocale = 'en'
    end
end

function LocaleSystem:get(key)
    if self.locales[self.currentLocale] and self.locales[self.currentLocale][key] then
        return self.locales[self.currentLocale][key]
    elseif self.locales['en'] and self.locales['en'][key] then
        return self.locales['en'][key]
    else
        return key
    end
end

function LocaleSystem:format(key, ...)
    local text = self:get(key)
    return text:format(...)
end

-- Fonction globale pour un accès facile
function TranslateCap(key, ...)
    if not LocaleSystem.instance then
        LocaleSystem.instance = LocaleSystem:new()
    end
    
    if ... then
        return LocaleSystem.instance:format(key, ...)
    else
        return LocaleSystem.instance:get(key)
    end
end

-- Initialiser le système de locales
CreateThread(function()
    LocaleSystem.instance = LocaleSystem:new()
    
    -- Définir la locale par défaut (peut être modifiée via config)
    local configLocale = GetConvar('policeinteractions_locale', 'en')
    LocaleSystem.instance:setLocale(configLocale)
    
    print('^2[policeinteractions]^7 Locale system initialized')
end)

-- Export pour d'autres ressources
exports('GetLocale', function()
    return LocaleSystem.instance
end)

exports('Translate', function(key, ...)
    return TranslateCap(key, ...)
end)
