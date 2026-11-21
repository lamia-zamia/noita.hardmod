local ability_id = GetUpdatedEntityID()
local host_id = EntityGetRootEntity(ability_id)
local comp_id = GetUpdatedComponentID()
local x, y = EntityGetTransform(host_id)
local fogofwar_vision = GameGetFogOfWar(x, y)
local children = EntityGetAllChildren(host_id) or {}
local stored_abilities = ""
for _,child in ipairs(children) do
    if EntityGetName(child) == "felcesis_brain" then
		local comp = EntityGetFirstComponentIncludingDisabled(child, "VariableStorageComponent")
        stored_abilities = comp and ComponentGetValue2(comp, "value_string")
        break
    end
end

function SplitStringOnCharIntoTable(string, char)
    local list = {}
    for w in (string .. char):gmatch("([^" .. char .. "]*)" .. char) do
        if w ~= "" then
            table.insert(list, w)
        end
    end
    return list
end

function GetPlayer()
    local tags = {"player_unit", "polymorphed_player", "polymorphed_cessation"}
    for tag=1,#tags do
        local player = EntityGetWithTag(tags[tag])
        if #player > 0 then
            return player[1]
        end
    end
    return nil
end

function IsOnCamera()
    local padding = 30
    local camX, camY, camW, camH = GameGetCameraBounds()
    return x >= camX - padding and x <= camX + camW + padding and y >= camY - padding and y <= camY + camH + padding
end

function GetTextSize(text)
    local w = math.max(1, #text) * 7
    local h = 12
    return w, h
end

function GetCorners(cx, cy, rot, hw, hh)
    local cos_r = math.cos(rot)
    local sin_r = math.sin(rot)
    local corners = {}
    local local_corners = {
        {-hw, -hh},
        { hw, -hh},
        { hw,  hh},
        {-hw,  hh}
    }
    for i, lc in ipairs(local_corners) do
        local lx, ly = lc[1], lc[2]
        local rx = lx * cos_r - ly * sin_r
        local ry = lx * sin_r + ly * cos_r
        corners[i] = {x = cx + rx, y = cy + ry}
    end
    return corners
end

function SeparatedOnAxis(cornersA, cornersB, axis)
    local minA, maxA = math.huge, -math.huge
    for _, c in ipairs(cornersA) do
        local proj = c.x * axis.x + c.y * axis.y
        if proj < minA then minA = proj end
        if proj > maxA then maxA = proj end
    end
    local minB, maxB = math.huge, -math.huge
    for _, c in ipairs(cornersB) do
        local proj = c.x * axis.x + c.y * axis.y
        if proj < minB then minB = proj end
        if proj > maxB then maxB = proj end
    end
    return maxA < minB or maxB < minA
end

function OverlapSAT(cornersA, cornersB, axesA, axesB)
    for _, axis in ipairs(axesA) do
        if SeparatedOnAxis(cornersA, cornersB, axis) then return false end
    end
    for _, axis in ipairs(axesB) do
        if SeparatedOnAxis(cornersA, cornersB, axis) then return false end
    end
    return true
end

function IsFreePosition(px, py, rot, hw, hh, placed)
    local corners = GetCorners(px, py, rot, hw, hh)
    local axes = {
        {x = math.cos(rot), y = math.sin(rot)},
        {x = -math.sin(rot), y = math.cos(rot)}
    }
    for _, p in ipairs(placed) do
        local placed_corners = GetCorners(p.x, p.y, p.rot, p.hw, p.hh)
        local placed_axes = {
            {x = math.cos(p.rot), y = math.sin(p.rot)},
            {x = -math.sin(p.rot), y = math.cos(p.rot)}
        }
        if OverlapSAT(corners, placed_corners, axes, placed_axes) then
            return false
        end
    end
    return true
end

function FindFreePosition(cx, cy, rot, hw, hh, placed, radius_start)
    local max_attempts = 15

    for _=1, max_attempts do
        local angle = math.random() * math.pi * 2
        local radius = radius_start + math.random() * 90 + (#placed * 12)
        local px = cx + math.cos(angle) * radius
        local py = cy + math.sin(angle) * radius

        if IsFreePosition(px, py, rot, hw, hh, placed) then
            return px, py
        end
    end

    local radius = radius_start
    local max_ring = radius_start + 128
    while radius <= max_ring do
        local steps = math.max(12, math.floor(radius / 12))
        for s = 1, steps do
            local angle = (s / steps) * math.pi * 2
            local px = cx + math.cos(angle) * radius
            local py = cy + math.sin(angle) * radius

            if IsFreePosition(px, py, rot, hw, hh, placed) then
                return px, py
            end
        end
        radius = radius + 8
    end

    local angle = math.random() * math.pi * 2
    return cx + math.cos(angle) * max_ring, cy + math.sin(angle) * max_ring
end

function CreateAbilityText()
    local ability_names = SplitStringOnCharIntoTable(stored_abilities, ",")
    local texts = {}

    for _, text_key in ipairs(ability_names) do
        local display_text = GameTextGetTranslatedOrNot("$" .. text_key)
        local text_id = EntityLoad("mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/misc/fx/ability_text.xml", x, y)
        local sprite_comp = EntityGetFirstComponentIncludingDisabled(text_id, "SpriteComponent")

        if text_id ~= 0 and sprite_comp then
            ComponentSetValue2(sprite_comp, "text", display_text)
            EntityRefreshSprite(text_id, sprite_comp)

            local w, h = GetTextSize(display_text)
            local hw = w * 0.5
            local hh = h * 0.5

            table.insert(texts, {
                entity = text_id,
                sprite = sprite_comp,
                hw = hw,
                hh = hh,
            })
        end
    end

    local placed = {}

    for _, text in ipairs(texts) do
        local rot = math.rad(math.random(-55, 55))
        local px, py = FindFreePosition(x, y, rot, text.hw, text.hh, placed, 20)

        EntitySetTransform(text.entity, px, py, rot, 1, 1)

        table.insert(placed, {
            x = px,
            y = py,
            rot = rot,
            hw = text.hw,
            hh = text.hh,
        })
    end
end

function Update()
    local player_id = GetPlayer()
    if player_id == nil then return end

    if fogofwar_vision < 200 and IsOnCamera() then
        CreateAbilityText()
        EntitySetComponentIsEnabled(ability_id, comp_id, false)
    end
end

Update()
