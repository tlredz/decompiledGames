local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InFaction = require(script.InFaction)
local NotInfaction = require(script.NotInfaction)
local TestData = require(script.TestData)
local FactionState = require(ReplicatedStorage.CAM.Client.Modules.FactionState)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
require(ReplicatedStorage.Packages.faye)
local localPlayer = Players.LocalPlayer
local v = localPlayer == nil and 0 or localPlayer.UserId
local v2 = localPlayer == nil and "You" or localPlayer.DisplayName
return function(object, _)
	local value = object:Value(nil)
	local value2 = object:Value(false)

	local function apply(record)
		if record == nil and not gameSettings.IsRunning then
			record = TestData(v, v2)
		end

		local v3 = value:Get()

		if record ~= nil and v3 ~= nil and record.FactionId == v3.FactionId and record.Version == v3.Version then
			return
		end

		local member = FactionState.MemberOf(record, v)
		value2:Set(member ~= nil and member.IsAdmin == true)
		value:Set(record)
	end

	apply(FactionState.Record)
	object:Connect(FactionState.Changed, apply)
	task.spawn(FactionState.Refresh)
	return object:Create("Frame")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = object:Animation(UDim2.fromScale(0.8, 0.8), object.SpringInfo(0.35, 1, 0.65), {
			From = UDim2.fromScale(0.7200000000000001, 0.7200000000000001)
		}),
		Instance.new("UIAspectRatioConstraint"),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		object:State(function(callback, p, _)
			local v3 = callback(value)

			if v3 == nil then
				return NotInfaction(p)
			end

			return InFaction(p, value2, v3)
		end)
	})
end