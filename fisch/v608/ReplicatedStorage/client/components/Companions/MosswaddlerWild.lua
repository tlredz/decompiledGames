local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "MosswaddlerWild"
})

function v:Construct()
	self.trove = Trove.new()
	self.prompt = self.Instance:FindFirstChildWhichIsA("ProximityPrompt", true)

	if not self.prompt then
		self.trove:Add(self.Instance.DescendantAdded:Connect(function(proximityPrompt)
			if proximityPrompt:IsA("ProximityPrompt") and not self.prompt then
				self.prompt = proximityPrompt
				self:_apply()
			end
		end))
	end

	self.trove:Add(self.Instance:GetAttributeChangedSignal("TargetUserId"):Connect(function()
		self:_apply()
	end))
	self:_apply()
end

function v:_apply()
	if not self.prompt then
		return
	end

	self.prompt.Enabled = self.Instance:GetAttribute("TargetUserId") == localPlayer.UserId
end

function v.Stop(p)
	p.trove:Clean()
end

return v