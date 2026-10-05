local module = require("../theme")
local module2 = require("../../roblox_packages/vide")
local create = module2.create
local read = module2.read
return function(list)
	return create("Frame")({
		Size = function()
			local v = read(list.width)
			local v2 = read(list.height)
			return UDim2.new(v and 0 or 1, v or 0, v2 and 0 or 1, v2 or 0)
		end,
		Position = function()
			return UDim2.new(read(list.xs) or 0, read(list.x) or 0, read(list.ys) or 0, read(list.y) or 0)
		end,
		AnchorPoint = list.anchor and function()
			return Vector2.new(read(list.anchor)[1] or 0, read(list.anchor)[2] or 0)
		end or nil,
		AutomaticSize = list.auto,
		LayoutOrder = list.layout,
		BackgroundColor3 = list.color or module.background,
		BackgroundTransparency = module.background_transparency,
		unpack(list)
	})
end