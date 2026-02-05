# AY Panel (FiveM)

Modern NUI panel FiveM-hez, admin + developer funkciókkal.

## Amit kérted és benne van
- A név már **nem "Developer Panel"**, hanem alapból **"AY Panel"**.
- A panel neve és a logo szöveg **configból szerkeszthető**:
  - `Config.Branding.panelName`
  - `Config.Branding.panelLogo`
- Van külön **Developer szekció**, amit csak a `developer = true` rang lát.
- A Developer részbe bekerültek a fejlesztő funkciók:
  - Print Coords
  - Set Ped Model
  - Spawn Object
  - Delete Aimed Entity
  - No Ragdoll
  - Entity Debug Overlay

## Fontos config pontok (`devpanel/config.lua`)
- `Config.Ranks`: saját rangok, saját nevek.
- `canManageAdmins = true`: ez a rang kezelheti az admin rangokat (`/setadminay`).
- `developer = true`: ez a rang látja a developer szekciót.
- `Config.ActionRanks`: minden funkcióhoz minimum rang.
- `Config.Branding`: panel név + logo.

## Parancsok
- `/devpanel` – panel nyitása
- `/dutyay` – duty váltás
- `/setadminay [id] [rank]` – rang állítás (csak erre jogosult rang)
