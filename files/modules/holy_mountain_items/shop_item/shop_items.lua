local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local dir = utils.module_dir.."holy_mountain_items/"


local shop_items = {}

shop_items.potion_materials = {
	{
		material = "magic_liquid_teleportation",
		price = 110,
		weight = 10,
	},
	{
		material = "magic_liquid_berserk",
		price = 110,
		weight = 10,
	},
	{
		material = "magic_liquid_invisibility",
		price = 110,
		weight = 10,
	},
}

shop_items.pouch_materials = {
	{
		material = "silver",
		price = 80,
		weight = 10,
	},
	{
		material = "purifying_powder",
		price = 110,
		weight = 10,
	},
	{
		material = "gunpowder_unstable",
		price = 60,
		weight = 10,
	},
	{
		material = "fungi",
		price = 90,
		weight = 10,
	},
	{
		material = "orb_powder",
		price = 250,
		weight = 5,
	},
}

shop_items.items = {
	{
		id = "ring_of_returning",
		name = "$hardmod_item_ring_of_returning_name",
		weight = 80,
		base_cost = 120,
		entity = dir.."entities/ring_of_returning.xml",
		sprite = dir.."gfx/ui_gfx/ring_of_returning.png",
		rotate_deg = 90, offset_x = 7, offset_y = 8,
	},
	{
		id = "potion",
		name = "potion",
		weight = 60,
		base_cost = 40, --if potion fails, this is probably about the worth of an empty potion lmao
		entity = "data/entities/items/pickup/potion_empty.xml",
		sprite = "data/items_gfx/potion.png",
		condition = function(self)
			local mat_data = utils.RandomFromTable(shop_items.potion_materials)
			self.material = mat_data.material
			self.name = GameTextGet("$item_potion_with_material",
				GameTextGetTranslatedOrNot(CellFactory_GetUIName(CellFactory_GetType(mat_data.material)))
			)
			self.base_cost = mat_data.price
			return true
		end,
		generate_func = function(self, entity_id)
			EntityAddComponent2(entity_id, "PotionComponent", {
				custom_color_material = CellFactory_GetType(self.material)
			})
			EntityAddComponent2(entity_id, "VariableStorageComponent", {
				name = "potion_material",
				value_string = self.material
			})
		end,
		bought_func = function(pickup_entity, item, data)
			for _,varcomp in ipairs(EntityGetComponentIncludingDisabled(pickup_entity, "VariableStorageComponent") or {}) do
				if ComponentGetValue2(varcomp, "name") == "potion_material" then
					AddMaterialInventoryMaterial(item, ComponentGetValue2(varcomp, "value_string"), 1000)
				end
			end
		end,
		offset_x = 4, offset_y = 4,
	},
	{
		id = "pouch",
		name = "$item_powder_stash_3",
		weight = 40,
		base_cost = 30,
		entity = dir.."entities/empty_pouch.xml",
		sprite = "data/items_gfx/material_pouch.png",
		condition = function(self)
			local mat_data = utils.RandomFromTable(shop_items.pouch_materials)
			self.material = mat_data.material
			self.name = GameTextGet("$item_powder_stash_with_material_3",
				GameTextGetTranslatedOrNot(CellFactory_GetUIName(CellFactory_GetType(mat_data.material)))
			)
			self.base_cost = mat_data.price
			return true
		end,
		generate_func = function(self, entity_id)
			EntityAddComponent2(entity_id, "VariableStorageComponent", {
				name = "potion_material",
				value_string = self.material
			})
		end,
		bought_func = function(pickup_entity, item, data)
			for _,varcomp in ipairs(EntityGetComponentIncludingDisabled(pickup_entity, "VariableStorageComponent") or {}) do
				if ComponentGetValue2(varcomp, "name") == "potion_material" then
					AddMaterialInventoryMaterial(item, ComponentGetValue2(varcomp, "value_string"), 1000)
				end
			end
		end,
		offset_x = 5, offset_y = 7,
	},
	{
		id = "refreshing_gourd",
		name = "$item_gourd",
		weight = 35,
		base_cost = 180,
		entity = "data/entities/items/pickup/gourd.xml",
		sprite = "data/ui_gfx/items/gourd.png",
		offset_x = 8, offset_y = 8,
	},
	{
		id = "ring_of_elevation",
		name = "$hardmod_item_ring_of_elevation_name",
		weight = 25,
		base_cost = 250,
		entity = dir.."entities/ring_of_elevation.xml",
		sprite = dir.."gfx/ui_gfx/ring_of_elevation.png",
		rotate_deg = 90, offset_x = 7, offset_y = 8,
		hm_escape = true,
	},
	{
		id = "mega_beam_stone",
		name = "$item_mega_beam_stone",
		weight = 10,
		base_cost = 400,
		entity = "data/entities/items/pickup/beamstone.xml",
		sprite = "data/ui_gfx/items/beamstone.png",
		offset_x = 4, offset_y = 6,
		hm_escape = true,
	},
}


shop_items.indexed = {}
for _,item in ipairs(shop_items.items) do
	shop_items.indexed[item.id] = item
end


for _,func in ipairs(ModLuaFileGetAppends(dir.."shop_item/shop_items.lua")) do
	func(shop_items)
end

return shop_items