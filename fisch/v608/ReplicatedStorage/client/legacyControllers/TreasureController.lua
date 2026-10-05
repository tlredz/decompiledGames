local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local chests = ReplicatedStorage:WaitForChild("resources"):WaitForChild("models"):WaitForChild("Chests")
local chestClosed = chests:WaitForChild("ChestClosed")
local chestOpen = chests:WaitForChild("ChestOpen")
local opening = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("treasure"):WaitForChild("Opening")
local Trove = require(ReplicatedStorage.packages.Trove)
ReplicatedStorage:WaitForChild("events"):WaitForChild("open_treasure")
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local chests2 = Workspace:WaitForChild("world"):WaitForChild("chests")
local TreasureController = {}
local v = {}

local function spawnChest(id: string)
	local v2 = DataController.InventoryReplicator:TryIndex({ "Inventory", id, "sub" })

	if not v2 then
		warn((`HOW!!!!!!!!! HOW IS THER ENO DATA FOR THE {id} I JUST HAD IT!!!!!!!!!`))
		return
	end

	local v3 = v[id]:Add(chestClosed:Clone())
	v3:PivotTo(CFrame.new(v2.x, v2.y, v2.z))
	v3:AddTag("TreasureChest")
	v3:SetAttribute("id", id)
	v3.Parent = chests2
	return v3
end

function TreasureController:Listen(p: string)
	if v[p] then
		return
	end

	local maid = Trove.new()
	local v2 = nil
	v[p] = maid
	local v3 = DataController.InventoryReplicator:TryIndex({ "Inventory", p, "sub" })
	local vector = Vector3.new(v3.x, v3.y, v3.z)
	maid:Add(function()
		if localPlayer:DistanceFromCharacter(vector) < 32 then
			local clone = chestOpen:Clone()
			clone:SetAttribute("Opened", true)
			clone:PivotTo(CFrame.new(vector))
			clone.Parent = chests2
			local clone2 = opening:Clone()
			clone2.Parent = clone
			clone2:Play()
			local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
			local treasureMap = playerGui and playerGui:FindFirstChild("Treasure Map")

			if treasureMap then
				treasureMap.Enabled = false
			end

			Debris:AddItem(clone, 30)
		end
	end)
	maid:Add(DataController.InventoryReplicator:Observe({
		"Inventory",
		p,
		"sub",
		"Repaired"
	}, function(p2)
		if p2 then
			if not v2 then
				v2 = spawnChest(p)
			end
		elseif v2 then
			maid:Remove(v2)
			v2 = nil
		end
	end))
end

function TreasureController.Start(_)
	if FischUtils.IsTradePlaza() then
		return
	end

	DataController.InventoryReplicator:ObserveKeys({ "Inventory" }, function(p: string, p2)
		if p2 then
			if p2.name == "Treasure Map" then
				TreasureController:Listen(p)
			end
		elseif v[p] then
			v[p]:Destroy()
			v[p] = nil
		end
	end)
end

return TreasureController