Config = {}

-- Permission modes:
-- ace: checks IsPlayerAceAllowed(source, Config.AcePermission)
-- ids: checks if player's license identifier is listed in Config.AllowedIdentifiers
Config.PermissionMode = 'ace'
Config.AcePermission = 'devpanel.use'
Config.AllowedIdentifiers = {
    -- 'license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
}

Config.OpenCommand = 'devpanel'
Config.ToggleKeybind = 'F7'

Config.DefaultWeather = 'EXTRASUNNY'
Config.DefaultTime = { hour = 12, minute = 0 }

Config.EnableWebhookLogs = false
Config.WebhookUrl = ''
