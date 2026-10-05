local module = require("../../roblox_packages/vide")
local create = module.create
local read = module.read
return function(list)
	return create("Frame")({
		Size = function()
			return UDim2.fromOffset(read(list.width) or 0, read(list.height) or 0)
		end,
		Position = function()
			return UDim2.new(read(list.xs) or 0, read(list.x) or 0, read(list.ys) or 0, read(list.y) or 0)
		end,
		AnchorPoint = list.anchor and function()
			return Vector2.new(read(list.anchor)[1] or 0, read(list.anchor)[2] or 0)
		end or nil,
		AutomaticSize = list.auto,
		LayoutOrder = list.layout,
		ZIndex = list.zindex,
		BackgroundTransparency = 1,
		unpack(list)
	})
end