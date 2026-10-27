--[=[
    Harry Extensions (documented-API-only build)
    Compatible with the Lilac Plugin Framework.

    Uses only what the Lilac plugin docs describe:
      api.name / api.version
      api.ui:addsection, sec:toggle / slider / dropdown / colorpicker / keybind
      api.ui:notify
      api.config:get / api.config:set
      api.ragebot:getstats

    Removed from the previous build because they are not documented:
      - sec:textbox            (Text is now a preset dropdown; the image URL
                                is read from the config key
                                "crosshair_image_url" only)
      - control:setvisible()   (all controls are always visible now)
      - api.game.fighter       (melee slot swapping / slot detection removed;
                                the 2 key is still pressed on enable, respawn
                                and after a weapon pick)
      - overriding api.unload  (cleanup now runs through a global hook that
                                is called when the plugin is re-initialised)
      - Lilac internals (library.ScreenGui) used to find the menu
      - passing `init` to lilac:plugin in the standalone path

    ============================================================================
    Zombie Tower Ragebot  (left side, top)
    ============================================================================
      Only settings: the enable toggle and its keybind. Everything else is
      fixed (see "Orbit Until Kill" and "Enemy Plans" below).
      Every mob starts in hover (your Y = mob Y + 5, directly over it, no
      orbit; plans with a bigger height such as acid floors or bosses use that
      height instead). The near orbit no longer exists.
        - can't hit from hover -> far position (static, 25 studs along X from
          the mob, at least 15 high); nothing orbits or spins any more
        - can't hit from the far position -> back to hover
      Slot follows the mode: hover = melee (key 2), far position = gun
      (key 1). Slot changes and M1 clicks are simulated with virtual input.
      The slot key is re-pressed every 1.5 s while that weapon is wanted, and
      M1 clicks pause for 0.15 s after each slot press.
      "Can't hit" means the mob lost no health for the plan's swap time.
      Drops are collected, mob triggers advanced, and the first weapon option
      on screen is chosen after a weapon drop.

      NOTE: you might have to disable the rage in the boss level and kill the
      bosses yourself.

    FFA Helper (right side): Disable 3D Rendering, Disable GUI Rendering,
    Auto Respawn.

    Crosshair (left) and Crosshair Text & Image (right) are cosmetic only.

    ============================================================================
    Orbit Until Kill  (always on, no toggle)
    ============================================================================
      - M1 clicks are simulated (virtual input) while a target exists (orbit,
        hover, stand). It
        is never paused, not even with the Lilac menu or any other GUI open.
      - Locks onto one mob (highest enemy-plan priority first, then nearest)
        and orbits it until its health reaches 0, then picks the next one.
      - With no health drop on the mob, swap hover <-> far position after the
        swap time of that enemy's plan (default 15 s). Any health drop resets
        the timer.
      - After 60 s with no health drop the mob is skipped for 30 s and a
        different target is chosen (stays on it if it is the only one alive).
      - Constants: SWAP_SECONDS, RETARGET_SECONDS, SKIP_SECONDS at the top of
        the Zombie Tower section.

    ============================================================================
    Enemy Plans  (PLANS table in the Zombie Tower section; first match wins)
    ============================================================================
      Fields: prio (higher targeted first), radius (only radius = 0 is used:
      stand on the mob; the far position is 25 studs away), height (minimum
      studs above the mob for hover and orbit), hide (no longer used: every
      enemy hovers first), swap (seconds without a hit before swapping).
      Plans with cycle (Charger Zombie) or stand (Chicken) ignore the ladder.
      Names are matched as lower-case letters only, so "Tin Hat Zombie" is
      "tinhatzombie". Unmatched names use the default plan (basic zombie).

      Zombie Tower
        Giant Chombie (F17) prio 40, orbit 30 at y15, hover first, swap 10 s
        Chombie Egg         prio 30, hover first (orbit fallback)
        Brute Zombie        prio 15, orbit 35, hover, swap 10 s
        Ghost               prio 10, hover first (y 5), then the orbit ladder
        Skeleton            prio 10, always orbit (M1 spam)
        Reaper (= Grim Reaper) prio 10, orbit 10, always orbit (M1 spam)
        Hunter Zombie       prio 5, slider radius, hover, swap 10 s
        Charger Zombie      prio 5, NO orbit: x 10 / y 20 for 2 s, then x 0 / y 5 for 0.3 s, repeat
        Exploding Zombie    prio 5, orbit 30 at y15, always orbit
        Tin Hat / Basic     prio 0, slider radius, hover, swap 15 s
        Chicken             prio 0, no orbit: y 0, 35 studs away on X, shot with the gun
      Gargoyle Tower
        Acidic Gargoyle Overlord (F17)  prio 40, orbit 30 at y15, always orbit
        Giant Gargoyle (F10)            prio 40, orbit 30 at y15, hover first, swap 10 s
        Acidic Gargoyle                 prio 10, orbit 10, height 10, always orbit
        Gargoyle                        same as Acidic Gargoyle (orbit, height 10)
        Electric / Tesla Zombie         prio 0, orbit 30 at y15, always orbit
        Dark Matter Baby                prio 0, orbit 8, hover, swap 15 s
        Black Ghost                     prio 0, orbit 10, always orbit (M1 spam)

    ============================================================================
    CHANGELOG  (newest first; every change gets an entry here)
    ============================================================================
    v2.16.1
      - Slot swapping reworked to behave like Auto Respawn: the key press is
        the same virtual key down / key up (0.05 s) inside a pcall. Because a
        single press on a mode change could be missed and was never retried,
        the wanted slot key is now re-pressed every 1.5 s (SLOT_REASSERT_SECONDS)
        while a target exists, and M1 clicks pause for 0.15 s after each press
        so the click spam cannot block the swap.
    v2.16
      - Slot changes are simulated too: number keys 1 / 2 are pressed with
        VirtualInputManager key events (held 0.1 s) only. The executor's
        keypress / keyrelease are no longer used.
      - Slot swapping now follows the mode: hover uses melee (key 2), the far
        position uses the gun (key 1); Charger Zombie stays on melee and the
        Chicken stays on the gun. The key is pressed whenever the wanted
        weapon differs from the last one selected.
      - Removed the spinning: the far "orbit" no longer circles the mob, it is
        a static spot 25 studs along X (at least 15 high). The Orbit Speed
        slider and its config key ztr_orbit_speed are gone.
    v2.15.1
      - The autoclicker now simulates M1 clicks with VirtualInputManager mouse
        events (down + up at the middle of the screen, every 0.02 s) instead
        of the executor's real mouse functions (mouse1click, mouse1press,
        mouse1release), so the real cursor is never clicked.
    v2.15
      - Added a keybind toggle for the Zombie Tower Ragebot ("Zombie Tower
        Ragebot Key", flag ztr_keybind, under the enable toggle). Pressing the
        bound key switches the ragebot on or off, updates the toggle on screen
        when the toggle object allows it, and shows a notification. Key
        presses in chat or text boxes are ignored, and so is the press that
        picks the key. sec:keybind has no option details in the docs, so the
        key is read from the control's callback value and the saved config.
    v2.14.1
      - Removed all menu / GUI detection. The melee autoclicker and the slot
        swapper (keys 1 and 2) are always active while the ragebot is on,
        whether or not the Lilac menu or any other GUI is open.
    v2.14
      - Near orbit removed; everything hovers. Every mob starts in hover (Y =
        mob Y + 5, or the plan's height when that is higher, e.g. acid floors
        and bosses). If hover cannot hit (no health drop for the plan's swap
        time) it swaps to the far orbit (25 studs, at least 15 high) and back.
        Removed: the near orbit (7 studs), the hit-while-hovering -> near
        orbit rule, near_failed, and the use of plan.hide (the field is kept
        but ignored). Skeleton, Ghost and the other plans that used to orbit
        now hover first too.
    v2.13.4
      - Ghost now hovers (hide = "hover"): it starts with the hover step
        (your Y = ghost Y + 5, M1 spam) and follows the normal ladder (hit
        while hovering -> near orbit, can't hit -> orbit/far orbit). Black
        Ghost is unchanged.
    v2.13.3
      - Menu detection simplified to the Lilac menu only: removed the text
        box focus check and the cursor-over-menu check. The clicker and slot
        keys pause while the Lilac menu (found by ScreenGui name, or by
        "Lilac" label text in gethui / CoreGui only) is enabled with a visible
        frame of at least 300 x 200 px.
      - Charger Zombie timings: hide spot (x 10, y 20) for 2 s, attack spot
        (x 0, y 5) for 0.3 s (were 0.2 s and 0.03 s).
    v2.13.2
      - Charger Zombie hide spot moved to x = 10 (10 studs along X from the
        mob, y 20, 0.2 s); the attack spot stays above the mob (x 0, y 5,
        0.03 s).
      - Fix: the autoclicker stopped working. The menu check from v2.13.1
        counted the menu as "open" whenever any big frame was visible (or any
        text box had focus), which could pause the clicker permanently. It now
        pauses only while the cursor is over a visible large frame of the Lilac
        menu, or one of the menu's own text boxes has focus, and re-checks
        every 0.1 s.
    v2.13.1
      - The autoclicker and the slot key presses now pause while the Lilac
        menu is open or a text box has focus, so clicks no longer hit menu
        buttons. The menu is found by ScreenGui name (lilac / linoria /
        obsidian) or "Lilac" label text in gethui, CoreGui and PlayerGui, and
        counts as open when it is enabled and has a visible frame at least
        300 x 200 px (checked every 0.25 s). Teleporting and targeting are
        not paused.
    v2.13
      - Near orbit is now 7 studs (was 10).
      - M1 is spam-clicked (every 0.02 s) instead of held, because a held
        click sometimes did not register. Uses mouse1click, then
        mouse1press + mouse1release, then a virtual mouse click.
      - Slot changes simply press key 1 (gun) or key 2 (melee). The key press
        goes through the executor's keypress/keyrelease when available (held
        0.08 s), otherwise a virtual key event. The old "re-send M1 after a
        slot swap" timer is gone.
    v2.12.1
      - Removed the separate "Grim Reaper" plan that ignored it as an instant
        kill enemy. The normal Reaper is the Grim Reaper, so the Reaper plan
        now matches both names ("reaper" and "grim") and it is targeted like
        any other enemy (prio 10, orbit, M1 held).
    v2.12
      - Underground removed. The old underground step (adaptive floor scan,
        multi-layer stack walk, teleport under the floor) is replaced by a
        hover step: your Y is set to the mob's Y + 5 (HOVER_HEIGHT), directly
        over it, camera on the mob, M1 held. Plans now use hide = "hover"
        instead of "underground"; the ladder is unchanged (start hover/near,
        hit while hovering -> near, can't hit near -> hover -> far).
    v2.11
      - Skeleton always orbits (M1 spam), no underground.
      - Charger Zombie: no orbit. It hovers over the mob at y = 20 for 0.2 s,
        then drops to y = 5 for 0.03 s, and repeats until it dies (M1 held).
      - Chicken: no orbit. Stays at y = 0, 35 studs away on the X axis, and
        shoots it with the gun (key 1, M1 held); melee (key 2) comes back
        when the target changes or nothing is left.
      - Gargoyle now uses the Acidic Gargoyle settings (orbit, height 10).
      - Plans gained `cycle` and `stand` fields for these behaviours.
    v2.10.1
      - Fix: "attempt to iterate over a nil value" every frame in the zombie
        tower step. refresh_blocked called CollectionService:GetTags() with no
        instance, which returns nothing; it now uses GetAllTags() (wrapped in
        pcall) to find the lava / hazard / out-of-bounds tags.
    v2.10
      - Mode ladder replaces the old attack/hide swap and the gun mode.
        Near orbit is 10 studs and far orbit is 25 studs (at least 15 studs
        high); per-plan radii are no longer used except radius = 0 (chicken).
        Mobs always start underground (plans that allow it) or in near orbit.
        Getting hit while underground switches to near orbit. If the near
        orbit cannot hit the mob (no health drop for the plan's swap time) it
        goes underground, then to the far orbit; orbit-only enemies go near ->
        far. Removed: switching to the gun (key 1) on hit, the 35 stud gun
        orbit, the post-hit underground hold, and the ammo check.
    v2.9.4
      - Fix: the underground hide could leave you above the mob. The hide
        height is now clamped so it can never be higher than 1.5 studs below
        the mob's lowest body part, whatever the floor scan returns. A failed
        underground teleport (an error inside the scan) used to be swallowed,
        leaving you at the orbit position above the mob; it is now reported
        once in the console as "Underground teleport failed".
    v2.9.3
      - Hide depth is now 1.5 studs under the bottom of the floor stack
        (UNDERGROUND_BELOW_FLOOR, was 0.2). The layer merge distance goes back
        to 0.5 studs (STACK_GAP), undoing the 2 stud merge change of v2.9.2.
    v2.9.2
      - Layer merge distance is now 2 studs (was 0.5): the scan looks 0 to 2
        studs under each layer's bottom (a 2 stud tall probe plus a 2 stud
        ray) and merges any ground part found there into the stack before
        hiding 0.2 studs under the whole stack.
    v2.9.1
      - Notifications: the toast text is now sent under every common field
        name (title/content/duration plus text, message, description, body and
        capitalised variants) and always coerced to strings, so the message
        body shows even if this Lilac build reads a different field. The load
        message no longer errors when api.version is missing.
    v2.9
      - Adaptive underground now handles stacked floor layers. It finds the
        highest ground part nearest to the mob (casting from just above its
        feet, skipping invisible non-collidable parts), then walks down every
        layer that overlaps or touches it (gap up to 0.5 studs, 12 layers
        max) and hides 0.2 studs below the bottom of the whole stack instead
        of the bottom of the first part only. The floor ray no longer
        requires CanCollide; parts count when they are collidable or visible.
    v2.8
      - Underground is now an adaptive method. Instead of a fixed offset
        below the mob's feet, the script raycasts down from the mob, finds
        the solid part it would noclip through, measures that part's bottom
        edge (size and rotation aware) and places you 0.2 studs under it.
        Replaces UNDERGROUND_BELOW_FEET (3 studs) with UNDERGROUND_BELOW_FLOOR
        (0.2) and UNDERGROUND_FALLBACK_DEPTH (3, used when no floor part is
        found). The floor ray now respects CanCollide so only solid floors
        count; Terrain falls back to the fallback depth.
    v2.7
      - Underground depth set to 3 studs below the mob's feet (was 1.2).
      - Crosshair text is customizable again: a "Custom Text Input" textbox
        (flag crosshair_text) plus the preset dropdown (now flag
        crosshair_text_preset). sec:textbox is undocumented, so if Lilac has
        no such control it is skipped and the config key crosshair_text can
        still hold any text.
      - Plans reworked (M1 is spammed in every phase):
          * underground (starts hidden, orbit fallback): Charger Zombie,
            Skeleton, Chombie Egg, Tin Hat Zombie, Dark Matter Baby, Brute
            Zombie (Giant bosses and Hunter/basic keep their underground too)
          * 10 stud orbit, never hide: Ghost, Black Ghost, Gargoyle, Reaper,
            Acidic Gargoyle (keeps its 10 stud height over acid)
          * high orbit, 30 studs at y = 15: all bosses, Charger Zombie,
            Exploding Zombie, Tesla Zombie
      - Underground remade: you now stand 3 studs below the mob's feet
        (floor found with a downward raycast from the mob, falling back to its
        lowest body part) instead of 5 studs below its hitbox. The old
        auto_depth/margin/max_depth fields are gone.
      - Underground plans start in the underground phase on a new target and
        after a gun hit, instead of orbiting for `swap` seconds first.
      - Orbit-only plans (hide = "none") no longer hide underneath after a
        gun hit; they go back to orbit-melee.
      - M1 auto hold restored: M1 is now held whenever a target exists, in
        the orbit, underground, gun and post-hit hold phases, and released
        when there is no target, the ragebot is off or you are dead. The
        press is re-sent every 1.5 s and 0.3 s after each slot swap (key 1/2)
        so swapping weapons does not drop the click.
      - Removed void hide: reapers, explosive zombies, skeletons and ghosts no
        longer hide at a huge depth; every mob now uses the normal underground
        depth (5 studs, or the Charger's measured depth).
      - Charger Zombie orbit distance fixed at 10 studs (was the 20 stud
        default, too far from its hitbox to land hits).
      - Added a Charger Zombie plan.
    v2.6
      - Zombie Tower Ragebot settings removed: only the enable toggle and
        Orbit Speed remain. Removed the Orbit Until Kill toggle (now always
        on), Orbit Radius (fixed 20, plans may override), Void Hide Time and
        Attack Time sliders, and the old M1 attack/hide cycle with them.
        Config keys ztr_orbit_only, ztr_orbit_radius, ztr_hide_time and
        ztr_attack_time are no longer used.
      - Out of bullets: gun mode ends immediately and switches back to melee
        (key 2), and getting hit with an empty gun no longer switches to it.
        Ammo is read best-effort from a numeric "ammo" attribute on the held
        tool or an on-screen label named "ammo"; if neither is found the
        check does nothing.
      - Underground depth confirmed at 5 studs.
      - Added per-enemy plans (PLANS table) for both towers so the ragebot can
        farm whole runs: target priority (bosses, eggs, brutes first), fixed
        orbit distance, orbit height over acid/shock floors, and per-enemy
        orbit/underground swap rules. Grim Reaper is never targeted. Replaces
        the old boss list, the hard-coded explosive 55-stud radius (now the
        Exploding Zombie plan) and the chicken special case (now a plan).
      - Orbit distance around explosive zombies is now 55 studs (fixed,
        overrides the Orbit Radius slider; applies to the normal orbit and the
        gun-mode orbit).
      - Underground hide depth reduced from 10 to 5 studs (applies to the
        attack/hide cycle, Orbit Until Kill swap and the post-hit hold).
      - Reapers, explosive zombies, skeletons and ghosts now keep orbiting in
        Orbit Until Kill mode instead of hiding (other mobs still hide 10
        studs underground on the 15 s swap).
      - Added 15 s orbit <-> underground swap when the mob is not losing
        health, and a 60 s retarget (skip the mob for 30 s, pick another).
      - Added "Orbit Until Kill (No M1)" toggle (flag ztr_orbit_only, default
        on): no M1 held, sticky target lock until the mob dies.
      - Rebuilt to use only API documented in plugins.md:
          * removed sec:textbox (Text is now a preset dropdown; the image URL
            is read from config key crosshair_image_url only)
          * removed control:setvisible (all controls always visible)
          * removed api.game.fighter (no slot swapping / slot detection; keys
            1 and 2 are still tapped)
          * stopped overriding api.unload (cleanup runs through a getgenv hook
            on the next init)
          * removed Lilac internals used to find the menu (name/label text only)
          * standalone path registers {name, author, version} then runs init
      - Config schema version bumped to 3.
    v2.5
      - Previous build (Zombie Tower ragebot with attack/hide cycle, FFA
        helper, crosshair, text and image overlay).
]=]

local RunService          = game:GetService("RunService")
local Players             = game:GetService("Players")
local Workspace           = game:GetService("Workspace")
local UserInputService    = game:GetService("UserInputService")
local StarterGui          = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService   = game:GetService("CollectionService")
local LocalPlayer         = Players.LocalPlayer

local GENV = (getgenv and getgenv()) or _G

local function safe_notify(api, props)
    local title = tostring(props.title or (api and api.name) or "Lilac")
    local content = tostring(props.content or props.text or props.message or "")
    local duration = tonumber(props.duration) or 3

    -- The documented fields are title / content / duration. The same text is
    -- also sent under the other names toast systems commonly read, so the body
    -- shows even if this Lilac build expects a different field.
    local payload = {
        title = title, content = content, duration = duration,
        text = content, message = content, description = content, body = content,
        Title = title, Content = content, Text = content, Message = content,
        Duration = duration, time = duration,
    }

    local function attempt()
        local ui = api and api.ui
        if ui and type(ui.notify) == "function" then
            local ok = pcall(function()
                ui:notify(payload)
            end)
            if ok then
                return true
            end
        end

        local ok = pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = content,
                Duration = duration,
            })
        end)
        return ok
    end

    task.spawn(function()
        local delays = { 0.15, 0.5, 1, 2, 4 }
        for _, delay in ipairs(delays) do
            task.wait(delay)
            if attempt() then
                return
            end
        end
    end)
end

local FONT_OPTIONS = {
    "UI", "System", "Plex", "Monospace", "Monospace Bold",
}

local TEXT_PRESETS = {
    "LILAC", "Harry Extensions", "harryfemboy", "Ragebot", "Rivals",
}

local CROSSHAIR_ANIMATIONS = {
    "Static", "Bounce", "Rotate", "Bounce + Rotate",
}

local function normalize_crosshair_animation(value)
    if type(value) == "number" then
        return CROSSHAIR_ANIMATIONS[value] or "Static"
    end

    local text = tostring(value or "Static")
    local numeric_index = tonumber(text)
    if numeric_index and CROSSHAIR_ANIMATIONS[numeric_index] then
        return CROSSHAIR_ANIMATIONS[numeric_index]
    end

    for _, option in ipairs(CROSSHAIR_ANIMATIONS) do
        if option == text then
            return option
        end
    end
    return "Static"
end

local function normalize_font_name(value)
    if type(value) == "number" then
        return FONT_OPTIONS[value] or "UI"
    end

    local text = tostring(value or "UI")
    local numeric_index = tonumber(text)
    if numeric_index and FONT_OPTIONS[numeric_index] then
        return FONT_OPTIONS[numeric_index]
    end

    for _, option in ipairs(FONT_OPTIONS) do
        if option == text then
            return option
        end
    end

    local legacy_names = {
        ubu = "Monospace",
        ubuntu = "Monospace",
        minecraft = "Monospace",
        minecraftia = "Monospace",
        pixel = "Monospace",
        monocraft = "Monospace Bold",
        ["monocraft bold"] = "Monospace Bold",
        monospacebold = "Monospace Bold",
        mono = "Monospace",
        code = "Monospace",
        ibmplex = "Plex",
        ["ibm plex"] = "Plex",
        default = "UI",
    }
    return legacy_names[string.lower(text)] or "UI"
end

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

local function color_from(value, fallback)
    if typeof(value) == "Color3" then
        return value
    end

    if type(value) == "table" then
        local r = tonumber(value.r or value[1])
        local g = tonumber(value.g or value[2])
        local b = tonumber(value.b or value[3])
        if r and g and b then
            if r > 1 or g > 1 or b > 1 then
                r, g, b = r / 255, g / 255, b / 255
            end
            return Color3.new(clamp(r, 0, 1), clamp(g, 0, 1), clamp(b, 0, 1))
        end
    end

    return fallback
end

local function color_to_table(color)
    local safe_color = color_from(color, Color3.new(1, 1, 1))
    return { r = safe_color.R, g = safe_color.G, b = safe_color.B }
end

local function round2(value)
    if type(value) ~= "number" then
        return value
    end
    return math.floor(value * 100 + 0.5) / 100
end

local function safe_control(section, method, props)
    local fn = section and section[method]
    if type(fn) ~= "function" then
        return nil
    end

    if method == "slider" and type(props) == "table" then
        local original_callback = props.callback
        props.float = 0.01
        props.min = round2(props.min)
        props.max = round2(props.max)
        props.default = round2(props.default)
        props.callback = function(value, ...)
            value = round2(value)
            if original_callback then
                return original_callback(value, ...)
            end
        end
    end

    local ok, result = pcall(function()
        return fn(section, props)
    end)
    if ok then
        return result
    end
    warn("[Harry Extensions] Could not create " .. method .. " control: " .. tostring(result))
    return nil
end

local PluginDefinition = {
    name = "Harry Extensions",
    author = "harryfemboy",
    version = "2.16.1",
}

function PluginDefinition:init(api)
    -- Re-initialisation (hot reload): tear down the previous instance first.
    if type(GENV.__harry_extensions_cleanup) == "function" then
        pcall(GENV.__harry_extensions_cleanup)
        GENV.__harry_extensions_cleanup = nil
    end

    local connections = {}

    local function track(conn)
        if conn then
            table.insert(connections, conn)
        end
        return conn
    end

    local function cleanup_connections()
        for _, conn in ipairs(connections) do
            if conn and conn.Disconnect then
                pcall(function() conn:Disconnect() end)
            end
        end
        table.clear(connections)
    end

    local CONFIG_SCHEMA_VERSION = 3
    local function migrate_config()
        local version = tonumber(api.config:get("config_schema_version", 0)) or 0

        if version < 1 then
            local legacy_gap = api.config:get("crosshair_gap", nil)
            local current_offset = api.config:get("crosshair_offset", nil)
            if current_offset == nil and legacy_gap ~= nil then
                api.config:set("crosshair_offset", legacy_gap)
            end
        end

        if version < 2 then
            local stored_font = api.config:get("crosshair_text_font", nil)
            if stored_font ~= nil then
                api.config:set("crosshair_text_font", normalize_font_name(stored_font))
            end
        end

        if version ~= CONFIG_SCHEMA_VERSION then
            api.config:set("config_schema_version", CONFIG_SCHEMA_VERSION)
        end
    end

    migrate_config()

    local apply_gui_rendering
    local zt_cleanup

    local ffa_state = {
        disable_3d_render = api.config:get("ffa_disable_3d_render", false),
        disable_gui_render = api.config:get("ffa_disable_gui_render", false),
        auto_respawn      = api.config:get("ffa_auto_respawn", false),
    }

    local ffa_sec = api.ui:addsection({
        name = "FFA Helper",
        side = "right",
    })

    safe_control(ffa_sec, "toggle", {
        name = "Disable 3D Rendering",
        flag = "ffa_disable_3d_render",
        default = ffa_state.disable_3d_render,
        callback = function(v)
            ffa_state.disable_3d_render = v
            api.config:set("ffa_disable_3d_render", v)
            pcall(function()
                RunService:Set3dRenderingEnabled(not v)
            end)
        end,
    })

    safe_control(ffa_sec, "toggle", {
        name = "Disable GUI Rendering",
        flag = "ffa_disable_gui_render",
        default = ffa_state.disable_gui_render,
        callback = function(v)
            ffa_state.disable_gui_render = v
            api.config:set("ffa_disable_gui_render", v)
            if apply_gui_rendering then
                apply_gui_rendering(v)
            end
        end,
    })

    safe_control(ffa_sec, "toggle", {
        name = "Auto Respawn",
        flag = "ffa_auto_respawn",
        default = ffa_state.auto_respawn,
        callback = function(v)
            ffa_state.auto_respawn = v
            api.config:set("ffa_auto_respawn", v)
        end,
    })

    if ffa_state.disable_3d_render then
        pcall(function()
            RunService:Set3dRenderingEnabled(false)
        end)
    end

    local respawn_death_conn = nil

    local function hook_auto_respawn(character)
        if respawn_death_conn then
            pcall(function() respawn_death_conn:Disconnect() end)
            respawn_death_conn = nil
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
            or character:WaitForChild("Humanoid", 5)
        if not humanoid then return end

        respawn_death_conn = humanoid.Died:Connect(function()
            if not ffa_state.auto_respawn then return end

            task.delay(0.3, function()
                if not ffa_state.auto_respawn then return end

                pcall(function()
                    VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.Space, false, game)
                    task.delay(0.05, function()
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                        end)
                    end)
                end)
            end)
        end)
    end

    if LocalPlayer.Character then
        task.spawn(hook_auto_respawn, LocalPlayer.Character)
    end

    track(LocalPlayer.CharacterAdded:Connect(function(character)
        task.spawn(hook_auto_respawn, character)
    end))

    ----------------------------------------------------------------------
    -- Zombie Tower Ragebot
    ----------------------------------------------------------------------
    do
        local zt_lp = Players.LocalPlayer

        local HOVER_HEIGHT = 5   -- hover mode: your Y is this many studs above the mob
        local FAR_ORBIT_RADIUS = 25   -- far / high orbit distance (studs), used when hover cannot hit
        local FAR_ORBIT_HEIGHT = 15   -- minimum height of the far orbit above the ground
        local SWAP_SECONDS = 15       -- seconds without a health drop before moving to the next mode
        local RETARGET_SECONDS = 60   -- give up on a mob that isn't losing health
        local SKIP_SECONDS = 30       -- how long a given-up mob is skipped

        local touched = setmetatable({}, { __mode = "k" })
        local drops = setmetatable({}, { __mode = "k" })

        local function cfg_number(key, default, min, max)
            local value = tonumber(api.config:get(key, default)) or default
            return round2(math.clamp(value, min, max))
        end

        local zt = {
            enabled = api.config:get("ztr_enabled", false),
        }
        local rt = {
            lock_ent = nil,
            lock_hp = 0,
            progress_at = 0,
            skip = setmetatable({}, { __mode = "k" }),
            weapon = "melee",    -- slot currently equipped by the script: "melee" or "gun"
            cycle_state = "hide",
            cycle_at = 0,
            cycle_target = nil,
            mode = nil,          -- "hover" (y + 5 over the mob) or "far" (high orbit)
            mode_at = 0,
            m1_down = false,
            last_cf = nil,
            weapon_choice_until = 0,
            next_choice_scan = 0,
            equip_after = nil,
            last_health = nil,
            hit_pending = false,
            cam_mode = nil,
            cam_target = nil,
            health_conn = nil,
        }
        local weapon_seen = setmetatable({}, { __mode = "k" })

        -- Simulated M1 click: a virtual mouse button down/up pair sent through
        -- VirtualInputManager at the middle of the screen. The executor's real
        -- mouse functions (mouse1click / mouse1press) are not used, so the
        -- real cursor is never clicked.
        local function virtual_mouse(down)
            pcall(function()
                local camera = Workspace.CurrentCamera
                local size = camera and camera.ViewportSize or Vector2.new(800, 600)
                VirtualInputManager:SendMouseButtonEvent(size.X / 2, size.Y / 2, 0, down, game, 0)
            end)
        end

        local function click_once()
            virtual_mouse(true)
            virtual_mouse(false)
        end

        -- m1_set(true) simulates one click; m1_set(false) stops clicking and
        -- makes sure no virtual button is left pressed.
        local function m1_set(down)
            if down then
                rt.m1_down = true
                click_once()
                return
            end
            if not rt.m1_down then return end
            rt.m1_down = false
            virtual_mouse(false)
        end

        -- Simulate M1 clicks repeatedly while a target exists (orbit, hover and
        -- stand phases).
        local M1_CLICK_INTERVAL = 0.02
        local function m1_hold(now)
            rt.m1_down = true
            if now < (rt.click_pause_until or 0) then
                return
            end
            if now - (rt.m1_last or 0) >= M1_CLICK_INTERVAL then
                rt.m1_last = now
                click_once()
            end
        end

        -- Slot change, done the same way as Auto Respawn presses Space: a
        -- virtual key down, then key up 0.05 s later, inside a pcall.
        local function tap_key(keycode)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, keycode, false, game)
                task.delay(0.05, function()
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(false, keycode, false, game)
                    end)
                end)
            end)
        end

        -- The slot key is pressed on every mode change AND re-pressed every
        -- SLOT_REASSERT_SECONDS while the wanted weapon is in use, so a missed
        -- press is retried instead of leaving the wrong weapon out. M1 clicks
        -- pause for SLOT_CLICK_PAUSE after each press so the click spam cannot
        -- block the swap. (Set SLOT_REASSERT_SECONDS to a huge number if your
        -- hotbar un-equips a weapon when its key is pressed twice.)
        local SLOT_REASSERT_SECONDS = 1.5
        local SLOT_CLICK_PAUSE = 0.15

        local function press_slot(weapon)
            local now = os.clock()
            rt.weapon = weapon
            rt.slot_next = now + SLOT_REASSERT_SECONDS
            rt.click_pause_until = now + SLOT_CLICK_PAUSE
            tap_key(weapon == "gun" and Enum.KeyCode.One or Enum.KeyCode.Two)
        end

        local function equip_melee_slot()
            press_slot("melee")
        end

        local function equip_gun_slot()
            press_slot("gun")
        end

        -- Slot follows the mode: melee (key 2) while hovering, gun (key 1) on
        -- the far position.
        local function apply_weapon(wanted)
            if rt.weapon ~= wanted or os.clock() >= (rt.slot_next or 0) then
                press_slot(wanted)
            end
        end

        local CHOICE_WORDS = { "weapon", "choice", "choose", "select", "pick", "reward", "loot", "option" }

        local function gui_is_visible(object)
            local node = object
            while node and node ~= game do
                if node:IsA("GuiObject") and not node.Visible then
                    return false
                end
                if node:IsA("ScreenGui") then
                    return node.Enabled
                end
                node = node.Parent
            end
            return true
        end

        local function path_has_choice_word(object)
            local node = object
            while node and not node:IsA("PlayerGui") do
                local lowered = string.lower(node.Name)
                for _, word in ipairs(CHOICE_WORDS) do
                    if lowered:find(word, 1, true) then
                        return true
                    end
                end
                node = node.Parent
            end
            return false
        end

        local function click_button(button)
            local fired = false
            pcall(function()
                if type(firesignal) == "function" then
                    firesignal(button.MouseButton1Click)
                    pcall(firesignal, button.Activated)
                    fired = true
                end
            end)
            if not fired then
                pcall(function()
                    if type(getconnections) == "function" then
                        for _, signal in ipairs({ button.MouseButton1Click, button.Activated }) do
                            for _, connection in ipairs(getconnections(signal)) do
                                pcall(function() connection:Fire() end)
                                fired = true
                            end
                        end
                    end
                end)
            end
            if not fired then
                pcall(function()
                    local inset = game:GetService("GuiService"):GetGuiInset()
                    local center = button.AbsolutePosition + button.AbsoluteSize / 2 + inset
                    VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
                end)
            end
        end

        local function try_choose_first_weapon()
            local player_gui = zt_lp:FindFirstChildOfClass("PlayerGui")
            if not player_gui then return false end

            local groups = {}
            for _, descendant in ipairs(player_gui:GetDescendants()) do
                if descendant:IsA("GuiButton") and descendant.AbsoluteSize.X > 0
                    and gui_is_visible(descendant) and path_has_choice_word(descendant) then
                    local root_gui = descendant:FindFirstAncestorOfClass("ScreenGui")
                    local lowered_root = string.lower(root_gui and root_gui.Name or "")
                    if not (lowered_root:find("lilac", 1, true) or lowered_root:find("linoria", 1, true)
                        or lowered_root:find("obsidian", 1, true)) then
                        local parent = descendant.Parent
                        groups[parent] = groups[parent] or {}
                        table.insert(groups[parent], descendant)
                    end
                end
            end

            local best_group
            for _, group in pairs(groups) do
                if not best_group or #group > #best_group then
                    best_group = group
                end
            end
            if not best_group then return false end

            table.sort(best_group, function(a, b)
                if a.LayoutOrder ~= b.LayoutOrder then
                    return a.LayoutOrder < b.LayoutOrder
                end
                if a.AbsolutePosition.X ~= b.AbsolutePosition.X then
                    return a.AbsolutePosition.X < b.AbsolutePosition.X
                end
                return a.AbsolutePosition.Y < b.AbsolutePosition.Y
            end)
            click_button(best_group[1])
            return true
        end

        local function watch(part)
            if part.Name == "_drop" then
                drops[part] = true
            elseif part:IsA("Model") and part.Parent and part.Parent:IsA("BasePart") and part:FindFirstChild("Primary") then
                drops[part.Parent] = true
            end
        end
        track(Workspace.DescendantAdded:Connect(watch))
        track(Workspace.DescendantRemoving:Connect(function(part) drops[part] = nil end))
        for _, part in Workspace:GetChildren() do watch(part) end

        local function touch(part, target)
            firetouchinterest(part, target, 0)
            firetouchinterest(part, target, 1)
        end

        local function get_tower()
            return Workspace:FindFirstChild("Zombie Tower") or Workspace:FindFirstChild("Gargoyle Tower")
        end

        local function entities()
            local tower = get_tower()
            local holder = tower and tower:FindFirstChild("Entities")
            local list = holder and holder:GetChildren() or {}
            if tower then
                for _, d in CollectionService:GetTagged("Entity") do
                    if d:IsDescendantOf(tower) and d:FindFirstChildOfClass("Humanoid") then
                        local already = false
                        for _, v in list do
                            if v == d then already = true; break end
                        end
                        if not already then table.insert(list, d) end
                    end
                end
            end
            return list
        end

        ------------------------------------------------------------------
        -- Enemy plans (first match wins; names are lower-cased with spaces,
        -- underscores and punctuation removed before matching).
        --   prio    higher is targeted first, ties go to the nearest mob
        --   radius  fixed orbit distance in studs (nil = Orbit Radius slider)
        --   height  studs above the ground to orbit at (acid / shock floors)
        --   hide    "hover" = use the hover step (your Y = mob + 5) of the
        --           ladder, "none" = never hover, orbit only
        --   swap    seconds without a health drop before swapping
        --   cycle   no orbit: alternate between a hide spot (hide_x studs along
        --           X from the mob, hide_y high, for hide_time s) and an attack
        --           spot (attack_x, attack_y, for attack_time s) until it dies
        --   stand   no orbit: stay still `x` studs along X from the mob at
        --           height `y`; gun = true shoots it with the gun (key 1)
        --   ignore  never target (anything else falls back to DEFAULT_PLAN)
        --   Hover plans start hovering on a new target (M1 is spammed from 5
        --   studs above the mob) and fall back to the orbit after `swap`
        --   seconds without a health drop.
        ------------------------------------------------------------------
        local PLANS = {
            -- Zombie Tower
            { label = "Giant Chombie (F17 boss)", match = { "giantchombie", "giantchrombie" },
                prio = 40, radius = 30, height = 15, hide = "hover", swap = 10 },
            { label = "Chombie Egg (spawner)", match = { "egg" },
                prio = 30, radius = 6, height = 0, hide = "hover", swap = 15 },
            -- Gargoyle Tower
            { label = "Acidic Gargoyle Overlord (F17 boss)", match = { "overlord" },
                prio = 40, radius = 30, height = 15, hide = "none", swap = 15 },
            { label = "Giant Gargoyle (F10 boss)", match = { "giantgargoyle" },
                prio = 40, radius = 30, height = 15, hide = "hover", swap = 10 },
            { label = "Acidic Gargoyle", match = { "acidic" },
                prio = 10, radius = 10, height = 10, hide = "none", swap = 15 },
            { label = "Gargoyle", match = { "gargoyle" },
                prio = 10, radius = 10, height = 10, hide = "none", swap = 15 },
            { label = "Electric / Tesla Zombie", match = { "tesla", "electric" },
                prio = 0, radius = 30, height = 15, hide = "none", swap = 15 },
            { label = "Dark Matter Baby", match = { "darkmatter", "baby" },
                prio = 0, radius = 8, height = 0, hide = "hover", swap = 15 },
            { label = "Black Ghost", match = { "blackghost" },
                prio = 0, radius = 10, height = 0, hide = "none", swap = 15 },
            -- Both towers
            { label = "Ghost", match = { "ghost" },
                prio = 10, radius = 10, height = 0, hide = "hover", swap = 15 },
            { label = "Reaper (Grim Reaper)", match = { "reaper", "grim" },
                prio = 10, radius = 10, height = 0, hide = "none", swap = 15 },
            { label = "Skeleton", match = { "skeleton" },
                prio = 10, radius = nil, height = 0, hide = "none", swap = 15 },
            { label = "Exploding Zombie", match = { "explo" },
                prio = 5, radius = 30, height = 15, hide = "none", swap = 15 },
            { label = "Charger Zombie", match = { "charger" },
                prio = 5, radius = nil, height = 0, hide = "none", swap = 15,
                cycle = { hide_x = 10, hide_y = 20, hide_time = 2, attack_x = 0, attack_y = 5, attack_time = 0.3 } },
            { label = "Hunter Zombie", match = { "hunter" },
                prio = 5, radius = nil, height = 0, hide = "hover", swap = 10 },
            { label = "Brute Zombie", match = { "brute" },
                prio = 15, radius = 35, height = 0, hide = "hover", swap = 10 },
            { label = "Tin Hat Zombie", match = { "tinhat" },
                prio = 0, radius = nil, height = 0, hide = "hover", swap = SWAP_SECONDS },
            { label = "Chicken", match = { "chicken" },
                prio = 0, radius = nil, height = 0, hide = "none", swap = SWAP_SECONDS,
                stand = { x = 35, y = 0, gun = true } },
        }
        local DEFAULT_PLAN = {
            label = "Basic Zombie / default", prio = 0, radius = nil, height = 0,
            hide = "hover", swap = SWAP_SECONDS,
        }
        local plan_cache = {}

        local function plan_for(name)
            local cached = plan_cache[name]
            if cached then return cached end
            local key = string.lower(name):gsub("[^%a]", "")
            local found = DEFAULT_PLAN
            for _, plan in ipairs(PLANS) do
                for _, pattern in ipairs(plan.match) do
                    if key:find(pattern, 1, true) then
                        found = plan
                        break
                    end
                end
                if found ~= DEFAULT_PLAN then break end
            end
            plan_cache[name] = found
            return found
        end

        -- Far orbit distance. Plans with radius = 0 are stood on.
        local function orbit_radius_for(name)
            if plan_for(name).radius == 0 then
                return 0
            end
            return FAR_ORBIT_RADIUS
        end

        -- Every mob starts in hover (the near orbit no longer exists).
        local function start_mode(ent)
            return "hover"
        end

        local function pick_target(origin, skip)
            local best, best_part, best_prio, best_d = nil, nil, -math.huge, math.huge
            local clock = os.clock()
            for _, ent in entities() do
                local plan = plan_for(ent.Name)
                if not plan.ignore then
                    local ep = ent:FindFirstChild("PinataHitbox") or ent:FindFirstChild("HitboxHead")
                        or ent:FindFirstChild("HitboxBody") or ent:FindFirstChild("HumanoidRootPart")
                        or ent:FindFirstChildWhichIsA("BasePart")
                    if ep then
                        local hum = ent:FindFirstChildOfClass("Humanoid")
                        local skipped = skip and skip[ent] and skip[ent] > clock
                        if hum and hum.Health > 0 and not skipped then
                            local offset = ep.Position - origin
                            local d = offset:Dot(offset)
                            if plan.prio > best_prio or (plan.prio == best_prio and d < best_d) then
                                best, best_part, best_prio, best_d = ent, ep, plan.prio, d
                            end
                        end
                    end
                end
            end
            return best, best_part, best_d
        end

        local function advance(part)
            local tower = get_tower()
            if not tower then return end
            for _, trig in CollectionService:GetTagged("MobTrigger") do
                if not touched[trig] and trig:IsDescendantOf(tower) then
                    touched[trig] = true
                    touch(part, trig)
                    return
                end
            end
        end

        local blocked_params = OverlapParams.new()
        blocked_params.FilterType = Enum.RaycastFilterType.Include
        local safe_params = OverlapParams.new()
        safe_params.FilterType = Enum.RaycastFilterType.Include

        local function refresh_blocked()
            local blocked = {}
            -- GetTags() needs an instance; the list of every tag in use is GetAllTags().
            local all_tags = {}
            local tags_ok, tags_result = pcall(function()
                return CollectionService:GetAllTags()
            end)
            if tags_ok and type(tags_result) == "table" then
                all_tags = tags_result
            end
            for _, tag in ipairs(all_tags) do
                local low = tag:lower()
                if low == "outofboundspart" or low == "lava" or low == "hazard" or low == "killzone" then
                    for _, inst in CollectionService:GetTagged(tag) do
                        if inst:IsA("BasePart") then blocked[#blocked + 1] = inst end
                        for _, d in inst:GetDescendants() do
                            if d:IsA("BasePart") then blocked[#blocked + 1] = d end
                        end
                    end
                end
            end
            for _, d in Workspace:GetDescendants() do
                if d:IsA("BasePart") then
                    local n = d.Name:lower()
                    if n:find("lava") or n:find("hazard") or n:find("burn") or n:find("kill") then
                        local found = false
                        for _, b in blocked do
                            if b == d then found = true; break end
                        end
                        if not found then blocked[#blocked + 1] = d end
                    end
                end
            end
            blocked_params.FilterDescendantsInstances = blocked

            local safe = {}
            for _, inst in CollectionService:GetTagged("OutOfBoundsSafePart") do
                if inst:IsA("BasePart") then safe[#safe + 1] = inst end
                for _, d in inst:GetDescendants() do
                    if d:IsA("BasePart") then safe[#safe + 1] = d end
                end
            end
            safe_params.FilterDescendantsInstances = safe
        end
        refresh_blocked()

        local function is_blocked_strict(pos)
            local overlap = Workspace:GetPartBoundsInBox(CFrame.new(pos), Vector3.new(4, 4, 4), blocked_params)
            if #overlap == 0 then return false end
            local safe_overlap = Workspace:GetPartBoundsInBox(CFrame.new(pos), Vector3.new(4, 4, 4), safe_params)
            return #safe_overlap == 0
        end

        local function safe_cframe_for(pos, lift)
            local candidates = {}
            for _, v in { lift, 5, 3, 1 } do
                local found = false
                for _, c in candidates do
                    if c == v then found = true; break end
                end
                if not found then candidates[#candidates + 1] = v end
            end
            for _, l in candidates do
                local p = pos + Vector3.new(0, l, 0)
                if not is_blocked_strict(p) then return CFrame.new(p) end
            end
            return CFrame.new(pos)
        end

        local function hook_health(character)
            if rt.health_conn then
                pcall(function() rt.health_conn:Disconnect() end)
                rt.health_conn = nil
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
                or character:WaitForChild("Humanoid", 5)
            if not humanoid then return end
            rt.last_health = humanoid.Health
            rt.health_conn = humanoid.HealthChanged:Connect(function(health)
                if rt.last_health and health < rt.last_health then
                    rt.hit_pending = true
                end
                rt.last_health = health
            end)
        end

        if zt_lp.Character then
            task.spawn(hook_health, zt_lp.Character)
        end

        local function camera_lock()
            if not (zt.enabled and rt.cam_mode) then return end
            local camera = Workspace.CurrentCamera
            if not camera then return end
            local position = camera.CFrame.Position
            if rt.cam_mode == "mob" and rt.cam_target then
                if (rt.cam_target - position).Magnitude > 0.1 then
                    camera.CFrame = CFrame.lookAt(position, rt.cam_target)
                end
            elseif rt.cam_mode == "up" then
                camera.CFrame = CFrame.lookAt(position, position + Vector3.new(0, 1, 0), Vector3.new(0, 0, -1))
            end
        end

        pcall(function()
            RunService:UnbindFromRenderStep("ZombieTowerCamera")
        end)
        pcall(function()
            RunService:BindToRenderStep("ZombieTowerCamera", Enum.RenderPriority.Camera.Value + 1, camera_lock)
        end)

        local function stop_and_restore()
            rt.cam_mode = nil
            rt.mode = nil
            rt.lock_ent = nil
            m1_set(false)
            local cf = rt.last_cf
            rt.last_cf = nil
            if not cf then return end
            local function restore()
                local char = zt_lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    pcall(function()
                        root.CFrame = CFrame.new(cf.Position) * root.CFrame.Rotation
                        root.AssemblyLinearVelocity = Vector3.zero
                    end)
                end
            end
            restore()
            task.delay(0.1, restore)
        end

        local zt_sec = api.ui:addsection({ name = "Zombie Tower Ragebot", side = "left" })

        local function set_zt_enabled(value)
            value = value and true or false
            zt.enabled = value
            api.config:set("ztr_enabled", value)
            if value then
                rt.mode = nil
                equip_melee_slot()
                safe_notify(api, {
                    title = "Zombie Tower Ragebot",
                    content = "You might have to disable the rage in the boss level and kill the bosses yourself.",
                    duration = 6,
                })
            else
                stop_and_restore()
                safe_notify(api, {
                    title = "Zombie Tower Ragebot",
                    content = "Disabled.",
                    duration = 2,
                })
            end
        end

        local zt_toggle = safe_control(zt_sec, "toggle", {
            name = "Zombie Tower Ragebot",
            flag = "ztr_enabled",
            default = zt.enabled,
            callback = function(value)
                if (value and true or false) ~= zt.enabled then
                    set_zt_enabled(value)
                end
            end,
        })

        -- Keybind: pressing the bound key switches the ragebot on / off.
        -- sec:keybind is listed in the Lilac docs without option details, so
        -- the key is read from the control's callback value (key enum, key
        -- name or table; booleans are press-state notifications and are
        -- ignored) and from the saved config, and the press itself is handled
        -- by UserInputService.
        local function parse_bind(value, depth)
            depth = depth or 0
            local value_type = typeof(value)
            if value_type == "EnumItem" then
                if (value.EnumType == Enum.KeyCode and value ~= Enum.KeyCode.Unknown)
                    or value.EnumType == Enum.UserInputType then
                    return value
                end
                return nil
            elseif value_type == "string" then
                local text = value:gsub("^%s+", ""):gsub("%s+$", "")
                local lowered = string.lower(text)
                if text == "" or lowered == "none" or lowered == "unbound" then
                    return nil
                end
                text = text:gsub("^Enum%.KeyCode%.", ""):gsub("^Enum%.UserInputType%.", "")
                local aliases = {
                    mb1 = "MouseButton1", mb2 = "MouseButton2", mb3 = "MouseButton3",
                    mouse1 = "MouseButton1", mouse2 = "MouseButton2", mouse3 = "MouseButton3",
                }
                text = aliases[string.lower(text)] or text
                local ok_key, key = pcall(function() return Enum.KeyCode[text] end)
                if ok_key and key and key ~= Enum.KeyCode.Unknown then return key end
                local ok_mouse, mouse = pcall(function() return Enum.UserInputType[text] end)
                if ok_mouse and mouse then return mouse end
                return nil
            elseif value_type == "table" and depth < 2 then
                for _, field in ipairs({ "Key", "key", "Keybind", "keybind", "Value", "value", 1 }) do
                    local inner = value[field]
                    if inner ~= nil then
                        local parsed = parse_bind(inner, depth + 1)
                        if parsed then return parsed end
                    end
                end
            end
            return nil
        end

        local toggle_key = parse_bind(api.config:get("ztr_keybind", "None"))
        local toggle_key_ignore_until = 0

        safe_control(zt_sec, "keybind", {
            name = "Zombie Tower Ragebot Key",
            flag = "ztr_keybind",
            default = toggle_key and toggle_key.Name or "None",
            callback = function(value)
                if type(value) == "boolean" then return end
                toggle_key = parse_bind(value)
                api.config:set("ztr_keybind", toggle_key and toggle_key.Name or "None")
                -- the key that was just picked must not toggle the ragebot
                toggle_key_ignore_until = os.clock() + 0.3
            end,
        })

        track(UserInputService.InputBegan:Connect(function(input, game_processed)
            if game_processed or os.clock() < toggle_key_ignore_until then return end

            local key = toggle_key
            if not key then
                key = parse_bind(api.config:get("ztr_keybind", "None"))
            end
            if not key then return end

            if input.KeyCode == key or input.UserInputType == key then
                local target_state = not zt.enabled
                -- move the toggle on screen too (its callback applies the change)
                if zt_toggle then
                    for _, method_name in ipairs({ "SetValue", "Set", "setvalue", "set" }) do
                        local ok_method, method = pcall(function() return zt_toggle[method_name] end)
                        if ok_method and type(method) == "function" then
                            if pcall(method, zt_toggle, target_state) then
                                break
                            end
                        end
                    end
                end
                if zt.enabled ~= target_state then
                    set_zt_enabled(target_state)
                end
            end
        end))

        local refresh_next = 0

        local function ent_part(ent)
            return ent:FindFirstChild("PinataHitbox") or ent:FindFirstChild("HitboxHead")
                or ent:FindFirstChild("HitboxBody") or ent:FindFirstChild("HumanoidRootPart")
                or ent:FindFirstChildWhichIsA("BasePart")
        end

        local function step(dt)
            local now_tick = tick()
            if now_tick > refresh_next then
                refresh_blocked()
                refresh_next = now_tick + 1
            end
            if not zt.enabled then
                rt.hit_pending = false
                rt.cam_mode = nil
                return
            end

            local char = zt_lp.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local part = char:FindFirstChild("HitboxBody") or root
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not (root and part) or (hum and hum.Health <= 0) then
                m1_set(false)
                return
            end

            for drop in drops do
                if drop.CanTouch and drop:FindFirstChildOfClass("TouchTransmitter") then
                    local want
                    if drop:FindFirstChild("Weapon") then
                        want = drop.Weapon
                        if not weapon_seen[drop] then
                            weapon_seen[drop] = true
                            rt.weapon_choice_until = os.clock() + 5
                            rt.next_choice_scan = 0
                        end
                    else
                        local model = drop:FindFirstChildOfClass("Model")
                        if model and model.Name ~= "Health" and model.Name ~= "Ammo"
                            and model.Name ~= "AmmoBalanced" and model.Name ~= "Revive" then
                            want = model
                        end
                    end
                    if want then touch(part, drop) end
                end
            end

            local now = os.clock()

            if now < rt.weapon_choice_until and now >= rt.next_choice_scan then
                rt.next_choice_scan = now + 0.25
                if try_choose_first_weapon() then
                    rt.weapon_choice_until = 0
                    rt.equip_after = now + 1
                end
            end

            if rt.equip_after and now >= rt.equip_after then
                rt.equip_after = nil
                if rt.weapon == "gun" then
                    equip_gun_slot()
                else
                    equip_melee_slot()
                end
            end

            local target_ent, target_part
            if rt.lock_ent and rt.lock_ent.Parent then
                local lock_hum = rt.lock_ent:FindFirstChildOfClass("Humanoid")
                local lock_part = ent_part(rt.lock_ent)
                if lock_hum and lock_hum.Health > 0 and lock_part then
                    if lock_hum.Health < rt.lock_hp - 0.01 then
                        rt.progress_at = now
                        rt.mode_at = now
                    end
                    rt.lock_hp = lock_hum.Health
                    if now - rt.progress_at >= RETARGET_SECONDS then
                        rt.skip[rt.lock_ent] = now + SKIP_SECONDS
                    else
                        target_ent, target_part = rt.lock_ent, lock_part
                    end
                end
            end
            if not target_part then
                target_ent, target_part = pick_target(part.Position, rt.skip)
                if not target_part then
                    target_ent, target_part = pick_target(part.Position)
                end
                if target_ent ~= rt.lock_ent then
                    rt.lock_ent = target_ent
                    local new_hum = target_ent and target_ent:FindFirstChildOfClass("Humanoid")
                    rt.lock_hp = new_hum and new_hum.Health or 0
                    rt.progress_at = now
                    rt.mode = start_mode(target_ent)
                    rt.mode_at = now
                else
                    rt.progress_at = now
                end
            end
            if not target_part then
                m1_set(false)
                rt.cam_mode = nil
                rt.hit_pending = false
                if rt.weapon == "gun" then
                    equip_melee_slot()
                end
                advance(part)
                return
            end

            local plan = plan_for(target_ent.Name)
            local target_pos = target_part.Position

            -- Charger Zombie: no orbit, alternate hide height / attack height.
            if plan.cycle then
                apply_weapon("melee")
                local c = plan.cycle
                if rt.cycle_target ~= target_ent then
                    rt.cycle_target = target_ent
                    rt.cycle_state = "hide"
                    rt.cycle_at = now
                end
                local duration = rt.cycle_state == "hide" and c.hide_time or c.attack_time
                if now - rt.cycle_at >= duration then
                    rt.cycle_state = rt.cycle_state == "hide" and "attack" or "hide"
                    rt.cycle_at = now
                end
                local hiding = rt.cycle_state == "hide"
                local offset_x = hiding and c.hide_x or c.attack_x
                local cf = safe_cframe_for(target_pos + Vector3.new(offset_x, 0, 0), hiding and c.hide_y or c.attack_y)
                rt.hit_pending = false
                rt.last_cf = cf
                rt.cam_mode = "mob"
                rt.cam_target = target_pos
                pcall(function()
                    root.CFrame = cf
                    root.AssemblyLinearVelocity = Vector3.zero
                end)
                m1_hold(now)
                return
            end

            -- Chicken: stay still at a fixed offset and shoot it.
            if plan.stand then
                local st = plan.stand
                apply_weapon(st.gun and "gun" or "melee")
                local cf = safe_cframe_for(target_pos + Vector3.new(st.x, 0, 0), st.y)
                local look_at = Vector3.new(target_pos.X, cf.Position.Y, target_pos.Z)
                if (look_at - cf.Position).Magnitude > 0.1 then
                    cf = CFrame.lookAt(cf.Position, look_at)
                end
                rt.hit_pending = false
                rt.last_cf = cf
                rt.cam_mode = "mob"
                rt.cam_target = target_pos
                pcall(function()
                    root.CFrame = cf
                    root.AssemblyLinearVelocity = Vector3.zero
                end)
                m1_hold(now)
                return
            end

            if not rt.mode then
                rt.mode = start_mode(target_ent)
                rt.mode_at = now
            end

            -- Not hitting the mob for `swap` seconds: hover <-> far orbit.
            if now - rt.mode_at >= plan.swap then
                rt.mode_at = now
                rt.mode = rt.mode == "hover" and "far" or "hover"
            end

            -- Slot by hover type: hover = melee, far position = gun.
            apply_weapon(rt.mode == "far" and "gun" or "melee")

            if rt.mode == "hover" then
                local cf = safe_cframe_for(target_pos, math.max(HOVER_HEIGHT, plan.height))
                local look_at = Vector3.new(target_pos.X, cf.Position.Y, target_pos.Z)
                if (look_at - cf.Position).Magnitude > 0.1 then
                    cf = CFrame.lookAt(cf.Position, look_at)
                end
                rt.last_cf = cf
                rt.cam_mode = "mob"
                rt.cam_target = target_pos
                pcall(function()
                    root.CFrame = cf
                    root.AssemblyLinearVelocity = Vector3.zero
                end)
                m1_hold(now)
            else
                -- Static far position (no spinning): FAR_ORBIT_RADIUS studs
                -- along X from the mob, at least FAR_ORBIT_HEIGHT high.
                local height = math.max(plan.height, FAR_ORBIT_HEIGHT)
                local base = target_pos + Vector3.new(orbit_radius_for(target_ent.Name), 0, 0)

                local cf = safe_cframe_for(base, height)
                local look_at = Vector3.new(target_pos.X, cf.Position.Y, target_pos.Z)
                if (look_at - cf.Position).Magnitude > 0.1 then
                    cf = CFrame.lookAt(cf.Position, look_at)
                end
                rt.last_cf = cf
                rt.cam_mode = "mob"
                rt.cam_target = target_pos
                pcall(function()
                    root.CFrame = cf
                    root.AssemblyLinearVelocity = Vector3.zero
                end)
                m1_hold(now)
            end
        end

        track(RunService.Heartbeat:Connect(function(dt)
            local ok, err = pcall(step, dt)
            if not ok then
                warn("[" .. api.name .. "] zombie tower step error: " .. tostring(err))
            end
        end))

        track(zt_lp.CharacterAdded:Connect(function(character)
            m1_set(false)
            task.spawn(hook_health, character)
            task.delay(1.5, function()
                if zt.enabled then
                    equip_melee_slot()
                end
            end)
        end))

        zt_cleanup = function()
            pcall(function() RunService:UnbindFromRenderStep("ZombieTowerCamera") end)
            if rt.health_conn then
                pcall(function() rt.health_conn:Disconnect() end)
                rt.health_conn = nil
            end
            zt.enabled = false
            stop_and_restore()
        end
    end

    ----------------------------------------------------------------------
    -- Crosshair
    ----------------------------------------------------------------------
    local default_colors = {
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 255, 255),
    }

    local xhair = {
        enabled   = api.config:get("crosshair_enabled", true),
        offset    = api.config:get("crosshair_offset", api.config:get("crosshair_gap", 7)),
        length    = api.config:get("crosshair_length", 13),
        thickness = api.config:get("crosshair_thickness", 2),
        rotation  = api.config:get("crosshair_rotation", 0),
        gradient  = api.config:get("crosshair_gradient", false),
        animation = normalize_crosshair_animation(
            api.config:get("crosshair_animation", "Static")
        ),
        bounce    = api.config:get("crosshair_bounce_offset", 8),
        bounce_speed = api.config:get("crosshair_bounce_speed", 2),
        rotate_speed = api.config:get("crosshair_rotate_speed", 1),
        rainbow   = api.config:get("crosshair_rainbow", false),
        rainbow_speed = api.config:get("crosshair_rainbow_speed", 0.3),
        disable_game_crosshair = api.config:get("crosshair_disable_game", false),
        outline   = api.config:get("crosshair_outline", true),
        outline_thickness = api.config:get("crosshair_outline_thickness", 2),
        outline_color = color_from(
            api.config:get("crosshair_outline_color", { r = 0, g = 0, b = 0 }),
            Color3.new(0, 0, 0)
        ),
        colors    = {},
        gradient_start = {},
        gradient_end = {},
    }

    for i = 1, 4 do
        xhair.colors[i] = color_from(
            api.config:get("crosshair_color_" .. i, color_to_table(default_colors[i])),
            default_colors[i]
        )
        local next_index = i == 4 and 1 or i + 1
        xhair.gradient_start[i] = color_from(
            api.config:get("crosshair_gradient_start_" .. i, color_to_table(xhair.colors[i])),
            xhair.colors[i]
        )
        xhair.gradient_end[i] = color_from(
            api.config:get("crosshair_gradient_end_" .. i, color_to_table(xhair.colors[next_index])),
            xhair.colors[next_index]
        )
    end

    local xtext = {
        enabled   = api.config:get("crosshair_text_enabled", false),
        text      = tostring(api.config:get("crosshair_text", "LILAC") or ""),
        font      = normalize_font_name(api.config:get("crosshair_text_font", "UI")),
        animation = api.config:get("crosshair_text_animation", "Static"),
        speed     = api.config:get("crosshair_text_speed", 1),
        size      = api.config:get("crosshair_text_size", 16),
        y_offset  = api.config:get("crosshair_text_y_offset", 0),
        font_animation = api.config:get("crosshair_text_font_animation", "None"),
        wave_offset = api.config:get("crosshair_text_wave_offset", 6),
        wave_speed = api.config:get("crosshair_text_wave_speed", 1),
        shake_intensity = api.config:get("crosshair_text_shake_intensity", 2),
        typing_speed = api.config:get("crosshair_text_typing_speed", 8),
        typing_delay = api.config:get("crosshair_text_typing_delay", 0.5),
        spacing = api.config:get("crosshair_text_spacing", 0),
        gradient = api.config:get("crosshair_text_gradient", false),
        rainbow = api.config:get("crosshair_text_rainbow", false),
        rainbow_gradient = api.config:get("crosshair_text_rainbow_gradient", false),
        rainbow_speed = api.config:get("crosshair_text_rainbow_speed", 0.3),
        replace_with_ragebot = api.config:get("crosshair_text_ragebot_status", false),
        color     = color_from(
            api.config:get("crosshair_text_color", { r = 1, g = 1, b = 1 }),
            Color3.new(1, 1, 1)
        ),
        gradient_start = color_from(
            api.config:get("crosshair_text_gradient_start", { r = 1, g = 1, b = 1 }),
            Color3.new(1, 1, 1)
        ),
        gradient_end = color_from(
            api.config:get("crosshair_text_gradient_end", { r = 0.3, g = 0.7, b = 1 }),
            Color3.new(0.3, 0.7, 1)
        ),
        shadow_enabled = api.config:get("crosshair_text_shadow", false),
        shadow_color = color_from(
            api.config:get("crosshair_text_shadow_color", { r = 0, g = 0, b = 0 }),
            Color3.new(0, 0, 0)
        ),
        shadow_offset_x = api.config:get("crosshair_text_shadow_x", 2),
        shadow_offset_y = api.config:get("crosshair_text_shadow_y", 2),
    }

    local ximg = {
        enabled = api.config:get("crosshair_image_enabled", false),
        -- No documented text-input control exists, so the URL is config-only.
        url     = tostring(api.config:get("crosshair_image_url", "") or ""),
        size    = api.config:get("crosshair_image_size", 24),
    }

    local drawings = {}
    local loaded_image_url = nil
    local image_request_active = false
    local accumulated_time = 0
    local game_crosshair_visibility = {}
    local last_game_crosshair_scan = -math.huge

    local function new_drawing(class)
        if not Drawing or type(Drawing.new) ~= "function" then
            return nil
        end
        local ok, object = pcall(function()
            return Drawing.new(class)
        end)
        return ok and object or nil
    end

    drawings.lines = {}
    drawings.outlines = {}
    drawings.outline_parts = {}
    drawings.gradient_lines = {}
    drawings.gradient_outlines = {}
    local GRADIENT_SEGMENTS = 8
    for i = 1, 4 do
        drawings.outlines[i] = new_drawing("Line")
        drawings.outline_parts[i] = {}
        drawings.lines[i] = new_drawing("Line")
        drawings.gradient_lines[i] = {}
        drawings.gradient_outlines[i] = {}
        for part = 1, 4 do
            drawings.outline_parts[i][part] = new_drawing("Line")
        end
        for segment = 1, GRADIENT_SEGMENTS do
            drawings.gradient_outlines[i][segment] = new_drawing("Line")
            drawings.gradient_lines[i][segment] = new_drawing("Line")
        end
    end

    local function ensure_crosshair_drawings()
        for i = 1, 4 do
            if not drawings.outlines[i] then
                drawings.outlines[i] = new_drawing("Line")
            end
            if not drawings.outline_parts[i] then
                drawings.outline_parts[i] = {}
            end
            for part = 1, 4 do
                if not drawings.outline_parts[i][part] then
                    drawings.outline_parts[i][part] = new_drawing("Line")
                end
            end
            if not drawings.lines[i] then
                drawings.lines[i] = new_drawing("Line")
            end
            for segment = 1, GRADIENT_SEGMENTS do
                if not drawings.gradient_outlines[i][segment] then
                    drawings.gradient_outlines[i][segment] = new_drawing("Line")
                end
                if not drawings.gradient_lines[i][segment] then
                    drawings.gradient_lines[i][segment] = new_drawing("Line")
                end
            end
        end
    end

    drawings.text_shadow = new_drawing("Text")
    drawings.text  = new_drawing("Text")
    drawings.text_letters = {}
    drawings.shadow_letters = {}
    drawings.image = new_drawing("Image")

    local function set_visible(object, visible)
        if object then
            pcall(function() object.Visible = visible end)
        end
    end

    local function configure_line(object, from, to, color, thickness, visible, zindex)
        if not object then
            return
        end

        pcall(function() object.From = from end)
        pcall(function() object.To = to end)
        pcall(function() object.Color = color end)
        pcall(function() object.Thickness = thickness end)
        pcall(function() object.Transparency = 1 end)
        set_visible(object, visible)
        pcall(function() object.ZIndex = zindex end)
    end

    local function configure_outline_box(parts, from, to, line_thickness, border_thickness, color, visible)
        if not parts then
            return
        end

        local dx = to.X - from.X
        local dy = to.Y - from.Y
        local length = math.sqrt(dx * dx + dy * dy)
        if length < 0.001 then
            for part = 1, 4 do
                configure_line(parts[part], from, to, color, border_thickness, false, 1)
            end
            return
        end

        local direction = Vector2.new(dx / length, dy / length)
        local perpendicular = Vector2.new(-direction.Y, direction.X)
        local half_width = math.max(0.5, line_thickness * 0.5)
        local border = math.max(1, border_thickness)
        local side_offset = half_width + border * 0.5
        local cap_offset = border * 0.5

        local start_cap = from - direction * cap_offset
        local end_cap = to + direction * cap_offset
        local side_a_from = start_cap + perpendicular * side_offset
        local side_a_to = end_cap + perpendicular * side_offset
        local side_b_from = start_cap - perpendicular * side_offset
        local side_b_to = end_cap - perpendicular * side_offset

        configure_line(parts[1], side_a_from, side_a_to, color, border, visible, 1)
        configure_line(parts[2], side_b_from, side_b_to, color, border, visible, 1)
        configure_line(parts[3], start_cap - perpendicular * side_offset,
            start_cap + perpendicular * side_offset, color, border, visible, 1)
        configure_line(parts[4], end_cap - perpendicular * side_offset,
            end_cap + perpendicular * side_offset, color, border, visible, 1)
    end

    local function destroy_drawing(object)
        if object then
            pcall(function() object:Remove() end)
            pcall(function() object:Destroy() end)
        end
    end

    local function rebuild_text_drawings()
        destroy_drawing(drawings.text)
        destroy_drawing(drawings.text_shadow)
        for _, letter in ipairs(drawings.text_letters or {}) do
            destroy_drawing(letter)
        end
        for _, letter in ipairs(drawings.shadow_letters or {}) do
            destroy_drawing(letter)
        end

        drawings.text_letters = {}
        drawings.shadow_letters = {}

        drawings.text_shadow = new_drawing("Text")
        drawings.text = new_drawing("Text")
    end

    local function ensure_text_letters(count)
        for i = #drawings.text_letters + 1, count do
            drawings.shadow_letters[i] = new_drawing("Text")
            drawings.text_letters[i] = new_drawing("Text")
        end
    end

    local function hide_text_letters()
        for _, letter in ipairs(drawings.text_letters) do
            set_visible(letter, false)
        end
        for _, letter in ipairs(drawings.shadow_letters) do
            set_visible(letter, false)
        end
    end

    local BASE_FONTS = { UI = 0, System = 1, Plex = 2, Monospace = 3 }

    local CUSTOM_FONT_KEYS = {
        ["Monospace Bold"] = {
            "Monospace Bold", "MonospaceBold", "RobotoMonoBold",
            "Monocraft Bold", "CodeBold",
        },
    }
    local font_cache = {}

    local function find_custom_font(candidates)
        if not (Drawing and Drawing.Fonts) then
            return nil
        end
        for _, candidate in ipairs(candidates) do
            local ok, value = pcall(function()
                return Drawing.Fonts[candidate]
            end)
            if ok and value ~= nil then
                return value
            end
        end

        local ok, resolved = pcall(function()
            for key, value in pairs(Drawing.Fonts) do
                local key_text = string.lower(tostring(key)):gsub("[%s_%-]", "")
                for _, candidate in ipairs(candidates) do
                    local want = string.lower(candidate):gsub("[%s_%-]", "")
                    if key_text == want and value ~= nil then
                        return value
                    end
                end
            end
            return nil
        end)
        return ok and resolved or nil
    end

    local function get_font(font_name)
        font_name = normalize_font_name(font_name)
        local cached = font_cache[font_name]
        if cached then
            return cached[1], cached[2]
        end

        local font, is_custom = BASE_FONTS.UI, true
        if BASE_FONTS[font_name] ~= nil then
            font = BASE_FONTS[font_name]
            if Drawing and Drawing.Fonts then
                local ok, value = pcall(function()
                    return Drawing.Fonts[font_name]
                end)
                if ok and value ~= nil then
                    font = value
                end
            end
        else
            local custom = find_custom_font(CUSTOM_FONT_KEYS[font_name] or {})
            if custom ~= nil then
                font = custom
            else
                font, is_custom = BASE_FONTS.Monospace, false
            end
        end

        font_cache[font_name] = { font, is_custom }
        return font, is_custom
    end

    local function get_ragebot_status()
        local ok, status = pcall(function()
            if not api.ragebot then
                return "Ragebot: unavailable"
            end

            local stats = api.ragebot:getstats()
            if not stats then
                return "Ragebot: unavailable"
            end

            local teleporting = tostring(stats.teleporting or "false")
            return "Ragebot: " .. teleporting
        end)

        return ok and status or "Ragebot: unavailable"
    end

    local function get_line_color(index, clock, local_t)
        if xhair.rainbow then
            local hue = (clock * math.max(0, tonumber(xhair.rainbow_speed) or 0)) % 1
            return Color3.fromHSV(hue, 0.9, 1)
        end
        if xhair.gradient then
            return xhair.gradient_start[index]:Lerp(
                xhair.gradient_end[index],
                clamp(tonumber(local_t) or 0, 0, 1)
            )
        end
        return xhair.colors[index]
    end

    local function set_all_hidden()
        for _, line in ipairs(drawings.lines) do
            set_visible(line, false)
        end
        for _, line in ipairs(drawings.outlines or {}) do
            set_visible(line, false)
        end
        for _, parts in ipairs(drawings.outline_parts or {}) do
            for _, line in ipairs(parts) do
                set_visible(line, false)
            end
        end
        for _, arm in ipairs(drawings.gradient_lines or {}) do
            for _, line in ipairs(arm) do
                set_visible(line, false)
            end
        end
        for _, arm in ipairs(drawings.gradient_outlines or {}) do
            for _, line in ipairs(arm) do
                set_visible(line, false)
            end
        end
        set_visible(drawings.text, false)
        set_visible(drawings.text_shadow, false)
        hide_text_letters()
        set_visible(drawings.image, false)
    end

    local function restore_game_crosshair()
        for object, visible in pairs(game_crosshair_visibility) do
            if object then
                pcall(function() object.Visible = visible end)
            end
        end
        table.clear(game_crosshair_visibility)
    end

    local function hide_game_crosshair()
        if not xhair.disable_game_crosshair or not LocalPlayer then
            restore_game_crosshair()
            return
        end

        if accumulated_time - last_game_crosshair_scan < 0.25 then
            return
        end
        last_game_crosshair_scan = accumulated_time

        local player_gui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not player_gui then
            return
        end

        for _, object in ipairs(player_gui:GetDescendants()) do
            local lower_name = string.lower(object.Name or "")
            local is_crosshair_name = lower_name:find("crosshair", 1, true)
                or lower_name:find("reticle", 1, true)
            if is_crosshair_name and object:IsA("GuiObject") then
                if game_crosshair_visibility[object] == nil then
                    game_crosshair_visibility[object] = object.Visible
                end
                object.Visible = false
            end
        end
    end

    local function rotate_vector(vector, radians)
        local cosine, sine = math.cos(radians), math.sin(radians)
        return Vector2.new(
            vector.X * cosine - vector.Y * sine,
            vector.X * sine + vector.Y * cosine
        )
    end

    local function request_image()
        if image_request_active or not ximg.enabled or ximg.url == "" then
            return
        end
        if loaded_image_url == ximg.url then
            return
        end

        image_request_active = true
        loaded_image_url = ximg.url

        task.spawn(function()
            local ok, data = pcall(function()
                return game:HttpGet(ximg.url)
            end)

            if ok and type(data) == "string" and drawings.image then
                pcall(function()
                    drawings.image.Data = data
                end)
            else
                warn("[Harry Extensions] Crosshair image could not be downloaded.")
                loaded_image_url = nil
            end

            image_request_active = false
        end)
    end

    local crosshair_sec = api.ui:addsection({
        name = "Custom Crosshair",
        side = "left",
    })

    safe_control(crosshair_sec, "toggle", {
        name = "Enable Crosshair",
        flag = "crosshair_enabled",
        default = xhair.enabled,
        callback = function(v)
            xhair.enabled = v
            api.config:set("crosshair_enabled", v)
        end,
    })

    safe_control(crosshair_sec, "dropdown", {
        name = "Crosshair Animation",
        flag = "crosshair_animation",
        options = CROSSHAIR_ANIMATIONS,
        default = xhair.animation,
        callback = function(v)
            xhair.animation = normalize_crosshair_animation(v)
            api.config:set("crosshair_animation", xhair.animation)
        end,
    })

    safe_control(crosshair_sec, "slider", {
        name = "Bounce Max Offset",
        flag = "crosshair_bounce_offset",
        min = 0, max = 80,
        float = 0.01,
        default = xhair.bounce,
        suffix = "px",
        callback = function(v)
            xhair.bounce = v
            api.config:set("crosshair_bounce_offset", v)
        end,
    })

    safe_control(crosshair_sec, "slider", {
        name = "Bounce Speed",
        flag = "crosshair_bounce_speed",
        min = 0.1, max = 10,
        default = xhair.bounce_speed,
        float = 0.01,
        suffix = " /s",
        callback = function(v)
            xhair.bounce_speed = v
            api.config:set("crosshair_bounce_speed", v)
        end,
    })

    safe_control(crosshair_sec, "slider", {
        name = "Rotate Speed",
        flag = "crosshair_rotate_speed",
        min = 0.1, max = 10,
        default = xhair.rotate_speed,
        float = 0.01,
        suffix = " rps",
        callback = function(v)
            xhair.rotate_speed = v
            api.config:set("crosshair_rotate_speed", v)
        end,
    })

    safe_control(crosshair_sec, "slider", {
        name = "Offset (px)",
        flag = "crosshair_offset",
        min = 0, max = 80,
        float = 0.01,
        default = xhair.offset,
        suffix = "px",
        callback = function(v)
            xhair.offset = v
            api.config:set("crosshair_offset", v)
        end,
    })

    safe_control(crosshair_sec, "slider", {
        name = "Line Length",
        flag = "crosshair_length",
        min = 1, max = 50,
        float = 0.01,
        default = xhair.length,
        suffix = "px",
        callback = function(v)
            xhair.length = v
            api.config:set("crosshair_length", v)
        end,
    })

    safe_control(crosshair_sec, "slider", {
        name = "Line Thickness",
        flag = "crosshair_thickness",
        min = 1, max = 8,
        float = 0.01,
        default = xhair.thickness,
        callback = function(v)
            xhair.thickness = v
            api.config:set("crosshair_thickness", v)
        end,
    })

    safe_control(crosshair_sec, "slider", {
        name = "Rotation",
        flag = "crosshair_rotation",
        min = -180, max = 180,
        float = 0.01,
        default = xhair.rotation,
        suffix = " deg",
        callback = function(v)
            xhair.rotation = v
            api.config:set("crosshair_rotation", v)
        end,
    })

    for i = 1, 4 do
        local index = i
        safe_control(crosshair_sec, "colorpicker", {
            name = "Color Line " .. i,
            flag = "crosshair_color_" .. i,
            default = xhair.colors[i],
            callback = function(v)
                xhair.colors[index] = color_from(v, xhair.colors[index])
                api.config:set("crosshair_color_" .. index, color_to_table(xhair.colors[index]))
            end,
        })
        safe_control(crosshair_sec, "colorpicker", {
            name = "Gradient Start Line " .. i,
            flag = "crosshair_gradient_start_" .. i,
            default = xhair.gradient_start[i],
            callback = function(v)
                xhair.gradient_start[index] = color_from(v, xhair.gradient_start[index])
                api.config:set(
                    "crosshair_gradient_start_" .. index,
                    color_to_table(xhair.gradient_start[index])
                )
            end,
        })
        safe_control(crosshair_sec, "colorpicker", {
            name = "Gradient End Line " .. i,
            flag = "crosshair_gradient_end_" .. i,
            default = xhair.gradient_end[i],
            callback = function(v)
                xhair.gradient_end[index] = color_from(v, xhair.gradient_end[index])
                api.config:set(
                    "crosshair_gradient_end_" .. index,
                    color_to_table(xhair.gradient_end[index])
                )
            end,
        })
    end

    safe_control(crosshair_sec, "toggle", {
        name = "Gradient Color",
        flag = "crosshair_gradient",
        default = xhair.gradient,
        callback = function(v)
            xhair.gradient = v
            api.config:set("crosshair_gradient", v)
        end,
    })

    safe_control(crosshair_sec, "toggle", {
        name = "Rainbow Color",
        flag = "crosshair_rainbow",
        default = xhair.rainbow,
        callback = function(v)
            xhair.rainbow = v
            api.config:set("crosshair_rainbow", v)
        end,
    })

    safe_control(crosshair_sec, "slider", {
        name = "Rainbow Delta Speed",
        flag = "crosshair_rainbow_speed",
        min = 0, max = 5,
        default = xhair.rainbow_speed,
        float = 0.01,
        suffix = " delta/s",
        callback = function(v)
            xhair.rainbow_speed = v
            api.config:set("crosshair_rainbow_speed", v)
        end,
    })

    safe_control(crosshair_sec, "toggle", {
        name = "Disable Game Crosshair",
        flag = "crosshair_disable_game",
        default = xhair.disable_game_crosshair,
        callback = function(v)
            xhair.disable_game_crosshair = v
            api.config:set("crosshair_disable_game", v)
            if not v then
                restore_game_crosshair()
            end
        end,
    })

    safe_control(crosshair_sec, "toggle", {
        name = "Outline",
        flag = "crosshair_outline",
        default = xhair.outline,
        callback = function(v)
            xhair.outline = v
            api.config:set("crosshair_outline", v)
        end,
    })

    safe_control(crosshair_sec, "slider", {
        name = "Outline Thickness",
        flag = "crosshair_outline_thickness",
        min = 1, max = 8,
        float = 0.01,
        default = xhair.outline_thickness,
        suffix = "px",
        callback = function(v)
            xhair.outline_thickness = v
            api.config:set("crosshair_outline_thickness", v)
        end,
    })

    safe_control(crosshair_sec, "colorpicker", {
        name = "Outline Color",
        flag = "crosshair_outline_color",
        default = xhair.outline_color,
        callback = function(v)
            xhair.outline_color = color_from(v, xhair.outline_color)
            api.config:set("crosshair_outline_color", color_to_table(xhair.outline_color))
        end,
    })

    ----------------------------------------------------------------------
    -- Crosshair text & image
    ----------------------------------------------------------------------
    local text_sec = api.ui:addsection({
        name = "Crosshair Text & Image",
        side = "right",
    })

    safe_control(text_sec, "toggle", {
        name = "Custom Text",
        flag = "crosshair_text_enabled",
        default = xtext.enabled,
        callback = function(v)
            xtext.enabled = v
            api.config:set("crosshair_text_enabled", v)
        end,
    })

    safe_control(text_sec, "toggle", {
        name = "Rainbow Text",
        flag = "crosshair_text_rainbow",
        default = xtext.rainbow,
        callback = function(v)
            xtext.rainbow = v
            api.config:set("crosshair_text_rainbow", v)
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Text Rainbow Speed",
        flag = "crosshair_text_rainbow_speed",
        min = 0, max = 5,
        default = xtext.rainbow_speed,
        float = 0.01,
        suffix = " delta/s",
        callback = function(v)
            xtext.rainbow_speed = v
            api.config:set("crosshair_text_rainbow_speed", v)
        end,
    })

    safe_control(text_sec, "toggle", {
        name = "Gradient Text Color",
        flag = "crosshair_text_gradient",
        default = xtext.gradient,
        callback = function(v)
            xtext.gradient = v
            api.config:set("crosshair_text_gradient", v)
        end,
    })

    safe_control(text_sec, "toggle", {
        name = "Rainbow Gradient",
        flag = "crosshair_text_rainbow_gradient",
        default = xtext.rainbow_gradient,
        callback = function(v)
            xtext.rainbow_gradient = v
            api.config:set("crosshair_text_rainbow_gradient", v)
        end,
    })

    safe_control(text_sec, "colorpicker", {
        name = "Text Gradient Start",
        flag = "crosshair_text_gradient_start",
        default = xtext.gradient_start,
        callback = function(v)
            xtext.gradient_start = color_from(v, xtext.gradient_start)
            api.config:set(
                "crosshair_text_gradient_start",
                color_to_table(xtext.gradient_start)
            )
        end,
    })

    safe_control(text_sec, "colorpicker", {
        name = "Text Gradient End",
        flag = "crosshair_text_gradient_end",
        default = xtext.gradient_end,
        callback = function(v)
            xtext.gradient_end = color_from(v, xtext.gradient_end)
            api.config:set(
                "crosshair_text_gradient_end",
                color_to_table(xtext.gradient_end)
            )
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Text Size",
        flag = "crosshair_text_size",
        min = 8, max = 64,
        float = 0.01,
        default = xtext.size,
        suffix = "px",
        callback = function(v)
            xtext.size = v
            api.config:set("crosshair_text_size", v)
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Text Y Offset",
        flag = "crosshair_text_y_offset",
        min = -100, max = 100,
        default = xtext.y_offset,
        float = 0.01,
        suffix = "px",
        callback = function(v)
            xtext.y_offset = v
            api.config:set("crosshair_text_y_offset", v)
        end,
    })

    do
        local text_default = TEXT_PRESETS[1]
        for _, preset in ipairs(TEXT_PRESETS) do
            if preset == xtext.text then
                text_default = preset
                break
            end
        end

        -- Free text: sec:textbox is not in the Lilac docs, so safe_control just
        -- returns nil when the framework has no such control (the preset
        -- dropdown and the "crosshair_text" config key still work then).
        safe_control(text_sec, "textbox", {
            name = "Custom Text Input",
            flag = "crosshair_text",
            default = xtext.text,
            placeholder = "Type your crosshair text",
            callback = function(v)
                xtext.text = tostring(v or "")
                api.config:set("crosshair_text", xtext.text)
            end,
        })

        safe_control(text_sec, "dropdown", {
            name = "Text Preset",
            flag = "crosshair_text_preset",
            options = TEXT_PRESETS,
            default = text_default,
            callback = function(v)
                xtext.text = tostring(v or "")
                api.config:set("crosshair_text", xtext.text)
            end,
        })
    end

    safe_control(text_sec, "dropdown", {
        name = "Font",
        flag = "crosshair_text_font",
        options = FONT_OPTIONS,
        default = xtext.font,
        callback = function(v)
            xtext.font = normalize_font_name(v)
            api.config:set("crosshair_text_font", xtext.font)
        end,
    })

    safe_control(text_sec, "dropdown", {
        name = "Color Animation",
        flag = "crosshair_text_animation",
        options = { "Static", "Fading", "Showing", "Blink" },
        default = xtext.animation,
        callback = function(v)
            xtext.animation = tostring(v or "Static")
            api.config:set("crosshair_text_animation", xtext.animation)
        end,
    })

    safe_control(text_sec, "dropdown", {
        name = "Font Animation",
        flag = "crosshair_text_font_animation",
        options = { "None", "Wavey", "Shakey", "Typing" },
        default = xtext.font_animation,
        callback = function(v)
            xtext.font_animation = tostring(v or "None")
            api.config:set("crosshair_text_font_animation", xtext.font_animation)
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Wave Offset (±px)",
        flag = "crosshair_text_wave_offset",
        min = -40, max = 40,
        float = 0.01,
        default = xtext.wave_offset,
        suffix = "px",
        callback = function(v)
            xtext.wave_offset = v
            api.config:set("crosshair_text_wave_offset", v)
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Wave Speed",
        flag = "crosshair_text_wave_speed",
        min = 0.1, max = 10,
        default = xtext.wave_speed,
        float = 0.01,
        suffix = " /s",
        callback = function(v)
            xtext.wave_speed = v
            api.config:set("crosshair_text_wave_speed", v)
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Shake Intensity",
        flag = "crosshair_text_shake_intensity",
        min = 0, max = 20,
        float = 0.01,
        default = xtext.shake_intensity,
        suffix = "px",
        callback = function(v)
            xtext.shake_intensity = v
            api.config:set("crosshair_text_shake_intensity", v)
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Typing Speed",
        flag = "crosshair_text_typing_speed",
        min = 1, max = 30,
        float = 0.01,
        default = xtext.typing_speed,
        suffix = " char/s",
        callback = function(v)
            xtext.typing_speed = v
            api.config:set("crosshair_text_typing_speed", v)
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Type Delay",
        flag = "crosshair_text_typing_delay",
        min = 0, max = 5,
        default = xtext.typing_delay,
        float = 0.01,
        suffix = "s",
        callback = function(v)
            xtext.typing_delay = v
            api.config:set("crosshair_text_typing_delay", v)
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Text Spacing",
        flag = "crosshair_text_spacing",
        min = -10, max = 30,
        float = 0.01,
        default = xtext.spacing,
        suffix = "px",
        callback = function(v)
            xtext.spacing = v
            api.config:set("crosshair_text_spacing", v)
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Animation Speed",
        flag = "crosshair_text_speed",
        min = 1, max = 10,
        float = 0.01,
        default = xtext.speed,
        callback = function(v)
            xtext.speed = v
            api.config:set("crosshair_text_speed", v)
        end,
    })

    safe_control(text_sec, "colorpicker", {
        name = "Text Color",
        flag = "crosshair_text_color",
        default = xtext.color,
        callback = function(v)
            xtext.color = color_from(v, xtext.color)
            api.config:set("crosshair_text_color", color_to_table(xtext.color))
        end,
    })

    safe_control(text_sec, "toggle", {
        name = "Replace Text with Ragebot Status",
        flag = "crosshair_text_ragebot_status",
        default = xtext.replace_with_ragebot,
        callback = function(v)
            xtext.replace_with_ragebot = v
            api.config:set("crosshair_text_ragebot_status", v)
        end,
    })

    safe_control(text_sec, "toggle", {
        name = "Text Shadow",
        flag = "crosshair_text_shadow",
        default = xtext.shadow_enabled,
        callback = function(v)
            xtext.shadow_enabled = v
            api.config:set("crosshair_text_shadow", v)
            rebuild_text_drawings()
        end,
    })

    safe_control(text_sec, "colorpicker", {
        name = "Shadow Color",
        flag = "crosshair_text_shadow_color",
        default = xtext.shadow_color,
        callback = function(v)
            xtext.shadow_color = color_from(v, xtext.shadow_color)
            api.config:set("crosshair_text_shadow_color", color_to_table(xtext.shadow_color))
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Shadow Offset X",
        flag = "crosshair_text_shadow_x",
        min = -20, max = 20,
        float = 0.01,
        default = xtext.shadow_offset_x,
        suffix = "px",
        callback = function(v)
            xtext.shadow_offset_x = v
            api.config:set("crosshair_text_shadow_x", v)
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Shadow Offset Y",
        flag = "crosshair_text_shadow_y",
        min = -20, max = 20,
        float = 0.01,
        default = xtext.shadow_offset_y,
        suffix = "px",
        callback = function(v)
            xtext.shadow_offset_y = v
            api.config:set("crosshair_text_shadow_y", v)
        end,
    })

    safe_control(text_sec, "toggle", {
        name = "Image Overlay",
        flag = "crosshair_image_enabled",
        default = ximg.enabled,
        callback = function(v)
            ximg.enabled = v
            api.config:set("crosshair_image_enabled", v)
            if not v then
                loaded_image_url = nil
            end
        end,
    })

    safe_control(text_sec, "slider", {
        name = "Image Size",
        flag = "crosshair_image_size",
        min = 8, max = 128,
        float = 0.01,
        default = ximg.size,
        callback = function(v)
            ximg.size = v
            api.config:set("crosshair_image_size", v)
        end,
    })

    ----------------------------------------------------------------------
    -- GUI rendering toggle
    ----------------------------------------------------------------------
    local gui_render = {
        loop = nil,
        child_conn = nil,
        saved = {},
        cleared = false,
        warned = false,
    }

    local menu_cache = setmetatable({}, { __mode = "k" })

    -- Identifies the Lilac menu by name / label text only (no Lilac internals).
    local function is_lilac_menu(gui)
        local cached = menu_cache[gui]
        if cached ~= nil then
            return cached
        end

        local result = false
        local lowered_name = string.lower(gui.Name)
        if lowered_name:find("lilac", 1, true) or lowered_name:find("linoria", 1, true)
            or lowered_name:find("obsidian", 1, true) then
            result = true
        end

        if not result then
            pcall(function()
                for _, descendant in ipairs(gui:GetDescendants()) do
                    if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                        if string.lower(descendant.Text):find("lilac", 1, true) then
                            result = true
                            break
                        end
                    end
                end
            end)
        end

        menu_cache[gui] = result
        return result
    end

    local function disable_screen_gui(gui)
        if gui:IsA("ScreenGui") and not is_lilac_menu(gui) then
            if gui_render.saved[gui] == nil then
                gui_render.saved[gui] = gui.Enabled
            end
            pcall(function() gui.Enabled = false end)
        end
    end

    local function reset_script_drawings()
        drawings.lines = {}
        drawings.outlines = {}
        drawings.outline_parts = {}
        drawings.gradient_lines = {}
        drawings.gradient_outlines = {}
        for i = 1, 4 do
            drawings.gradient_lines[i] = {}
            drawings.gradient_outlines[i] = {}
        end
        loaded_image_url = nil
        drawings.image = new_drawing("Image")
        rebuild_text_drawings()
        ensure_crosshair_drawings()
    end

    apply_gui_rendering = function(enabled, skip_rebuild)
        if enabled then
            if gui_render.loop then return end

            local player_gui = Players.LocalPlayer
                and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if player_gui then
                for _, gui in ipairs(player_gui:GetChildren()) do
                    disable_screen_gui(gui)
                end
                gui_render.child_conn = player_gui.ChildAdded:Connect(disable_screen_gui)
                track(gui_render.child_conn)
            end
            pcall(function()
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
            end)

            gui_render.loop = RunService.Heartbeat:Connect(function()
                local clear = (getgenv and getgenv().cleardrawcache) or cleardrawcache
                if type(clear) == "function" then
                    pcall(clear)
                    gui_render.cleared = true
                else
                    set_all_hidden()
                    if not gui_render.warned then
                        gui_render.warned = true
                        warn("[" .. api.name .. "] cleardrawcache is unavailable; only this script's drawings are hidden.")
                    end
                end
            end)
            track(gui_render.loop)
        else
            if gui_render.loop then
                pcall(function() gui_render.loop:Disconnect() end)
                gui_render.loop = nil
            end
            if gui_render.child_conn then
                pcall(function() gui_render.child_conn:Disconnect() end)
                gui_render.child_conn = nil
            end
            for gui, was_enabled in pairs(gui_render.saved) do
                if gui and gui.Parent then
                    pcall(function() gui.Enabled = was_enabled end)
                end
            end
            gui_render.saved = {}
            pcall(function()
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
            end)
            if gui_render.cleared and not skip_rebuild then
                reset_script_drawings()
            end
            gui_render.cleared = false
        end
    end

    if ffa_state.disable_gui_render then
        apply_gui_rendering(true)
    end

    ----------------------------------------------------------------------
    -- Render loop
    ----------------------------------------------------------------------
    track(RunService.RenderStepped:Connect(function(dt)
        accumulated_time = accumulated_time + dt

        if ffa_state.disable_gui_render then
            return
        end
        hide_game_crosshair()
        ensure_crosshair_drawings()

        if not xhair.enabled or not drawings.lines then
            set_all_hidden()
            return
        end

        local camera = Workspace.CurrentCamera
        if not camera then
            set_all_hidden()
            return
        end

        local center = camera.ViewportSize / 2
        local now = os.clock()
        local text_offset = math.max(0, tonumber(xhair.offset) or 0)
        local offset = text_offset
        local length = math.max(1, tonumber(xhair.length) or 1)
        local angle = math.rad(tonumber(xhair.rotation) or 0)

        if xhair.animation == "Bounce" or xhair.animation == "Bounce + Rotate" then
            local bounce_phase = math.abs(math.sin(
                now * math.max(0, tonumber(xhair.bounce_speed) or 0) * math.pi
            ))
            offset = offset + math.max(0, tonumber(xhair.bounce) or 0) * bounce_phase
        end
        if xhair.animation == "Rotate" or xhair.animation == "Bounce + Rotate" then
            angle = angle + now * math.max(0, tonumber(xhair.rotate_speed) or 0) * math.pi * 2
        end

        local vectors = {
            { Vector2.new(0, -offset - length), Vector2.new(0, -offset) },
            { Vector2.new(offset, 0), Vector2.new(offset + length, 0) },
            { Vector2.new(0, offset), Vector2.new(0, offset + length) },
            { Vector2.new(-offset - length, 0), Vector2.new(-offset, 0) },
        }

        local points = {}
        for i = 1, 4 do
            points[i] = {
                center + rotate_vector(vectors[i][1], angle),
                center + rotate_vector(vectors[i][2], angle),
            }
        end

        for i, line in ipairs(drawings.lines) do
            local outline = drawings.outlines and drawings.outlines[i]
            local outline_parts = drawings.outline_parts and drawings.outline_parts[i]
            local line_thickness = math.max(1, tonumber(xhair.thickness) or 1)
            local outline_thickness = math.max(1, tonumber(xhair.outline_thickness) or 1)

            configure_outline_box(
                outline_parts,
                points[i][1],
                points[i][2],
                line_thickness,
                outline_thickness,
                xhair.outline_color,
                xhair.outline
            )

            configure_line(
                outline,
                points[i][1],
                points[i][2],
                xhair.outline_color,
                outline_thickness,
                false,
                1
            )

            configure_line(
                line,
                points[i][1],
                points[i][2],
                (function()
                    local color = Color3.new(1, 1, 1)
                    pcall(function()
                        color = get_line_color(i, accumulated_time)
                    end)
                    return color
                end)(),
                line_thickness,
                not xhair.gradient,
                2
            )

            for segment = 1, GRADIENT_SEGMENTS do
                local segment_start = (segment - 1) / GRADIENT_SEGMENTS
                local segment_end = segment / GRADIENT_SEGMENTS
                local segment_from = points[i][1]:Lerp(points[i][2], segment_start)
                local segment_to = points[i][1]:Lerp(points[i][2], segment_end)
                local segment_color = Color3.new(1, 1, 1)
                pcall(function()
                    segment_color = get_line_color(
                        i,
                        accumulated_time,
                        (segment_start + segment_end) / 2
                    )
                end)

                local gradient_outline = drawings.gradient_outlines[i][segment]
                configure_line(
                    gradient_outline,
                    segment_from,
                    segment_to,
                    xhair.outline_color,
                    outline_thickness,
                    false,
                    1
                )

                local gradient_line = drawings.gradient_lines[i][segment]
                configure_line(
                    gradient_line,
                    segment_from,
                    segment_to,
                    segment_color,
                    line_thickness,
                    xhair.gradient,
                    2
                )
            end
        end

        local anim = xtext.animation
        local alpha = 1
        local using_ragebot_status = xtext.replace_with_ragebot
        local display_text = using_ragebot_status
            and get_ragebot_status()
            or tostring(xtext.text or "")
        local text_visible = (xtext.enabled or xtext.replace_with_ragebot)
            and display_text ~= ""
        if anim == "Fading" then
            alpha = 0.2 + 0.8 * ((math.sin(accumulated_time * xtext.speed) + 1) / 2)
        elseif anim == "Showing" then
            alpha = clamp((math.sin(accumulated_time * xtext.speed) + 1) / 2, 0, 1)
        elseif anim == "Blink" then
            text_visible = text_visible and math.sin(accumulated_time * xtext.speed * 2) > 0
        end

        local font_animation = xtext.font_animation
        local rendered_text = display_text
        if font_animation == "Typing" and display_text ~= "" then
            local character_count = #display_text
            local typing_speed = math.max(0.1, tonumber(xtext.typing_speed) or 1)
            local type_delay = math.max(0, tonumber(xtext.typing_delay) or 0)
            local write_duration = character_count / typing_speed
            local cycle_duration = math.max(0.001,
                type_delay + write_duration + type_delay + write_duration
            )
            local phase = accumulated_time % cycle_duration
            local visible_count
            local write_start = type_delay
            local write_end = write_start + write_duration
            local delete_start = write_end + type_delay
            if phase < write_start then
                visible_count = 0
            elseif phase < write_end then
                visible_count = math.floor((phase - write_start) * typing_speed)
            elseif phase < delete_start then
                visible_count = character_count
            else
                visible_count = math.floor(
                    character_count - (phase - delete_start) * typing_speed
                )
            end
            rendered_text = string.sub(display_text, 1, math.max(0, visible_count))
        end

        local rendered_visible = text_visible and rendered_text ~= ""

        local text_y_offset = tonumber(xtext.y_offset) or 0
        local text_position = center + Vector2.new(
            0,
            text_offset + length + 5 + text_y_offset
        )
        local text_size = clamp(tonumber(xtext.size) or 16, 8, 64)
        local font_name = normalize_font_name(xtext.font)
        local text_font, custom_font = get_font(font_name)
        local faux_bold = font_name == "Monospace Bold" and not custom_font
        local pixel_outline_color = Color3.new(0, 0, 0)
        local text_color = xtext.color
        local rainbow_speed = math.max(0, tonumber(xtext.rainbow_speed) or 0)
        if using_ragebot_status then
            text_color = Color3.new(1, 1, 1)
        elseif xtext.rainbow then
            text_color = Color3.fromHSV((accumulated_time * rainbow_speed) % 1, 0.9, 1)
        end

        local main_outline = true
        local main_outline_color = pixel_outline_color
        local shadow_on = xtext.shadow_enabled
        local shadow_color = xtext.shadow_color
        local shadow_dx = tonumber(xtext.shadow_offset_x) or 2
        local shadow_dy = tonumber(xtext.shadow_offset_y) or 2
        if faux_bold then
            main_outline_color = text_color
        end

        local text_spacing = tonumber(xtext.spacing) or 0
        local letter_animation = font_animation == "Wavey" or font_animation == "Shakey"
            or math.abs(text_spacing) > 0.001
            or (xtext.gradient and not using_ragebot_status)
        hide_text_letters()

        if letter_animation and rendered_visible then
            ensure_text_letters(#rendered_text)

            local glyph_widths, total_width = {}, 0
            for index = 1, #rendered_text do
                local width
                local letter = drawings.text_letters[index]
                if letter then
                    pcall(function()
                        letter.Text = string.sub(rendered_text, index, index)
                        letter.Size = text_size
                        letter.Font = text_font
                        width = letter.TextBounds.X
                    end)
                end
                if type(width) ~= "number" or width <= 0 then
                    width = text_size * 0.55
                end
                glyph_widths[index] = width + text_spacing
                total_width = total_width + glyph_widths[index]
            end
            local start_x = text_position.X - total_width / 2
            local cursor_x = start_x
            local wave_offset = tonumber(xtext.wave_offset) or 0
            local shake_intensity = math.max(0, tonumber(xtext.shake_intensity) or 0)
            local shadow_x, shadow_y = shadow_dx, shadow_dy

            for index = 1, #rendered_text do
                local character = string.sub(rendered_text, index, index)
                local letter_x = cursor_x + glyph_widths[index] / 2
                cursor_x = cursor_x + glyph_widths[index]
                local letter_y = text_position.Y
                local letter_rotation = 0

                if font_animation == "Wavey" then
                    letter_y = letter_y
                        + math.sin(accumulated_time * math.max(0.1, tonumber(xtext.wave_speed) or 1)
                            * math.pi * 2 + index * 0.75) * wave_offset
                elseif font_animation == "Shakey" then
                    letter_x = letter_x
                        + math.sin(accumulated_time * 31 + index * 1.7) * shake_intensity
                    letter_y = letter_y
                        + math.cos(accumulated_time * 37 + index * 2.3) * shake_intensity
                    letter_rotation = math.sin(accumulated_time * 43 + index * 2.1)
                        * shake_intensity * 0.7
                end

                local letter_color = text_color
                if xtext.gradient and not using_ragebot_status then
                    local gradient_position = (index - 1) / math.max(1, #rendered_text - 1)
                    if xtext.rainbow_gradient then
                        local hue = (gradient_position + accumulated_time * rainbow_speed) % 1
                        letter_color = Color3.fromHSV(hue, 0.9, 1)
                    else
                        letter_color = xtext.gradient_start:Lerp(
                            xtext.gradient_end,
                            clamp(gradient_position, 0, 1)
                        )
                    end
                end

                local letter = drawings.text_letters[index]
                if letter then
                    pcall(function()
                        letter.Text         = character
                        letter.Position     = Vector2.new(letter_x, letter_y)
                        letter.Center       = true
                        letter.Outline      = main_outline
                        letter.OutlineColor = main_outline_color
                        letter.Size         = text_size
                        letter.Font         = text_font
                        letter.Color        = letter_color
                        letter.Transparency = alpha
                        letter.Rotation     = letter_rotation
                        letter.Visible      = true
                    end)
                end

                local shadow_letter = drawings.shadow_letters[index]
                if shadow_letter then
                    pcall(function()
                        shadow_letter.Text         = character
                        shadow_letter.Position     = Vector2.new(letter_x + shadow_x, letter_y + shadow_y)
                        shadow_letter.Center       = true
                        shadow_letter.Outline      = false
                        shadow_letter.OutlineColor = pixel_outline_color
                        shadow_letter.Size         = text_size
                        shadow_letter.Font         = text_font
                        shadow_letter.Color        = shadow_color
                        shadow_letter.Transparency = alpha
                        shadow_letter.Rotation     = letter_rotation
                        shadow_letter.Visible      = shadow_on
                    end)
                end
            end
        end

        if drawings.text_shadow then
            pcall(function()
                drawings.text_shadow.Text         = rendered_text
                drawings.text_shadow.Position     = text_position
                    + Vector2.new(shadow_dx, shadow_dy)
                drawings.text_shadow.Center       = true
                drawings.text_shadow.Outline      = false
                drawings.text_shadow.OutlineColor = pixel_outline_color
                drawings.text_shadow.Size         = text_size
                drawings.text_shadow.Font         = text_font
                drawings.text_shadow.Color        = shadow_color
                drawings.text_shadow.Transparency = alpha
                drawings.text_shadow.Visible      = shadow_on
                    and rendered_visible and not letter_animation
            end)
        end

        if drawings.text then
            pcall(function()
                drawings.text.Text         = rendered_text
                drawings.text.Position     = text_position
                drawings.text.Center       = true
                drawings.text.Outline      = main_outline
                drawings.text.OutlineColor = main_outline_color
                drawings.text.Size         = text_size
                drawings.text.Font         = text_font
                drawings.text.Color        = text_color
                drawings.text.Transparency = alpha
                drawings.text.Visible      = rendered_visible and not letter_animation
            end)
        end

        if drawings.image then
            request_image()
            pcall(function()
                drawings.image.Position     = center - Vector2.new(ximg.size / 2, ximg.size / 2)
                drawings.image.Size         = Vector2.new(ximg.size, ximg.size)
                drawings.image.Visible      = ximg.enabled and loaded_image_url == ximg.url
                drawings.image.Transparency = 1
            end)
        end
    end))

    ----------------------------------------------------------------------
    -- Cleanup (runs on the next init / hot reload; api.unload is not touched)
    ----------------------------------------------------------------------
    local function full_cleanup()
        if apply_gui_rendering then
            apply_gui_rendering(false, true)
        end
        cleanup_connections()

        if zt_cleanup then
            zt_cleanup()
        end

        if respawn_death_conn then
            pcall(function() respawn_death_conn:Disconnect() end)
            respawn_death_conn = nil
        end

        set_all_hidden()
        for _, line in ipairs(drawings.lines or {}) do
            destroy_drawing(line)
        end
        for _, line in ipairs(drawings.outlines or {}) do
            destroy_drawing(line)
        end
        for _, parts in ipairs(drawings.outline_parts or {}) do
            for _, line in ipairs(parts) do
                destroy_drawing(line)
            end
        end
        for _, arm in ipairs(drawings.gradient_lines or {}) do
            for _, line in ipairs(arm) do
                destroy_drawing(line)
            end
        end
        for _, arm in ipairs(drawings.gradient_outlines or {}) do
            for _, line in ipairs(arm) do
                destroy_drawing(line)
            end
        end
        destroy_drawing(drawings.text)
        destroy_drawing(drawings.text_shadow)
        for _, letter in ipairs(drawings.text_letters or {}) do
            destroy_drawing(letter)
        end
        for _, letter in ipairs(drawings.shadow_letters or {}) do
            destroy_drawing(letter)
        end
        destroy_drawing(drawings.image)
        restore_game_crosshair()

        pcall(function()
            RunService:Set3dRenderingEnabled(true)
        end)
    end

    GENV.__harry_extensions_cleanup = full_cleanup

    safe_notify(api, {
        title = api.name,
        content = "FFA helper, zombie tower ragebot, crosshair & animations loaded. (v" .. tostring(api.version or PluginDefinition.version) .. ")",
        duration = 3,
    })
end

local lilac = rawget(_G, "lilac") or (getgenv and getgenv().lilac)
if lilac and lilac.plugin and not ... then
    -- Standalone path, exactly as documented: register with name/author/version,
    -- then run init on the returned api object.
    local api = lilac:plugin({
        name = PluginDefinition.name,
        author = PluginDefinition.author,
        version = PluginDefinition.version,
    })
    PluginDefinition:init(api)
    return api
end

return PluginDefinition
