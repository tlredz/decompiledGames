local v = {}
local localPlayer = game.Players.LocalPlayer
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local Octree = require(game.ReplicatedStorage.Util.Octree)
local v2 = Octree.new()
local CollectionService = game:GetService("CollectionService")

local function createBush(instance)
	local parent = instance.Parent
	assert(v[parent.Name] == nil, (`no bush found for "{parent.Name}"`))
	local boundingBox, _ = parent:GetBoundingBox()
	local v3 = {
		Node = v2:CreateNode(boundingBox.Position, parent.Name),
		Stream = function(self)
			CollectionService:AddTag(instance, "BerryBushStreamed")
		end,
		Destream = function(self)
			CollectionService:RemoveTag(instance, "BerryBushStreamed")
		end
	}
	v[parent.Name] = v3
end

local function destroyBush(p)
	local parent = p.Parent

	if v[parent.Name] then
		v[parent.Name]:Destream()
		v[parent.Name].Node:Destroy()
		v[parent.Name].Node = nil
		v[parent.Name] = nil
	end
end

return {
	OnStart = function(_)
		if not localPlayer.Team then
			localPlayer:GetPropertyChangedSignal("Team"):Wait()
		end

		CollectionService:GetInstanceRemovedSignal("BerryBush"):Connect(destroyBush)
		CollectionService:GetInstanceAddedSignal("BerryBush"):Connect(createBush)
		task.spawn(function()
			tick()
			local count = 0

			for _, v3 in pairs(CollectionService:GetTagged("BerryBush")) do
				if not v3.Parent then
					continue
				end

				task.spawn(createBush, v3)
				count += 1

				if count % 20 == 0 then
					task.wait(0.1)
				end
			end
		end)
		local v3 = {
			None = 5,
			MouseKeyboard = 2,
			Gamepad = 2,
			Touch = 2
		}
		local v4 = {
			None = 1,
			MouseKeyboard = 5,
			Gamepad = 5,
			Touch = 5
		}
		local v5 = {
			None = 1,
			MouseKeyboard = 500,
			Gamepad = 500,
			Touch = 300
		}
		local v6 = {}

		while true do
			local v7 = nil
			local success, result = pcall(function()
				if not localPlayer.Character or localPlayer.Character.Parent ~= workspace:FindFirstChild("Characters") then
					v7 = 0.25
					return
				end

				local v8 = LastInput:Get() or "None"
				v7 = v3[v8]
				local v9 = v4[v8]
				local v10 = v5[v8]
				debug.profilebegin("BerryBushOctree")
				local kNearestNeighborsSearch = v2:KNearestNeighborsSearch(
					localPlayer.Character:GetPivot().Position,
					v9,
					v10
				)

				for k in pairs(v6) do
					if table.find(kNearestNeighborsSearch, k) or not v[k] then
						continue
					end

					v[k]:Destream()
				end

				local count = 0
				v6 = {}

				for _, v11 in pairs(kNearestNeighborsSearch) do
					if not v[v11] then
						continue
					end

					v6[v11] = true
					count += 1
					v[v11]:Stream()
				end

				debug.profileend()
			end)

			if not success then
				warn(result)
			end

			task.wait(v7 or 1)
		end
	end
}