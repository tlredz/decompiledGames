local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.Config)
require(script.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureCollisionGroup(p: string)
	if not PhysicsService:IsCollisionGroupRegistered(p) then
		PhysicsService:RegisterCollisionGroup(p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function configureCollisionGroups()
	ensureCollisionGroup(Config.collisionGroupName) -- equivalent call inferred; original call site unknown
	ensureCollisionGroup(Config.playerCollisionGroupName) -- equivalent call inferred; original call site unknown
	PhysicsService:CollisionGroupSetCollidable(Config.collisionGroupName, Config.playerCollisionGroupName, false)
end

local function prepareTemplate(template)
	local clone = template:Clone()

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CollisionGroup = Config.collisionGroupName
		elseif descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		end
	end

	local humanoid = clone:FindFirstChildOfClass("Humanoid")

	if not humanoid:FindFirstChildOfClass("Animator") then
		local animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	clone.PrimaryPart = clone:FindFirstChild("HumanoidRootPart")
	return clone
end

local function getGroundPoint(zone, random, raycastParams)
	local v = zone.Size * 0.5
	local number = random:NextNumber(-v.X, v.X)
	local number2 = random:NextNumber(-v.Z, v.Z)
	local raycastResult = Workspace:Raycast(
		zone.CFrame:PointToWorldSpace((Vector3.new(number, v.Y, number2))),
		Vector3.new(0, -(zone.Size.Y + Config.groundProbeExtraStuds), 0),
		raycastParams
	)

	if raycastResult then
		return raycastResult.Position
	end

	return zone.CFrame:PointToWorldSpace((Vector3.new(number, -v.Y, number2)))
end

local function isWandererAlive(data)
	return data.model.Parent ~= nil and data.root.Parent ~= nil and data.humanoid.Health > 0
end

return {
	start = function(data)
		local random = Random.new()
		local count = data.count or Config.count
		local topUpIntervalSeconds = data.topUpIntervalSeconds or Config.topUpIntervalSeconds
		local v = {}
		local v2 = {}
		configureCollisionGroups() -- equivalent call inferred; original call site unknown

		for _, template in data.templates do
			table.insert(v2, (prepareTemplate(template)))
		end

		local folder = Instance.new("Folder")
		folder.Name = Config.containerName
		folder.Parent = data.parent
		local zones = { folder }

		for _, zone in data.zones do
			table.insert(zones, zone)
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = zones

		local function pauseDuration()
			return random:NextNumber(Config.minPauseSeconds, Config.maxPauseSeconds)
		end

		local function spawnWanderer()
			local zone = data.zones[random:NextInteger(1, #data.zones)]
			local clone = v2[random:NextInteger(1, #v2)]:Clone()
			local humanoid = clone:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
			local v3 = getGroundPoint(zone, random, raycastParams) + Vector3.new(0, Config.rootFloorOffsetStuds, 0)
			humanoid.WalkSpeed = random:NextNumber(Config.minWalkSpeed, Config.maxWalkSpeed) * data.walkSpeedMultiplier
			clone:PivotTo(CFrame.new(v3) * CFrame.Angles(0, random:NextNumber(0, 6.283185307179586), 0))
			clone.Parent = folder
			humanoidRootPart:SetNetworkOwner(nil)
			CollectionService:AddTag(clone, Config.tagName)
			table.insert(v, {
				model = clone,
				humanoid = humanoid,
				root = humanoidRootPart,
				zone = zone,
				target = nil,
				resumeAt = os.clock() + random:NextNumber(0, Config.maxPauseSeconds),
				refreshAt = 0,
				deadline = 0
			})
		end

		local function startWalking(state, p: number)
			local groundPoint = getGroundPoint(state.zone, random, raycastParams)
			local magnitude = (groundPoint - state.root.Position).Magnitude
			state.target = groundPoint
			state.refreshAt = p + Config.moveRefreshSeconds
			state.deadline = p + magnitude / state.humanoid.WalkSpeed * Config.stuckTimeoutFactor + Config.stuckTimeoutPaddingSeconds
			state.humanoid:MoveTo(groundPoint)
			state.model:SetAttribute(Config.movingAttribute, true)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopWalking(state, p: number)
			state.target = nil
			state.resumeAt = p + random:NextNumber(Config.minPauseSeconds, Config.maxPauseSeconds)
			state.humanoid:MoveTo(state.root.Position)
			state.model:SetAttribute(Config.movingAttribute, false)
		end

		local function stepWanderer(state, now: number)
			local target = state.target

			if target then
				local v3 = target - state.root.Position

				if Vector3.new(v3.X, 0, v3.Z).Magnitude <= Config.arriveDistanceStuds or state.deadline <= now then
					stopWalking(state, now) -- equivalent call inferred; original call site unknown
				elseif state.refreshAt <= now then
					state.refreshAt = now + Config.moveRefreshSeconds
					state.humanoid:MoveTo(target)
				end
			elseif state.resumeAt <= now then
				startWalking(state, now)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function topUp()
			for _ = #v + 1, count do
				spawnWanderer()
			end
		end

		topUp() -- equivalent call inferred; original call site unknown
		local now = os.clock()
		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			local now2 = os.clock()

			for i = #v, 1, -1 do
				local v3 = v[i]
				local v4

				if v3.model.Parent == nil or v3.root.Parent == nil then
					v4 = false
				else
					v4 = v3.humanoid.Health > 0
				end

				if v4 then
					stepWanderer(v3, now2)
				else
					if data.onKilled and v3.humanoid.Health <= 0 then
						task.spawn(data.onKilled, v3.humanoid)
					end

					v3.model:SetAttribute(Config.movingAttribute, false)
					Debris:AddItem(v3.model, Config.deathLingerSeconds)
					table.remove(v, i)
				end
			end

			if topUpIntervalSeconds <= now2 - now then
				now = now2
				topUp() -- equivalent call inferred; original call site unknown
			end
		end)
		return function()
			heartbeatConnection:Disconnect()
			table.clear(v)

			for _, v3 in v2 do
				v3:Destroy()
			end

			table.clear(v2)
			folder:Destroy()
		end
	end
}