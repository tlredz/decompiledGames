local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mutations = require(ReplicatedStorage.Shared.Modules.Mutations)
local v = {}
local labels = {}

for k, v2 in Mutations.All() do
	v[v2.Label] = k
	table.insert(labels, v2.Label)
end

table.sort(labels)
return function(registry)
	local enumType = registry.Cmdr.Util.MakeEnumType("Mutation", labels)
	local v2 = {
		Validate = enumType.Validate,
		Autocomplete = enumType.Autocomplete,
		Parse = function(p)
			return v[enumType.Parse(p)]
		end
	}
	registry:RegisterType("mutation", v2)
	registry:RegisterType("mutations", registry.Cmdr.Util.MakeListableType(v2))
end