
local me = GetUpdatedEntityID()
local caster = EntityGetRootEntity(me)
local controls = EntityGetFirstComponent(caster, "ControlsComponent")
if not controls then return end

local function is_alt_fire_pressed()
    local binding = tostring(ModSettingGet("noita.hardmod.alt_fire_keybind"))
    local mode = "key_code"
    for code in string.gmatch(binding, "[^,]+") do
        if code == "mouse_code" or code == "key_code" or code == "joystick_code" then
            mode = code
        else
			---@diagnostic disable-next-line: cast-local-type
            code = tonumber(code) or 0
            if mode == "key_code" then
                if InputIsKeyDown(code) then
                  return true
                end
            elseif mode == "mouse_code" then
                if InputIsMouseButtonDown(code) then
                  return true
                end
            elseif mode == "joystick_code" then
                if InputIsJoystickButtonDown(0, code) then
                  return true
                end
            end
        end
    end
end

if is_alt_fire_pressed() then
    if not ModSettingGet("noita.hardmod.alt_fire_enable_in_inventory") and GameIsInventoryOpen() then return end

    local platform_shooter = EntityGetFirstComponent(caster, "PlatformShooterPlayerComponent")
    if not platform_shooter then return end
    ComponentSetValue2(platform_shooter, "mForceFireOnNextUpdate", true)
    local vscs = EntityGetComponent(caster, "VariableStorageComponent") or {}
    for _, vsc in ipairs(vscs) do
      	if ComponentGetValue2(vsc, "name") == "alt_fire_cause" then
      		  EntityRemoveComponent(caster, vsc)
        end
    end
    EntityAddComponent2( caster, "VariableStorageComponent", {
        name = "alt_fire_cause",
        value_string = "alt_fire",
        value_int = GameGetFrameNum()
    })
end
