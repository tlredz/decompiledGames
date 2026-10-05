local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- equivalent calls inferred from this helper; original call sites unknown
local function randomInRange(p: number, p2: number)
	return p + math.random() * (p2 - p)
end

local function randomPointInZone(instance, Y: number)
	local v = instance.Size.X * 0.5
	local v2 = instance.Size.Z * 0.5
	local v3 = math.max(0, (math.min(4, v - 1, v2 - 1)))
	local v4 = (math.random() * 2 - 1) * (v - v3)
	local v5 = (math.random() * 2 - 1) * (v2 - v3)
	local pointToWorldSpace = instance.CFrame:PointToWorldSpace((Vector3.new(v4, 0, v5)))
	return (Vector3.new(pointToWorldSpace.X, Y, pointToWorldSpace.Z))
end

local function buildProbeParams(rig, zones, npcFloorHazardTag: string)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true
	local filterDescendantsInstances = { rig }

	for _, item in zones do
		table.insert(filterDescendantsInstances, item)
	end

	for _, v2 in CollectionService:GetTagged(npcFloorHazardTag) do
		table.insert(filterDescendantsInstances, v2)
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	return raycastParams
end

local function nearestZone(position: Vector3, zones)
	local v = zones[1]
	local magnitude = (v.Position - position).Magnitude

	for i = 2, #zones do
		local magnitude2 = (zones[i].Position - position).Magnitude

		if not (magnitude2 < magnitude) then
			continue
		end

		v = zones[i]
		magnitude = magnitude2
	end

	return v
end

local function pickNextZone(zones, p)
	if #zones <= 1 then
		return nil
	end

	local v = zones[math.random(#zones)]

	while v == p do
		v = zones[math.random(#zones)]
	end

	return v
end

local function prepareRig(folder, humanoid)
	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	humanoid.PlatformStand = false
	humanoid.Sit = false
end

local function walkStep(humanoid, primaryPart, position: Vector3, npcMoveTimeoutSeconds: number, fn)
	local position2 = primaryPart.Position
	local v = false
	local v2 = false
	local moveToFinishedConnection = humanoid.MoveToFinished:Connect(function(flag: boolean)
		v = true
		v2 = flag
	end)
	humanoid:MoveTo(position)
	local total = 0

	while fn() and not v and total < npcMoveTimeoutSeconds do
		task.wait(0.2)
		total += 0.2
	end

	moveToFinishedConnection:Disconnect()
	return (primaryPart.Position - position2).Magnitude, v2
end

local function jumpToZone(humanoid, primaryPart, p, probeParams, config, onJump, fn)
	local position = primaryPart.Position
	local raycastResult = Workspace:Raycast(
		position,
		Vector3.new(0, -config.npcJumpLandProbeDepthStuds, 0),
		probeParams
	)
	local v

	if raycastResult then
		v = position.Y - raycastResult.Position.Y
	else
		v = primaryPart.Size.Y * 0.5 + humanoid.HipHeight
	end

	local v2 = randomPointInZone(p, position.Y)
	local raycastResult2 = Workspace:Raycast(
		Vector3.new(v2.X, p.Position.Y + config.npcJumpLandProbeHeightStuds, v2.Z),
		Vector3.new(0, -(config.npcJumpLandProbeHeightStuds + config.npcJumpLandProbeDepthStuds), 0),
		probeParams
	)
	local v3

	if raycastResult2 then
		v3 = raycastResult2.Position.Y
	else
		v3 = p.Position.Y
	end

	local vector3 = Vector3.new(v2.X, v3 + v, v2.Z)
	local color

	if raycastResult2 then
		color = raycastResult2.Instance.Color
	end

	local rotation = CFrame.lookAt(position, (Vector3.new(vector3.X, position.Y, vector3.Z))).Rotation
	local autoRotate = humanoid.AutoRotate
	humanoid.AutoRotate = false
	humanoid:Move(createVector(0, 0, 0))
	primaryPart.Anchored = true

	if onJump then
		onJump(position, vector3, config.npcJumpAirtimeSeconds, config.npcJumpPeakHeightStuds, color)
	end

	local v4 = os.clock() + config.npcJumpAirtimeSeconds + 0.2

	while fn() and os.clock() < v4 do
		task.wait(0.1)
	end

	primaryPart.CFrame = CFrame.new(vector3) * rotation
	primaryPart.Anchored = false
	primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoid.AutoRotate = autoRotate
end

return {
	start = function(data)
		assert(RunService:IsServer(), "AllanBossRoom.Movement.start is server-only")
		local flag = true
		local logger = data.logger

		local function fn()
			return flag
		end

		local v = nil
		local v2 = nil
		local thread = task.spawn(function()
			while flag do
				local rig = data.getRig()
				local zones = data.getZones()
				local humanoid

				if rig then
					humanoid = rig:FindFirstChildOfClass("Humanoid")
				end

				local primaryPart

				if rig then
					primaryPart = rig.PrimaryPart or rig:FindFirstChild("HumanoidRootPart")
				end

				if rig and humanoid and primaryPart and primaryPart:IsA("BasePart") and #zones >= 1 then
					if rig ~= v then
						prepareRig(rig, humanoid)
						v = rig
					end

					humanoid.WalkSpeed = data.config.npcWalkSpeed
					local probeParams = buildProbeParams(rig, zones, data.config.npcFloorHazardTag)

					if not (v2 and v2.Parent) then
						v2 = nearestZone(primaryPart.Position, zones)
					end

					local v3 = v2
					local v4 = os.clock() + randomInRange(
						data.config.npcZoneDwellMinSeconds,
						data.config.npcZoneDwellMaxSeconds
					)

					while flag and os.clock() < v4 do
						local v6, v7 = walkStep(
							humanoid,
							primaryPart,
							randomPointInZone(v3, primaryPart.Position.Y),
							data.config.npcMoveTimeoutSeconds,
							fn
						)

						if logger and v6 < 1 and not v7 then
							logger:warn(`wander: in-zone step moved only {string.format("%.1f", v6)} studs — ` .. "rig anchored, boxed in by a barrier, or the Humanoid can't walk")
						end

						local isTaunting = data.isTaunting

						if isTaunting then
							while flag and isTaunting() do
								task.wait(0.2)
							end
						else
							task.wait(data.config.npcWanderPointPauseSeconds)
						end
					end

					local isTaunting = data.isTaunting

					if isTaunting then
						while flag and isTaunting() do
							task.wait(0.2)
						end
					end

					local v5

					if flag then
						v5 = pickNextZone(zones, v3)
					end

					if v5 then
						jumpToZone(humanoid, primaryPart, v5, probeParams, data.config, data.onJump, fn)
						v2 = v5
					end
				else
					task.wait(1)
				end
			end
		end)
		return {
			stop = function()
				if not flag then
					return
				end

				flag = false
				pcall(task.cancel, thread)
			end
		}
	end
}