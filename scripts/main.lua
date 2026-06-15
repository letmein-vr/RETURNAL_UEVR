-- =============================================================================
-- Returnal VR - main.lua
-- Merged from: attachments.lua, config.lua, hiddenparasites.lua, returnalcinematics.lua
-- returnalhands.lua remains as a separate script
-- =============================================================================

-- Requires (deduplicated across all source scripts)
local api         = uevr.api
local uevrUtils   = require("libs/uevr_utils")
local attachments = require("libs/attachments")
local configui    = require("libs/configui")

-- Global settings (must run before attachments.init())
uevrUtils.setDeveloperMode(true)
uevrUtils.setLogLevel(LogLevel.Debug)
attachments.setLogLevel(LogLevel.Debug)

-- Module-level state
local prevViewTarget    = nil  -- cinematic view target tracker
local obj_hook_disabled = nil  -- cinematic hook state cache

-- =============================================================================
-- ATTACHMENTS  (was: attachments.lua)
-- =============================================================================

attachments.init()

local function getWeaponMesh()
    if uevrUtils.getValid(pawn) ~= nil and pawn.GetCurrentWeapon ~= nil then
        local currentWeapon = pawn:GetCurrentWeapon()
        if currentWeapon ~= nil then return currentWeapon.RootComponent end
    end
    return nil
end

attachments.registerOnGripUpdateCallback(function()
    -- rightAttachment, rightMesh, rightSocket, leftAttachment, leftMesh, leftSocket, detachFromParent, allowReattach
    -- allowReattach=true → attachments system calls set_permanent(true) on the UObjectHook state,
    -- overriding the gun actor's own tick which would otherwise reset DefaultSceneRoot every frame.
    return getWeaponMesh(), nil, nil, nil, nil, nil, true, true
end)

-- =============================================================================
-- CONFIG PANEL  (was: config.lua)
-- =============================================================================

local configDefinition = {
    {
        panelLabel = "Returnal VR Config",
        saveFile   = "config_returnal_mod",
        layout = {
            { widgetType = "text_colored", label = "Returnal VR", color = "#00CC66FF" },
            { widgetType = "spacing" },
            { widgetType = "text",    label = "UI Follow Mode:" },
            { widgetType = "spacing" },
            {
                widgetType    = "checkbox",
                id            = "ui_follow_hmd",
                label         = "UI Follows HMD (Head)",
                initialValue  = true
            },
            {
                widgetType    = "checkbox",
                id            = "ui_follow_controller",
                label         = "UI Follows Right Controller",
                initialValue  = false
            },
        }
    }
}

configui.create(configDefinition)

configui.onUpdate("ui_follow_hmd", function(value)
    if value == true then
        configui.setValue("ui_follow_controller", false)
        uevrUtils.enableUIFollowsView(true)
        print("[ReturnalMod] UI now follows HMD")
    end
end)

configui.onUpdate("ui_follow_controller", function(value)
    if value == true then
        configui.setValue("ui_follow_hmd", false)
        uevrUtils.enableUIFollowsView(false)
        print("[ReturnalMod] UI now follows Right Controller")
    end
end)

configui.onCreate("ui_follow_hmd", function(value)
    uevrUtils.enableUIFollowsView(value)
end)

print("[ReturnalMod] Config panel loaded")

-- =============================================================================
-- PARASITE HIDER  (was: hiddenparasites.lua)
-- =============================================================================

local hiddenParasites = {}
local CHECK_INTERVAL  = 1.0
local lastCheckTime   = 0

local function findAndHideParasites()
    print("[ParasiteHider] Checking...")

    local localPawn = api:get_local_pawn()
    if not localPawn then
        print("[ParasiteHider] No pawn")
        return
    end

    print("[ParasiteHider] Pawn found: " .. localPawn:get_full_name())

    local children = localPawn.Children
    if not children then
        print("[ParasiteHider] No Children property")

        local owned = localPawn.OwnedComponents
        if owned then
            print("[ParasiteHider] Trying OwnedComponents...")
            for i, comp in ipairs(owned) do
                if comp then
                    local name = comp:get_full_name()
                    if name:find("Parasite") then
                        print("[ParasiteHider] Found: " .. name)
                        local owner = comp:GetOwner()
                        if owner and owner ~= localPawn then
                            owner:SetActorHiddenInGame(true)
                            print("[ParasiteHider] Hidden actor")
                        end
                    end
                end
            end
        end
        return
    end

    print("[ParasiteHider] Children found, iterating...")
    for i, childActor in ipairs(children) do
        if childActor then
            local name = childActor:get_full_name()
            print("[ParasiteHider] Child: " .. name)
            if name:find("Parasite") then
                childActor:SetActorHiddenInGame(true)
                print("[ParasiteHider] Hidden: " .. name)
            end
        end
    end
end

uevr.sdk.callbacks.on_pre_engine_tick(function(engine, delta)
    lastCheckTime = lastCheckTime + delta
    if lastCheckTime < CHECK_INTERVAL then return end
    lastCheckTime = 0
    findAndHideParasites()
end)

print("[ParasiteHider] Loaded - using on_pre_engine_tick")

-- =============================================================================
-- CINEMATIC DETECTION  (was: returnalcinematics.lua)
-- =============================================================================

local function disable_object_hooks(state)
    if state ~= obj_hook_disabled then
        obj_hook_disabled = state
        UEVR_UObjectHook.set_disabled(state)
    end
end

uevr.sdk.callbacks.on_post_engine_tick(function(engine, delta)
    local player = api:get_player_controller(0)
    if player then
        local currentVT = player:GetViewTarget()
        if prevViewTarget ~= currentVT then
            local view_target = currentVT:get_full_name()
            print(view_target)

            local objClass = currentVT:get_class()
            print(objClass:get_full_name())

            local is_cinematic = view_target:find("BP_Cinematic", 1, true) ~= nil
            disable_object_hooks(is_cinematic == true)
            if is_cinematic == true then
                uevr.params.vr.set_mod_value("VR_AimMethod", "0")
            else
                uevr.params.vr.set_mod_value("VR_AimMethod", "2")
            end

            prevViewTarget = currentVT
        end
    end
end)
