 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/README.md b/README.md
new file mode 100644
index 0000000000000000000000000000000000000000..ddd78c8ff9ca1d9c6fc061832f02370a9c8d74bb
--- /dev/null
+++ b/README.md
@@ -0,0 +1,34 @@
+# AY DevPanel (FiveM)
+
+Egy modern, NUI-alapú developer panel FiveM szerverekhez.
+
+## Funkciók
+- Godmode
+- Heal + armor
+- Noclip
+- Koordináta HUD
+- Teleport waypointra
+- Jármű spawn / javítás / törlés / tankolás
+- Időjárás és idő állítás
+- Freeze time
+- Globál announce üzenet
+- Jogosultság ellenőrzés ACE vagy identifier alapján
+
+## Telepítés
+1. Másold a `devpanel` mappát a `resources` könyvtárba.
+2. `server.cfg`:
+   ```cfg
+   ensure devpanel
+   add_ace group.admin devpanel.use allow
+   add_principal identifier.license:YOUR_LICENSE group.admin
+   ```
+3. Ha identifier alapú jogosultságot szeretnél, akkor `config.lua`:
+   - `Config.PermissionMode = 'ids'`
+   - töltsd fel a `Config.AllowedIdentifiers` listát.
+
+## Használat
+- Chat parancs: `/devpanel`
+- Keybind: `F7` (átállítható a `config.lua`-ban)
+
+## Megjegyzés
+A script framework-független (ESX/QBCore nélkül is fut).
 
EOF
)
