local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.Config)
require(script.Parent.Types)

local function assembleTree(folder, primaryPart)
	local parts = {}
	local parts2 = {}

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false

		if part == primaryPart then
			continue
		end

		part.Anchored = false
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = primaryPart
		weldConstraint.Part1 = part
		weldConstraint.Parent = part
		local v = not part.Parent and "" or part.Parent.Name

		if v == "Leaves" then
			table.insert(parts2, part)
		elseif v == "SubLogs" then
			table.insert(parts, part)
		end
	end

	table.sort(parts2, function(a, b)
		return a.Position.Y < b.Position.Y
	end)
	table.sort(parts, function(a, b)
		return a.Position.Y < b.Position.Y
	end)
	primaryPart.Anchored = true
	return parts2, parts
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyCharred(p)
	p.Color = Config.charredColor
	p.Material = Config.charredMaterial
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shedPart(p, flag: boolean, shedFolder)
	if flag then
		applyCharred(p) -- equivalent call inferred; original call site unknown
	end

	p.Parent = shedFolder
end

return {
	start = function(data)
		local template = data.template
		local zones = data.zones
		local awardChop = data.awardChop
		local awardFell = data.awardFell
		local v = {}
		local random = Random.new()
		local now = os.clock()
		local flag = false
		local folder = Instance.new("Folder")
		folder.Name = Config.treesFolderName
		folder.Parent = data.mapParent

		local function buildRaycastParams()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local characters = { folder }

			for _, v2 in Players:GetPlayers() do
				local character = v2.Character

				if character then
					table.insert(characters, character)
				end
			end

			raycastParams.FilterDescendantsInstances = characters
			return raycastParams
		end

		local function isPositionClear(position: Vector3)
			local v2 = true

			for _, v3 in v do
				local v4 = v3.trunk.Position - position

				if Vector2.new(v4.X, v4.Z).Magnitude < Config.minTreeSeparationStuds then
					v2 = false
				end
			end

			for _, v3 in Players:GetPlayers() do
				local character = v3.Character
				local humanoidRootPart

				if character then
					humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				end

				if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
					continue
				end

				local v4 = humanoidRootPart.Position - position

				if Vector2.new(v4.X, v4.Z).Magnitude < Config.minPlayerSeparationStuds then
					v2 = false
				end
			end

			return v2
		end

		local function pickSpawnPosition()
			local raycastParams = buildRaycastParams()

			for _ = 1, Config.spawnAttempts do
				local zone = zones[random:NextInteger(1, #zones)]
				local v2 = math.max(0, zone.Size.X * 0.5 - Config.zoneEdgeMarginStuds)
				local v3 = math.max(0, zone.Size.Z * 0.5 - Config.zoneEdgeMarginStuds)
				local vector = Vector3.new(
					random:NextNumber(-v2, v2),
					Config.raycastHeightStuds,
					random:NextNumber(-v3, v3)
				)
				local raycastResult = Workspace:Raycast(
					(zone.CFrame * CFrame.new(vector)).Position,
					Vector3.new(0, -Config.raycastDepthStuds, 0),
					raycastParams
				)

				if raycastResult and isPositionClear(raycastResult.Position) then
					return raycastResult.Position
				end
			end

			return nil
		end

		local function spawnTree(vector: Vector3)
			local clone = template:Clone()
			local primaryPart = clone.PrimaryPart
			local leaves, subLogs = assembleTree(clone, primaryPart)
			local folder2 = Instance.new("Folder")
			folder2.Name = Config.shedFolderName
			folder2.Parent = clone
			clone.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
			local v4 = clone:GetBoundingBox().Position.Y - clone:GetExtentsSize().Y * 0.5
			local v5 = clone:GetPivot().Position.Y - v4
			clone:PivotTo(CFrame.new(vector + Vector3.new(0, v5, 0)) * CFrame.Angles(
				0,
				random:NextNumber(0, 6.283185307179586),
				0
			))
			clone.Parent = folder
			local highlight = clone:FindFirstChildOfClass("Highlight")

			if highlight then
				highlight.Enabled = true
			end

			table.insert(v, {
				model = clone,
				trunk = primaryPart,
				highlight = highlight,
				shedFolder = folder2,
				leaves = leaves,
				subLogs = subLogs,
				hitPointsLeft = Config.treeHitPoints,
				contributors = {},
				spawnedAt = os.clock(),
				felling = false
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function removeTree(p)
			local index = table.find(v, p)

			if index then
				table.remove(v, index)
			end

			p.model:Destroy()
		end

		local function shedOnHit(data2)
			local v2 = #data2.leaves + #data2.subLogs

			for _ = 1, math.min(v2, (math.ceil(v2 / (data2.hitPointsLeft + 1)))) do
				if #data2.leaves > 0 then
					local remove = table.remove(data2.leaves)
					remove.Parent = data2.shedFolder
				else
					shedPart(table.remove(data2.subLogs), true, data2.shedFolder) -- equivalent call inferred; original call site unknown
				end
			end

			if #data2.leaves == 0 then
				applyCharred(data2.trunk) -- equivalent call inferred; original call site unknown
			end
		end

		local function fellTree(data2)
			local highlight = data2.highlight

			if highlight then
				highlight.Enabled = false
			end

			for k in data2.contributors do
				if k.Parent == Players then
					awardFell(k)
				end
			end

			data2.model:SetAttribute(Config.fallYawAttributeName, random:NextNumber(0, 6.283185307179586))
			task.delay(Config.fallDespawnDelaySeconds, function()
				if not flag then
					removeTree(data2) -- equivalent call inferred; original call site unknown
				end
			end)
		end

		local function findTargetTree(humanoidRootPart)
			local chopReachStuds = Config.chopReachStuds
			local v2 = nil

			for _, v3 in v do
				local v4 = v3.trunk.Position - humanoidRootPart.Position
				local magnitude = v4.Magnitude
				local dot = humanoidRootPart.CFrame.LookVector:Dot(v4.Unit)

				if v3.felling or not (magnitude <= chopReachStuds) or not (Config.chopFacingDot <= dot) then
					continue
				end

				v2 = v3
				chopReachStuds = magnitude
			end

			return v2
		end

		local function checkChopReady(player)
			local character = player.Character
			local humanoid

			if character then
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				local targetTree = findTargetTree(humanoidRootPart)
				return targetTree ~= nil, targetTree
			else
				return false, nil
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyChop(p, state)
			state.hitPointsLeft -= 1
			local contributor = state.contributors[p]
			state.contributors[p] = not contributor and 1 or contributor + 1
			local v2 = state.hitPointsLeft <= 0

			if v2 then
				state.felling = true
			end

			shedOnHit(state)
			awardChop(p)

			if v2 then
				fellTree(state)
			end
		end

		local function expireTrees(now2: number)
			for i = #v, 1, -1 do
				local v2 = v[i]

				if v2.felling or not (now2 - v2.spawnedAt >= Config.treeLifetimeSeconds) then
					continue
				end

				removeTree(v2) -- equivalent call inferred; original call site unknown
			end
		end

		local function spawnWave(p: number)
			for _ = 1, p do
				if not (#v < Config.maxActiveTrees) then
					continue
				end

				local v2 = pickSpawnPosition()

				if v2 then
					spawnTree(v2)
				end
			end
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			local now2 = os.clock()
			expireTrees(now2)

			if now2 - now >= Config.spawnIntervalSeconds then
				now = now2
				spawnWave(Config.treesPerWave)
			end
		end)
		spawnWave(Config.initialTrees)
		return {
			chop = function(p)
				if flag then
					return
				end

				local v2, v3 = checkChopReady(p)

				if v2 then
					applyChop(p, v3) -- equivalent call inferred; original call site unknown
				end
			end,
			stop = function()
				flag = true
				heartbeatConnection:Disconnect()

				for i = #v, 1, -1 do
					removeTree(v[i]) -- equivalent call inferred; original call site unknown
				end

				folder:Destroy()
			end
		}
	end
}