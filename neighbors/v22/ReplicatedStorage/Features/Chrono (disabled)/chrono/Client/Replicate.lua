local createVector = vector.create
local shared = script.Parent.Parent.Shared
local RunService = game:GetService("RunService")
local Warn = require(shared.Warn)
local Stats = require(script.Parent.Parent.Shared.Stats)
local ApplyMounts = require(script.Parent.Parent.Shared.ApplyMounts)
local ClientClock = require(script.Parent.ClientClock)
local ModelResolver = require(script.Parent.ModelResolver)
local Entity = require(shared.Entity)
local Holder = require(shared.Holder)
local Config = require(shared.Config)
require(shared.Types)
local Sender = require(script.Parent.Sender)
local Stats2 = require(shared.Stats)
local CLIENT = Stats2.CLIENT
require(script.Parent.Player)
require(script.Parent.Receiver)
local idMap = Holder.idMap
local lookVector = createVector(0, 0, -1)
local rightVector = createVector(1, 0, 0)
local upVector = createVector(0, 1, 0)
local position = createVector(0, 0, 0)
local v = 0
local v2 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function PrepareFrustumCheck()
	local cFrame = workspace.CurrentCamera.CFrame
	lookVector = cFrame.LookVector
	rightVector = cFrame.RightVector
	upVector = cFrame.UpVector
	position = cFrame.Position
	local currentCamera = workspace.CurrentCamera
	local v3 = math.rad(currentCamera.FieldOfView / 2)
	local v4 = currentCamera.ViewportSize.X / currentCamera.ViewportSize.Y
	v = math.tan(v3) * v4
	v2 = math.tan(v3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CheckPointInFrustum(vector2: Vector3)
	local v3 = vector2 - position
	local v4 = vector.magnitude(v3)

	if v4 == 0 then
		return true
	end

	local v5 = vector.dot(v3, lookVector)
	local v6 = v5 / v4

	if v6 < 0 then
		return false
	end

	if v5 < 1 then
		return true
	end

	local v7 = v3 / v4
	local v8 = math.abs((vector.dot(v7, rightVector)))

	if v6 * v < v8 then
		return false
	end

	local v9 = math.abs((vector.dot(v7, upVector)))
	return not (v6 * v2 < v9)
end

local function CheckBroadPhaseInFrustum(position2: Vector3, broadPhase: Vector3)
	if broadPhase == createVector(0, 0, 0) then
		local v3 = position2 - position
		local v4 = vector.magnitude(v3)

		if v4 == 0 then
			return true
		end

		local v5 = vector.dot(v3, lookVector)
		local v6 = v5 / v4

		if v6 < 0 then
			return false
		end

		if v5 < 1 then
			return true
		end

		local v7 = v3 / v4
		local v8 = math.abs((vector.dot(v7, rightVector)))

		if v6 * v < v8 then
			return false
		end

		local v9 = math.abs((vector.dot(v7, upVector)))
		return not (v6 * v2 < v9)
	else
		local v3 = broadPhase * 0.5
		local x = v3.x
		local y = v3.y
		local z = v3.z
		local v4 = -x
		local v5 = -y
		local v6 = -z
		local checkPointInFrustum = CheckPointInFrustum(position2 + vector.create(x, y, z)) -- equivalent call inferred; original call site unknown

		if checkPointInFrustum then
			return checkPointInFrustum
		end

		local v8 = position2 + vector.create(v4, y, z) - position
		local v9 = vector.magnitude(v8)

		if v9 == 0 then
			checkPointInFrustum = true
		else
			local v10 = vector.dot(v8, lookVector)
			local v11 = v10 / v9

			if v11 < 0 then
				checkPointInFrustum = false
			elseif v10 < 1 then
				checkPointInFrustum = true
			else
				local v12 = v8 / v9
				local v13 = math.abs((vector.dot(v12, rightVector)))

				if v11 * v < v13 then
					checkPointInFrustum = false
				else
					local v14 = math.abs((vector.dot(v12, upVector)))
					checkPointInFrustum = not (v11 * v2 < v14)
				end
			end
		end

		if checkPointInFrustum then
			return checkPointInFrustum
		end

		local v10 = position2 + vector.create(x, v5, z) - position
		local v11 = vector.magnitude(v10)

		if v11 == 0 then
			checkPointInFrustum = true
		else
			local v12 = vector.dot(v10, lookVector)
			local v13 = v12 / v11

			if v13 < 0 then
				checkPointInFrustum = false
			elseif v12 < 1 then
				checkPointInFrustum = true
			else
				local v14 = v10 / v11
				local v15 = math.abs((vector.dot(v14, rightVector)))

				if v13 * v < v15 then
					checkPointInFrustum = false
				else
					local v16 = math.abs((vector.dot(v14, upVector)))
					checkPointInFrustum = not (v13 * v2 < v16)
				end
			end
		end

		if checkPointInFrustum then
			return checkPointInFrustum
		end

		local v12 = position2 + vector.create(v4, v5, z) - position
		local v13 = vector.magnitude(v12)

		if v13 == 0 then
			checkPointInFrustum = true
		else
			local v14 = vector.dot(v12, lookVector)
			local v15 = v14 / v13

			if v15 < 0 then
				checkPointInFrustum = false
			elseif v14 < 1 then
				checkPointInFrustum = true
			else
				local v16 = v12 / v13
				local v17 = math.abs((vector.dot(v16, rightVector)))

				if v15 * v < v17 then
					checkPointInFrustum = false
				else
					local v18 = math.abs((vector.dot(v16, upVector)))
					checkPointInFrustum = not (v15 * v2 < v18)
				end
			end
		end

		if checkPointInFrustum then
			return checkPointInFrustum
		end

		local v14 = position2 + vector.create(x, y, v6) - position
		local v15 = vector.magnitude(v14)

		if v15 == 0 then
			checkPointInFrustum = true
		else
			local v16 = vector.dot(v14, lookVector)
			local v17 = v16 / v15

			if v17 < 0 then
				checkPointInFrustum = false
			elseif v16 < 1 then
				checkPointInFrustum = true
			else
				local v18 = v14 / v15
				local v19 = math.abs((vector.dot(v18, rightVector)))

				if v17 * v < v19 then
					checkPointInFrustum = false
				else
					local v20 = math.abs((vector.dot(v18, upVector)))
					checkPointInFrustum = not (v17 * v2 < v20)
				end
			end
		end

		if checkPointInFrustum then
			return checkPointInFrustum
		end

		local v16 = position2 + vector.create(v4, y, v6) - position
		local v17 = vector.magnitude(v16)

		if v17 == 0 then
			checkPointInFrustum = true
		else
			local v18 = vector.dot(v16, lookVector)
			local v19 = v18 / v17

			if v19 < 0 then
				checkPointInFrustum = false
			elseif v18 < 1 then
				checkPointInFrustum = true
			else
				local v20 = v16 / v17
				local v21 = math.abs((vector.dot(v20, rightVector)))

				if v19 * v < v21 then
					checkPointInFrustum = false
				else
					local v22 = math.abs((vector.dot(v20, upVector)))
					checkPointInFrustum = not (v19 * v2 < v22)
				end
			end
		end

		if checkPointInFrustum then
			return checkPointInFrustum
		end

		local v18 = position2 + vector.create(x, v5, v6) - position
		local v19 = vector.magnitude(v18)

		if v19 == 0 then
			checkPointInFrustum = true
		else
			local v20 = vector.dot(v18, lookVector)
			local v21 = v20 / v19

			if v21 < 0 then
				checkPointInFrustum = false
			elseif v20 < 1 then
				checkPointInFrustum = true
			else
				local v22 = v18 / v19
				local v23 = math.abs((vector.dot(v22, rightVector)))

				if v21 * v < v23 then
					checkPointInFrustum = false
				else
					local v24 = math.abs((vector.dot(v22, upVector)))
					checkPointInFrustum = not (v21 * v2 < v24)
				end
			end
		end

		if checkPointInFrustum then
			return checkPointInFrustum
		end

		local v20 = position2 + vector.create(v4, v5, v6) - position
		local v21 = vector.magnitude(v20)

		if v21 == 0 then
			return true
		end

		local v22 = vector.dot(v20, lookVector)
		local v23 = v22 / v21

		if v23 < 0 then
			return false
		end

		if v22 < 1 then
			return true
		end

		local v24 = v20 / v21
		local v25 = math.abs((vector.dot(v24, rightVector)))

		if v23 * v < v25 then
			return false
		end

		local v26 = math.abs((vector.dot(v24, upVector)))

		if v23 * v2 < v26 then
			return false
		end

		checkPointInFrustum = true
		return true
	end
end

local count = 0
local count2 = 0
local total = 0
local count3 = 0
local count4 = 0
local count5 = 0
local count6 = 0

local function Interpolate(state)
	local entityConfig = state.entityConfig

	if not state.interpolation or entityConfig.CUSTOM_INTERPOLATION then
		return
	end

	local primaryPart = Entity.GetPrimaryPart(state)

	if not primaryPart or state.isContextOwner then
		return
	end

	if entityConfig.ASSEMBLY_ROOT_PART_CHECK and primaryPart.AssemblyRootPart ~= primaryPart then
		Warn.low("Primary part for entity " .. state.id .. " is not the assembly root part. Skipping interpolation for this entity.")
		return
	end

	local _outofBroadPhaseTick = state._outofBroadPhaseTick

	if _outofBroadPhaseTick and _outofBroadPhaseTick ~= count2 then
		return
	end

	local snapshot = state.snapshot

	if not snapshot then
		Warn.medium("No snapshot for entity", state)
		return
	end

	count4 += 1
	debug.profilebegin("Get Render CFrame")
	local at = snapshot:GetAt((Entity.GetTargetRenderTime(state)))
	debug.profileend()

	if not at then
		return
	end

	local broadPhase = state.broadPhase

	if broadPhase then
		local lastCheckedCFrame = state.lastCheckedCFrame
		debug.profilebegin("Prepare Frustum")
		local checkBroadPhaseInFrustum = CheckBroadPhaseInFrustum(at.Position, broadPhase)
		debug.profileend()

		if not checkBroadPhaseInFrustum then
			if lastCheckedCFrame and lastCheckedCFrame.Position ~= at.Position then
				debug.profilebegin("Check Last CFrame")
				local checkBroadPhaseInFrustum2 = CheckBroadPhaseInFrustum(lastCheckedCFrame.Position, broadPhase)
				debug.profileend()

				if not checkBroadPhaseInFrustum2 then
					count5 += 1
					return
				end
			else
				if not lastCheckedCFrame then
					state.lastCheckedCFrame = at
				end

				if not state._outofBroadPhaseTick then
					state._outofBroadPhaseTick = count
					count += 1

					if count % 4 == 0 then
						count = 0
					end
				end

				count5 += 1
				return
			end
		end

		state.lastCheckedCFrame = nil
		state._outofBroadPhaseTick = nil
	end

	debug.profilebegin("Set CFrame")

	if at == at then
		primaryPart.CFrame = at
	end

	count6 += 1
	debug.profileend()
end

local function updateEntityStats()
	if not Stats.SERVER._SHOULD_REPLICATE or CLIENT._PAUSE then
		return
	end

	local v3 = {}

	for _, entity in idMap do
		local id = entity.id
		local entityConfig = entity.entityConfig
		local NAME = entityConfig and entityConfig.NAME or "DEFAULT"
		local networkOwner = entity.networkOwner
		local isCharacter = entity._player ~= nil
		local latestTime = entity.latestTime or 0
		local lastReplicatedTime = entity.lastReplicatedTime or 0
		local _clientClock = entity._clientClock

		if not _clientClock then
			local CLIENT_CLOCK = entity.entityConfig.CLIENT_CLOCK

			if CLIENT_CLOCK then
				_clientClock = entity.isHalfTicked and CLIENT_CLOCK.HALF or CLIENT_CLOCK.NORMAL
			end
		end

		local averageLatency = 0
		local deviation = 0
		local targetRenderTime, bufferedTime

		if _clientClock then
			targetRenderTime = _clientClock:GetTargetRenderTime()
			local buffer = _clientClock.buffer

			if buffer then
				averageLatency = buffer.averageLatency
				deviation = buffer.deviation
			end

			bufferedTime = ClientClock._getBuffer(_clientClock)
		else
			targetRenderTime = 0
			bufferedTime = 0
		end

		local primaryPart = Entity.GetPrimaryPart(entity)
		local snapshot = entity.snapshot
		local position2 = primaryPart and primaryPart.Position
		local snapshots = {}

		if snapshot then
			for _, v8 in snapshot.cache do
				table.insert(snapshots, {
					t = v8.t,
					value = v8.value,
					velocity = v8.velocity
				})
			end

			table.sort(snapshots, function(a, b)
				return a.t > b.t
			end)
		end

		table.insert(v3, {
			id = id,
			entity = entity,
			networkOwner = networkOwner,
			isCharacter = isCharacter,
			config = NAME,
			lastReceivedTime = latestTime,
			lastReplicatedTime = lastReplicatedTime,
			targetTime = targetRenderTime,
			averageLatency = averageLatency,
			deviation = deviation,
			bufferedTime = bufferedTime,
			currentPosition = position2,
			snapshots = snapshots
		})
	end

	CLIENT.CLIENT_ENTITIES = v3
end

Config._WaitForLock(function()
	RunService.Heartbeat:Connect(function(dt: number)
		count2 += 1

		if count2 % 4 == 0 then
			CLIENT.TOTAL_ENTITIES_CULLED = count5
			count5 = 0
			count2 = 0
		end

		ClientClock.UpdateAll(dt)
		debug.profilebegin("Prepare Frustum Check")
		PrepareFrustumCheck() -- equivalent call inferred; original call site unknown
		debug.profileend()
		local now = os.clock()
		debug.profilebegin("Interpolate Entities")
		local count7 = 0

		for _, v3 in idMap do
			ModelResolver(v3)

			if v3.destroyed or v3.paused or v3.mountParentId then
				continue
			end

			count7 += 1
			Interpolate(v3)
		end

		debug.profileend()
		local now2 = os.clock()
		debug.profilebegin("Update Entity Stats")
		updateEntityStats()
		debug.profileend()
		total += now2 - now
		count3 += 1
		ApplyMounts()

		if not CLIENT._PAUSE then
			CLIENT.TOTAL_CLIENT_ENTITIES_CHECKED_THIS_FRAME = count7
			CLIENT.ENTITIES_MOVED_THIS_FRAME = count6
			CLIENT.TOTAL_CLIENT_ENTITIES = count7
			CLIENT.AVG_INTERPOLATION_TIME_MS = total / count3 * 1000
		end

		count6 = 0
		count4 = 0

		if count3 > 60 then
			total = 0
			count3 = 0
		end
	end)
	RunService.Heartbeat:Connect(Sender.Update)
	local clientHeartbeat = shared.Remotes.ClientHeartbeat
	clientHeartbeat:FireServer(os.clock())
	local total2 = 0
	RunService.Heartbeat:Connect(function(dt: number)
		total2 += dt

		if total2 >= 15 then
			total2 = 0
			clientHeartbeat:FireServer(os.clock())
		end
	end)
	shared.Remotes.ClientLoaded:FireServer()
end)
return nil