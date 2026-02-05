# AY DevPanel (FiveM)

Egy modern, NUI-alapú developer panel FiveM szerverekhez, sok extra fejlesztői/admin funkcióval.

## Funkciók
### Player
- Godmode
- Heal + armor
- Láthatatlanság (Invisible)
- Noclip + állítható noclip speed
- Super Jump
- Fast Run
- Koordináta HUD
- Clean ped (vér/sérülés/kosz törlés)
- Teleport waypointra
- Teleport konkrét XYZ koordinátára
- Fegyver adás (weapon hash név alapján)

### Vehicle
- Jármű spawn
- Jármű javítás
- Full fuel
- Flip vehicle
- Max upgrade (modok + turbo stb.)
- Force engine ON
- Jármű törlés

### World
- Időjárás állítás
- Idő állítás
- Freeze time
- Blackout (globális)
- Area tisztítás (peds/vehicles/objects) megadott sugárral

### Communication / Security
- Globál announce üzenet
- Jogosultság ellenőrzés ACE vagy identifier alapján
- Opcionális Discord webhook audit log

## Telepítés
1. Másold a `devpanel` mappát a `resources` könyvtárba.
2. `server.cfg`:
   ```cfg
   ensure devpanel
   add_ace group.admin devpanel.use allow
   add_principal identifier.license:YOUR_LICENSE group.admin
   ```
3. Ha identifier alapú jogosultságot szeretnél, akkor `config.lua`:
   - `Config.PermissionMode = 'ids'`
   - töltsd fel a `Config.AllowedIdentifiers` listát.

## Használat
- Chat parancs: `/devpanel`
- Keybind: `F7` (átállítható a `config.lua`-ban)

## Megjegyzés
- A script framework-független (ESX/QBCore nélkül is fut).
- Bizonyos funkciók (pl. üzemanyag) szerver oldali fuel resource-tól függhetnek.
