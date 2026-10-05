local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SpatialIndex = require(ReplicatedStorage.Modules.SpatialIndex)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local places = workspace:WaitForChild("Places")
local v = { "SurfaceGui", "BillboardGui", "Light" }

local function Check(instance)
	if not table.find(v, instance.ClassName) or instance:FindFirstAncestor("Activities") then
		return
	end

	if instance:HasTag("SpatialIndexCantQuery") then
		return
	else
		return true
	end
end

local function CacheFunction(object)
	for _, descendant in places:GetDescendants() do
		local v2

		if table.find(v, descendant.ClassName) and not descendant:FindFirstAncestor("Activities") then
			v2 = not descendant:HasTag("SpatialIndexCantQuery") or nil
		end

		if not v2 then
			continue
		end

		local basePart = descendant:FindFirstAncestorWhichIsA("BasePart")

		if basePart then
			object:Set(basePart.CFrame.Position, basePart, {
				OriginalParent = basePart.Parent
			})
		end
	end

	local descendantAddedConnection = places.DescendantAdded:Connect(function(descendant)
		local v2

		if table.find(v, descendant.ClassName) and not descendant:FindFirstAncestor("Activities") then
			v2 = not descendant:HasTag("SpatialIndexCantQuery") or nil
		end

		if not v2 then
			return
		end

		local basePart = descendant:FindFirstAncestorWhichIsA("BasePart")

		if not basePart then
			return
		end

		task.wait()
		object:Set(basePart.CFrame.Position, basePart, {
			OriginalParent = basePart.Parent
		})
	end)
	table.insert(object.Connections, descendantAddedConnection)
	local descendantRemovingConnection = places.DescendantRemoving:Connect(function(descendant)
		local v2

		if table.find(v, descendant.ClassName) and not descendant:FindFirstAncestor("Activities") then
			v2 = not descendant:HasTag("SpatialIndexCantQuery") or nil
		end

		if not v2 or descendant.Parent then
			return
		end

		task.wait()
		object:Remove(descendant)
	end)
	table.insert(object.Connections, descendantRemovingConnection)
end

local function In(_, instance, p)
	if p.OriginalParent.Parent then
		instance.Parent = p.OriginalParent
	else
		instance:Destroy()
	end
end

local function Out(_, p, _)
	p.Parent = ReplicatedStorage.HiddenAssets
end

local v2 = SpatialIndex.new(character:WaitForChild("HumanoidRootPart"), 16, vector.create(1, 0, 1), CacheFunction, {
	[-1] = Out,
	[0] = In,
	[1] = In
})
localPlayer.CharacterAdded:Connect(function(character2)
	v2.Subject = character2:WaitForChild("HumanoidRootPart")
end)