local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local Map = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminAbuseEvent.AdminAbuseUtils.Map)
local Config = require(script.Parent.Parent.Config)
local cframe = CFrame.Angles(0, -1.5707963267948966, 0)
local color = Color3.fromRGB(255, 45, 45)

local function getLocalRootPart()
	local localPlayer = Players.LocalPlayer
	local character

	if localPlayer then
		character = localPlayer.Character
	end

	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function isPointInsidePart(instance, vector2: Vector3)
	local pointToObjectSpace = instance.CFrame:PointToObjectSpace(vector2)
	local v = instance.Size * 0.5
	return math.abs(pointToObjectSpace.X) <= v.X and math.abs(pointToObjectSpace.Y) <= v.Y and math.abs(pointToObjectSpace.Z) <= v.Z
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRaisedCFrame(cframe2: CFrame, p: number)
	return cframe2 + Vector3.new(0, p * 0.5, 0)
end

local function getSpawnParts(p)
	local parent = p.Parent

	if not parent then
		return { p }
	end

	local parts = {}

	for _, part in parent:GetChildren() do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	table.sort(parts, function(a, b)
		return a.Name < b.Name
	end)

	if #parts > 0 then
		return parts
	end

	return { p }
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sendWave(spawnIndex: number, xAxis: number, sizeX: number, configIndex: number, callback)
	callback({
		kind = "BossAttack",
		attack = "Tsunami",
		action = "Spawn",
		spawnIndex = spawnIndex,
		xAxis = xAxis,
		sizeX = sizeX,
		configIndex = configIndex
	})
end

local function getLiveSpawnParts()
	local map = Map.getMap("SummerBossAA_Live")
	local v

	if map then
		v = InstanceUtils.getPotentialInstance(map, "Scriptables/TsunamiSpawns")
	end

	if not v then
		return nil
	end

	local parts = {}

	for _, part in v:GetChildren() do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	table.sort(parts, function(a, b)
		return a.Name < b.Name
	end)
	return parts
end

return {
	new = function(configIndex: number, callback)
		local tsunamiAttackConfig = Config.tsunamiAttackConfigs[configIndex]
		assert(tsunamiAttackConfig, (`Tsunami config index {configIndex} does not exist`))
		local v

		if tsunamiAttackConfig.waveCount > 0 then
			v = tsunamiAttackConfig.waveCount % 1 == 0
		else
			v = false
		end

		assert(v, "Tsunami waveCount must be a positive integer")
		assert(tsunamiAttackConfig.waveIntervalSeconds > 0, "Tsunami waveIntervalSeconds must be positive")
		assert(tsunamiAttackConfig.growDurationSeconds > 0, "Tsunami growDurationSeconds must be positive")
		assert(tsunamiAttackConfig.travelDurationSeconds > 0, "Tsunami travelDurationSeconds must be positive")
		assert(tsunamiAttackConfig.shrinkDurationSeconds > 0, "Tsunami shrinkDurationSeconds must be positive")
		assert(tsunamiAttackConfig.recoverySeconds >= 0, "Tsunami recoverySeconds must be non-negative")
		assert(type(callback) == "function", "Tsunami requires an onLocalHit callback")
		local v2 = Config.tsunamiSizeXRange[1]
		local v3 = Config.tsunamiSizeXRange[2]
		local v4

		if v2 > 0 then
			v4 = v2 <= v3
		else
			v4 = false
		end

		assert(v4, "Tsunami Size.X range is invalid")
		local v6 = {}
		local flag = false
		local count = 0
		local v7 = nil
		return {
			name = "Tsunami",
			durationSeconds = (tsunamiAttackConfig.waveCount - 1) * tsunamiAttackConfig.waveIntervalSeconds + tsunamiAttackConfig.growDurationSeconds + tsunamiAttackConfig.travelDurationSeconds + tsunamiAttackConfig.shrinkDurationSeconds + tsunamiAttackConfig.recoverySeconds,
			startServer = function(_, _)
				count = 0
				v7 = nil
			end,
			updateServer = function(p2: number, p3, callback2)
				local v8 = math.min(
					tsunamiAttackConfig.waveCount,
					math.floor(p2 / tsunamiAttackConfig.waveIntervalSeconds) + 1
				)
				local spawnParts = getSpawnParts(p3)

				while count < v8 do
					count += 1
					local v9 = math.random(1, #spawnParts)
					local spawnPart = spawnParts[v9]

					if #spawnParts > 1 and spawnPart == v7 then
						v9 = v9 % #spawnParts + 1
						spawnPart = spawnParts[v9]
					end

					v7 = spawnPart
					local sizeX = v2 + math.random() * (v3 - v2)
					sendWave(v9, math.random(), sizeX, configIndex, callback2) -- equivalent call inferred; original call site unknown
				end
			end,
			handleServerEvent = function(data)
				if flag or typeof(data) ~= "table" then
					return
				end

				if data.kind == "BossAttack" and data.attack == "Tsunami" and data.action == "Spawn" and type(data.spawnIndex) == "number" and data.spawnIndex % 1 == 0 and type(data.xAxis) == "number" and not (data.xAxis < 0) and not (data.xAxis > 1) and type(data.sizeX) == "number" and not (data.sizeX < v2) and not (v3 < data.sizeX) and type(data.configIndex) == "number" then
					local tsunamiAttackConfig2 = Config.tsunamiAttackConfigs[data.configIndex]

					if not tsunamiAttackConfig2 then
						return
					end

					local liveSpawnParts = getLiveSpawnParts()
					local v8

					if liveSpawnParts then
						v8 = liveSpawnParts[data.spawnIndex]
					end

					if not v8 then
						return
					end

					local v9 = v8.Size.Z * 0.5
					local v10 = math.max(0, v8.Size.X * 0.5 - data.sizeX * 0.5)
					local v11 = (data.xAxis * 2 - 1) * v10
					local v12 = v8.CFrame * CFrame.new(v11, 0, v9)
					local v13 = v8.CFrame * CFrame.new(v11, 0, -v9)
					local potentialInstance = InstanceUtils.getPotentialInstance(
						ReplicatedStorage,
						"AdminAbuse/SummerBossEvent/Assets/Attacks/Tsunami"
					)

					if not potentialInstance then
						return
					end

					local clone = potentialInstance:Clone()
					local vector2 = Vector3.new(clone.Size.X, clone.Size.Y, data.sizeX)
					local vector3 = Vector3.new(vector2.X, 0.1, vector2.Z)
					local v14 = v12 * cframe
					local v15 = v13 * cframe
					local part = Instance.new("Part")
					part.Name = "TsunamiPathTelegraph"
					part.Anchored = true
					part.CanCollide = false
					part.CanQuery = false
					part.CanTouch = false
					part.CastShadow = false
					part.Material = Enum.Material.Neon
					part.Color = color
					part.Transparency = 0.45
					part.Size = Vector3.new(math.min(v8.Size.X, data.sizeX), 2, v8.Size.Z)
					part.CFrame = v8.CFrame * CFrame.new(v11, v8.Size.Y * 0.5, 0) + createVector(0, 1.5, 0)
					part.Parent = Workspace
					clone.Size = vector3
					clone.CFrame = v14 + createVector(0, 0.05, 0)
					clone.Parent = Workspace
					local potentialInstance2 = InstanceUtils.getPotentialInstance(
						ReplicatedStorage,
						"AdminAbuse/SummerBossEvent/SFX/TsunamiSound"
					)

					if potentialInstance2 then
						local clone2 = potentialInstance2:Clone()
						clone2.Looped = true
						clone2.Parent = clone
						clone2:Play()
					end

					local v16 = false
					local v17 = {
						visual = clone,
						telegraph = part,
						hitConnection = RunService.Heartbeat:Connect(function()
							if v16 or clone.Parent == nil then
								return
							end

							local localPlayer = Players.LocalPlayer
							local character

							if localPlayer then
								character = localPlayer.Character
							end

							local humanoidRootPart

							if character then
								humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
							end

							if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
								humanoidRootPart = nil
							end

							if humanoidRootPart then
								local v18 = clone
								local position = humanoidRootPart.Position
								local pointToObjectSpace = v18.CFrame:PointToObjectSpace(position)
								local v19 = v18.Size * 0.5
								local v20

								if math.abs(pointToObjectSpace.X) <= v19.X and math.abs(pointToObjectSpace.Y) <= v19.Y then
									v20 = math.abs(pointToObjectSpace.Z) <= v19.Z
								else
									v20 = false
								end

								if v20 then
									v16 = true
									callback()
								end
							end
						end),
						tween = nil,
						telegraphTween = nil,
						finished = false
					}
					table.insert(v6, v17)

					local function finish()
						if v17.finished then
							return
						end

						v17.finished = true
						v17.hitConnection:Disconnect()
						local index = table.find(v6, v17)

						if index then
							table.remove(v6, index)
						end

						part:Destroy()
						clone:Destroy()
					end

					local function playTween(duration: number, p2, callback2)
						local tween = TweenService:Create(clone, TweenInfo.new(duration, Enum.EasingStyle.Linear), p2)
						v17.tween = tween
						tween.Completed:Once(function(p3)
							if p3 == Enum.PlaybackState.Completed and not (flag or v17.finished) then
								callback2()
							end
						end)
						tween:Play()
					end

					local tween = TweenService:Create(
						part,
						TweenInfo.new(tsunamiAttackConfig2.growDurationSeconds, Enum.EasingStyle.Linear),
						{
							Transparency = 1
						}
					)
					v17.telegraphTween = tween
					tween:Play()
					playTween(tsunamiAttackConfig2.growDurationSeconds, {
						Size = vector2,
						CFrame = getRaisedCFrame(v14, vector2.Y)
					}, function()
						part:Destroy()
						playTween(tsunamiAttackConfig2.travelDurationSeconds, {
							CFrame = getRaisedCFrame(v15, vector2.Y)
						}, function()
							playTween(tsunamiAttackConfig2.shrinkDurationSeconds, {
								Size = vector3,
								CFrame = v15 + createVector(0, 0.05, 0)
							}, finish)
						end)
					end)
				end
			end,
			cleanup = function()
				if flag then
					return
				end

				flag = true
				local clone = table.clone(v6)
				table.clear(v6)

				for _, v8 in clone do
					v8.finished = true
					v8.hitConnection:Disconnect()

					if v8.tween then
						v8.tween:Cancel()
					end

					if v8.telegraphTween then
						v8.telegraphTween:Cancel()
					end

					v8.telegraph:Destroy()
					v8.visual:Destroy()
				end
			end
		}
	end
}