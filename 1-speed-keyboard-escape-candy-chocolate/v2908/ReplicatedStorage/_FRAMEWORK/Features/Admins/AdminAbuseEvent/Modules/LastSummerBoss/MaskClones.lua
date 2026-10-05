local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)
local AdminAbuseUtils = require(script.Parent.Parent.Parent.AdminAbuseUtils)
local Config = require(script.Parent.Config)
local cloneWalkAnimation = Config.cloneWalkAnimation
local v = { "Server", "AdminAbuseServerModules", "AABossNpcs" }

-- equivalent calls inferred from this helper; original call sites unknown
local function getSwordTemplate()
	return InstanceUtils.getPotentialInstance(ReplicatedStorage, "AdminAbuse/LastSummerBoss/Assets/MaskSlayerSword")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCloneTemplate()
	return InstanceUtils.getPotentialInstance(ReplicatedStorage, "AdminAbuse/LastSummerBoss/Assets/MaskClone")
end

local function resolveNpcEngine()
	local moduleScript = ServerScriptService

	for _, childName in v do
		if moduleScript then
			moduleScript = moduleScript:FindFirstChild(childName)
		else
			moduleScript = nil
		end
	end

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local module = require(moduleScript)
		return module
	else
		return nil
	end
end

local function prepareChaseTemplate(cloneTemplate)
	local clone = cloneTemplate:Clone()

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
		elseif descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		end
	end

	local humanoid = clone:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid:FindFirstChildOfClass("Animator") == nil then
		local animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		clone.PrimaryPart = humanoidRootPart
	end

	return clone
end

local function randomSpawnCFrameInZone(instance)
	local v2 = (math.random() - 0.5) * instance.Size.X
	local v3 = (math.random() - 0.5) * instance.Size.Z
	local v4 = -instance.Size.Y * 0.5 + 3
	local v5 = math.random() * 3.141592653589793 * 2
	return instance.CFrame * CFrame.new(v2, v4, v3) * CFrame.Angles(0, v5, 0)
end

local MaskClones = {}
MaskClones.swordToolName = "MaskSlayerSword"
MaskClones.walkAnimation = cloneWalkAnimation

function MaskClones.new(data)
	assert(data.config.cloneCount > 0, "MaskClones cloneCount must be positive")
	assert(data.config.hitPoints > 0, "MaskClones hitPoints must be positive")
	assert(data.config.swordDamage > 0, "MaskClones swordDamage must be positive")
	assert(data.config.chaseWalkSpeed > 0, "MaskClones chaseWalkSpeed must be positive")
	assert(data.config.touchDamage >= 0, "MaskClones touchDamage must be non-negative")
	assert(data.config.respawnIntervalSeconds > 0, "MaskClones respawnIntervalSeconds must be positive")
	local flag = false
	local flag2 = false
	local connections = {}
	local v2 = nil
	local v3 = nil
	local v4 = nil
	local now = 0
	local object = setmetatable({}, {
		__mode = "k"
	})

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeSword(player)
		local function clean(instance)
			if not instance then
				return
			end

			for _, tool in instance:GetChildren() do
				if tool:IsA("Tool") and tool.Name == "MaskSlayerSword" then
					tool:Destroy()
				end
			end
		end

		clean(player:FindFirstChild("Backpack"))
		clean(player.Character)
	end

	local function giveSword(instance)
		if not flag then
			return
		end

		removeSword(instance) -- equivalent call inferred; original call site unknown
		local backpack = instance:FindFirstChild("Backpack")
		local swordTemplate = getSwordTemplate() -- equivalent call inferred; original call site unknown

		if not (backpack and swordTemplate) then
			warn("[LastSummerBoss] MaskClones: sword template not found at 'AdminAbuse/LastSummerBoss/Assets/MaskSlayerSword'")
			return
		end

		local clone = swordTemplate:Clone()
		clone.Name = "MaskSlayerSword"
		clone.Parent = backpack
	end

	local function awardKillFromHumanoid(instance)
		local v5 = {}

		for _, objectValue in instance:GetChildren() do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			local value = objectValue.Value

			if not value or not value:IsA("Player") or table.find(v5, value) then
				continue
			end

			table.insert(v5, value)

			if not pcall(data.onKilled, value) then
				warn((`[LastSummerBoss] MaskClones: onKilled raised an error for {value.Name}`))
			end
		end

		if #v5 == 0 then
			warn("[LastSummerBoss] MaskClones: a clone died with no Player ObjectValue tag -- no win granted")
			return
		end

		local names = {}

		for _, v6 in v5 do
			table.insert(names, v6.Name)
		end

		print((`[LastSummerBoss] MaskClones: clone kill -> {table.concat(names, ", ")}`))
	end

	local function sampleWanderPoint(object2, humanoidRootPart)
		for _ = 1, 4 do
			local v5 = math.random() * 3.141592653589793 * 2
			local v6 = math.random() * 18
			local v7 = humanoidRootPart.Position + Vector3.new(math.cos(v5) * v6, 0, math.sin(v5) * v6)

			if object2:isPointInBounds(v7) then
				return v7
			end
		end

		return object2:getRandomPointInBounds()
	end

	local function resolveIdleWanderDestination(instance)
		local v5 = v2
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not (v5 and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			return nil
		end

		local now2 = os.clock()
		local v6 = object[instance]

		if v6 and now2 < v6.expiresAt then
			local vector = Vector3.new(v6.point.X, humanoidRootPart.Position.Y, v6.point.Z)

			if (vector - humanoidRootPart.Position).Magnitude > 4 then
				return vector
			end
		end

		local point = sampleWanderPoint(v5, humanoidRootPart)

		if not point then
			return nil
		end

		object[instance] = {
			point = point,
			expiresAt = now2 + 6
		}
		return (Vector3.new(point.X, humanoidRootPart.Position.Y, point.Z))
	end

	local function checkSpawnReady()
		local arenaModel = data.getArenaModel()
		local spawnZone = data.getSpawnZone()
		local npcEngine = resolveNpcEngine()
		local cloneTemplate = getCloneTemplate() -- equivalent call inferred; original call site unknown

		if not arenaModel then
			return false, nil, nil, nil, nil, "no arena model was available"
		end

		if not spawnZone then
			return false, nil, nil, nil, nil, "no spawn zone was provided"
		end

		if not npcEngine then
			return false, nil, nil, nil, nil, "AABossNpcs engine module was not found on the server"
		end

		if cloneTemplate then
			return true, arenaModel, spawnZone, npcEngine, cloneTemplate, nil
		end

		return false, nil, nil, nil, nil, "clone template not found at 'AdminAbuse/LastSummerBoss/Assets/MaskClone'"
	end

	local function spawnSingleClone(object2, p, spawnZone)
		local npc = object2:spawnNpc(p, (randomSpawnCFrameInZone(spawnZone)))

		if npc and npc:FindFirstChildOfClass("Humanoid") then
			return true
		end

		if npc then
			npc:Destroy()
		end

		warn("[LastSummerBoss] MaskClones: engine failed to spawn a clone")
		return false
	end

	local function beginSession()
		local arenaModel = data.getArenaModel()
		local spawnZone = data.getSpawnZone()
		local npcEngine = resolveNpcEngine()
		local cloneTemplate = getCloneTemplate() -- equivalent call inferred; original call site unknown
		local v5, v6

		if arenaModel then
			if spawnZone then
				if npcEngine then
					if cloneTemplate then
						v5 = true
					else
						v5 = false
						cloneTemplate = nil
						npcEngine = nil
						arenaModel = nil
						spawnZone = nil
						v6 = "clone template not found at 'AdminAbuse/LastSummerBoss/Assets/MaskClone'"
					end
				else
					v5 = false
					cloneTemplate = nil
					npcEngine = nil
					arenaModel = nil
					spawnZone = nil
					v6 = "AABossNpcs engine module was not found on the server"
				end
			else
				v5 = false
				cloneTemplate = nil
				npcEngine = nil
				arenaModel = nil
				spawnZone = nil
				v6 = "no spawn zone was provided"
			end
		else
			v5 = false
			cloneTemplate = nil
			npcEngine = nil
			arenaModel = nil
			spawnZone = nil
			v6 = "no arena model was available"
		end

		if not v5 then
			warn((`[LastSummerBoss] MaskClones: {v6}`))
			return
		end

		local templateModel = prepareChaseTemplate(cloneTemplate)
		v3 = templateModel
		local v8 = npcEngine.new({
			arenaModel = arenaModel,
			playerBoundsZoneName = "PlayerBoundsZone",
			archetypes = {
				MaskClone = {
					chaseUpdateSec = 0.2,
					retargetHoldSec = 0.2,
					idleWalkSpeed = data.config.chaseWalkSpeed,
					resolveIdleDestination = resolveIdleWanderDestination
				}
			},
			awardMobWin = function(p, _: string)
				awardKillFromHumanoid(p)
			end
		})
		v2 = v8
		local v9 = {
			source = "template",
			templateModel = templateModel,
			archetypeId = "MaskClone",
			scale = 1,
			walkSpeed = data.config.chaseWalkSpeed,
			maxHealth = data.config.hitPoints * data.config.swordDamage,
			instantKill = false,
			damage = data.config.touchDamage,
			showHighlight = false,
			namePrefix = "MaskClone",
			mobWinKey = "MaskClone"
		}
		v4 = v9
		now = os.clock()

		for _ = 1, data.config.cloneCount do
			spawnSingleClone(v8, v9, spawnZone)
		end
	end

	local function topUpClones()
		local v5 = v2
		local v6 = v4
		local spawnZone = data.getSpawnZone()

		if flag and v5 and v6 and spawnZone and v5:isActive() then
			for _ = v5:getNpcCount() + 1, data.config.cloneCount do
				if not spawnSingleClone(v5, v6, spawnZone) then
					break
				end
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function teardownSession()
		if v2 then
			v2:teardown()
			v2 = nil
		end

		table.clear(object)
		v4 = nil

		if v3 then
			v3:Destroy()
			v3 = nil
		end
	end

	local v5 = nil
	v5 = {
		start = function()
			assert(RunService:IsServer(), "MaskClones.start can only be called on the server")

			if flag then
				return
			end

			flag = true
			beginSession()

			-- equivalent calls inferred from this helper; original call sites unknown
			local function hookRespawn(p)
				connections[#connections + 1] = p.CharacterAdded:Connect(function()
					task.delay(0.25, function()
						if flag then
							giveSword(p)
						end
					end)
				end)
			end

			for _, v6 in Players:GetPlayers() do
				giveSword(v6)
				hookRespawn(v6) -- equivalent call inferred; original call site unknown
			end

			connections[#connections + 1] = Players.PlayerAdded:Connect(function(player)
				giveSword(player)
				hookRespawn(player) -- equivalent call inferred; original call site unknown
			end)
			print((`[LastSummerBoss] MaskClones: phase started, {#Players:GetPlayers()} player(s) armed`))
		end,
		stop = function()
			assert(RunService:IsServer(), "MaskClones.stop can only be called on the server")

			if not flag then
				return
			end

			flag = false

			for _, connection in connections do
				connection:Disconnect()
			end

			table.clear(connections)
			teardownSession() -- equivalent call inferred; original call site unknown

			for _, v6 in Players:GetPlayers() do
				removeSword(v6) -- equivalent call inferred; original call site unknown
			end
		end,
		update = function()
			assert(RunService:IsServer(), "MaskClones.update can only be called on the server")

			if not flag or v2 == nil then
				return
			end

			local now2 = os.clock()

			if now2 - now >= data.config.respawnIntervalSeconds then
				now = now2
				topUpClones()
			end
		end,
		cleanup = function()
			if flag2 then
				return
			end

			flag2 = true
			v5.stop()
		end
	}
	return v5
end

function MaskClones.newRenderer()
	assert(RunService:IsClient(), "MaskClones.newRenderer can only be called on the client")
	local v2 = false
	local flag = false
	local v3 = {}
	local v4 = {}
	local connections = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isMaskCloneRig(model)
		return model:IsA("Model") and string.sub(model.Name, 1, 10) == "MaskClone_"
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopTrack(p)
		v4[p] = nil
		local v5 = v3[p]

		if v5 then
			v5:Stop(0)
			v5:Destroy()
			v3[p] = nil
		end
	end

	local function playWalk(instance)
		if v2 and not (v3[instance] or v4[instance]) then
			v4[instance] = true
			task.spawn(function()
				local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:WaitForChild("Humanoid", 5)

				if humanoid and humanoid:IsA("Humanoid") and humanoid:FindFirstChildOfClass("Animator") == nil then
					humanoid:WaitForChild("Animator", 5)
				end

				v4[instance] = nil

				if not v2 or v3[instance] or not instance.Parent then
					return
				end

				local success, result = pcall(AdminAbuseUtils.Animations.loadAnimation, instance, cloneWalkAnimation)

				if not success then
					warn((`[LastSummerBoss] MaskClones renderer: {tostring(result)}`))
					return
				end

				result.Looped = true
				result.Priority = Enum.AnimationPriority.Movement
				result:Play(0)
				v3[instance] = result
				local humanoid2 = instance:FindFirstChildOfClass("Humanoid")

				if humanoid2 then
					connections[#connections + 1] = humanoid2.Died:Once(function()
						local v5 = v3[instance]

						if v5 then
							v5:Stop(0.2)
						end
					end)
				end
			end)
		end
	end

	local v5 = nil
	v5 = {
		start = function()
			if v2 or flag then
				return
			end

			v2 = true
			connections[#connections + 1] = CollectionService:GetInstanceAddedSignal("AABossNpc"):Connect(function(model)
				if isMaskCloneRig(model) and v2 and not v3[model] then
					if v4[model] then
						return
					end

					v4[model] = true
					task.spawn(function()
						local humanoid = model:FindFirstChildOfClass("Humanoid") or model:WaitForChild("Humanoid", 5)

						if humanoid and humanoid:IsA("Humanoid") and humanoid:FindFirstChildOfClass("Animator") == nil then
							humanoid:WaitForChild("Animator", 5)
						end

						v4[model] = nil

						if not v2 or v3[model] or not model.Parent then
							return
						end

						local success, result = pcall(
							AdminAbuseUtils.Animations.loadAnimation,
							model,
							cloneWalkAnimation
						)

						if not success then
							warn((`[LastSummerBoss] MaskClones renderer: {tostring(result)}`))
							return
						end

						result.Looped = true
						result.Priority = Enum.AnimationPriority.Movement
						result:Play(0)
						v3[model] = result
						local humanoid2 = model:FindFirstChildOfClass("Humanoid")

						if humanoid2 then
							connections[#connections + 1] = humanoid2.Died:Once(function()
								local v6 = v3[model]

								if v6 then
									v6:Stop(0.2)
								end
							end)
						end
					end)
				end
			end)
			connections[#connections + 1] = CollectionService:GetInstanceRemovedSignal("AABossNpc"):Connect(function(model)
				if model:IsA("Model") then
					stopTrack(model) -- equivalent call inferred; original call site unknown
				end
			end)

			for _, model in CollectionService:GetTagged("AABossNpc") do
				if not (isMaskCloneRig(model) and model:IsDescendantOf(Workspace) and v2) then
					continue
				end

				if v3[model] or v4[model] then
					continue
				end

				v4[model] = true
				local v6 = model
				task.spawn(function()
					local humanoid = v6:FindFirstChildOfClass("Humanoid") or v6:WaitForChild("Humanoid", 5)

					if humanoid and humanoid:IsA("Humanoid") and humanoid:FindFirstChildOfClass("Animator") == nil then
						humanoid:WaitForChild("Animator", 5)
					end

					v4[v6] = nil

					if not v2 or v3[v6] or not v6.Parent then
						return
					end

					local success, result = pcall(AdminAbuseUtils.Animations.loadAnimation, v6, cloneWalkAnimation)

					if not success then
						warn((`[LastSummerBoss] MaskClones renderer: {tostring(result)}`))
						return
					end

					result.Looped = true
					result.Priority = Enum.AnimationPriority.Movement
					result:Play(0)
					v3[v6] = result
					local humanoid2 = v6:FindFirstChildOfClass("Humanoid")

					if humanoid2 then
						connections[#connections + 1] = humanoid2.Died:Once(function()
							local v7 = v3[v6]

							if v7 then
								v7:Stop(0.2)
							end
						end)
					end
				end)
			end
		end,
		stop = function()
			if not v2 then
				return
			end

			v2 = false

			for _, connection in connections do
				connection:Disconnect()
			end

			table.clear(connections)

			for k in v3 do
				stopTrack(k) -- equivalent call inferred; original call site unknown
			end

			table.clear(v4)
		end,
		update = function() end,
		cleanup = function()
			if flag then
				return
			end

			flag = true
			v5.stop()
		end
	}
	return v5
end

return MaskClones