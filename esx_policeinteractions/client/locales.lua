local Locale = {}

function Locale:new()
    local instance = {}
    setmetatable(instance, self)
    self.__index = self
    
    self.currentLocale = 'en'
    self.locales = {}
    
    return instance
end

function Locale:setLocale(locale)
    if Locales[locale] then
        self.currentLocale = locale
    else
        print(('^3[WARNING]^7 Locale "%s" not found, using default "en"'):format(locale))
        self.currentLocale = 'en'
    end
end

function Locale:get(key)
    if Locales[self.currentLocale] and Locales[self.currentLocale][key] then
        return Locales[self.currentLocale][key]
    elseif Locales['en'] and Locales['en'][key] then
        return Locales['en'][key]
    else
        return key -- Return the key if translation not found
    end
end

function Locale:format(key, ...)
    local text = self:get(key)
    return text:format(...)
end

-- Global function for easy access
function TranslateCap(key, ...)
    if not Locale.instance then
        Locale.instance = Locale:new()
    end
    
    if ... then
        return Locale.instance:format(key, ...)
    else
        return Locale.instance:get(key)
    end
end

-- Initialize the locale system
CreateThread(function()
    Locale.instance = Locale:new()
    
    -- You can set the locale based on player preference or config
    -- For now, we'll use English as default
    Locale.instance:setLocale('en')
end)

-- Export for other resources
exports('GetLocale', function()
    return Locale.instance
end)

exports('Translate', function(key, ...)
    return TranslateCap(key, ...)
end)
