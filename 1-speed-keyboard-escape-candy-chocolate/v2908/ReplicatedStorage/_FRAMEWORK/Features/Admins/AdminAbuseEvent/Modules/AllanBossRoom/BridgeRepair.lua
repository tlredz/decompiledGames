local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
require(script.Parent.Bridges)

local function getAliveRootPosition(player)
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
		return humanoidRootPart.Position
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isWithinAnyRing(vector: Vector3, ringPositions, ringRadiusStuds: number)
	for _, item in ringPositions do
		local v = vector - item

		if Vector3.new(v.X, 0, v.Z).Magnitude <= ringRadiusStuds then
			return true
		end
	end

	return false
end

return {
	start = function(data)
		assert(RunService:IsServer(), "AllanBossRoom.BridgeRepair.start is server-only")
		local config = data.config
		local isPlayerEligible = data.isPlayerEligible
		local v = {}
		local v2 = {}

		local function spawnRingsFor(p)
			v[p.id] = {
				ringPositions = p.ringPositions,
				lastProgressSent = -1,
				lastProgressClock = 0
			}

			for k, ringPosition in p.ringPositions do
				data.sendRingSpawn(p.id, k, ringPosition, config.ringRadiusStuds)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function despawnRingsFor(p: string)
			if v[p] then
				v[p] = nil
				data.sendRingDespawn(p)
			end
		end

		local function syncActiveRepairs(bridges)
			local v3 = {}

			for _, v4 in bridges.getRepairableUnits() do
				v3[v4.id] = true

				if not v[v4.id] then
					spawnRingsFor(v4)
				end
			end

			for k in v do
				if v3[k] or not v[k] then
					continue
				end

				v[k] = nil
				data.sendRingDespawn(k)
			end
		end

		local function collectEligiblePositions()
			local aliveRootPositions = {}

			for _, v3 in Players:GetPlayers() do
				local aliveRootPosition = getAliveRootPosition(v3)

				if aliveRootPosition and (isPlayerEligible == nil or isPlayerEligible(v3)) then
					aliveRootPositions[v3] = aliveRootPosition
				end
			end

			return aliveRootPositions
		end

		local function advanceRepair(p, k: string, state, count: number, p2: number, now: number)
			local v3 = 1 / config.fullRepairSecondsOnePlayer * ((count - 1) * config.extraPlayerRateFactor + 1)
			local lastProgressSent, v5 = p.addRepairProgress(k, v3 * p2)

			if v5 then
				despawnRingsFor(k) -- equivalent call inferred; original call site unknown
			elseif lastProgressSent - state.lastProgressSent >= 0.01 or now - state.lastProgressClock >= config.progressReplicationIntervalSeconds then
				state.lastProgressSent = lastProgressSent
				state.lastProgressClock = now
				data.sendRingProgress(k, lastProgressSent)
			end
		end

		local function runRepairTick(bridges, p: number)
			local now = os.clock()
			local v3 = collectEligiblePositions()

			for k, v4 in v do
				local count = 0

				for k2, v5 in v3 do
					-- equivalent call inferred; original call site unknown
					if not isWithinAnyRing(v5, v4.ringPositions, config.ringRadiusStuds) then
						continue
					end

					count += 1
					local v6 = v2[k2]

					if not (not v6 or now - v6 >= config.winAwardIntervalSeconds) then
						continue
					end

					v2[k2] = now
					data.awardWin(k2)
				end

				if count > 0 then
					advanceRepair(bridges, k, v4, count, p, now)
				end
			end
		end

		local function tick(p: number)
			local bridges = data.getBridges()

			if not bridges then
				return
			end

			syncActiveRepairs(bridges)

			if next(v) ~= nil then
				runRepairTick(bridges, p)
			end
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(tick)
		local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
			v2[player] = nil
		end)
		return {
			resync = function()
				for k, v3 in v do
					for k2, ringPosition in v3.ringPositions do
						data.sendRingSpawn(k, k2, ringPosition, config.ringRadiusStuds)
					end
				end

				local bridges = data.getBridges()

				if bridges then
					for _, v3 in bridges.getRepairableUnits() do
						if v[v3.id] then
							data.sendRingProgress(v3.id, v3.progress)
						end
					end
				end
			end,
			stop = function()
				heartbeatConnection:Disconnect()
				playerRemovingConnection:Disconnect()

				for k in v do
					data.sendRingDespawn(k)
				end

				table.clear(v)
				table.clear(v2)
			end
		}
	end
}