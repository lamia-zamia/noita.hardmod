dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/biomes/temple_shared.lua")

local x,y = EntityGetTransform(GetUpdatedEntityID())

if GlobalsGetValue("TEMPLE_PEACE_WITH_GODS") == "1" then
	GamePrintImportant("$logdesc_temple_peace_temple_break", "")
	GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/angered_the_gods/create", x, y)
	return
end

local leak_name = "TEMPLE_LEAKED_" .. temple_pos_to_id(x, y)

-- spawn workshop guard
if GlobalsGetValue("TEMPLE_SPAWN_GUARDIAN") ~= "1" then
	temple_spawn_guardian(x, y)
end

GlobalsSetValue("TEMPLE_SPAWN_GUARDIAN", "1")


if GlobalsGetValue(leak_name) ~= "1" then
	if tonumber(GlobalsGetValue("STEVARI_DEATHS", "0")) < 3 then
		GamePrintImportant("$logdesc_temple_spawn_guardian", "")
	else
		GamePrintImportant("$logdesc_gods_are_very_angry", "")
		GameGiveAchievement("GODS_ENRAGED")
	end
	GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/angered_the_gods/create", x, y)
	GameScreenshake(150)
end

print("gods angered by "..EntityGetName(GetUpdatedEntityID()))
for _,eid in ipairs(EntityGetInRadius(x, y, 350)) do
	if EntityGetName(eid) == "hardmod.hm_rework.missing_perk_check" then EntityKill(eid) end
end

GlobalsSetValue(leak_name, "1")

--function death(damage_type_bit_field, message, attacker, drop_items)
--	print(("DIED!\ndamage_type_bit_field: %s\nmessage: %s\nattacker: %s\nframe: %s"):format(damage_type_bit_field, message, attacker, GameGetFrameNum()))
--	if attacker then
--		print(("ATTACKER INFO:\nname: [%s]\npath: [%s]"):format(EntityGetName(attacker), EntityGetFilename(attacker)))
--	end
--end
