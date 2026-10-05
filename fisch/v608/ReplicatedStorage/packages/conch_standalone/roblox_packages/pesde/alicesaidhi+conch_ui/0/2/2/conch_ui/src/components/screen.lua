local module = require("../../roblox_packages/vide")
local create = module.create
return function(list)
	return create("ScreenGui")({
		Name = list.name,
		Enabled = list.enabled,
		DisplayOrder = list.display_order,
		unpack(list)
	})
end