local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "TransparencyZone"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.Area = self.Instance:WaitForChild("Area")
	self.Transparent = false
end

function v:Start()
	local v2 = 0
	self._Janitor:Add(RunService.Heartbeat:Connect(function(dt)
		v2 += dt

		if v2 < 1 then
			return
		end

		while v2 >= 1 do
			v2 -= 1
		end

		local overlapParams = OverlapParams.new()
		overlapParams.FilterDescendantsInstances = { Players.LocalPlayer.Character.HumanoidRootPart }
		overlapParams.FilterType = Enum.RaycastFilterType.Include

		if #Workspace:GetPartBoundsInBox(self.Area.CFrame, self.Area.Size, overlapParams) == 0 then
			if self.Transparent then
				self.Instance.Transparency = NumberSequence.new(0)
				self.Transparent = 0
			end
		else
			self.Transparent = true
			self.Instance.Transparency = NumberSequence.new(1)
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v