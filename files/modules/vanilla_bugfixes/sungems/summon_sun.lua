function material_area_checker_success()
	local entity_id = GetUpdatedEntityID()
	if GlobalsGetValue("MISC_SUN_EFFECT") ~= "1" then
		local x, y = EntityGetTransform(entity_id)

		local sungem_entity = EntityGetClosestWithTag(x, y, "sunrock")
		if sungem_entity ~= 0 then x, y = EntityGetTransform(sungem_entity) EntityKill(sungem_entity) end

		EntityLoad("data/entities/items/pickup/sun/newsun.xml", x, y)
		EntityLoad("data/entities/particles/image_emitters/chest_effect.xml", x, y)

		GlobalsSetValue("MISC_SUN_EFFECT", "1")
		GamePrintImportant("$log_altar_magic", "")
		AddFlagPersistent("misc_sun_effect")
	end

	EntityKill(entity_id)
end
