local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Config = require(script.Parent.Config)
require(script.Parent.Types)

local function randomPointInZone(instance, hoverHeightStuds: number, zoneEdgeMarginStuds: number)
	local v = instance.Size * 0.5
	local v2 = math.max(0, v.X - zoneEdgeMarginStuds)
	local v3 = math.max(0, v.Z - zoneEdgeMarginStuds)
	local v4 = (math.random() * 2 - 1) * v2
	local v5 = (math.random() * 2 - 1) * v3
	return (instance.CFrame * CFrame.new(v4, -v.Y + hoverHeightStuds, v5)).Position
end

local function buildZoneWeights(list, zoneEdgeMarginStuds: number)
	local result = table.create(#list)
	local total = 0

	for k, v in list do
		total += math.max(1, v.Size.X - zoneEdgeMarginStuds * 2) * math.max(1, v.Size.Z - zoneEdgeMarginStuds * 2)
		result[k] = total
	end

	return result, total
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pickWeightedZone(list, items, p: number)
	local v = math.random() * p

	for k, item in items do
		if v < item then
			return list[k]
		end
	end

	return list[#list]
end

local function distanceToNearestSquared(vector: Vector3, positions)
	local v = 1e999

	for _, item in positions do
		local vector2 = vector - item
		local dot = vector2:Dot(vector2)

		if dot < v then
			v = dot
		end
	end

	return v
end

local function getAliveRoot(player)
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
		return humanoidRootPart
	end

	return nil
end

return {
	start = function(data)
		assert(RunService:IsServer(), "floatingOrbWins.Server.start is server-only")
		local resolved = Config.resolve(data.config)
		local logger = data.logger
		local isPlayerEligible = data.isPlayerEligible
		local v = {}
		local v2 = {}
		local v3 = {}
		local v4 = {}
		local total = 0
		local spawnIntervalMinSeconds = resolved.spawnIntervalMinSeconds
		local now = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rollSpawnInterval()
			return resolved.spawnIntervalMinSeconds + math.random() * (resolved.spawnIntervalMaxSeconds - resolved.spawnIntervalMinSeconds)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function removeOrb(p, p2: string, flag: boolean)
			local v5 = v2[p]

			if v5 then
				v5[p2] = nil
			end

			local v6 = v[p]
			local index = v6 and table.find(v6, p2)

			if index then
				table.remove(v6, index)
			end

			if flag then
				data.sendDespawn(p, p2)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function forgetPlayer(p)
			local v5 = v2[p]

			if v5 then
				for k in v5 do
					data.sendDespawn(p, k)
				end
			end

			v[p] = nil
			v2[p] = nil
			v3[p] = nil
		end

		local function pickSpawnPosition(p, list, items, p2: number)
			local positions = {}
			local v5 = v2[p]

			if v5 then
				for _, v6 in v5 do
					table.insert(positions, v6.position)
				end
			end

			local v6 = -1
			local v7 = nil

			for _ = 1, resolved.spawnCandidates do
				local weightedZone = pickWeightedZone(list, items, p2) -- equivalent call inferred; original call site unknown
				local position = randomPointInZone(
					weightedZone,
					resolved.hoverHeightStuds,
					resolved.zoneEdgeMarginStuds
				)
				local v10 = distanceToNearestSquared(position, positions)

				if not (v6 < v10) then
					continue
				end

				v7 = position
				v6 = v10
			end

			return v7
		end

		local function isEligible(player)
			local v5 = false
			local character = player.Character
			local humanoid

			if character then
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if not (humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end

			if humanoidRootPart ~= nil then
				return isPlayerEligible == nil or isPlayerEligible(player)
			end

			return v5
		end

		local function spawnOrbAt(p, vector: Vector3)
			local v5 = v2[p]

			if not v5 then
				v5 = {}
				v2[p] = v5
			end

			local GUIDs = v[p]

			if not GUIDs then
				GUIDs = {}
				v[p] = GUIDs
			end

			while #GUIDs >= resolved.maxActivePerPlayer do
				local v6 = GUIDs[1]
				local v7 = v2[p]

				if v7 then
					v7[v6] = nil
				end

				local v8 = v[p]
				local index = v8 and table.find(v8, v6)

				if index then
					table.remove(v8, index)
				end

				data.sendDespawn(p, v6)
			end

			local GUID = HttpService:GenerateGUID(false)
			v5[GUID] = {
				position = vector,
				expiresAt = os.clock() + resolved.orbLifetimeSeconds,
				collected = false
			}
			table.insert(GUIDs, GUID)
			data.sendSpawn(p, GUID, vector)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function spawnOrbForPlayer(p, p2, zoneWeights, p3: number)
			spawnOrbAt(p, pickSpawnPosition(p, p2, zoneWeights, p3))
		end

		local function sweepExpiredOrbs()
			local now2 = os.clock()

			for k, v5 in v2 do
				for k2, v6 in v5 do
					if not (v6.expiresAt <= now2) then
						continue
					end

					local v7 = v2[k]

					if v7 then
						v7[k2] = nil
					end

					local v8 = v[k]
					local index = v8 and table.find(v8, k2)

					if index then
						table.remove(v8, index)
					end

					data.sendDespawn(k, k2)
				end
			end
		end

		local function runSpawnWave(getSpawnZones)
			local v5 = getSpawnZones()

			if #v5 == 0 then
				if logger and os.clock() - now >= 3 then
					now = os.clock()
					logger:warn("floatingOrbWins: no spawn zones resolved — nothing to spawn on")
				end
			else
				local zoneWeights, v6 = buildZoneWeights(v5, resolved.zoneEdgeMarginStuds)

				for _, v7 in Players:GetPlayers() do
					local v8 = false
					local character = v7.Character
					local humanoid

					if character then
						humanoid = character:FindFirstChildOfClass("Humanoid")
					end

					local humanoidRootPart

					if character then
						humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					end

					if not (humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
						humanoidRootPart = nil
					end

					if humanoidRootPart ~= nil then
						v8 = isPlayerEligible == nil or isPlayerEligible(v7)
					end

					if not v8 then
						continue
					end

					local v9 = v4[v7.UserId] and 0 or resolved.initialOrbsPerPlayer
					v4[v7.UserId] = true

					for _ = 1, resolved.orbsPerWave + v9 do
						spawnOrbForPlayer(v7, v5, zoneWeights, v6) -- equivalent call inferred; original call site unknown
					end
				end
			end
		end

		local getSpawnZones = data.getSpawnZones
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			sweepExpiredOrbs()
			total += dt

			if getSpawnZones and spawnIntervalMinSeconds <= total then
				total = 0
				spawnIntervalMinSeconds = rollSpawnInterval()
				runSpawnWave(getSpawnZones)
			end
		end)
		local playerRemovingConnection = Players.PlayerRemoving:Connect(forgetPlayer)

		local function checkCollect(player, p: string)
			local v5 = v2[player]
			local selected

			if v5 then
				selected = v5[p]
			end

			if not selected or selected.collected then
				return false, nil, "unknown"
			end

			if os.clock() >= selected.expiresAt then
				return false, selected, "expired"
			end

			local v7 = v3[player]

			if v7 and os.clock() - v7 < resolved.collectCooldownSeconds then
				return false, selected, "cooldown"
			end

			local character = player.Character
			local humanoid

			if character then
				humanoid = character:FindFirstChildOfClass("Humanoid")
			end

			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			if not (humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end

			if not humanoidRootPart then
				return false, selected, "downed"
			end

			if (humanoidRootPart.Position - selected.position).Magnitude > resolved.collectMaxDistanceStuds then
				return false, selected, "toofar"
			end

			return true, selected, "ok"
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyCollect(p, p2: string, p3)
			p3.collected = true
			v3[p] = os.clock()
			removeOrb(p, p2, false) -- equivalent call inferred; original call site unknown
			data.awardWin(p)
		end

		return {
			stop = function()
				heartbeatConnection:Disconnect()
				playerRemovingConnection:Disconnect()

				for _, v5 in Players:GetPlayers() do
					forgetPlayer(v5) -- equivalent call inferred; original call site unknown
				end

				table.clear(v)
				table.clear(v2)
				table.clear(v3)
			end,
			spawnAt = function(vector: Vector3)
				for _, v5 in Players:GetPlayers() do
					local v6 = false
					local character = v5.Character
					local humanoid

					if character then
						humanoid = character:FindFirstChildOfClass("Humanoid")
					end

					local humanoidRootPart

					if character then
						humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					end

					if not (humanoid and humanoid.Health > 0 and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
						humanoidRootPart = nil
					end

					if humanoidRootPart ~= nil then
						v6 = isPlayerEligible == nil or isPlayerEligible(v5)
					end

					if v6 then
						spawnOrbAt(v5, vector)
					end
				end
			end,
			handleCollect = function(p, p2: string)
				local v5, v6, v7 = checkCollect(p, p2)

				if v5 then
					applyCollect(p, p2, v6) -- equivalent call inferred; original call site unknown
				elseif v7 == "expired" and v6 then
					local v8 = v2[p]

					if v8 then
						v8[p2] = nil
					end

					local v9 = v[p]
					local index = v9 and table.find(v9, p2)

					if index then
						table.remove(v9, index)
					end

					data.sendDespawn(p, p2)
				end
			end
		}
	end
}