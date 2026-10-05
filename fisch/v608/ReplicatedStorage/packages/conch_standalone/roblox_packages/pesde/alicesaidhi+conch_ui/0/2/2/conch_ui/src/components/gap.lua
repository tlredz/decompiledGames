local module = require("../../roblox_packages/vide")
local create = module.create
local read = module.read
return function(list)
	return create("Frame")({
		Name = "gap",
		Size = function()
			return UDim2.fromOffset(read(list.width) or 0, read(list.height) or 0)
		end,
		BackgroundTransparency = 1,
		unpack(list)
	})
end