local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- equivalent calls inferred from this helper; original call sites unknown
local function tagPart(part, p, tag: string)
	p[part] = true

	if not CollectionService:HasTag(part, tag) then
		CollectionService:AddTag(part, tag)
	end

	if not part.CanQuery then
		part.CanQuery = true
	end
end

local function tagUntaggedParts(folder, p, keycapTag: string)
	local count = 0

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or p[part] then
			continue
		end

		tagPart(part, p, keycapTag) -- equivalent call inferred; original call site unknown
		count += 1
	end

	return count
end

local function getRigFootSweep(instance, p: number)
	local boundingBox, v = instance:GetBoundingBox()
	return boundingBox.Position - Vector3.new(0, v.Y * 0.5, 0), p + math.max(v.X, v.Z) * 0.5
end

local function hideNearPosition(vector: Vector3, p: number, overlapParams, config)
	for _, instance in Workspace:GetPartBoundsInRadius(vector, p, overlapParams) do
		if not CollectionService:HasTag(instance, config.keycapTag) or CollectionService:HasTag(
			instance,
			config.keycapHiddenTag
		) then
			continue
		end

		CollectionService:AddTag(instance, config.keycapHiddenTag)
	end
end

local function restoreNearPosition(vector: Vector3, p: number, overlapParams, config)
	local count = 0

	for _, instance in Workspace:GetPartBoundsInRadius(vector, p, overlapParams) do
		if not CollectionService:HasTag(instance, config.keycapHiddenTag) then
			continue
		end

		CollectionService:RemoveTag(instance, config.keycapHiddenTag)
		count += 1
	end

	return count
end

return {
	setup = function(data)
		assert(RunService:IsServer(), "AllanBossRoom.Keycaps.setup is server-only")
		local config = data.config
		local logger = data.logger
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		local v = {}
		local v2 = nil
		local descendantAddedConnection = nil
		local total = 0
		local total2 = 0
		local total3 = 0

		local function syncFolder()
			local keycapsFolder = data.getKeycapsFolder()

			if not keycapsFolder then
				return nil
			end

			if keycapsFolder == v2 then
				return keycapsFolder
			end

			v2 = keycapsFolder
			total = 0
			table.clear(v)
			overlapParams.FilterDescendantsInstances = { keycapsFolder }

			if descendantAddedConnection then
				descendantAddedConnection:Disconnect()
			end

			descendantAddedConnection = keycapsFolder.DescendantAdded:Connect(function(part)
				if part:IsA("BasePart") and not v[part] then
					tagPart(part, v, config.keycapTag) -- equivalent call inferred; original call site unknown
					total += 1
				end
			end)
			total += tagUntaggedParts(keycapsFolder, v, config.keycapTag)

			if logger and total == 0 then
				logger:warn((`keycaps: folder '{keycapsFolder:GetFullName()}' has no BaseParts yet — waiting for geometry`))
			end

			return keycapsFolder
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			if not syncFolder() then
				return
			end

			total2 += dt

			if total2 >= config.restoreCheckIntervalSeconds then
				total2 = 0

				for _, v3 in Players:GetPlayers() do
					local character = v3.Character
					local humanoidRootPart

					if character then
						humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					end

					if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
						continue
					end

					local v4 = restoreNearPosition(
						humanoidRootPart.Position,
						config.restoreRadiusStuds,
						overlapParams,
						config
					)

					if v4 > 0 and data.onPlayerRestoredKeycaps then
						data.onPlayerRestoredKeycaps(v3, v4)
					end
				end
			end

			total3 += dt

			if total3 >= config.hideTickSeconds then
				total3 = 0
				local lokiiRig = data.getLokiiRig()

				if lokiiRig then
					local hideRadiusStuds = config.hideRadiusStuds
					local boundingBox, v3 = lokiiRig:GetBoundingBox()
					hideNearPosition(
						boundingBox.Position - Vector3.new(0, v3.Y * 0.5, 0),
						hideRadiusStuds + math.max(v3.X, v3.Z) * 0.5,
						overlapParams,
						config
					)
				end

				local allanRig = data.getAllanRig()

				if allanRig then
					local repairRadiusStuds = config.repairRadiusStuds
					local boundingBox, v3 = allanRig:GetBoundingBox()
					restoreNearPosition(
						boundingBox.Position - Vector3.new(0, v3.Y * 0.5, 0),
						repairRadiusStuds + math.max(v3.X, v3.Z) * 0.5,
						overlapParams,
						config
					)
				end
			end
		end)
		return {
			stop = function()
				heartbeatConnection:Disconnect()

				if descendantAddedConnection then
					descendantAddedConnection:Disconnect()
					descendantAddedConnection = nil
				end

				for _, instance in CollectionService:GetTagged(config.keycapHiddenTag) do
					CollectionService:RemoveTag(instance, config.keycapHiddenTag)
				end

				table.clear(v)
			end
		}
	end
}