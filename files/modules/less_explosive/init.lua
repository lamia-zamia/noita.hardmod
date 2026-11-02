local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

local module = {

}

module.edit_material = function(material)
    if material.attr.name == "oil" then
        -- material.attr.burnable = "0" -- oil is really not that flammable, sorry arson enjoyers
		material.attr.tags = "[liquid],[impure],[liquid_common],[chaotic_transmutation],[evaporable_custom]"
	end

end

ModMaterialsFileAdd("mods/noita.hardmod/files/modules/less_explosive/materials.xml")

local explosives = {"data/entities/props/physics_barrel_oil.xml", "data/entities/props/physics_barrel_radioactive.xml", "data/entities/props/physics_box_explosive.xml"}
for _, file in ipairs(explosives)do
	for entity in nxml.edit_file(file) do
		local explode_comp = entity:first_of("ExplodeOnDamageComponent")
		if explode_comp then
			entity:remove_child(explode_comp) -- these things make no sense to explode on impact, fucking leak instead idiot
		end

		local material_inventory = entity:first_of("MaterialInventoryComponent")

		if material_inventory then
			material_inventory:set("on_death_spill", true)
			material_inventory:set("leak_on_damage_percent", 0.5)
			local count_per_material_type = material_inventory:first_of("count_per_material_type")
			if count_per_material_type then
				local material = count_per_material_type:first_of("Material")
				if material then
					material:set("count", 1500)
				end
			end
		else
			entity:create_child("MaterialInventoryComponent", {
				drop_as_item = false,
				on_death_spill = true,
				leak_on_damage_percent = 0.5,
				audio_collision_size_modifier_amount = 0.8
			}, {
				nxml.new_element("count_per_material_type", {}, {
					nxml.new_element("Material", {
						material = "gunpowder_unstable",
						count = 1500
					})
				})
			})
		end
	end
end

return module
