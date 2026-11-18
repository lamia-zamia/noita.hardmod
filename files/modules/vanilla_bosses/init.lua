--- Credits to Boss Reworks by GrahamBurger for some of the nerfs

local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml
local root = "mods/noita.hardmod/files/modules/vanilla_bosses/"

ModMaterialsFileAdd(root.."materials.xml")

local patches = {
	"alchemist",
	"door_boss",
	"boss_pit",
	"boss_wizard",
}

local edit = {
	["boss_centipede/boss_centipede"] = {
		damagecomp = { materials_damage = false },
		tags = "touchmagic_immunity,no_enemy_perks",
	},
	["boss_dragon"] = {
		effects = { "STUN_PROTECTION_FREEZE" }
	},
	["boss_ghost/boss_ghost"] = {
		damagemult = { explosion = 0.3 }
	},
	["boss_alchemist/boss_alchemist"] = {
		from_base = true,
		effects = { "KNOCKBACK_IMMUNITY" },
		damagecomp = {
			blood_multiplier = 0.1,
			minimum_knockback_force = 99999,
		},
		damagemult = {
			slice = 0.4,
			explosion = 0.5,
			projectile = 0.5,
		}
	},
	["boss_pit/boss_pit"] = {
		from_base = true,
		tags = "no_enemy_perks",
		damagecomp = {
			max_hp = 120,
			hp = 120,
		},
		damagemult = {
			projectile = 1,
			explosion = 1,
			fire = 1,
			electric = 1,
			ice = 1,
			holy = 1.2,
			slice = 2.4,
			toxic = 2.4,
		}
	},
	["boss_gate/gate_monster_a"] = {
		from_base = true,
		damagecomp = { hp = 130 },
		damagemult = {
			projectile = 0.3,
			explosion = 0.3,
		}
	},
	["boss_meat/boss_meat"] = {
		effects = { "STUN_PROTECTION_FREEZE" },
		damagecomp = { hp = 80 },
		damagemult = {
			projectile = 0.3,
			explosion = 0.4,
			drill = 0.6,
			slice = 0.6,
		}
	},
	["boss_fish/fish_giga"] = {}, --missing boss tag
	["boss_gate/gate_monster_b"] = {}, --missing boss tag
	["boss_gate/gate_monster_c"] = {}, --missing boss tag
	["boss_gate/gate_monster_d"] = {}, --missing boss tag
}

for enemy,data in pairs(edit) do
	for f in nxml.edit_file("data/entities/animals/"..enemy..".xml") do
		local file = data.from_base and f:first_of("Base") or f

		local tags = f.attr.tags or file.attr.tags or "boss"
		if not (','..tags..','):find(",boss,") then
			if #tags == 0 then tags = "boss" else tags = table.concat({tags, "boss"}, ',') end
			f.attr.tags = tags
		end
		if data.tags then
			file:set("tags", tags..','..data.tags) --should always have boss tag at least thanks to above code
		end

		if data.damagecomp then
			local dmc = file:first_of("DamageModelComponent")
			for k,v in pairs(data.damagecomp) do
				if dmc then dmc:set(k, v) end
			end
		end

		if data.damagemult then
			local dmc = file:first_of("DamageModelComponent"):first_of("damage_multipliers")
			for k,v in pairs(data.damagemult) do
				if dmc then dmc:set(k, v) end
			end
		end

		for _,effect in pairs(data.effects or {}) do
			local entity = file:create_child("Entity")

			entity:create_child("InheritTransformComponent")
			entity:create_child("GameEffectComponent", {
				effect = effect,
				frames = -1
			})
		end
	end
end

for _,patch in pairs(patches) do
	dofile_once(root.."patches/"..patch..".lua")
end

return {}
