local module = require("../theme")
local module2 = require("../../roblox_packages/vide")
local create = module2.create
return function(list)
	return create("UIStroke")({
		Thickness = list.thickness,
		Color = module.stroke,
		unpack(list)
	})
end