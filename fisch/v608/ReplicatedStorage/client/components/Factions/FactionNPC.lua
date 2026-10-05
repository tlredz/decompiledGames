local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local modules = ReplicatedStorage:WaitForChild("shared").modules
local Factions = require(modules.Factions)
local localPlayer = Players.LocalPlayer
local ReputationQuestsController = require(ReplicatedStorage.client.modules.ui.ReputationQuestsController)
local v = Component.new({
	Tag = "FactionNPC"
})

function v:Construct()
	self.trove = Trove.new()
	self.ProximityPrompt = Instance.new("ProximityPrompt", self.Instance)
	self.ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	self.ProximityPrompt.RequiresLineOfSight = false
	self.ProximityPrompt.ActionText = "Open"
	self.ProximityPrompt.ObjectText = self.Instance.Name .. " Faction"
	self.trove:Add(self.ProximityPrompt)
end

function v.Start(data)
	data.trove:Add(data.ProximityPrompt.Triggered:Connect(function(player)
		if player ~= localPlayer then
			return
		end

		if not Factions[data.Instance.Name] then
			print("[Faction NPC] This faction don't exist!")
		end

		ReputationQuestsController:OpenUI(data.Instance.Name)
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v