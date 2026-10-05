local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
local Platform_Handler = require(ReplicatedStorage.CAM.Client.Controllers.Platform_Handler)
local Toolbar = require(script.Toolbar)
local Skills = require(script.Skills)
local Dash = require(script.Dash)
local Run = require(script.Run)
local Combat = require(script.Combat)
local Edit = require(script.Edit)
local Aim = require(script.Aim)
local visibility = ReplicatedStorage.CAM.Client.Components.Layout.Visibility
local HUD = visibility.HUD
local v = visibility:FindFirstChild("Controls")

if v == nil then
	v = Instance.new("BoolValue")
	v.Name = "Controls"
	v.Value = true
	v.Parent = visibility
end

local function Build(object, parent)
	local visible = object:Value(v.Value == true)
	object:Connect(v.Changed, function()
		visible:Set(v.Value == true)
	end)
	local visible2 = object:Value(HUD.Value == true)
	object:Connect(HUD.Changed, function()
		visible2:Set(HUD.Value == true)
	end)
	local value3 = object:Value(false)
	Edit(object, value3, parent)
	object:Create("Frame")({
		Parent = parent,
		Name = "Mobile",
		Visible = visible,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 100,
		Dash(object, parent, value3),
		Run(object, parent, value3),
		object:Create("Frame")({
			Name = "Hud",
			Visible = visible2,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Toolbar(object, parent, value3),
			Skills(object, parent, value3),
			Combat(object, parent, value3),
			Aim(object)
		})
	})
end

return function(parent)
	local v2 = faye.new()
	local v3 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		if Platform_Handler.Platform.Value == "Mobile" == (v3 ~= nil) then
			return
		end

		if v3 == nil then
			v3 = v2:Extend()
			Build(v3, parent)
		else
			v3:Destroy()
			v3 = nil
		end
	end

	update() -- equivalent call inferred; original call site unknown
	v2:Connect(Platform_Handler.Platform.Changed.Event, update)
	return function()
		v2:Destroy()
	end
end