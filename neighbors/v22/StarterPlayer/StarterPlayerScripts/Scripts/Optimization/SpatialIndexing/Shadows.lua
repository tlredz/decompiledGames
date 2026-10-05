local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SpatialIndex = require(ReplicatedStorage.Modules.SpatialIndex)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local places = workspace:WaitForChild("Places")

local function Check(part)
	if not part:IsA("BasePart") or part:HasTag("SpatialIndexCantQuery") or not part.CastShadow then
		return
	end

	if part:FindFirstAncestor("Activities") then
		return
	else
		return true
	end
end

local function CacheFunction(object)
	for _, part in places:GetDescendants() do
		local v

		if part:IsA("BasePart") and not part:HasTag("SpatialIndexCantQuery") and part.CastShadow then
			v = not part:FindFirstAncestor("Activities") or nil
		end

		if v then
			object:Set(part.CFrame.Position, part, {
				OriginalParent = part.Parent
			})
		end
	end

	local descendantAddedConnection = places.DescendantAdded:Connect(function(part)
		local v

		if part:IsA("BasePart") and not part:HasTag("SpatialIndexCantQuery") and part.CastShadow then
			v = not part:FindFirstAncestor("Activities") or nil
		end

		if not v then
			return
		end

		task.wait()
		object:Set(part.CFrame.Position, part, {
			OriginalParent = part.Parent
		})
	end)
	table.insert(object.Connections, descendantAddedConnection)
	local descendantRemovingConnection = places.DescendantRemoving:Connect(function(part)
		local v

		if part:IsA("BasePart") and not part:HasTag("SpatialIndexCantQuery") and part.CastShadow then
			v = not part:FindFirstAncestor("Activities") or nil
		end

		if not v or part.Parent then
			return
		end

		task.wait()
		object:Remove(part)
	end)
	table.insert(object.Connections, descendantRemovingConnection)
end

local function In(_, p, _)
	p.CastShadow = true
end

local function Out(_, p, _)
	p.CastShadow = false
end

local v = SpatialIndex.new(character:WaitForChild("HumanoidRootPart"), 16, vector.create(1, 0, 1), CacheFunction, {
	[-1] = Out,
	[0] = In,
	[1] = In
})
localPlayer.CharacterAdded:Connect(function(character2)
	v.Subject = character2:WaitForChild("HumanoidRootPart")
end)