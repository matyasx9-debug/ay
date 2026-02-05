Config = {}

-- Rang rendszer: 0 = nincs admin, 1-5 = admin szintek
Config.MaxRank = 5
Config.BossRank = 5

-- Rang alapú jogosultság identifier szerint
Config.AdminRanks = {
    -- ['license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'] = 5,
    -- ['license:yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'] = 2,
}

-- Opcionális ACE fallback (ha rank nincs identifierben)
Config.UseAceFallback = true
Config.AceRanks = {
    [5] = 'devpanel.rank5',
    [4] = 'devpanel.rank4',
    [3] = 'devpanel.rank3',
    [2] = 'devpanel.rank2',
    [1] = 'devpanel.rank1'
}

Config.OpenCommand = 'devpanel'
Config.DutyCommand = 'dutyay'
Config.ToggleKeybind = 'F7'

Config.DefaultWeather = 'EXTRASUNNY'
Config.DefaultTime = { hour = 12, minute = 0 }

Config.EnableWebhookLogs = false
Config.WebhookUrl = ''

-- Melyik funkcióhoz minimum milyen rang kell
Config.ActionRanks = {
    duty = 1,
    godmode = 2,
    heal = 1,
    invisible = 2,
    noclip = 2,
    setNoclipSpeed = 2,
    coords = 1,
    superJump = 3,
    fastRun = 2,
    cleanPed = 1,
    tpWaypoint = 2,
    tpCoords = 3,
    giveWeapon = 3,
    spawnVehicle = 2,
    deleteVehicle = 2,
    fixVehicle = 1,
    fullFuel = 1,
    flipVehicle = 1,
    maxVehicle = 3,
    forceEngine = 1,
    setWeather = 4,
    setTime = 4,
    freezeTime = 4,
    blackout = 5,
    clearArea = 4,
    announce = 2
}

-- Duty ruhák (freemode pedre optimalizált)
-- component index: 3=torso,4=pants,6=shoes,8=undershirt,11=top
Config.DutyOutfits = {
    [1] = {
        label = 'Admin I',
        model = 'mp_m_freemode_01',
        components = {
            [3] = { drawable = 0, texture = 0 },
            [4] = { drawable = 25, texture = 2 },
            [6] = { drawable = 25, texture = 2 },
            [8] = { drawable = 15, texture = 0 },
            [11] = { drawable = 287, texture = 2 }
        }
    },
    [2] = {
        label = 'Admin II',
        model = 'mp_m_freemode_01',
        components = {
            [3] = { drawable = 0, texture = 0 },
            [4] = { drawable = 25, texture = 5 },
            [6] = { drawable = 25, texture = 5 },
            [8] = { drawable = 15, texture = 0 },
            [11] = { drawable = 287, texture = 5 }
        }
    },
    [3] = {
        label = 'Admin III',
        model = 'mp_m_freemode_01',
        components = {
            [3] = { drawable = 0, texture = 0 },
            [4] = { drawable = 25, texture = 9 },
            [6] = { drawable = 25, texture = 9 },
            [8] = { drawable = 15, texture = 0 },
            [11] = { drawable = 287, texture = 9 }
        }
    },
    [4] = {
        label = 'Admin IV',
        model = 'mp_m_freemode_01',
        components = {
            [3] = { drawable = 0, texture = 0 },
            [4] = { drawable = 25, texture = 11 },
            [6] = { drawable = 25, texture = 11 },
            [8] = { drawable = 15, texture = 0 },
            [11] = { drawable = 287, texture = 11 }
        }
    },
    [5] = {
        label = 'Admin V (Boss)',
        model = 'mp_m_freemode_01',
        components = {
            [3] = { drawable = 0, texture = 0 },
            [4] = { drawable = 25, texture = 14 },
            [6] = { drawable = 25, texture = 14 },
            [8] = { drawable = 15, texture = 0 },
            [11] = { drawable = 287, texture = 14 }
        }
    }
}
