local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.packages.Net)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local _ = Players.LocalPlayer.PlayerGui
local safezone = script.Parent.Parent.Parent.ships.main.safezone
local isUtilityTab = safezone:GetAttribute("IsUtilityTab") == true
DataController.PlayerDataReplicator:Observe({ "UnlockedFromNPCs" }, function(p)
	if not p then
		return
	end

	local parent = script.Parent
	parent.Visible = p.UtilityBoats ~= nil and p.UtilityBoats
end)
safezone:GetAttributeChangedSignal("IsUtilityTab"):Connect(function()
	isUtilityTab = safezone:GetAttribute("IsUtilityTab")

	if isUtilityTab then
		script.Parent.title.Text = "View Regular Boats"
	else
		script.Parent.title.Text = "View Utility Boats"
	end
end)
script.Parent.Activated:Connect(function()
	isUtilityTab = not isUtilityTab
	safezone:SetAttribute("IsUtilityTab", isUtilityTab)
end)