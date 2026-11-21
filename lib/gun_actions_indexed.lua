dofile_once("data/scripts/gun/gun_enums.lua")
dofile_once("data/scripts/gun/gun_actions.lua")

local indexed_gun_actions = {}
for _, action in ipairs(actions or {}) do
	if action.id then
		indexed_gun_actions[action.id] = action
	end
end

return indexed_gun_actions
