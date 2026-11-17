local potions = {
	"blood_fungi",
	"blood_fungi",
	"fungi",
	"fungisoil",
	"fungus_powder_bad",
	"fungal_gas",
}

function init(entity_id)
	local x, y = EntityGetTransform(entity_id)
	SetRandomSeed(x + GameGetFrameNum(), y)
	AddMaterialInventoryMaterial(entity_id, potions[Random(1, #potions)], 1000)
end
