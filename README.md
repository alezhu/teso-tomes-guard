# TomesGuard

**TomesGuard** is a lightweight quality-of-life add-on for *The Elder Scrolls Online* (ESO) designed to prevent UI lockups and fatal Lua security taint errors when opening the **Tamriel Tomes** (Endless Archive / Seasonal Tomes / Direct Purchase) interface while other UI panels (such as mail, inventory, or notifications) are open.

---

### The Problem

In ESO, opening the Tamriel Tomes screen invokes the native engine function `QuerySkuCatalog()`, which is a **protected / private** C-level function requiring an untainted execution callstack.

When switching directly to Tamriel Tomes while another interface is closing (e.g., closing `mailInbox` or `inventory`), any add-on that hooks into scene transitions or fragment animations (such as older versions of minimaps, `LibMainMenu`, or UI overhauls) contaminates the callstack with untrusted code. This causes the game engine to block `QuerySkuCatalog()` with the error:

```text
/EsoUI/Ingame/DirectPurchase/DirectPurchase_Manager.lua:42: Attempt to access a private function 'QuerySkuCatalog' from insecure code.
```

Because this error occurs mid-transition inside `ZO_Scene:SetState()`, ESO's scene manager gets stuck in an incomplete state (`disallowEvaluateTransitionCompleteCount`), leaving the player with an invisible UI and locked controls that require `/reloadui`.

---

### How TomesGuard Solves It

1. **Detects Conflict:** When Tamriel Tomes is requested (via keybind `F4` or the main menu bar), TomesGuard checks whether another interface panel is active.
2. **Prevents Taint & UI Freeze:** If a conflicting window is open, it blocks the transition and alerts the player to close the current window first.
3. **Keeps UI Intact:** The active window remains functional, no Lua errors are triggered, and `/reloadui` is no longer needed.

---

### Localization

TomesGuard supports multi-language localization:
- English (`en`)
- Russian (`ru`)
- German (`de`)
- French (`fr`)

---

### Installation

1. Download or clone this repository.
2. Copy the `TomesGuard` folder into your ESO AddOns directory:
   - **Windows:** `Documents\Elder Scrolls Online\live\AddOns\TomesGuard`
   - **Mac:** `~/Documents/Elder Scrolls Online/live/AddOns/TomesGuard`
3. Ensure `TomesGuard` is enabled in your game's **Add-Ons** menu.

---

### License

This project is licensed under the [MIT License](LICENSE).
