local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.Config)
local floatingOrbWins = require(script.Parent.Parent.floatingOrbWins)
require(script.Parent.Types)
local t = require(ReplicatedStorage.Packages.t)
local strictInterface = t.strictInterface({
	kind = t.literal("meteorOrbCollect"),
	id = t.string
})

local function randomPointInZone(instance, zoneEdgeMarginStuds: number)
	local v = instance.Size * 0.5
	local v2 = (math.random() * 2 - 1) * math.max(0, v.X - zoneEdgeMarginStuds)
	local v3 = (math.random() * 2 - 1) * math.max(0, v.Z - zoneEdgeMarginStuds)
	return (instance.CFrame * CFrame.new(v2, -v.Y, v3)).Position
end

return {
	start = function(data)
		assert(RunService:IsServer(), "meteorOrbRain.Server.start is server-only")
		local resolved = Config.resolve(data.config)
		local isPlayerEligible = data.isPlayerEligible
		local v = {}
		local total = 0
		local dropIntervalMinSeconds = resolved.dropIntervalMinSeconds
		local v2 = 0
		local v3 = floatingOrbWins.startServer({
			config = resolved.orbs,
			isPlayerEligible = isPlayerEligible,
			awardWin = data.awardWin,
			sendSpawn = function(p, id: string, vector: Vector3)
				data.send(p, {
					kind = "meteorOrbSpawn",
					id = id,
					position = vector
				})
			end,
			sendDespawn = function(p, id: string)
				data.send(p, {
					kind = "meteorOrbDespawn",
					id = id
				})
			end,
			logger = data.logger
		})

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rollWaveInterval()
			return resolved.dropIntervalMinSeconds + math.random() * (resolved.dropIntervalMaxSeconds - resolved.dropIntervalMinSeconds)
		end

		local function broadcastDrop(vector: Vector3, impactAt: number)
			for _, v4 in Players:GetPlayers() do
				if isPlayerEligible == nil or isPlayerEligible(v4) then
					data.send(v4, {
						kind = "meteorDrop",
						position = vector,
						impactAt = impactAt
					})
				end
			end
		end

		local function runWave(serverTimeNow: number)
			local zones = data.getZones()

			if #zones == 0 then
				if data.logger and serverTimeNow - v2 >= 3 then
					v2 = serverTimeNow
					data.logger:warn("meteorOrbRain: no zones resolved — no meteors will fall")
				end
			else
				local v4 = resolved.maxActiveMeteors - #v

				for _ = 1, math.min(resolved.dropsPerWave, v4) do
					local position = randomPointInZone(zones[math.random(1, #zones)], resolved.zoneEdgeMarginStuds)
					local dueAt = serverTimeNow + resolved.fallDurationSeconds
					table.insert(v, {
						dueAt = dueAt,
						position = position
					})
					broadcastDrop(position, dueAt)
				end
			end
		end

		local function resolveMaturedImpacts(serverTimeNow: number)
			for i = #v, 1, -1 do
				local v4 = v[i]

				if not (v4.dueAt <= serverTimeNow) then
					continue
				end

				table.remove(v, i)

				if resolved.impactDamage > 0 then
					for _, v5 in Players:GetPlayers() do
						local character = v5.Character
						local humanoidRootPart

						if character then
							humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
						end

						local humanoid

						if character then
							humanoid = character:FindFirstChildOfClass("Humanoid")
						end

						if not (humanoidRootPart and humanoidRootPart:IsA("BasePart") and humanoid and humanoid.Health > 0) then
							continue
						end

						if not ((isPlayerEligible == nil or isPlayerEligible(v5)) and (humanoidRootPart.Position - v4.position).Magnitude <= resolved.impactRadiusStuds) then
							continue
						end

						humanoid:TakeDamage(resolved.impactDamage)
					end
				end

				v3.spawnAt(v4.position + Vector3.new(0, resolved.orbHoverStuds, 0))
			end
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			local serverTimeNow = Workspace:GetServerTimeNow()
			resolveMaturedImpacts(serverTimeNow)
			total += dt

			if dropIntervalMinSeconds <= total then
				total = 0
				dropIntervalMinSeconds = rollWaveInterval()
				runWave(serverTimeNow)
			end
		end)
		return {
			stop = function()
				heartbeatConnection:Disconnect()
				table.clear(v)
				v3.stop()
			end,
			handleMessage = function(p, p2)
				if strictInterface(p2) then
					v3.handleCollect(p, p2.id)
				end
			end
		}
	end
}