local function hasPermission(src)
    if src == 0 then
        return true
    end

    if Config.PermissionMode == 'ace' then
        return IsPlayerAceAllowed(src, Config.AcePermission)
    end

    if Config.PermissionMode == 'ids' then
        local identifiers = GetPlayerIdentifiers(src)
        for _, id in ipairs(identifiers) do
            for _, allowed in ipairs(Config.AllowedIdentifiers) do
                if id == allowed then
                    return true
                end
            end
        end
    end

    return false
end

local function logToDiscord(message)
    if not Config.EnableWebhookLogs or Config.WebhookUrl == '' then
        return
    end

    PerformHttpRequest(Config.WebhookUrl, function() end, 'POST', json.encode({
        username = 'DevPanel',
        embeds = {
            {
                title = 'Developer Panel Action',
                description = message,
                color = 3447003,
                footer = { text = os.date('%Y-%m-%d %H:%M:%S') }
            }
        }
    }), { ['Content-Type'] = 'application/json' })
end

lib = lib or {}

RegisterNetEvent('ay_devpanel:requestOpen', function()
    local src = source
    local allowed = hasPermission(src)
    TriggerClientEvent('ay_devpanel:setPermission', src, allowed)
    if allowed then
        logToDiscord(('**%s** opened the panel.'):format(GetPlayerName(src) or ('ID %s'):format(src)))
    end
end)

RegisterNetEvent('ay_devpanel:serverAction', function(action, payload)
    local src = source
    if not hasPermission(src) then
        DropPlayer(src, 'Unauthorized devpanel usage attempt detected.')
        return
    end

    if action == 'setWeather' and type(payload) == 'string' then
        TriggerClientEvent('ay_devpanel:setWeatherClient', -1, payload)
        logToDiscord(('**%s** changed weather to `%s`.'):format(GetPlayerName(src), payload))
    elseif action == 'setTime' and type(payload) == 'table' then
        local hour = tonumber(payload.hour) or 12
        local minute = tonumber(payload.minute) or 0
        TriggerClientEvent('ay_devpanel:setTimeClient', -1, hour, minute)
        logToDiscord(('**%s** set time to `%02d:%02d`.'):format(GetPlayerName(src), hour, minute))
    elseif action == 'announce' and type(payload) == 'string' then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 80, 80 },
            multiline = true,
            args = { 'DEV', payload }
        })
        logToDiscord(('**%s** sent an announcement: %s'):format(GetPlayerName(src), payload))
    elseif action == 'setBlackout' and type(payload) == 'boolean' then
        TriggerClientEvent('ay_devpanel:setBlackoutClient', -1, payload)
        logToDiscord(('**%s** toggled blackout: `%s`.'):format(GetPlayerName(src), tostring(payload)))
    end
end)

RegisterCommand(Config.OpenCommand, function(src)
    if src == 0 then
        print('This command can only be used in-game.')
        return
    end

    TriggerClientEvent('ay_devpanel:togglePanel', src)
end, false)
