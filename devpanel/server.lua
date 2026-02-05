local AdminController = {
    players = {}
}

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

local function getRankFromIdentifiers(src)
    local ids = GetPlayerIdentifiers(src)
    for _, id in ipairs(ids) do
        local rank = Config.AdminRanks[id]
        if rank then
            return math.min(Config.MaxRank, math.max(0, tonumber(rank) or 0))
        end
    end

    if Config.UseAceFallback then
        for rank = Config.MaxRank, 1, -1 do
            local ace = Config.AceRanks[rank]
            if ace and IsPlayerAceAllowed(src, ace) then
                return rank
            end
        end
    end

    return 0
end

local function ensureAdminState(src)
    local state = AdminController.players[src]
    if not state then
        state = {
            rank = getRankFromIdentifiers(src),
            duty = false
        }
        AdminController.players[src] = state
    end
    return state
end

local function hasActionAccess(src, action, requiresDuty)
    local state = ensureAdminState(src)
    local minRank = Config.ActionRanks[action] or 99
    if state.rank < minRank then
        return false, state
    end
    if requiresDuty and not state.duty then
        return false, state
    end
    return true, state
end

local function syncState(src)
    local state = ensureAdminState(src)
    TriggerClientEvent('ay_devpanel:adminState', src, {
        rank = state.rank,
        duty = state.duty,
        maxRank = Config.MaxRank,
        actionRanks = Config.ActionRanks,
        dutyOutfit = Config.DutyOutfits[state.rank]
    })
end

local function setDuty(src, value)
    local state = ensureAdminState(src)
    state.duty = value
    syncState(src)
    TriggerClientEvent('ay_devpanel:setDutyClient', src, value, state.rank, Config.DutyOutfits[state.rank])

    local playerName = GetPlayerName(src) or ('ID %s'):format(src)
    logToDiscord(('**%s** duty state: `%s` (rank %s)'):format(playerName, tostring(value), state.rank))
end

local function notify(src, msg)
    TriggerClientEvent('chat:addMessage', src, {
        color = { 80, 200, 120 },
        args = { 'DEV', msg }
    })
end

RegisterNetEvent('ay_devpanel:requestOpen', function()
    local src = source
    local state = ensureAdminState(src)
    TriggerClientEvent('ay_devpanel:setPermission', src, state.rank > 0)
    syncState(src)
    if state.rank > 0 then
        logToDiscord(('**%s** opened the panel (rank %s).'):format(GetPlayerName(src) or ('ID %s'):format(src), state.rank))
    end
end)

RegisterNetEvent('ay_devpanel:toggleDuty', function()
    local src = source
    local allowed, state = hasActionAccess(src, 'duty', false)
    if not allowed then
        notify(src, '^1Nincs jogosultságod a duty rendszerhez.')
        return
    end
    setDuty(src, not state.duty)
    notify(src, ('Duty: %s'):format(state.duty and '^2ON' or '^1OFF'))
end)

RegisterNetEvent('ay_devpanel:serverAction', function(action, payload)
    local src = source
    local allowed, state = hasActionAccess(src, action, true)
    if not allowed then
        notify(src, '^1Nincs rang vagy duty jogosultság ehhez a művelethez.')
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
    elseif action == 'announce' and type(payload) == 'string' and payload ~= '' then
        TriggerClientEvent('chat:addMessage', -1, {
            color = { 255, 80, 80 },
            multiline = true,
            args = { ('DEV R%s'):format(state.rank), payload }
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

RegisterCommand(Config.DutyCommand, function(src)
    if src == 0 then
        print('This command can only be used in-game.')
        return
    end

    local allowed, state = hasActionAccess(src, 'duty', false)
    if not allowed then
        notify(src, '^1Nincs jogosultságod a duty rendszerhez.')
        return
    end

    setDuty(src, not state.duty)
    notify(src, ('Duty: %s'):format(state.duty and '^2ON' or '^1OFF'))
end, false)

RegisterCommand('setadminay', function(src, args)
    local issuer = ensureAdminState(src)
    if src ~= 0 and issuer.rank < Config.BossRank then
        notify(src, '^1Csak a főnök (Admin 5) állíthat rangot.')
        return
    end

    local target = tonumber(args[1] or '')
    local rank = tonumber(args[2] or '')
    if not target or not GetPlayerName(target) then
        if src == 0 then
            print('Usage: setadminay <id> <rank 0-5>')
        else
            notify(src, '^1Hibás target ID.')
        end
        return
    end

    rank = math.floor(math.min(Config.MaxRank, math.max(0, rank or 0)))
    local st = ensureAdminState(target)
    st.rank = rank
    if rank == 0 and st.duty then
        st.duty = false
        TriggerClientEvent('ay_devpanel:setDutyClient', target, false, rank, nil)
    end

    syncState(target)
    notify(target, ('^3Admin rangod frissült: ^2Admin %s'):format(rank))

    local issuerName = src == 0 and 'CONSOLE' or (GetPlayerName(src) or ('ID %s'):format(src))
    local targetName = GetPlayerName(target) or ('ID %s'):format(target)
    logToDiscord(('**%s** set admin rank of **%s** to `%s`.'):format(issuerName, targetName, rank))

    if src ~= 0 then
        notify(src, ('^2Beállítva: %s -> Admin %s'):format(targetName, rank))
    end
end, true)

AddEventHandler('playerDropped', function()
    AdminController.players[source] = nil
end)
