local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")

local COOLDOWN_DURATION = 600

function damage_received( damage, desc, entity_who_caused, is_fatal )
	local owner = GetUpdatedEntityID()
	if owner == nil then return end
	local shield = EntityGetAllChildren( owner, "hardmod_gold_shield" )[1]
	if shield == nil then return end

	-- check whether the effect is on cooldown
	local game_effect = EntityGetAllChildren( owner, "hardmod_gold_shield_cooldown" )[1]
	if game_effect ~= nil then
		local ge_comp = EntityGetFirstComponentIncludingDisabled( game_effect, "GameEffectComponent" )
		if ge_comp ~= nil then
			ComponentSetValue2( ge_comp, "frames", COOLDOWN_DURATION )
		end
		local lt_comp = EntityGetFirstComponentIncludingDisabled( game_effect, "LifetimeComponent" )
		if lt_comp ~= nil then
			ComponentSetValue2( lt_comp, "kill_frame", GameGetFrameNum() + COOLDOWN_DURATION )
		end

		-- if so, reset the status effect and don't trigger the rest of this script
		return
	else
		-- don't apply the cooldown to enemies
		if EntityHasTag( owner, "player_unit" ) then
			LoadGameEffectEntityTo( owner,
				"mods/noita.hardmod/files/modules/vanilla_bosses/entity/status_effects/effect_gold_shield_cooldown.xml"
			)
		end
	end

	-- activate the shield
	utils.SetInternalInt( shield, "hardmod_gold_shield_trigger_frame", GameGetFrameNum() )
	EntitySetComponentsWithTagEnabled( shield, "hardmod_gold_shield_active", true )
	EntitySetComponentsWithTagEnabled( shield, "hardmod_gold_shield_inactive", false )
	local x, y = EntityGetTransform( shield )
	GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/shield/activate", x, y )

	-- briefly give the owner Protection From All
	local duration = utils.GetInternalInt( shield, "hardmod_gold_shield_duration" ) or 75
	LoadGameEffectEntityTo( owner,
		"mods/noita.hardmod/files/modules/vanilla_bosses/entity/status_effects/effect_protection_all_"..duration.."f.xml"
	)
end
