local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Component = require(packages.Component)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local Trove = require(packages.Trove)
local remoteEvent = Net:RemoteEvent("LostJungle/MoveWorker")
local v = {
	Samuel = CFrame.new(-2971.82, 135.748, -2182.992) * CFrame.Angles(0, -0.8835729338221293, 0),
	Theo = CFrame.new(-2933.211, 127.776, -2198.607) * CFrame.Angles(0, 0.9534908236570222, 0),
	Elias = CFrame.new(-2945.668, 132.516, -2187.352) * CFrame.Angles(
		-0.10759954838545041,
		0.2485174321914726,
		-0.07468263869283737
	),
	Paul = CFrame.new(-2973.378, 145.748, -2192.699) * CFrame.Angles(0, -0.8835729338221293, 0),
	Hayden = CFrame.new(-2960.21, 129.441, -2205.25) * CFrame.Angles(0, -1.4366154139015725, 0)
}
local v2 = Component.new({
	Tag = "LostJungleWorker"
})

function v2:Construct()
	self._trove = Trove.new()
end

function v2:MoveToSite(p2: string)
	local v3 = v[p2]

	if not v3 then
		return
	end

	local instance = self.Instance

	if not instance:IsA("Model") then
		return
	end

	if not instance.PrimaryPart then
		instance:WaitForChild("HumanoidRootPart", 5)
	end

	if instance.PrimaryPart then
		instance:PivotTo(v3)
		instance.PrimaryPart.Anchored = true
	end
end

function v2:Start()
	local npcType = self.Instance:GetAttribute("NpcType")

	if not npcType then
		return
	end

	local v3 = string.gsub(npcType, "LostJungle_", "")

	if not v[v3] then
		return
	end

	DataController.PlayerDataReplicator:WaitForLoaded()
	local index = DataController.PlayerDataReplicator:Index({ "LostJungle" })

	if index and index.Workers and index.Workers[v3] then
		self:MoveToSite(v3)
	end

	self._trove:Add(remoteEvent.OnClientEvent:Connect(function(p: string)
		if p == v3 then
			self:MoveToSite(p)
		end
	end))
end

function v2:Stop()
	if self._trove then
		self._trove:Destroy()
		self._trove = nil
	end
end

return v2