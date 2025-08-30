local Translations = {
    ['already_stored'] = "Dit voertuig staat al in deze garage opgeslagen.",
    ['limit_reached'] = "Opslag limiet is bereikt, je kunt geen voertuigen meer opslaan.",
    ['not_your_vehicle'] = "Dit is niet uw voertuig.",
    ['garage_stash_blip'] = "Stash Garage",
    ['vehicle_storage'] = "Voertuigopslag",
    ['park_vehicle'] = "Park Vehicle",
    ['area_obstructed'] = "Gebied is geblokkeerd",
    ['press_open_garage'] = "[E] - Open Garage Opslag",
    ['no_money'] = "Om een voertuig op te slaan moet je %{amount} betalen!",
    ['close'] = "Sluit",
}

if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({phrases = Translations, warnOnMissing = true, fallbackLang = Lang})
end