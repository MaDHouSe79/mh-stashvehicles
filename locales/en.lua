local Translations = {
    ['already_stored'] = "This vehicle is already stored in this garage...",
    ['limit_reached'] = "Storage limit has been reached, you can no longer store vehicles.",
    ['not_your_vehicle'] = "This is not your vehicle...",
    ['garage_stash_blip'] = "Stash Garage",
    ['vehicle_storage'] = "Vehicle Storage",
    ['park_vehicle'] = "Park Vehicle",
    ['area_obstructed'] = "Area is obstructed",
    ['press_open_garage'] = "[E] - Open Vehicle Storage",
    ['no_money'] = "To store a vehicle you need to pay %{amount}!",
    ['close'] = "Close",
}

if GetConvar('qb_locale', 'en') == 'en' then
    Lang = Locale:new({phrases = Translations, warnOnMissing = true, fallbackLang = Lang})
end