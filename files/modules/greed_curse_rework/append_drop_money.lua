return function(hooks) ---@param hooks drop_money_hooks
	hooks.pre_processing[#hooks.pre_processing+1] = {
		id = "hardmod_greed_cursed_nuggets",
		func = function(data) ---@param data gold_drop_data
			if GameHasFlagRun("greed_curse_gone") or not GameHasFlagRun("greed_curse") then return end

			for i,nugget in ipairs(data.nuggets) do
				local cursed_nugget_form = hooks.nuggets_indexed.hardmod_greed_cursed[nugget.value]
				local gold_nugget_form = hooks.nuggets_indexed.gold[nugget.value]
				if nugget.group == "gold" and cursed_nugget_form then
					data.nuggets[i] = hooks.clone_table(cursed_nugget_form)
				elseif nugget.group == "blood" and gold_nugget_form then
					nugget = hooks.clone_table(gold_nugget_form)
				end
			end
		end
	}


	hooks.nuggets.hardmod_greed_cursed = {
		{
			path = "mods/noita.hardmod/files/modules/greed_curse_rework/nuggets/200000.xml",
			value = 200000,
		},
		{
			path = "mods/noita.hardmod/files/modules/greed_curse_rework/nuggets/10000.xml",
			value = 10000,
		},
		{
			path = "mods/noita.hardmod/files/modules/greed_curse_rework/nuggets/1000.xml",
			value = 1000,
		},
		{
			path = "mods/noita.hardmod/files/modules/greed_curse_rework/nuggets/200.xml",
			value = 200,
		},
		{
			path = "mods/noita.hardmod/files/modules/greed_curse_rework/nuggets/50.xml",
			value = 50,
		},
		{
			path = "mods/noita.hardmod/files/modules/greed_curse_rework/nuggets/10.xml",
			value = 10,
		},
	}
end