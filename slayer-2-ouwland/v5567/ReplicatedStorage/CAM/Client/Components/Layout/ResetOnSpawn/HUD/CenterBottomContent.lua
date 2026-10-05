local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Toolbar = require(script.Toolbar)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local HUD = ReplicatedStorage.CAM.Client.Components.Layout.Visibility.HUD
local BottomCenterNotifications = require(script.BottomCenterNotifications)
local ValueHub = require(script.ValueHub)
local hiddenOn = {
	Mobile = true
}
local v2 = -gameSettings.BottomHudLift
local v3 = -gameSettings.BottomHudLiftPad

-- equivalent calls inferred from this helper; original call sites unknown
local function onMobile()
	return Platform_Handler.Platform.Value == "Mobile"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function holderHeight()
	if onMobile() then
		return 0.09
	end

	return 0.15
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bottomShift()
	if onMobile() then
		return -90
	end

	return 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bottomLift()
	if onMobile() then
		return -13
	end

	if Platform_Handler.IsGamepad() then
		return v3
	end

	return v2
end

local v4 = {
	Skills = {
		Module = require(script.Skills),
		Value = HUD.Skills,
		HiddenOn = hiddenOn
	},
	Toolbar = {
		Module = Toolbar,
		HiddenOn = hiddenOn
	},
	EquippedTool = {
		Module = require(script.EquippedTool)
	},
	MobileMastery = {
		Module = require(script.MobileMastery),
		OnlyOn = {
			Mobile = true
		}
	}
}
return function(object, parent)
	for _, v8 in pairs(v4) do
		v8.last = nil
	end

	local v8 = bottomLift() -- equivalent call inferred; original call site unknown
	local value = object:Value(v8)
	local value2 = object:Value(holderHeight())
	local value3 = object:Value(bottomShift())
	object:Connect(Platform_Handler.Platform.Changed.Event, function()
		local v10 = bottomLift() -- equivalent call inferred; original call site unknown
		value:Set(v10)
		value2:Set(holderHeight())
		value3:Set(bottomShift())
	end)
	local v9 = object:Create("Frame")({
		Name = "BottomHolder",
		Size = object:Do(function(callback)
			return UDim2.fromScale(0.2, callback(value2))
		end),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = object:Do(function(callback)
			return UDim2.new(0.5, callback(value3), 1, callback(value))
		end),
		Parent = parent,
		BackgroundTransparency = 1,
		object:Create("UIListLayout")({
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0.065, 0)
		}),
		ValueHub(object, parent),
		BottomCenterNotifications(object, parent)
	})

	local function update(_: boolean)
		for _, v10 in pairs(v4) do
			local last

			if v10.Value == nil then
				last = true
			else
				last = v10.Value.Value ~= false and v10.Value.Value ~= 0
			end

			if v10.OnlyOn ~= nil and not v10.OnlyOn[Platform_Handler.Platform.Value] then
				last = false
			end

			if v10.HiddenOn ~= nil and v10.HiddenOn[Platform_Handler.Platform.Value] then
				last = false
			end

			if v10.last == last then
				continue
			end

			v10.last = last

			if v10.Thread ~= nil and v10.Thread.Destroy then
				v10.Thread:Destroy()
				v10.Thread = nil
			end

			if last ~= true then
				continue
			end

			v10.Thread = object:Extend()
			v10.Module(v10.Thread, v9, parent)
		end
	end

	for _, child in pairs(HUD:GetChildren()) do
		object:Connect(child.Changed, update)
	end

	object:Connect(Platform_Handler.Platform.Changed.Event, update)
	update(true)
	return v9
end