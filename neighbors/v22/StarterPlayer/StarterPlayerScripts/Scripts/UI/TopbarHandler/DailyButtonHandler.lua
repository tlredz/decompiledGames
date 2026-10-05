local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Client = require(ReplicatedStorage.Modules.GameConfig.Client)
local Icon = require(ReplicatedStorage.Modules:WaitForChild("Icon"))
local v = Icon.new()
v:setImage("rbxassetid://118591553275491")
v:align("Right")
v:setImageScale(0.4)
v:setOrder(2)
v:setEnabled(false)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateVisibility()
	v:setEnabled(Client:GetValue("DailyRewardType") ~= "NoReward")
end

localPlayer.CharacterAdded:connect(function(_)
	v:deselect()
end)
v:bindEvent("selected", function()
	if localPlayer.PlayerGui.Neighbors and localPlayer.PlayerGui.Neighbors.DailyRewards then
		localPlayer.PlayerGui.Neighbors.DailyRewards.Visible = not localPlayer.PlayerGui.Neighbors.DailyRewards.Visible
		v:deselect()
	end
end)
updateVisibility() -- equivalent call inferred; original call site unknown
Client:GetValueChangedSignal("DailyRewardType"):Connect(updateVisibility)