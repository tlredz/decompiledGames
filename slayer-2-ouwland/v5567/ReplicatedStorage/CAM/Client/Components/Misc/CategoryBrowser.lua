local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local PageBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.PageBrowser)
return function(object, instance, p, list, data)
	local tabHeight = data.TabHeight or 0.07
	local uniform = data.Uniform == true
	local overscan = data.Overscan or 1

	-- equivalent calls inferred from this helper; original call sites unknown
	local function uiScale()
		local uIScale = instance:FindFirstChildOfClass("UIScale")

		if uIScale == nil or not (uIScale.Scale > 0) then
			return 1
		end

		return uIScale.Scale
	end

	local height = object:Value(0)

	local function stripHeight(callback)
		return #list * (callback(height) + 6)
	end

	local v = object:Create("Frame")
	local v2 = {
		Name = "CategoriesHolder",
		Size = data.Size,
		AnchorPoint = data.AnchorPoint,
		Position = data.Position,
		BackgroundTransparency = 1
	}
	local v3 = object:Create("CanvasGroup")
	local v4 = {
		Name = "ListMask",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(1 + overscan, 1),
		BackgroundTransparency = 1
	}
	local v5 = object:Create("UIGradient")({
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.84, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
	})
	local v6 = object:Create("ScrollingFrame")
	local v7 = {
		Name = "CategoriesList",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		CanvasSize = object:Do(function(callback)
			return UDim2.fromOffset(0, (math.ceil(#list * (callback(height) + 6) * 1.2)))
		end),
		AbsoluteSizeOnChangedInit = function(_, point: Vector2)
			if point.Y <= 0 then
				return
			end

			local v9 = point.Y * tabHeight
			height:Set((math.floor(v9 / uiScale())))
		end
	}
	local v9 = {
		Key = function(_, p2)
			return p2
		end,
		Label = function(_, p2)
			local v10

			if data.Counts ~= nil then
				v10 = data.Counts[p2]
			end

			if v10 == nil then
				return p2
			end

			return (`{p2} ({v10})`)
		end,
		FillDirection = Enum.FillDirection.Vertical,
		Size = object:Do(function(callback)
			return UDim2.new(1 / (1 + overscan), 0, 0, #list * (callback(height) + 6))
		end),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		TabSize = 0,
		HugWidth = 0,
		Padding = 0,
		HorizontalAlignment = 0,
		TextXAlignment = 0,
		Backdrop = false
	}
	local tabSize

	if uniform then
		tabSize = object:Do(function(callback)
			return UDim2.new(1, 0, 0, callback(height))
		end)
	end

	v9.TabSize = tabSize
	v9.HugWidth = not uniform and {
		Pad = 12,
		Height = height,
		uiScale = uiScale
	} or nil
	v9.Padding = UDim.new(0, 6)
	local horizontalAlignment

	if uniform then
		horizontalAlignment = Enum.HorizontalAlignment.Center
	else
		horizontalAlignment = Enum.HorizontalAlignment.Right
	end

	v9.HorizontalAlignment = horizontalAlignment
	local textXAlignment

	if uniform then
		textXAlignment = Enum.TextXAlignment.Center
	else
		textXAlignment = Enum.TextXAlignment.Right
	end

	v9.TextXAlignment = textXAlignment
	do local _values = table.pack(PageBrowser(object, p, list, v9)); for _k = 1, _values.n do v7[_k] = _values[_k] end end
	do local _values = table.pack(v5, v6(v7)); for _k = 1, _values.n do v4[_k] = _values[_k] end end
	do local _values = table.pack(v3(v4)); for _k = 1, _values.n do v2[_k] = _values[_k] end end
	return v(v2)
end