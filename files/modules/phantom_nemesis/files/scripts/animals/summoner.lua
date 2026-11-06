
local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent(entity_id)
local target = EntityGetFilename(parent_id)
local x,y = EntityGetTransform(parent_id)
local r = 300

local targets = EntityGetInRadiusWithTag( x, y, r, "miniboss_minion" ) or {}

if #targets < 4 then

	--Wipe angelings
	local targets2 = EntityGetInRadiusWithTag( x, y, 600, "miniboss_minion" ) or {}
	for z=1,#targets2 do
		EntityKill(targets2[z])
	end
	
	for k=1,7 do
		SetRandomSeed(x + k,y)
		local rnd = Random(-60,60)
		local minion_id = EntityLoad(target, x + rnd, y + rnd)
		EntityLoad( "data/entities/particles/teleportation_target.xml", x + rnd, y + rnd )
		EntityAddChild(minion_id, EntityLoad("mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/misc/fx/miniboss_particles.xml", x, y))
		--Teleport sound
		GamePlaySound( "data/audio/Desktop/misc.bank", "game_effect/teleport/tick", x, y );

		EntityAddTag(minion_id,"miniboss_minion")
		EntityAddTag(minion_id,"necrobot_NOT")
		LoadGameEffectEntityTo( minion_id, "mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/misc/summoner_stun.xml" ) --Stun nearly spawned summons for 2 seconds

		EntityAddComponent2(
			minion_id,
			"VariableStorageComponent",
			{
				_tags="no_gold_drop"
			}
		)

		EntityAddComponent2(
			minion_id,
			"LifetimeComponent",
			{
				lifetime=720
			}
		)
	end
end
