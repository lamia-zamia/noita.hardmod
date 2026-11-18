-- most of this code was shamelessly stolen from Apoth pylons
dofile_once("data/scripts/lib/utilities.lua")
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local entity_id = GetUpdatedEntityID()
local owner = EntityGetRootEntity(entity_id)
local x, y = EntityGetTransform(owner)

local ally = utils.GetInternalInt(owner, "hardmod_soul_linked_ally") or 0

-- TODO: wtf do i do instead of this
---@diagnostic disable-next-line: cast-type-mismatch
---@cast ally entity_id

if ally == 0 then return end
local time = GameGetFrameNum()

-- "arms" particle fx position.
-- sets the fx entity position to between hand and body and wobbles it!
-- do
	local children = EntityGetAllChildren(entity_id)
	if children == nil or #children == 0 then return end

	-- "shoulder" position
	local ax, ay = EntityGetTransform(ally)
	local offset_y = 0
	for _,hitbox in ipairs(EntityGetComponent(ally, "HitboxComponent") or {}) do
		offset_y = math.max(offset_y, -0.5 * ComponentGetValue2(hitbox, "aabb_min_y"))
	end
	ay = ay + offset_y

	for _,fx_entity in pairs(children) do
		if EntityHasTag(fx_entity, "arm_fx") then
			-- pick a position between body and hand. 0 is body, 1 is hand
			---@diagnostic disable-next-line: param-type-mismatch
			local pos = ProceduralRandomf(time, fx_entity)

			-- -- figure out how much to distort the position
			-- -- middle distorts most so we want a range of 0 to 1 to 0
			-- local amount = pos * 2 - 1 -- 0...1 -> -1...0...1
			-- amount = -math.abs(amount) -- -1...0...-1
			-- amount = amount + 1 -- 0...1...0

			-- local distort_x = math.sin((x + time) * 0.03) * 8 * amount
			-- local distort_y = math.sin((y + time) * 0.05734 + 40) * 4 * amount

			local tx, ty = vec_lerp(ax, ay, x, y, pos)
			-- x = x + distort_x
			-- y = y + distort_y
			EntitySetTransform(fx_entity, tx, ty)
		end
	end
-- end
