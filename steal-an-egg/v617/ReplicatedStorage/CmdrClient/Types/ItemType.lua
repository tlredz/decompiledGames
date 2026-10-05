local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminItemCatalog = require(ReplicatedStorage.Shared.AdminItemCatalog)
return function(registry)
	local enumType = registry.Cmdr.Util.MakeEnumType("Item", AdminItemCatalog.Choices)
	registry:RegisterType("item", {
		Validate = enumType.Validate,
		Autocomplete = enumType.Autocomplete,
		Parse = function(p)
			return AdminItemCatalog.IdByChoice[enumType.Parse(p)]
		end
	})
end