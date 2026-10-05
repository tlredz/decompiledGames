game:GetService("GuiService")
local module = require("../theme")
local module2 = require("../../roblox_packages/vide")
local create = module2.create
local read = module2.read
return function(list)
	local v = create(list.scrolling and "ScrollingFrame" or "Frame")
	local v2 = {
		Size = function()
			local v3 = read(list.width)
			local v4 = read(list.height)
			return UDim2.new(v3 and 0 or 1, v3 or 0, v4 and 0 or 1, v4 or 0)
		end,
		Position = function()
			return UDim2.new(read(list.xs) or 0, read(list.x) or 0, read(list.ys) or 0, read(list.y) or 0)
		end,
		AnchorPoint = list.anchor and function()
			return Vector2.new(read(list.anchor)[1] or 0, read(list.anchor)[2] or 0)
		end or nil
	}
	local automaticSize

	if not list.scrolling then
		automaticSize = list.auto
	end

	v2.AutomaticSize = automaticSize
	local automaticCanvasSize

	if list.scrolling then
		automaticCanvasSize = list.auto or nil
	end

	v2.AutomaticCanvasSize = automaticCanvasSize
	v2.LayoutOrder = list.layout
	v2.BackgroundColor3 = list.color or module.background
	v2.BackgroundTransparency = module.background_transparency
	v2.ScrollBarImageColor3 = list.scrolling and Color3.new(1, 1, 1) or nil
	v2.ScrollBarThickness = list.scrolling and 5 or nil
	v2.ScrollingDirection = list.scrolling and Enum.ScrollingDirection.Y or nil
	v2.CanvasSize = list.scrolling and UDim2.new() or nil
	v2.CanvasPosition = list.cpos or nil
	do local _values = table.pack(unpack(list)); for _k = 1, _values.n do v2[_k] = _values[_k] end end
	return v(v2)
end