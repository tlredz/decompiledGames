game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
require(packages.Net)
local Trove = require(packages.Trove)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local v = Component.new({
	Tag = "SkycrestGate",
	Ancestors = { workspace }
})

function v:Construct()
	self.Trove = Trove.new()
end

local v2 = {
	[false] = CFrame.identity,
	[true] = CFrame.new(-60, 0, 0)
}

local function countTrues(list)
	local count = 0

	for _, v3 in ipairs(list) do
		if v3 then
			count += 1
		end
	end

	return count
end

function v.Start(p)
	local door = p.Instance:WaitForChild("door")
	local root = p.Instance:WaitForChild("root")
	local openSound = root:WaitForChild("openSound")
	local clone = nil
	p.Trove:Add(playerDataReplicator:Observe({ "Skycrest", "SkyCrystalsPlaced" }, function(list)
		local count = 0

		for _, v3 in ipairs(list) do
			if v3 then
				count += 1
			end
		end

		local v3 = count >= 4
		local v4 = clone

		if v4 then
			local v5 = clone
			local count2 = 0

			for _, v6 in ipairs(v5) do
				if v6 then
					count2 += 1
				end
			end

			if count2 >= 4 then
				v4 = true
			else
				v4 = false
			end
		end

		if v3 and v4 == false then
			TweenService:Create(door, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				CFrame = root.CFrame * v2[v3]
			}):Play()
			openSound:Play()
		else
			door.CFrame = root.CFrame * v2[v3]
		end

		clone = table.clone(list)
	end))
end

function v.Stop(p)
	p.Trove:Clean()
end

return v