local panelOpen = false
local hasAccess = false

local adminRank = 0
local isOnDuty = false
local actionRanks = {}

local godMode = false
local noclip = false
local noClipSpeed = 1.5
local showCoords = false
local frozenTime = false
local blackoutEnabled = false
local invisible = false
local superJump = false
local fastRun = false
local engineForcedOn = false

local savedAppearance = nil

local function notify(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function captureAppearance(ped)
    local data = {
        model = GetEntityModel(ped),
        components = {},
        props = {}
    }

    for i = 0, 11 do
        data.components[i] = {
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i),
            palette = GetPedPaletteVariation(ped, i)
        }
    end

    for i = 0, 7 do
        data.props[i] = {
            index = GetPedPropIndex(ped, i),
            texture = GetPedPropTextureIndex(ped, i)
        }
    end

    return data
end

local function loadModel(modelName)
    local model = modelName
    if type(modelName) == 'string' then
        model = joaat(modelName)
    end

    if not IsModelInCdimage(model) then
        return false
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    return true
end

local function applyAppearance(data)
    if not data then
        return
    end

    if data.model then
        loadModel(data.model)
    end

    local ped = PlayerPedId()

    if data.components then
        for i = 0, 11 do
            local c = data.components[i]
            if c then
                SetPedComponentVariation(ped, i, c.drawable, c.texture, c.palette or 0)
            end
        end
    end

    ClearAllPedProps(ped)
    if data.props then
        for i = 0, 7 do
            local p = data.props[i]
            if p and p.index and p.index >= 0 then
                SetPedPropIndex(ped, i, p.index, p.texture or 0, true)
            end
        end
    end
end

local function applyDutyOutfit(rank, outfit)
    local ped = PlayerPedId()

    if not savedAppearance then
        savedAppearance = captureAppearance(ped)
    end

    if outfit and outfit.model then
        loadModel(outfit.model)
        ped = PlayerPedId()
    end

    if outfit and outfit.components then
        for compId, comp in pairs(outfit.components) do
            SetPedComponentVariation(ped, tonumber(compId), comp.drawable, comp.texture or 0, comp.palette or 0)
        end
    end

    notify(('~g~Duty ON | Admin %s'):format(rank))
end

local function clearDutyOutfit()
    if savedAppearance then
        applyAppearance(savedAppearance)
        savedAppearance = nil
    end
    notify('~r~Duty OFF | Előző kinézet visszaállítva')
end

local function hasActionPermission(action)
    local required = actionRanks[action] or 99
    if adminRank < required then
        notify(('~r~Ehhez legalább Admin %s rang kell.'):format(required))
        return false
    end
    if action ~= 'duty' and not isOnDuty then
        notify('~r~Előbb duty-ba kell lépned (/dutyay)!')
        return false
    end
    return true
end

local function setPanel(state)
    panelOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({
        action = 'toggle',
        state = state,
        defaults = {
            weather = Config.DefaultWeather,
            hour = Config.DefaultTime.hour,
            minute = Config.DefaultTime.minute,
            noclipSpeed = noClipSpeed
        },
        admin = {
            rank = adminRank,
            duty = isOnDuty,
            actionRanks = actionRanks
        }
    })
end

local function setGodMode(state)
    godMode = state
    local ped = PlayerPedId()
    SetEntityInvincible(ped, state)
    SetPlayerInvincible(PlayerId(), state)
end

local function setInvisible(state)
    invisible = state
    local ped = PlayerPedId()
    SetEntityVisible(ped, not state, false)
end

local function setNoclip(state)
    noclip = state
    local ped = PlayerPedId()
    SetEntityCollision(ped, not state, not state)
    FreezeEntityPosition(ped, state)
    SetEntityInvincible(ped, state or godMode)
    if not invisible then
        SetEntityVisible(ped, not state, false)
    end
end

local function getForwardVector(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

RegisterNetEvent('ay_devpanel:togglePanel', function()
    TriggerServerEvent('ay_devpanel:requestOpen')
    Wait(100)
    if not hasAccess then
        notify('~r~Nincs jogosultsagod a developer panelhez.')
        return
    end
    setPanel(not panelOpen)
end)

RegisterNetEvent('ay_devpanel:setPermission', function(state)
    hasAccess = state
end)

RegisterNetEvent('ay_devpanel:adminState', function(state)
    adminRank = tonumber(state.rank) or 0
    isOnDuty = state.duty == true
    actionRanks = state.actionRanks or {}

    SendNUIMessage({
        action = 'adminState',
        admin = {
            rank = adminRank,
            duty = isOnDuty,
            actionRanks = actionRanks
        }
    })
end)

RegisterNetEvent('ay_devpanel:setDutyClient', function(state, rank, outfit)
    isOnDuty = state == true
    adminRank = tonumber(rank) or adminRank

    if isOnDuty then
        applyDutyOutfit(adminRank, outfit)
    else
        clearDutyOutfit()
    end

    SendNUIMessage({
        action = 'adminState',
        admin = {
            rank = adminRank,
            duty = isOnDuty,
            actionRanks = actionRanks
        }
    })
end)

RegisterNUICallback('close', function(_, cb)
    setPanel(false)
    cb('ok')
end)

RegisterNetEvent('ay_devpanel:setWeatherClient', function(weather)
    SetWeatherTypeOverTime(weather, 3.0)
    Wait(3000)
    SetWeatherTypeNowPersist(weather)
end)

RegisterNetEvent('ay_devpanel:setTimeClient', function(hour, minute)
    NetworkOverrideClockTime(hour, minute, 0)
end)

RegisterNetEvent('ay_devpanel:setBlackoutClient', function(state)
    blackoutEnabled = state
    SetArtificialLightsState(state)
    SetArtificialLightsStateAffectsVehicles(false)
end)

RegisterNUICallback('action', function(data, cb)
    local action = data.action
    local ped = PlayerPedId()

    if action == 'duty' then
        TriggerServerEvent('ay_devpanel:toggleDuty')
        cb('ok')
        return
    end

    if not hasActionPermission(action) then
        cb('ok')
        return
    end

    if action == 'godmode' then
        setGodMode(data.state)
    elseif action == 'heal' then
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        SetPedArmour(ped, 100)
    elseif action == 'invisible' then
        setInvisible(data.state)
    elseif action == 'noclip' then
        setNoclip(data.state)
    elseif action == 'setNoclipSpeed' then
        noClipSpeed = math.max(0.5, math.min(15.0, tonumber(data.value) or 1.5))
    elseif action == 'coords' then
        showCoords = data.state
    elseif action == 'superJump' then
        superJump = data.state
    elseif action == 'fastRun' then
        fastRun = data.state
    elseif action == 'cleanPed' then
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        ClearPedEnvDirt(ped)
    elseif action == 'tpWaypoint' then
        local blip = GetFirstBlipInfoId(8)
        if DoesBlipExist(blip) then
            local x, y, z = table.unpack(GetBlipInfoIdCoord(blip))
            SetPedCoordsKeepVehicle(ped, x, y, z + 1.0)
        else
            notify('~r~Nincs waypoint beállítva.')
        end
    elseif action == 'tpCoords' then
        local x = tonumber(data.x)
        local y = tonumber(data.y)
        local z = tonumber(data.z)
        if x and y and z then
            SetPedCoordsKeepVehicle(ped, x, y, z)
        else
            notify('~r~Hibás koordináta formátum.')
        end
    elseif action == 'giveWeapon' then
        local weaponName = tostring(data.weapon or ''):upper()
        if weaponName ~= '' then
            local hash = joaat(weaponName)
            if IsWeaponValid(hash) then
                GiveWeaponToPed(ped, hash, 250, false, true)
                notify(('~g~Fegyver adva: %s'):format(weaponName))
            else
                notify('~r~Érvénytelen fegyver név.')
            end
        end
    elseif action == 'spawnVehicle' then
        local modelName = (data.model or ''):lower()
        local model = joaat(modelName)
        if modelName ~= '' and IsModelInCdimage(model) and IsModelAVehicle(model) then
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(0) end
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
            SetPedIntoVehicle(ped, vehicle, -1)
            SetVehicleOnGroundProperly(vehicle)
            SetModelAsNoLongerNeeded(model)
        else
            notify('~r~Érvénytelen jármű model.')
        end
    elseif action == 'deleteVehicle' then
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 then
            DeleteEntity(vehicle)
        end
    elseif action == 'fixVehicle' then
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 then
            SetVehicleFixed(vehicle)
            SetVehicleDeformationFixed(vehicle)
            SetVehicleDirtLevel(vehicle, 0.0)
            SetVehicleEngineHealth(vehicle, 1000.0)
            SetVehicleBodyHealth(vehicle, 1000.0)
            SetVehiclePetrolTankHealth(vehicle, 1000.0)
        end
    elseif action == 'fullFuel' then
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 then
            SetVehicleFuelLevel(vehicle, 100.0)
        end
    elseif action == 'flipVehicle' then
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 then
            local coords = GetEntityCoords(vehicle)
            SetEntityRotation(vehicle, 0.0, 0.0, GetEntityHeading(vehicle), 2, true)
            SetEntityCoordsNoOffset(vehicle, coords.x, coords.y, coords.z + 1.0, false, false, false)
        end
    elseif action == 'maxVehicle' then
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 then
            SetVehicleModKit(vehicle, 0)
            for modType = 0, 16 do
                local count = GetNumVehicleMods(vehicle, modType)
                if count > 0 then
                    SetVehicleMod(vehicle, modType, count - 1, false)
                end
            end
            ToggleVehicleMod(vehicle, 18, true)
            ToggleVehicleMod(vehicle, 20, true)
            SetVehicleTyresCanBurst(vehicle, false)
            SetVehicleWindowTint(vehicle, 1)
            SetVehicleNumberPlateText(vehicle, 'DEVPANEL')
        end
    elseif action == 'forceEngine' then
        engineForcedOn = data.state
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 then
            SetVehicleEngineOn(vehicle, data.state, true, true)
        end
    elseif action == 'setWeather' then
        TriggerServerEvent('ay_devpanel:serverAction', 'setWeather', data.weather)
    elseif action == 'setTime' then
        TriggerServerEvent('ay_devpanel:serverAction', 'setTime', {
            hour = data.hour,
            minute = data.minute
        })
    elseif action == 'freezeTime' then
        frozenTime = data.state
    elseif action == 'blackout' then
        TriggerServerEvent('ay_devpanel:serverAction', 'setBlackout', data.state)
    elseif action == 'clearArea' then
        local radius = math.max(5.0, math.min(500.0, tonumber(data.radius) or 50.0))
        local c = GetEntityCoords(ped)
        ClearAreaOfVehicles(c.x, c.y, c.z, radius, false, false, false, false, false)
        ClearAreaOfPeds(c.x, c.y, c.z, radius, 1)
        ClearAreaOfObjects(c.x, c.y, c.z, radius, 0)
        notify(('~b~Area megtisztítva (%sm).'):format(math.floor(radius)))
    elseif action == 'announce' then
        TriggerServerEvent('ay_devpanel:serverAction', 'announce', data.message)
    end

    cb('ok')
end)

CreateThread(function()
    RegisterKeyMapping('+ay_devpanel', 'Open Developer Panel', 'keyboard', Config.ToggleKeybind)
    RegisterCommand('+ay_devpanel', function()
        TriggerEvent('ay_devpanel:togglePanel')
    end, false)
    RegisterCommand('-ay_devpanel', function() end, false)
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()

        if noclip then
            sleep = 0
            local coords = GetEntityCoords(ped)
            local rot = GetGameplayCamRot(2)
            local forward = getForwardVector(rot)
            local camRight = GetEntityRightVector(ped)

            if IsControlPressed(0, 32) then coords = coords + (forward * noClipSpeed) end
            if IsControlPressed(0, 33) then coords = coords - (forward * noClipSpeed) end
            if IsControlPressed(0, 34) then coords = coords - (camRight * noClipSpeed) end
            if IsControlPressed(0, 35) then coords = coords + (camRight * noClipSpeed) end
            if IsControlPressed(0, 44) then coords = coords + vector3(0.0, 0.0, noClipSpeed) end
            if IsControlPressed(0, 38) then coords = coords - vector3(0.0, 0.0, noClipSpeed) end

            SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, true, true, true)
            SetEntityRotation(ped, 0.0, 0.0, rot.z, 2, true)
        end

        if godMode then
            SetPlayerInvincible(PlayerId(), true)
            SetEntityInvincible(ped, true)
        end

        if invisible then
            SetEntityVisible(ped, false, false)
        end

        if superJump then
            sleep = 0
            SetSuperJumpThisFrame(PlayerId())
        end

        if fastRun then
            sleep = 0
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.49)
        else
            SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        end

        if showCoords then
            sleep = 0
            local c = GetEntityCoords(ped)
            local h = GetEntityHeading(ped)
            SetTextFont(4)
            SetTextProportional(0)
            SetTextScale(0.35, 0.35)
            SetTextColour(255, 255, 255, 220)
            SetTextEntry('STRING')
            SetTextOutline()
            AddTextComponentString(string.format('X: %.2f | Y: %.2f | Z: %.2f | H: %.2f', c.x, c.y, c.z, h))
            DrawText(0.015, 0.76)
        end

        if frozenTime then
            local h = GetClockHours()
            local m = GetClockMinutes()
            NetworkOverrideClockTime(h, m, 0)
        end

        if blackoutEnabled then
            SetArtificialLightsState(true)
            SetArtificialLightsStateAffectsVehicles(false)
        end

        if engineForcedOn then
            local vehicle = GetVehiclePedIsIn(ped, false)
            if vehicle ~= 0 then
                SetVehicleEngineOn(vehicle, true, true, true)
            end
        end

        Wait(sleep)
    end
end)
