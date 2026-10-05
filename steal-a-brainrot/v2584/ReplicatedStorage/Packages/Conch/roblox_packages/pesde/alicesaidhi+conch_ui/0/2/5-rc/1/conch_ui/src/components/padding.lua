local module = require("../../roblox_packages/vide")
local create = module.create

local function padding(data)
	local padding2 = data.padding or 0
	local x = data.x or padding2
	local y = data.y or padding2
	local left = data.left or x
	local right = data.right or x
	local top = data.top or y
	local bottom = data.bottom or y
	return create("UIPadding")({
		PaddingLeft = UDim.new(0, left),
		PaddingRight = UDim.new(0, right),
		PaddingTop = UDim.new(0, top),
		PaddingBottom = UDim.new(0, bottom)
	})
end

return padding