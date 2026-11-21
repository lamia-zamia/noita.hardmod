dofile_once("data/scripts/perks/perk.lua")
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local entity_id = GetUpdatedEntityID()
local x,y = EntityGetTransform(entity_id)

if GameHasFlagRun("hardmod.collapse_crystal_sacrificed") then EntityKill(entity_id) return end


for _,crystal in ipairs(EntityGetInRadiusWithTag(x, y, 50, "hm_crystal")) do
	if EntityGetName(crystal) == "hardmod.collapse_crystal" then
		for _,luacomp in ipairs(EntityGetComponent(crystal, "LuaComponent") or {}) do
			EntityRemoveComponent(crystal, luacomp)
		end
		EntityInflictDamage(crystal, 20, "NONE", "kill the fuckin crystal", "NONE", 0, 0)

		GameScreenshake(80)
		GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/orb/create", x, y)
		EntityLoad("data/entities/particles/image_emitters/magical_symbol.xml", x, y) --okay we need to stop overusing this effect BUT IT FITS SO WELL HERE!!!
		GamePrintImportant("$hardmod_collapse_crystal_sacrificed", "$hardmod_collapse_crystal_sacrificed_desc")

		local valid_perks = {}
		for _,perk in ipairs(perk_list) do
			if not (perk.not_in_default_perk_pool or perk.holy_mountain_exclusive or GameHasFlagRun("PERK_PICKED_"..perk.id)) then
				valid_perks[#valid_perks+1] = perk
			end
		end
		SetRandomSeed(y-1937, x-213048)

		for i = #valid_perks, 2, -1 do
			local j = math.random(i)
			valid_perks[i], valid_perks[j] = valid_perks[j], valid_perks[i]
		end

		local perks = utils.SpawnPerkCircle(valid_perks, x, y, 220)
		for _,perk in ipairs(perks) do
			EntityAddComponent2(perk, "LuaComponent", {
				execute_every_n_frame = -1,
				script_item_picked_up = "mods/noita.hardmod/files/modules/holy_mountain_rework/crystal/crystal_perk_pickup.lua",
			})
		end

		GameAddFlagRun("hardmod.collapse_crystal_sacrificed")
		AddFlagPersistent("hardmod_collapse_crystal_sacrificed")
		EntityKill(entity_id)
	end
end
