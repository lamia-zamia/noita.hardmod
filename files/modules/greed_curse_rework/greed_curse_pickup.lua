function item_pickup(item, taker, name)

	local x,y = EntityGetTransform(item)

	EntityAddChild(taker, EntityLoad("mods/noita.hardmod/files/modules/greed_curse_rework/greed_curse.xml", x, y))

	EntityLoad("data/entities/buildings/teleport_start.xml", x, y - 66)

	GameAddFlagRun("greed_curse")
	AddFlagPersistent("greed_curse_picked")


	EntityLoad("data/entities/particles/image_emitters/perk_effect.xml", x, y)
	GamePrintImportant("$log_curse", "$logdesc_greed_curse")

	EntityKill(item)
end