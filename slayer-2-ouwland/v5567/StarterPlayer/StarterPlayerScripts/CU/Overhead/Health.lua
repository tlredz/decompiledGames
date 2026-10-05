local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local faye = require(ReplicatedStorage.Packages.faye)
local color = Color3.new(0.031373, 0.352941, 0.156863)
local color2 = Color3.new(0.333333, 1, 0.333333)
local color3 = Color3.new(0.639216, 1, 0.639216)
local color4 = Color3.new(0.580392, 0.039216, 0)
local color5 = Color3.new(1, 0, 0)
local color6 = Color3.new(1, 0.192157, 0.192157)
local uDim = UDim.new(0.25)
local info = faye.Info(0.2)
local info2 = faye.Info(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
return function(parent, _, p2, _)
	local v = faye.new()
	local v2 = p2 or script.Humanoid
	local v3 = nil

	local function show()
		if v3 then
			return
		end

		v3 = faye.new()
		local backgroundColor = v3:Value(color)
		local color7 = v3:Value(color2)
		local backgroundColor2 = v3:Value(color3)
		local value4 = v3:Value(UDim2.fromScale(1, 1))

		local function fn()
			if v2 == nil or v2.Parent == nil then
				return
			end

			local v4 = v2.Health / v2.MaxHealth
			backgroundColor:Set(Utility.Lerp_Color2(color4, color, v4))
			color7:Set(Utility.Lerp_Color2(color5, color2, v4))
			backgroundColor2:Set(Utility.Lerp_Color2(color6, color3, v4))
			value4:Set(UDim2.fromScale(v4, 1))
		end

		v3:Connect(v2:GetPropertyChangedSignal("Health"), fn)
		fn()
		v3:Create("Frame")({
			Size = UDim2.fromScale(1, 0.175),
			Name = "ZHealth",
			Parent = parent,
			BackgroundTransparency = 1,
			v3:Create("Frame")({
				Size = UDim2.new(0.7, -2, 0.7, -2),
				Name = "Actual",
				v3:Create("UICorner")({
					CornerRadius = uDim
				}),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = backgroundColor,
				v3:Create("UIStroke")({
					Thickness = 3,
					Color = color7,
					Transparency = 0.75
				}),
				v3:Create("Frame")({
					Size = v3:Animation(value4, info),
					Name = "Bar",
					ZIndex = 2,
					BackgroundColor3 = backgroundColor2,
					v3:Create("UICorner")({
						CornerRadius = uDim
					})
				}),
				v3:Create("Frame")({
					Size = v3:Animation(value4, info2),
					Name = "BarRed",
					BackgroundColor3 = Color3.new(1, 1, 1),
					v3:Create("UICorner")({
						CornerRadius = uDim
					})
				})
			})
		})
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function hide()
		if v3 then
			v3:Destroy()
			v3 = nil
		end
	end

	local function onHealth()
		if v2 == nil or v2.Parent == nil then
			return
		end

		if v2.Health < v2.MaxHealth then
			show()
			return
		end

		hide() -- equivalent call inferred; original call site unknown
	end

	v:Connect(v2:GetPropertyChangedSignal("Health"), onHealth)

	if v2 ~= nil and v2.Parent ~= nil then
		if v2.Health < v2.MaxHealth then
			show()
		else
			hide() -- equivalent call inferred; original call site unknown
		end
	end

	return function()
		hide() -- equivalent call inferred; original call site unknown
		v:Destroy()
	end
end