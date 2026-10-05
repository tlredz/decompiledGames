local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local TitleCell = require(script.Parent.TitleCell)
require(script.Parent.Types)
return function(object, instance, p, object2)
	local cellSize = object:Value(UDim2.fromOffset(0, 0))
	local canvasSize = object:Value(UDim2.new())
	local space = object:Space(function(state)
		local state2 = object2:Compare(state.Id) and 1 or 0

		if state.State == state2 then
			return
		end

		if state2 == 1 then
			state.PlateColor:Set(Color3.new(1, 1, 1))
			state.ShadowColor:Set(Color3.new(1, 1, 1))
			state.PlateTransparency:Set(0)
			state.ShadowTransparency:Set(0.5)
			state.ContentColor:Set(Color3.new(0, 0, 0))
			state.ContentTransparency:Set(0)
		else
			state.PlateColor:Reset()
			state.ShadowColor:Reset()
			state.PlateTransparency:Reset()
			state.ShadowTransparency:Reset()
			state.ContentColor:Reset()
			state.ContentTransparency:Reset()
		end

		state.State = state2
	end)
	space:Connect(object2.Changed)
	local textSize = object:Value(20)
	local v = {}

	local function fitTextSize()
		local v2 = 0

		for _, v3 in v do
			v2 = math.max(v2, v3)
		end

		local v3 = cellSize:Get()

		if v2 <= 0 or v3.X.Offset <= 0 then
			return
		end

		local v4 = v3.X.Offset - 16 - 4
		local uIScale = instance:FindFirstChildOfClass("UIScale")
		local v5 = v4 / (v2 / ((uIScale == nil or not (uIScale.Scale > 0)) and 1 or uIScale.Scale) + 1)
		local v6 = v3.Y.Offset * 0.6
		textSize:Set((math.clamp(math.floor((math.min(v5, v6))), 1, 100)))
	end

	object:Connect(cellSize.Changed, fitTextSize)
	local v2 = {
		Space = space,
		Equipped = object2,
		TextSize = textSize,
		LockGap = 4,
		uiScale = function()
			local uIScale = instance:FindFirstChildOfClass("UIScale")

			if uIScale == nil or not (uIScale.Scale > 0) then
				return 1
			end

			return uIScale.Scale
		end,
		Measure = function(p2: string, p3: number)
			if p3 <= (v[p2] or 0) then
				return
			end

			v[p2] = p3
			fitTextSize()
		end
	}
	return object:Create("CanvasGroup")({
		Name = "ListMask",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1.16, -16, 1, -16),
		BackgroundTransparency = 1,
		object:Create("UIGradient")({
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.84, 0),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		object:Create("ScrollingFrame")({
			Name = "TitlesList",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = canvasSize,
			AbsoluteSizeOnChangedInit = function(_, point: Vector2)
				if point.X <= 0 then
					return
				end

				local v3 = point.X / 1.16
				local uIScale = instance:FindFirstChildOfClass("UIScale")
				local v4 = math.floor((v3 / ((uIScale == nil or not (uIScale.Scale > 0)) and 1 or uIScale.Scale) - 16) / 3)
				cellSize:Set(UDim2.fromOffset(v4, (math.floor(v4 * 0.25))))
			end,
			object:Create("Frame")({
				Name = "Holder",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.8620689655172414, 1),
				BackgroundTransparency = 1,
				object:Create("UIGridLayout")({
					CellSize = cellSize,
					CellPadding = UDim2.fromOffset(8, 8),
					SortOrder = Enum.SortOrder.LayoutOrder,
					AbsoluteContentSizeOnChangedInit = function(_, point: Vector2)
						local v4 = point.Y * 1.2
						local uIScale = instance:FindFirstChildOfClass("UIScale")
						canvasSize:Set(UDim2.fromOffset(
							0,
							v4 / ((uIScale == nil or not (uIScale.Scale > 0)) and 1 or uIScale.Scale)
						))
					end
				}),
				object:Iterate(p, function(p2: number, p3, p4)
					return TitleCell(p4, p2, p3, v2)
				end)
			})
		})
	})
end