local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local InputHandler = require(ReplicatedStorage.CAM.Client.Components.Client.InputHandler)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.08)
local v = {
	[Enum.UserInputType.MouseMovement] = true,
	[Enum.UserInputType.Touch] = true
}
local v2 = {
	[Enum.KeyCode.Thumbstick1] = true,
	[Enum.KeyCode.Thumbstick2] = true
}
local color = Color3.new(0.15, 0.15, 0.15)
local color2 = Color3.new(0.25, 0.25, 0.25)
local color3 = Color3.fromRGB(155, 208, 255)
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new(1, 1, 1)
local uDim = UDim.new(1, 0)
local uDim2 = UDim2.fromScale(0, 0.08)
local color6 = Color3.new()
return function(maid, object, text: string, options)
	local v3 = options or {}
	local min = v3.Min or 0
	local max = v3.Max or 1
	local v4 = max - min
	local format = v3.Format or function(p2: number)
		return string.format("%.2f", p2)
	end

	local function clamp(value: number)
		local v5 = math.clamp(value, min, max)

		if v3.Step ~= nil and v3.Step > 0 then
			return (math.clamp(min + math.round((v5 - min) / v3.Step) * v3.Step, min, max))
		end

		return v5
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function alphaOf(p2: number)
		if v4 <= 0 then
			return 0
		end

		return (math.clamp((p2 - min) / v4, 0, 1))
	end

	local function current()
		local v5 = object:Get()

		if type(v5) == "number" then
			return v5
		end

		return min
	end

	local uiScale = v3.uiScale or function()
		return 1
	end
	local value = maid:Value(0)
	local value2 = maid:Value(0)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function roomForValue(callback)
		local v5 = callback(value2) * 0.13 * 3.2
		return callback(value) + 10 + v5 / 2
	end

	local v5 = object:Get()

	if type(v5) ~= "number" then
		v5 = min
	end

	local value3 = maid:Value(alphaOf(v5))
	local v6 = object:Get()

	if type(v6) ~= "number" then
		v6 = min
	end

	local text2 = maid:Value(format(v6))
	maid:Connect(object.Changed, function()
		local v8 = object:Get()

		if type(v8) ~= "number" then
			v8 = min
		end

		value3:Set(alphaOf(v8))
		local v11 = object:Get()

		if type(v11) ~= "number" then
			v11 = min
		end

		text2:Set(format(v11))
	end)
	local v7 = nil
	local v8 = false
	local flag = false
	local flag2 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function allowed()
		return v3.CanClick == nil or v3.CanClick()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function pointer()
		return UserInputService:GetMouseLocation()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function alphaAt(point: Vector2)
		local v9 = v7

		if v9 == nil or v9.AbsoluteSize.X <= 0 then
			return value3:Get()
		end

		return (math.clamp((point.X - v9.AbsolutePosition.X) / v9.AbsoluteSize.X, 0, 1))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function write(p2: number, flag3: boolean)
		local v9 = math.clamp(min + p2 * v4, min, max)

		if v3.Step ~= nil and v3.Step > 0 then
			v9 = math.clamp(min + math.round((v9 - min) / v3.Step) * v3.Step, min, max)
		end

		value3:Set(alphaOf(v9))
		text2:Set(format(v9))
		object:Set(v9)

		if flag3 and v3.OnCommit ~= nil then
			v3.OnCommit(v9)
		end
	end

	maid:Connect(UserInputService.InputChanged, function(p2)
		if not v8 or v[p2.UserInputType] == nil and v2[p2.KeyCode] == nil then
			return
		end

		local v9 = pointer() -- equivalent call inferred; original call site unknown
		local v10 = alphaAt(v9) -- equivalent call inferred; original call site unknown
		write(v10, false) -- equivalent call inferred; original call site unknown
	end)
	maid:Add(InputHandler.ListenTo("Slot_Drag", function(p2: string)
		if p2 ~= "Up" or not v8 then
			return
		end

		v8 = false
		write(value3:Get(), true)
	end))
	return maid:Create("Frame")({
		Name = "Dragbar",
		Size = v3.Size or UDim2.fromScale(1, 1),
		Position = v3.Position,
		AnchorPoint = v3.AnchorPoint,
		BackgroundColor3 = color,
		AbsoluteSizeOnChangedInit = function(_, point: Vector2)
			if point.Y <= 0 then
				return
			end

			value2:Set(point.Y / uiScale())
		end,
		maid:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
		}),
		maid:Create("UICorner")({
			CornerRadius = UDim.new(0.2)
		}),
		maid:Create("TextLabel")({
			Name = "Label",
			Text = text,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.08, 0.5),
			Size = UDim2.fromScale(0.4, 0.45),
			BackgroundTransparency = 1,
			TextColor3 = color5,
			Font = Enum.Font.SourceSansSemibold,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		maid:Create("TextLabel")({
			Name = "Amount",
			Text = text2,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(0.97, 0.5),
			Size = UDim2.fromScale(100, 0.45),
			BackgroundTransparency = 1,
			TextBoundsOnChangedInit = function(_, point: Vector2)
				if point.X <= 0 then
					return
				end

				value:Set(point.X / uiScale())
			end,
			TextColor3 = color5,
			Font = Enum.Font.SourceSansBold,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right
		}),
		maid:Create("Frame")({
			Name = "Track",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = maid:Do(function(callback)
				return UDim2.new(0.92, -roomForValue(callback), 0.5, 0)
			end),
			Size = maid:Do(function(callback)
				return UDim2.new(0.43000000000000005, -roomForValue(callback), 0.13, 0)
			end),
			BackgroundColor3 = color2,
			function(p2)
				v7 = p2
			end,
			maid:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			maid:Create("Frame")({
				Name = "Fill",
				Size = maid:Do(function(callback)
					local uDim3 = UDim2.fromScale(callback(value3), 1)

					if flag then
						return maid:Animation(uDim3, info)
					end

					flag = true
					return uDim3
				end),
				BackgroundColor3 = color3,
				maid:Create("UICorner")({
					CornerRadius = UDim.new(1)
				})
			}),
			maid:Create("Frame")({
				Name = "Knob",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = maid:Do(function(callback)
					local uDim3 = UDim2.fromScale(callback(value3), 0.5)

					if flag2 then
						return maid:Animation(uDim3, info)
					end

					flag2 = true
					return uDim3
				end),
				Size = UDim2.fromScale(3.2, 3.2),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundColor3 = color4,
				maid:Create("UIShadow")({
					BlurRadius = uDim,
					Offset = uDim2,
					Transparency = 0.55,
					Color = color6
				}),
				maid:Create("UICorner")({
					CornerRadius = UDim.new(1)
				})
			}),
			maid:Create("TextButton")({
				Name = "Grab",
				AutoButtonColor = false,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1.5, 3),
				BackgroundTransparency = 1,
				ZIndex = 5,
				MouseButton1Down = function()
					if not allowed() then
						return
					end

					ScreenEffects.CircleClick()
					v8 = true
					local v9 = pointer() -- equivalent call inferred; original call site unknown
					local v10 = alphaAt(v9) -- equivalent call inferred; original call site unknown
					write(v10, false) -- equivalent call inferred; original call site unknown
				end
			})
		})
	})
end