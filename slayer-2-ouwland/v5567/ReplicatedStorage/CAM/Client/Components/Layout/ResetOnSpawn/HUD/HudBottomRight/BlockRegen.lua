local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local SkillTreeConfig = require(ReplicatedStorage.CAM.Global.SkillService.SkillTreeholder.SkillTreeConfig)
local Ring = require(script.Parent.Parent.CenterBottomContent.ValueHub.Ring)
local color = Color3.new(0.15, 0.15, 0.15)
local numberSequence = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.85) })
local color2 = Color3.new(0.7, 0.7, 0.75)
local info = faye.Info(0.3, Enum.EasingStyle.Back)
local info2 = faye.Info(0.3)
local localPlayer = Players.LocalPlayer
return function(maid, p)
	local v = math.round((Platform_Handler.Platform.Value == "Mobile" and 1.25 or 1) * 30)
	local v2 = math.round(v * 0.5616)
	local v3 = v2 + 10 + 8
	local v4 = math.round(v * 0.8)
	local icon = (SkillTreeConfig["Block Points"] or {}).Icon
	local value = maid:Value(false)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function platformServed()
		return p == nil or p[Platform_Handler.Platform.Value] == true
	end

	local value2 = maid:Value(platformServed())
	maid:Connect(Platform_Handler.Platform.Changed.Event, function()
		value2:Set(platformServed())
	end)
	local value3 = maid:Value(0)
	local value4 = maid:Value(1)
	local value5 = maid:Value(0)
	local v5 = nil
	local v6 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function evaluate()
		local v7 = v5

		if v7 == nil or v7.Parent == nil then
			value:Set(false)
			return
		end

		local v8 = v7.Value - (v7:GetAttribute("D") or 0)
		value:Set(v7.Parent == localPlayer and v8 < v7.MaxValue)
	end

	local function onBlockChanged()
		local v7 = v5

		if v7 == nil then
			return
		end

		local v8 = v7.Value - (v7:GetAttribute("D") or 0)
		value3:Set(v8)
		value4:Set((math.max(v7.MaxValue, 1)))
		value5:Set(math.clamp(v8 / math.max(v7.MaxValue, 1), 0, 1) * 360)
		evaluate() -- equivalent call inferred; original call site unknown
	end

	local function bind(intConstrainedValue)
		if intConstrainedValue == nil or intConstrainedValue == v5 or not intConstrainedValue:IsA("IntConstrainedValue") then
			return
		end

		if v6 ~= nil then
			v6:Destroy()
		end

		v5 = intConstrainedValue
		v6 = faye.new()
		v6:Connect(intConstrainedValue:GetPropertyChangedSignal("Value"), onBlockChanged)
		v6:Connect(intConstrainedValue:GetAttributeChangedSignal("D"), onBlockChanged)
		v6:Connect(intConstrainedValue:GetPropertyChangedSignal("MaxValue"), onBlockChanged)
		v6:Connect(intConstrainedValue:GetPropertyChangedSignal("Parent"), evaluate)
		onBlockChanged()
	end

	maid:Add(function()
		if v6 ~= nil then
			v6:Destroy()
			v6 = nil
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watch(instance)
		maid:Connect(instance.ChildAdded, function(p2)
			if p2.Name == "Blocking" then
				bind(p2)
			end
		end)
		bind(instance:FindFirstChild("Blocking"))
	end

	local v7 = localPlayer
	maid:Connect(v7.ChildAdded, function(p2)
		if p2.Name == "Blocking" then
			bind(p2)
		end
	end)
	bind(v7:FindFirstChild("Blocking"))
	maid:Spawn(function()
		watch(Utility.getvaluesfolder(localPlayer, true)) -- equivalent call inferred; original call site unknown
	end)
	return maid:State(function(callback, object)
		if not (callback(value) and callback(value2)) then
			return nil
		end

		local value6 = object:Value(v3 + 8)
		local v8 = object:Create("Frame")
		local v9 = {
			Name = "BlockRegen",
			LayoutOrder = -1,
			Size = object:Do(function(callback2)
				return UDim2.fromOffset(callback2(value6), v)
			end),
			BackgroundColor3 = color,
			BackgroundTransparency = object:Animation(0.25, info, {
				From = 1
			}),
			CleanDelay = 0.3,
			OnClean = {
				BackgroundTransparency = object:Animation(1, info2)
			}
		}
		local v10 = object:Create("UICorner")({
			CornerRadius = UDim.new(1)
		})
		local v11 = object:Create("UIShadow")({
			Color = color2,
			BlurRadius = UDim.new(0.8, 0),
			Transparency = 0.85
		})
		local v12 = object:Create("UIGradient")({
			Transparency = numberSequence,
			Rotation = -90
		})
		local v13 = object:Create("TextLabel")({
			Name = "Label",
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Position = UDim2.fromOffset(v3, 0),
			BackgroundTransparency = 1,
			Text = object:Do(function(callback2)
				return (`Block {string.format("%.1f", callback2(value3))}/{callback2(value4)}`)
			end),
			TextBoundsOnChangedInit = function(_, point: Vector2)
				value6:Set(v3 + point.X + 16)
			end,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = math.round(v * 0.62),
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = object:Animation(0, info2, {
				From = 1
			}),
			OnClean = {
				TextTransparency = object:Animation(1, info2)
			}
		})
		local ring = Ring(object, value5, UDim2.fromOffset(v2 / 2 + 10, v / 2), UDim2.fromOffset(v4, v4), 2, nil, 0.4)
		local v15

		if icon ~= nil then
			v15 = object:Create("ImageLabel")({
				Name = "Glyph",
				Size = UDim2.fromOffset(v2, v2),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 10, 0.5, 0),
				BackgroundTransparency = 1,
				Image = icon,
				ScaleType = Enum.ScaleType.Fit,
				ImageTransparency = object:Animation(0, info2, {
					From = 1
				}),
				OnClean = {
					ImageTransparency = object:Animation(1, info2)
				},
				object:Create("UIShadow")({
					BlurRadius = UDim.new(0.8, 0),
					Transparency = 0.7
				})
			})
		end

		v9[1], v9[2], v9[3], v9[4], v9[5], v9[6] = v10, v11, v12, v13, ring, v15
		return v8(v9)
	end)
end