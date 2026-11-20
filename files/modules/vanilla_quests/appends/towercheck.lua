---@param hooks towercheck_hooks
return function(hooks)
	hooks.kill_trigger = false

	for _,quest in pairs(hooks.quests) do
		if quest.id == "tower_player" then
			quest.check = function()
				return not GameHasFlagRun("tower_done_any_quest")
			end

			break
		end
	end

	table.insert(hooks.post_quest_funcs, function()
		GameAddFlagRun("tower_done_any_quest")
	end)
end
