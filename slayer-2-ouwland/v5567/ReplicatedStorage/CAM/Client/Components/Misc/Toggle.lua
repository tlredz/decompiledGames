local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScreenEffects = require(ReplicatedStorage.CAM.Client.Components.Misc.ScreenEffects)
local faye = require(ReplicatedStorage.Packages.faye)
local info = faye.Info(0.15)
local color = Color3.new(0.15, 0.15, 0.15)
local color2 = Color3.new(0.25, 0.25, 0.25)
local color3 = Color3.new(0.85, 0.85, 0.85)
local color4 = Color3.new(1, 1, 1)
local color5 = Color3.new(0.15, 0.15, 0.15)
local uDim = UDim.new(1, 0)
local uDim2 = UDim2.fromScale(0, 0.08)
local color6 = Color3.new()
return function(object, object2, text: string, options)
	local v = options or {}
	local value = object:Value(color2)
	local value2 = object:Value(color3)
	local value3 = object:Value(0.5)
	local v2 = false
	local v3 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function upd()
		if object2:Compare(true) then
			value:Set(color4)
			value2:Set(color5)
		else
			value:Reset()
			value2:Reset()
		end
	end

	object:Connect(object2.Changed, upd)
	upd() -- equivalent call inferred; original call site unknown
	local v4

	if v.Fade == true then
		v4 = object:Create("UIGradient")({
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
		})
	end

	return object:Create("TextButton")({
		Name = "Toggle",
		AutoButtonColor = false,
		Size = v.Size or UDim2.fromScale(1, 1),
		Position = v.Position,
		AnchorPoint = v.AnchorPoint,
		BackgroundColor3 = color,
		v4,
		object:Create("UICorner")({
			CornerRadius = UDim.new(0.2)
		}),
		object:Create("UIStroke")({
			Color = Color3.new(1, 1, 1),
			Transparency = 0.8
		}),
		object:Create("TextLabel")({
			Name = "Label",
			Text = text,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.08, 0.5),
			Size = UDim2.fromScale(0.9 - (v.SwitchWidth or 0.2) - 0.08, v.TextSize == nil and 0.55 or 0.85),
			BackgroundTransparency = 1,
			TextColor3 = Color3.new(1, 1, 1),
			Font = Enum.Font.SourceSansSemibold,
			TextScaled = v.TextSize == nil,
			TextSize = v.TextSize,
			TextWrapped = v.TextSize ~= nil,
			TextXAlignment = Enum.TextXAlignment.Left
		}),
		object:Create("Frame")({
			Name = "Track",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(0.94, 0.5),
			Size = UDim2.fromScale(v.SwitchWidth or 0.2, 0.5),
			BackgroundColor3 = object:Animation(value, info),
			AbsoluteSizeOnChangedInit = function(_, point: Vector2)
				if point.X <= 0 or point.Y <= 0 then
					return
				end

				v2 = true
				value3:Set((math.clamp(point.Y * 0.8 / 2 / point.X, 0, 0.5)))
			end,
			object:Create("UICorner")({
				CornerRadius = UDim.new(1)
			}),
			object:Create("Frame")({
				Name = "Knob",
				object:Create("UIShadow")({
					BlurRadius = uDim,
					Offset = uDim2,
					Transparency = 0.55,
					Color = color6
				}),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = object:Do(function(callback)
					local v5 = callback(value3)

					if callback(object2) == true then
						v5 = 1 - v5
					end

					local uDim3 = UDim2.fromScale(v5, 0.5)

					if v3 then
						return object:Animation(uDim3, info)
					end

					v3 = v2
					return uDim3
				end),
				Size = UDim2.fromScale(0.8, 0.8),
				object:Create("UIAspectRatioConstraint")({}),
				BackgroundColor3 = object:Animation(value2, info),
				object:Create("UICorner")({
					CornerRadius = UDim.new(1)
				})
			})
		}),
		MouseButton1Click = function()
			if v.CanClick ~= nil and not v.CanClick() then
				return
			end

			ScreenEffects.CircleClick()
			object2:Set(not object2:Compare(true))
		end
	})
end