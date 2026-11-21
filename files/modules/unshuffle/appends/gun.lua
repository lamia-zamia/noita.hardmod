-- Unused, may experiment with this more later

-- Changes shuffle wands to only swap two random spells at most
-- which is much more possible to make builds for

function order_deck()
	table.sort(deck, function(a, b)
		local a_index = a.deck_index or 0
		local b_index = b.deck_index or 0
		return a_index < b_index
	end)

	if gun.shuffle_deck_when_empty then
		SetRandomSeed(GameGetFrameNum(), GameGetFrameNum())

		local i = Random(1, #deck)
		local j = Random(1, #deck)

		deck[i], deck[j] = deck[j], deck[i]
	end
end
