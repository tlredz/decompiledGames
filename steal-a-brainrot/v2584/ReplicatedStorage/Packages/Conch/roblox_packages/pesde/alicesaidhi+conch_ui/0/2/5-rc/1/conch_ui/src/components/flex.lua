local module = require("../../roblox_packages/vide")
local create = module.create
return function()
	local v = create("UIListLayout")({})
	return (setmetatable({ v }, {
		__index = {
			row = function(p)
				v.FillDirection = Enum.FillDirection.Vertical
				return p
			end,
			column = function(p)
				v.FillDirection = Enum.FillDirection.Horizontal
				return p
			end,
			layout = function(p)
				v.SortOrder = Enum.SortOrder.LayoutOrder
				return p
			end,
			name = function(p)
				v.SortOrder = Enum.SortOrder.Name
				return p
			end,
			none = function(p, p2: string?)
				if p2 ~= "vertical" then
					v.HorizontalFlex = Enum.UIFlexAlignment.None
				end

				if p2 ~= "horizontal" then
					v.VerticalFlex = Enum.UIFlexAlignment.None
				end

				return p
			end,
			even = function(p, p2: string?)
				if p2 ~= "vertical" then
					v.HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly
				end

				if p2 ~= "horizontal" then
					v.VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly
				end

				return p
			end,
			around = function(p, p2: string?)
				if p2 ~= "vertical" then
					v.HorizontalFlex = Enum.UIFlexAlignment.SpaceAround
				end

				if p2 ~= "horizontal" then
					v.VerticalFlex = Enum.UIFlexAlignment.SpaceAround
				end

				return p
			end,
			between = function(p, p2: string?)
				if p2 ~= "vertical" then
					v.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
				end

				if p2 ~= "horizontal" then
					v.VerticalFlex = Enum.UIFlexAlignment.SpaceBetween
				end

				return p
			end,
			fill = function(p, p2: string)
				if p2 ~= "vertical" then
					v.HorizontalFlex = Enum.UIFlexAlignment.Fill
				end

				if p2 ~= "horizontal" then
					v.VerticalFlex = Enum.UIFlexAlignment.Fill
				end

				return p
			end,
			horizontal = function(p, p2: string)
				local v2 = v
				local left

				if p2 == "left" then
					left = Enum.HorizontalAlignment.Left
				elseif p2 == "right" then
					left = Enum.HorizontalAlignment.Right
				else
					left = Enum.HorizontalAlignment.Center
				end

				v2.HorizontalAlignment = left
				return p
			end,
			vertical = function(p, p2: string)
				local v2 = v
				local top

				if p2 == "top" then
					top = Enum.VerticalAlignment.Top
				elseif p2 == "bottom" then
					top = Enum.VerticalAlignment.Bottom
				else
					top = Enum.VerticalAlignment.Center
				end

				v2.VerticalAlignment = top
				return p
			end,
			gap = function(p, p2: number)
				v.Padding = UDim.new(0, p2)
				return p
			end
		}
	}))
end