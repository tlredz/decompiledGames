require(script.Parent.Types)
local MaterialIconsHD = require(game.ReplicatedStorage.Packages.MaterialIconsHD)
local IslandDistance = require(game.ReplicatedStorage.IslandDistance)
local Config = require(script.Parent.Config)
local TargetResolver = {}

local function getHighestPointInModel(folder)
	local v = nil

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local v2 = part.Size * 0.5

		for i = -1, 1, 2 do
			for i2 = -1, 1, 2 do
				for i3 = -1, 1, 2 do
					local pointToWorldSpace = part.CFrame:PointToWorldSpace((Vector3.new(v2.X * i, v2.Y * i2, v2.Z * i3)))

					if not v or pointToWorldSpace.Y > v.Y then
						v = pointToWorldSpace
					end
				end
			end
		end
	end

	return v
end

local function getTargetIslandBoundingBox(instance)
	return (instance:GetBoundingBox())
end

local function updateTargetIslandBounds(state, targetPosition: Vector3)
	local _, targetIslandData = IslandDistance(targetPosition)
	state.TargetIslandData = targetIslandData
	state.TargetIslandBoundingBox = nil

	if not targetIslandData then
		return
	end

	if targetIslandData.Model then
		state.TargetIslandBoundingBox = targetIslandData.Model:GetBoundingBox()
		return
	end

	local map = workspace:FindFirstChild("Map")

	if not map then
		return
	end

	local v2 = 1e999
	local v3 = nil

	for _, model in ipairs(map:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		local magnitude = (model:GetBoundingBox().Position - targetPosition).Magnitude

		if not (magnitude < v2) then
			continue
		end

		v3 = model
		v2 = magnitude
	end

	if v3 and v2 < targetIslandData.Radius then
		state.TargetIslandBoundingBox = v3:GetBoundingBox()
	end
end

function TargetResolver:resolveTarget()
	local target = self.Options.Target

	if typeof(target) ~= "function" then
		self.ResolvedTarget = target
		return
	end

	local success, result = pcall(target)

	if success then
		self.ResolvedTarget = result
		return
	end

	warn((`CompassTracker target function for tracker {self.Id} errored: {result}`))
	self.ResolvedTarget = nil
end

function TargetResolver.getTargetPosition(instance)
	local typeName = typeof(instance)

	if typeName == "Vector3" then
		return instance
	elseif typeName == "CFrame" then
		return instance.Position
	end

	if typeName ~= "Instance" then
		return nil
	end

	if instance:IsA("BasePart") then
		return instance.Position
	end

	if instance:IsA("Model") then
		return instance:GetPivot().Position
	end

	return nil
end

function TargetResolver.getNearestLocation(vector: Vector3)
	local v = nil
	local children = workspace:WaitForChild("_WorldOrigin"):WaitForChild("Locations"):GetChildren()

	if #children > 0 then
		for _, part in pairs(children) do
			if part:GetAttribute("IgnoreInTracking") or not part:IsA("BasePart") or not (not v or (part.Position - vector).Magnitude < (v.Position - vector).Magnitude) then
				continue
			end

			v = part
		end
	end

	return v
end

function TargetResolver:refreshTrackerTarget()
	TargetResolver.resolveTarget(self)
	local targetPosition = TargetResolver.getTargetPosition(self.ResolvedTarget)

	if targetPosition then
		self.TrackedPosition = targetPosition

		if self.Id ~= Config.DEFAULT_TRACKER_ID then
			local Map = require(game.ReplicatedStorage.Controllers.UI.Map)

			if Map.IsInitialized then
				if self.TrackedPosition then
					Map:SetMarker(
						tostring(self.Id),
						self.TrackedPosition,
						MaterialIconsHD.priority_high,
						Color3.fromHex("78C8FF")
					)
				else
					Map:RemoveMarker((tostring(self.Id)))
				end
			end
		end

		self.TrackedLocation = TargetResolver.getNearestLocation(targetPosition)
		updateTargetIslandBounds(self, targetPosition)
	else
		self.TrackedPosition = nil
		self.TrackedLocation = nil
		self.TargetIslandData = nil
		self.TargetIslandBoundingBox = nil
		self.IsWithinTargetIsland = false
	end
end

function TargetResolver.getTrackerDistance(p)
	local trackedPosition = p.TrackedPosition or TargetResolver.getTargetPosition(p.ResolvedTarget)

	if not trackedPosition then
		return 0
	end

	local character = game.Players.LocalPlayer.Character

	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			return (trackedPosition - humanoidRootPart.Position).Magnitude
		end
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		return (trackedPosition - currentCamera.CFrame.Position).Magnitude
	end

	return 0
end

return TargetResolver