local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml
local deck = "data/entities/projectiles/deck/"

local damage_nerfs = {
	["chainsaw"] = { dmg = { slice = 0.3 } },
	["digger"] = { dmg = { drill = 0.1 } },

	-- so that enemies realize theyre being damaged
	["flamethrower"] = { projectile = 0.01 },

	["data/entities/projectiles/darkflame.xml"] = { unpierce = true },
	["data/entities/projectiles/darkflame_stationary.xml"] = {
		projectile = 0.05,
		unpierce = true,
		dmg = {
			fire = 0.3,
		},
	},

	["purple_explosion_field"] = {
		unpierce = true,
	},

	-- Already can't have any damage, just want to fix the lying tooltip
	-- (smh nolla)
	["powerdigger"] = { dmg = { drill = 0 } },
}

for proj,nerfs in pairs(damage_nerfs) do
	local path = proj:find("%.xml") and proj or deck..proj..".xml"

	for file in nxml.edit_file(path) do
		local pcomp = file:first_of("ProjectileComponent")
		if not pcomp then goto continue end

		if nerfs.projectile then
			pcomp:set("damage", nerfs.projectile)
		end

		if nerfs.unpierce then
			pcomp:set("damage_every_x_frames", 15)
		end

		local dmg = pcomp:first_of("damage_by_type")
		if dmg and nerfs.dmg then
			for kind,value in pairs(nerfs.dmg) do
				dmg:set(kind, value)
			end
		end

		::continue::
	end
end

-- Evil and fucked up damage
local lasers = {
	"orb_laseremitter.xml",
	"orb_laseremitter_four.xml",
	"orb_laseremitter_cutter.xml",
	"orb_laseremitter_weak.xml",
	"orb_laseremitter_weak_opposite.xml",
}

for _,proj in pairs(lasers) do
	for file in nxml.edit_file(deck..proj) do
		local pcomp = file:first_of("ProjectileComponent")
		if pcomp then
			pcomp:set("damage", 0)
			pcomp:set("damage_every_x_frames", 300)
			pcomp:set("penetrate_entities", 1)
		end

		for emitter in file:each_of("LaserEmitterComponent") do
			local laser = emitter:first_of("laser")
			if laser then
				laser:set("damage_to_entities", 0.001)
				-- laser:set("max_cell_durability_to_destroy", 11)
				laser:set("damage_apply_hitbox_dmg_multiplier", 0)
			end
		end
	end
end

for file in nxml.edit_file(deck.."flamethrower.xml") do
	local pcomp = file:first_of("ProjectileComponent")
	if pcomp then
		local expl = pcomp:first_of("config_explosion")
		if expl then
			expl:set("damage", 0)
		end
	end
end

for file in nxml.edit_file(deck.."luminous_drill.xml") do
	local pcomp = file:first_of("ProjectileComponent")
	if pcomp then
		pcomp:set("friendly_fire", true) -- >:)
		pcomp:set("damage", 0.25)
	end
end
