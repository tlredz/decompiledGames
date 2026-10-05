local ListData = require(game.ReplicatedStorage.Modules.ListData)
local v = {
	Autocomplete = function(value)
		local characters = {}

		if game.PlaceId ~= 9164905432 then
			return characters
		end

		for _, character in ListData.Characters do
			if not character:lower():find(value:lower()) then
				continue
			end

			table.insert(characters, character)
		end

		return characters
	end,
	Parse = function(p)
		return p
	end
}
return function(registry)
	registry:RegisterType("character", v)
end