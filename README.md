# AY DevPanel (FiveM)

Egy modern, NUI-alapú developer panel FiveM szerverekhez, most már **Admin 1 - Admin 5** rangrendszerrel, duty móddal és admin controllerrel.

## Új rendszer (kérés alapján)
- **Admin rangok 1-től 5-ig**
- **Ranghoz kötött funkciók** (minden action minimum ranghoz van kötve)
- **Admin Controller (Boss = Admin 5)**
- **Duty rendszer**:
  - Parancs: `/dutyay`
  - Panelből is kapcsolható (Duty ON/OFF gomb)
- Duty belépéskor rang szerinti admin ruha (zöld árnyalatok rankenként)
- Duty kilépéskor visszaáll az előző ped/skin (amit duty előtt viselt a játékos)

## Fontos parancsok
- Panel nyitás: `/devpanel`
- Duty váltás: `/dutyay`
- Rang állítás (csak Boss/Admin 5 vagy konzol):
  - `/setadminay [id] [0-5]`

## Rang alapú jogosultságok
A `config.lua` fájlban található:
- `Config.ActionRanks` táblában adható meg, melyik funkcióhoz minimum milyen rang kell.
- A legtöbb funkció duty állapotot is igényel.

## Rang hozzárendelés
Két mód:
1. **Identifier alapú** (ajánlott):
   - `Config.AdminRanks['license:...'] = 5`
2. **ACE fallback**:
   - `Config.AceRanks[5] = 'devpanel.rank5'`, stb.

## Telepítés
1. Másold a `devpanel` mappát a `resources` könyvtárba.
2. `server.cfg` példa:
   ```cfg
   ensure devpanel

   # opcionális ACE fallback
   add_ace group.owner devpanel.rank5 allow
   add_principal identifier.license:YOUR_LICENSE group.owner
   ```
3. A `config.lua`-ban töltsd fel az `AdminRanks` táblát a license ID-kkel.

## Megjegyzés
- A duty ruha jelenleg freemode alapra van optimalizálva (`Config.DutyOutfits`).
- Ha egyedi ruharendszert használsz, finomhangold a `Config.DutyOutfits` komponenseit.
- Opcionális webhook log támogatás továbbra is elérhető (`Config.WebhookUrl`).
