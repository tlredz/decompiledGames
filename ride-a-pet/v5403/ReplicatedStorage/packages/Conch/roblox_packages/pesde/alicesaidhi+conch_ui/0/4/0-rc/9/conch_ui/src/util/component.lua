local module = require("./auto")
local module2 = require("../components/core/pad")
local module3 = require("../../roblox_packages/vide")
local effect = module3.effect
local read = module3.read

local function component(callback)
	local v = nil
	local action = module3.action(function(p)
		v = p
	end)
	return function(list)
		v = nil
		local parent = callback(list, action)
		local parent2 = v or parent
		v = nil
		local v4 = { unpack(list) }
		module3.apply(parent2)(v4)

		if list.name then
			parent.Name = list.name
		end

		if list.z then
			module3.effect(function()
				parent.ZIndex = module3.read(list.z)
			end)
		end

		if list.order then
			parent.LayoutOrder = typeof(list.order) == "function" and 0 or list.order

			if typeof(list.order) == "function" then
				module3.effect(function()
					parent.LayoutOrder = list.order()
				end)
			end
		end

		if list.anchor and typeof(list.anchor) == "table" then
			parent.AnchorPoint = Vector2.new(list.anchor[1], list.anchor[2])
		elseif list.anchor then
			module3.effect(function()
				parent.AnchorPoint = Vector2.new(list.anchor()[1], list.anchor()[2])
			end)
		end

		if list.visible then
			module3.effect(function()
				parent.Visible = list.visible()
			end)
		end

		local flex = list.flex

		if flex then
			local uIListLayout = parent2:FindFirstChildWhichIsA("UIListLayout") or Instance.new("UIListLayout")
			uIListLayout.FillDirection = (flex.direction or "column") == "column" and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
			uIListLayout.SortOrder = (flex.sort or "order") == "order" and Enum.SortOrder.LayoutOrder or Enum.SortOrder.Name
			local wraps

			if flex.wrap == nil then
				wraps = false
			else
				wraps = flex.wrap
			end

			uIListLayout.Wraps = wraps
			local pad = flex.pad

			if pad then
				module3.effect(function()
					uIListLayout.Padding = UDim.new(0, pad)
				end)
			end

			local justify = flex.justify or "center"
			effect(function()
				local v6 = read(justify)

				if v6 == "center" then
					uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				elseif v6 == "left" then
					uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				elseif v6 == "right" then
					uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
				elseif v6 == "around" then
					uIListLayout.HorizontalFlex = Enum.UIFlexAlignment.SpaceAround
				elseif v6 == "between" then
					uIListLayout.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
				elseif v6 == "even" then
					uIListLayout.HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly
				elseif v6 == "fill" then
					uIListLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
				end
			end)
			local align = flex.align or "center"
			effect(function()
				local v6 = read(align)

				if v6 == "center" then
					uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				elseif v6 == "top" then
					uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
				elseif v6 == "bottom" then
					uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
				elseif v6 == "fill" then
					uIListLayout.VerticalFlex = Enum.UIFlexAlignment.Fill
				elseif v6 == "around" then
					uIListLayout.VerticalFlex = Enum.UIFlexAlignment.SpaceAround
				elseif v6 == "between" then
					uIListLayout.VerticalFlex = Enum.UIFlexAlignment.SpaceBetween
				elseif v6 == "even" then
					uIListLayout.VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly
				end
			end)
			uIListLayout.Parent = parent2
		end

		if list.align or list.grow or list.shrink then
			local v5 = module3.create("UIFlexItem")
			local v6 = {
				FlexMode = Enum.UIFlexMode.Custom,
				GrowRatio = list.grow,
				ShrinkRatio = list.shrink,
				ItemLineAlignment = 0
			}
			local automatic

			if list.align == "auto" then
				automatic = Enum.ItemLineAlignment.Automatic
			elseif list.align == "center" then
				automatic = Enum.ItemLineAlignment.Center
			elseif list.align == "end" then
				automatic = Enum.ItemLineAlignment.End
			elseif list.align == "start" then
				automatic = Enum.ItemLineAlignment.Start
			elseif list.align == "stretch" then
				automatic = Enum.ItemLineAlignment.Stretch
			end

			v6.ItemLineAlignment = automatic
			local v5_2 = v5(v6)
			v5_2.Parent = parent
		end

		if list.pad then
			local module2_2 = module2(list.pad)
			module2_2.Parent = parent2
		end

		if list.rot then
			module3.effect(function()
				parent.Rotation = module3.read(list.rot)
			end)
		end

		local w = list.w
		local h = list.h
		local ws = list.ws
		local hs = list.hs
		local wr = list.wr
		local hr = list.hr
		local v5 = w or ws or wr
		local v6 = h or hs or hr

		if list.auto then
			module3.effect(function()
				parent.AutomaticSize = module(module3.read(list.auto))
			end)
		end

		if v5 or v6 then
			local v7 = h or 0
			local v8 = not v5 and 0 or ws
			local v9 = not v6 and 0 or hs

			if wr then
				v8 = v8 or 1
			else
				wr = w or 0
			end

			if hr then
				v7 = hr
				v9 = v9 or 1
			end

			local v10 = v8 or 0
			local v11 = v9 or 0
			assert(wr and v7 and v10 and v11)
			module3.effect(function()
				local v12 = module3.read(wr)
				local v13 = module3.read(v7)
				local v14 = module3.read(v10)
				local v15 = module3.read(v11)

				if v12 and v13 and v14 and v15 then
					parent.Size = UDim2.new(v14, v12, v15, v13)
				end
			end)
		end

		if list.aspectratio then
			local v7 = module3.create("UIAspectRatioConstraint")
			local v8 = {
				Parent = parent,
				AspectRatio = list.aspectratio.ratio,
				AspectType = 0,
				DominantAxis = 0
			}
			local fitWithinMaxSize

			if list.aspectratio.type == "fit" then
				fitWithinMaxSize = Enum.AspectType.FitWithinMaxSize
			elseif list.aspectratio.type == "scale" then
				fitWithinMaxSize = Enum.AspectType.ScaleWithParentSize
			end

			v8.AspectType = fitWithinMaxSize
			local width

			if list.aspectratio.axis == "width" then
				width = Enum.DominantAxis.Width
			elseif list.aspectratio.axis == "height" then
				width = Enum.DominantAxis.Height
			end

			v8.DominantAxis = width
			v7(v8)
		elseif list.ratio then
			module3.create("UIAspectRatioConstraint")({
				Parent = parent,
				AspectRatio = list.ratio
			})
		end

		local x = list.x
		local y = list.y
		local xs = list.xs
		local ys = list.ys

		if x or xs or y or ys then
			local v7 = x or 0
			local v8 = y or 0
			local v9 = xs or 0
			local v10 = ys or 0
			module3.effect(function()
				local v11 = module3.read(v7)
				local v12 = module3.read(v8)
				local v13 = module3.read(v9)
				local v14 = module3.read(v10)

				if v11 and v12 and v13 and v14 then
					parent.Position = UDim2.new(v13, v11, v14, v12)
				end
			end)
		end

		return parent
	end
end

return component