local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
require(packages.Net)
local Trove = require(packages.Trove)
require(ReplicatedStorage.shared.modules.FishModel)
local QuestShared = require(ReplicatedStorage.shared.modules.QuestShared)
local module = require("../legacyControllers/DataController")
local playerDataReplicator = module.PlayerDataReplicator
local v = Component.new({
	Tag = "StarSign",
	Ancestors = { workspace }
})

function v:Construct()
	self.Trove = Trove.new()
	self.Id = self.Instance:GetAttribute("StarId")
end

function v:UpdateVisual()
	local v2 = table.find(playerDataReplicator:TryIndex({ "AstralObservatory", "StarSignsFound" }) or {}, self.Id) ~= nil
	local enabled = v2 or QuestShared:GetState(localPlayer, "Stellarwave3") >= QuestShared.QuestState.InProgress
	local root = self.Instance:WaitForChild("Root")
	root.SurfaceGui.Enabled = enabled
	root.SurfaceGui.glow.Visible = v2
	root.SurfaceLight.Enabled = v2
	root.ProximityPrompt.Enabled = enabled and not v2

	for _, v4 in root.active:QueryDescendants("ParticleEmitter") do
		v4.Enabled = v2
	end
end

function v:Start()
	self:UpdateVisual()
	self.Trove:Add(playerDataReplicator:Observe({ "AstralObservatory", "StarSignsFound" }, function()
		self:UpdateVisual()
	end))
	local dataPath = QuestShared:ReadDataPath(localPlayer, QuestShared.QuestsFolder.Active)

	if dataPath then
		self.Trove:Add(dataPath.ChildAdded:Connect(function(child)
			if child.Name == "Stellarwave3" then
				self:UpdateVisual()
			end
		end))
	end
end

function v.Stop(p)
	p.Trove:Clean()
end

return v