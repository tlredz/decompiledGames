local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local v = Component.new({
	Tag = "FriendFish"
})

function v:Construct()
	self.Collector = Trove.new()
	self.UserId = self.Instance:GetAttribute("FriendId")
end

function v:Start()
	if not self.UserId then
		return
	end

	self.Humanoid = Instance.new("Humanoid", self.Instance)
	self.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local humanoidDescriptionFromUserId = Players:GetHumanoidDescriptionFromUserId(self.UserId)
	self.Collector:Add(humanoidDescriptionFromUserId)

	for _, part in self.Instance:GetChildren() do
		if part:IsA("BasePart") and part.Name ~= "Head" then
			part.Color = humanoidDescriptionFromUserId.HeadColor
		end
	end

	self.Humanoid:ApplyDescription(humanoidDescriptionFromUserId)
end

function v.Stop(p)
	p.Collector:Destroy()
end

return v