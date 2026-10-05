local module = require("../../roblox_packages/vide")
local create = module.create
return function(p: number)
	return create("UICorner")({
		CornerRadius = UDim.new(0, p)
	})
end