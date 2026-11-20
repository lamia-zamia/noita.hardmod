dofile_once("data/scripts/lib/utilities.lua")

local trigger_eid = GetUpdatedEntityID()
local xpos, ypos = EntityGetTransform(trigger_eid)

---@class TowerQuest
---@field id string
---@field check_entity_tag string?
---@field check (fun(x: number, y: number): boolean)?
---@field spawn_spell string?
---@field add_persistent_flags string[]?
---@field func (fun(x: number, y: number))?

hooks = {---@class towercheck_hooks
	kill_trigger = true,
	---@type TowerQuest[]
	quests = {
		{
			id = "tower_small_friend",
			check_entity_tag = "small_friend",
			spawn_spell = "NUKE_GIGA",
			add_persistent_flags = { "card_unlocked_nukegiga", "final_secret_orb" },
			func = function(x, y)
				EntityLoad("data/entities/projectiles/deck/nuke.xml", x, y)
			end
		},
		{
			id = "tower_big_friend",
			check_entity_tag = "big_friend",
			spawn_spell = "BOMB_HOLY_GIGA",
			add_persistent_flags = { "card_unlocked_bomb_holy_giga", "final_secret_orb2" },
			func = function(x, y)
				EntityLoad("data/entities/projectiles/deck/nuke.xml", x, y)
			end
		},
		{
			id = "tower_curse_of_greed",
			check_entity_tag = "player_unit",
			check = function()
				return GameHasFlagRun("greed_curse") and not GameHasFlagRun("greed_curse_gone")
			end,
			spawn_spell = "DIVIDE_10",
			add_persistent_flags = { "card_unlocked_divide" },
		},
		{
			id = "tower_player",
			check_entity_tag = "player_unit",
			check = function()
				return not GameHasFlagRun("tower_done_any_quest")
			end,
			spawn_spell = "AIR_BULLET",
		}
	},
	post_quest_funcs = {}, ---@type fun(quest)[]
}

for _,path in ipairs(ModLuaFileGetAppends("data/scripts/magic/__towercheck.lua")) do
	if ModDoesFileExist(path) then
		dofile_once(path)(hooks)
	else
		print("Warning!! towercheck.lua append " .. path .. " not found!!")
	end
end

for _,quest in pairs(hooks.quests) do
	if GameHasFlagRun(quest.id) then goto continue end

	----

	if quest.check and not quest.check(xpos, ypos) then
		goto continue
	end

	if quest.check_entity_tag and #EntityGetInRadiusWithTag(xpos, ypos, 16, quest.check_entity_tag) < 1 then
		goto continue
	end

	---

	for _,flag in pairs(quest.add_persistent_flags or {}) do
		AddFlagPersistent(flag)
	end

	if quest.spawn_spell then
		CreateItemActionEntity(quest.spawn_spell, xpos, ypos)
	end

	if quest.func then
		quest.func(xpos, ypos)
	end

	GameAddFlagRun(quest.id)

	if hooks.kill_trigger then
		EntityKill(trigger_eid)
	end

	for _,hook in pairs(hooks.post_quest_funcs) do hook(quest) end

    ::continue::
end
