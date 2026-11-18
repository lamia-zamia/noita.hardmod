
local _move_hand_to_discarded = move_hand_to_discarded
function move_hand_to_discarded()
	_move_hand_to_discarded()

	if not reflecting and GetUpdatedEntityID() ~= 0 then
		local vsc = EntityGetFirstComponentIncludingDisabled(GetUpdatedEntityID(), "VariableStorageComponent", "hardmod_wand_spells_cast")
		if vsc then
			ComponentSetValue2(vsc, "value_int", #discarded)
		else
			vsc = EntityAddComponent2(GetUpdatedEntityID(), "VariableStorageComponent", {
				_tags = "hardmod_wand_spells_cast",
				name = "hardmod_wand_spells_cast",
				value_int = #discarded,
			})
		end
	end
end
