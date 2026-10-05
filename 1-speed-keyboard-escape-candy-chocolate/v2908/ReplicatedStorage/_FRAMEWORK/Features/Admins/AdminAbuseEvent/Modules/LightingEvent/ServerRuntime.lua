local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
require(script.Parent.Parent.Parent)
local BonusManager = require(ReplicatedStorage.BonusManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local KeycapTargets = require(script.Parent.KeycapTargets)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})

local function shuffle(players)
	for i = #players, 2, -1 do
		local v = math.random(1, i)
		local v2 = players[v]
		local v3 = players[i]
		players[i] = v2
		players[v] = v3
	end
end

local function getPlayers()
	local result = {}

	for _, player in Players:GetPlayers() do
		local character = player.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			continue
		end

		local v2 = {
			player = player,
			position = humanoidRootPart.Position,
			alive = humanoid ~= nil and humanoid.Health > 0
		}
		table.insert(result, v2)
	end

	return result
end

local function isOnZone(position: Vector3, strike)
	local pointToObjectSpace = strike.cframe:PointToObjectSpace(position)
	return math.abs(pointToObjectSpace.X) <= strike.size.X / 2 + Config.keycapHorizontalMarginStuds and math.abs(pointToObjectSpace.Z) <= strike.size.Z / 2 + Config.keycapHorizontalMarginStuds and pointToObjectSpace.Y >= -Config.keycapVerticalRangeStuds and pointToObjectSpace.Y <= strike.size.Y / 2 + Config.keycapVerticalRangeStuds
end

return {
	create = function(data)
		local v = KeycapTargets.create()
		local v2 = {}
		local v3 = {}
		local v4 = {}
		local v5 = {}
		local v6 = {}
		local v7 = {}
		local clone = {}
		local v8 = 1
		local v9 = false
		local v10 = 0
		local v11 = 0
		local count = 0

		local function grant(player, data2, p: number)
			local v12 = v6[player]
			local charges = (not (v12 and p < v12.expiresAt) and 0 or v12.charges) + data2.chargeCount
			local multiplier = 1 + charges * Config.xpPerCharge
			v6[player] = {
				charges = charges,
				expiresAt = p + Config.xpBoostDurationSeconds
			}
			BonusManager:StopBonus("player", "XP", player, "EventBoost")
			BonusManager:ActivateBonus("player", "XP", multiplier, Config.xpBoostDurationSeconds, player, "EventBoost")
			data.FireServerEventToPlayer(player, {
				kind = "claim",
				id = data2.id,
				cframe = data2.cframe,
				isSuper = data2.isSuper,
				multiplier = multiplier,
				color = data2.color,
				chargeCount = data2.chargeCount
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearBoost(k)
			v6[k] = nil

			if k.Parent == Players then
				BonusManager:StopBonus("player", "XP", k, "EventBoost")
			end
		end

		local function queueStrike(p: number, player)
			if #v7 == 0 then
				return
			end

			local character = player and player.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local isSuper = math.random() <= Config.superStrikeChance
			local v13 = math.random()
			local superChargeCount

			if isSuper then
				superChargeCount = Config.superChargeCount
			elseif v13 <= Config.redKeycapChance then
				superChargeCount = Config.redChargeCount
			elseif v13 <= Config.redKeycapChance + Config.purpleKeycapChance then
				superChargeCount = Config.purpleChargeCount
			else
				superChargeCount = Config.regularChargeCount
			end

			local superColor

			if isSuper then
				superColor = Config.superColor
			elseif superChargeCount == Config.redChargeCount then
				superColor = Config.redColor
			elseif superChargeCount == Config.purpleChargeCount then
				superColor = Config.purpleColor
			else
				superColor = Config.regularColor
			end

			local v14

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				local pick = v.pick
				local position = humanoidRootPart.Position
				local v15

				if isSuper then
					v15 = Config.superStrikeRadiusStuds * 0.75
				else
					v15 = Config.strikeRadiusMaxStuds
				end

				v14 = pick(position, v15)
			else
				v14 = v7[math.random(1, #v7)]
			end

			if v14 then
				count += 1
				local v15 = {
					kind = "strike",
					id = count,
					cframe = v14.CFrame,
					size = v14.Size,
					impactAt = p + Config.strikeWarningSeconds,
					expiresAt = p + Config.strikeWarningSeconds + Config.electrifiedDurationSeconds,
					isSuper = isSuper,
					chargeCount = superChargeCount,
					color = superColor
				}
				table.insert(v3, v15)
				data.FireServerEventToAll(v15)
			end
		end

		local function updateStrikes(serverTimeNow: number)
			if v10 <= serverTimeNow then
				v10 = serverTimeNow + Config.strikeIntervalSeconds
				local players = Players:GetPlayers()

				if #players > 0 then
					shuffle(players)

					for i = 1, math.clamp(
						math.ceil(#players / Config.playersPerStrike),
						Config.minimumStrikesPerWave,
						Config.maxStrikesPerWave
					) do
						table.insert(v5, {
							at = serverTimeNow + (i - 1) * Config.strikeStaggerSeconds,
							player = players[(i - 1) % #players + 1]
						})
					end
				end
			end

			for i = #v5, 1, -1 do
				local v12 = v5[i]

				if not (v12.at <= serverTimeNow) then
					continue
				end

				table.remove(v5, i)

				if v12.player.Parent == Players then
					queueStrike(serverTimeNow, v12.player)
				end
			end

			local v12 = nil

			for i = #v3, 1, -1 do
				local strike = v3[i]

				if not (strike.impactAt <= serverTimeNow) then
					continue
				end

				table.remove(v3, i)

				if strike.isSuper then
					v12 = v12 or getPlayers()
					local position = (strike.cframe * CFrame.new(0, strike.size.Y / 2, 0)).Position

					for _, v14 in v12 do
						local vector = v14.position - position

						if vector:Dot(vector) <= Config.superStrikeRadiusStuds ^ 2 then
							grant(v14.player, strike, serverTimeNow)
						end
					end
				elseif serverTimeNow < strike.expiresAt then
					table.insert(v4, {
						strike = strike,
						claimed = {}
					})
				end
			end
		end

		local function updateZones(serverTimeNow: number)
			local players = getPlayers()

			for i = #v4, 1, -1 do
				local v12 = v4[i]

				if v12.strike.expiresAt <= serverTimeNow then
					table.remove(v4, i)
				else
					for _, player in players do
						local player2 = player.player

						if not player.alive or v12.claimed[player2.UserId] or not isOnZone(player.position, v12.strike) then
							continue
						end

						v12.claimed[player2.UserId] = true
						grant(player2, v12.strike, serverTimeNow)
					end
				end
			end
		end

		return {
			onStart = function()
				local KeycapCache = require(ServerScriptService.Utilities.KeycapCache)
				v7 = KeycapCache.getNormalKeycaps()
				clone = table.clone(v7)
				data.janitor:Add(KeycapCache.Added:Connect(function(p)
					v2[p] = nil
					v.add(p)
				end))
				data.janitor:Add(KeycapCache.Removed:Connect(function(p)
					if not v9 then
						v2[p] = true
					end

					v.remove(p)
				end))
				data.janitor:Add(Players.PlayerRemoving:Connect(clearBoost))

				if #clone == 0 then
					logger:warn("Lighting Event has no normal keycaps to target")
				end
			end,
			onUpdate = function()
				local serverTimeNow = Workspace:GetServerTimeNow()

				if v9 then
					updateStrikes(serverTimeNow)

					if v11 <= serverTimeNow then
						v11 = serverTimeNow + Config.keycapCheckIntervalSeconds
						updateZones(serverTimeNow)

						for k, v12 in v6 do
							if not (v12.expiresAt <= serverTimeNow) then
								continue
							end

							clearBoost(k) -- equivalent call inferred; original call site unknown
						end
					end
				else
					local v12 = os.clock() + Config.indexFrameBudgetSeconds

					while true do
						for _ = 1, 64 do
							local v13 = clone[v8]

							if not v13 then
								continue
							end

							if v13.Parent and not v2[v13] then
								v.add(v13)
							end

							v8 += 1
						end

						if not (v8 > #clone or v12 <= os.clock()) then
							continue
						end

						v9 = v8 > #clone

						if not v9 then
							break
						end

						table.clear(clone)
						table.clear(v2)
						return
					end
				end
			end,
			onPlayerAdded = function(p)
				local serverTimeNow = Workspace:GetServerTimeNow()

				for _, v12 in v3 do
					data.FireServerEventToPlayer(p, v12)
				end

				for _, v12 in v4 do
					if not (serverTimeNow < v12.strike.expiresAt) or v12.claimed[p.UserId] then
						continue
					end

					local clone2 = table.clone(v12.strike)
					clone2.kind = "zone"
					data.FireServerEventToPlayer(p, clone2)
				end
			end,
			onStop = function()
				local serverTimeNow = Workspace:GetServerTimeNow()

				for k, v12 in v6 do
					if not (k.Parent == Players and serverTimeNow < v12.expiresAt) then
						continue
					end

					BonusManager:StopBonus("player", "XP", k, "EventBoost")
					BonusManager:ActivateBonus(
						"player",
						"XP",
						1 + v12.charges * Config.xpPerCharge,
						Config.xpBoostDurationSeconds,
						k,
						"EventBoost"
					)
				end

				table.clear(v6)
				table.clear(v3)
				table.clear(v5)
				table.clear(v4)
				table.clear(v2)
				table.clear(clone)
			end
		}
	end
}