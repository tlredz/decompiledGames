local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.faye)
local ItemCell = require(script.Parent.ItemCell)
return function(object, instance, object2, p, p2, p3)
	local value = object:Value(UDim2.fromOffset(0, 0))
	local canvasSize = object:Value(UDim2.new())
	local value3 = object:Value(0)
	local value4 = object:Value(0)
	local value5 = object:Value({})
	local v = {}
	local v2 = {}
	local v3 = {}
	local v4 = 1
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function uiScale()
		local uIScale = instance:FindFirstChildOfClass("UIScale")

		if uIScale == nil or not (uIScale.Scale > 0) then
			return 1
		end

		return uIScale.Scale
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function step()
		return value:Get().Y.Offset + 8
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resize()
		local v5 = step() -- equivalent call inferred; original call site unknown

		if v5 <= 8 then
			return
		end

		local v6 = math.ceil(#object2:Get() / 7)
		canvasSize:Set(UDim2.fromOffset(0, v6 * v5))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function feed()
		if flag then
			return
		end

		flag = true
		object:Spawn(function()
			local v5 = object2:Get()

			while v4 <= #v3 do
				for _ = 1, 20 do
					local v6 = v3[v4]

					if v6 == nil then
						break
					end

					v4 += 1

					if not v[v6] or v2[v6] or v5[v6] == nil then
						continue
					end

					v2[v6] = true
					value5:Add(v6, v5[v6])
				end

				if v4 > #v3 then
					break
				end

				task.wait()
				v5 = object2:Get()
			end

			table.clear(v3)
			v4 = 1
			flag = false
		end)
	end

	local function refresh()
		local v5 = step() -- equivalent call inferred; original call site unknown

		if v5 <= 8 then
			return
		end

		local v6 = object2:Get()
		local v7 = math.max(0, math.floor(value3:Get() / v5) - 2)
		local v8 = math.ceil(value4:Get() / v5) + 4 + 1
		local v9 = v7 * 7 + 1
		local v10 = math.min(#v6, (v7 + v8) * 7)
		table.clear(v)

		for i = v9, v10 do
			v[i] = true
		end

		for k in v2 do
			if v[k] then
				continue
			end

			v2[k] = nil
			value5:Remove(k)
		end

		for i = v9, v10 do
			if not v2[i] then
				table.insert(v3, i)
			end
		end

		feed() -- equivalent call inferred; original call site unknown
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function rebuild()
		resize() -- equivalent call inferred; original call site unknown
		refresh()
	end

	object:Connect(value.Changed, rebuild)
	object:Connect(object2.Changed, function()
		for k in v2 do
			v2[k] = nil
			value5:Remove(k)
		end

		table.clear(v3)
		v4 = 1
		rebuild() -- equivalent call inferred; original call site unknown
	end)
	object:Connect(value3.Changed, refresh)
	object:Connect(value4.Changed, refresh)
	return object:Create("CanvasGroup")({
		Name = "ListMask",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -8),
		Size = UDim2.new(1.08, -16, 1.04, -16),
		BackgroundTransparency = 1,
		object:Create("UIGradient")({
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.8846153846153846, 0),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		object:Create("ScrollingFrame")({
			Name = "ItemsList",
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(1, 0.9615384615384615),
			ClipsDescendants = false,
			BackgroundTransparency = 1,
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			CanvasSize = canvasSize,
			AbsoluteSizeOnChangedInit = function(_, point: Vector2)
				if point.X <= 0 then
					return
				end

				local v5 = uiScale() -- equivalent call inferred; original call site unknown
				local v6 = math.floor((point.X / 1.08 / v5 - 48) / 7)
				value4:Set(point.Y / v5)
				value:Set(UDim2.fromOffset(v6, v6))
			end,
			CanvasPositionOnChangedInit = function(_, point: Vector2)
				value3:Set(point.Y)
			end,
			object:Create("Frame")({
				Name = "Holder",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.9259259259259258, 1),
				BackgroundTransparency = 1,
				object:AdvancedIterate(value5, function(p4: number, p5: string, object3)
					return ItemCell(object3, p5, p, p2, p3, value, (object3:Do(function(callback)
						local v6 = callback(value)
						local v7 = v6.Y.Offset + 8
						return UDim2.fromOffset((p4 - 1) % 7 * (v6.X.Offset + 8), math.floor((p4 - 1) / 7) * v7)
					end)))
				end)
			})
		})
	})
end