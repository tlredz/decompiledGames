game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local remoteEvent = Net:RemoteEvent("BazaarCandle/Light")
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local v = Component.new({
	Tag = "BazaarCandle",
	Ancestors = { workspace }
})

function v:Construct()
	self.trove = Trove.new()
end

function v:UpdateState()
	playerDataReplicator:WaitForLoaded()
	local enabled = (playerDataReplicator:TryIndex({ "LitBazaarCandles" }) or {})[tonumber(self.Instance.Name)] == true
	local isActive = self.Instance:GetAttribute("IsActive") == true

	for _, v3 in self.Instance:QueryDescendants("ParticleEmitter, Light") do
		v3.Enabled = enabled
	end

	local main = self.Instance:WaitForChild("Main")
	local highlight = main:FindFirstChildOfClass("Highlight")
	local proximityPrompt = main:FindFirstChildOfClass("ProximityPrompt")

	if enabled or isActive then
		main.Color = Color3.fromRGB(73, 125, 119)
	else
		main.Color = Color3.fromRGB(86, 100, 96)
	end

	if isActive and not enabled then
		if not highlight then
			local highlight2 = Instance.new("Highlight")
			highlight2.FillTransparency = 1
			highlight2.OutlineColor = Color3.fromRGB(0, 255, 128)
			highlight2.OutlineTransparency = 0.5
			highlight2.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight2.Parent = main
		end

		if not proximityPrompt then
			local clone = script.ProximityPrompt:Clone()
			local instance = self.Instance
			clone.Triggered:Connect(function(_)
				remoteEvent:FireServer(instance)
			end)
			clone.Parent = main
		end
	else
		if highlight then
			highlight:Destroy()
		end

		if proximityPrompt then
			proximityPrompt:Destroy()
		end
	end
end

function v:Start()
	self.trove:Add(self.Instance:GetAttributeChangedSignal("IsActive"):Connect(function()
		self:UpdateState()
	end))
	self.trove:Add(playerDataReplicator:Observe({ "LitBazaarCandles" }, function()
		self:UpdateState()
	end))
end

function v.Stop(p)
	p.trove:Clean()
end

return v