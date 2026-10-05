local ListData = require(game.ReplicatedStorage.Modules.ListData)
local v = {
	Autocomplete = function(value)
		local result = {}

		for _, item in ListData.Items do
			if not item:lower():find(value:lower()) then
				continue
			end

			table.insert(result, item)
		end

		return result
	end,
	Parse = function(p)
		return p
	end
}
return function(registry)
	registry:RegisterType("item", v)
end