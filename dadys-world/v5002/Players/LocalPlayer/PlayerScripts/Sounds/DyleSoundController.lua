local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local modules = ReplicatedStorage:WaitForChild("Modules")
local SoundGroupManager = require(modules:WaitForChild("Audio"):WaitForChild("SoundGroupManager"))
local Audio = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("Audio"))
local v = nil
local v2 = {}
local v3 = {
	"Sounds.Twisted.Dyle.Attack.Attack1",
	"Sounds.Twisted.Dyle.Attack.Attack2",
	"Sounds.Twisted.Dyle.Attack.Attack3"
}
local now = tick()
local v4 = false
local v5 = false
local flag = false
local humanoidRootPart = nil
local humanoid = nil
local animator = nil
local particleEmitter = nil
local particleEmitter2 = nil
local v6 = nil
local v7 = nil
local song = nil
local attack = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function getState(attributeName)
	if v then
		return v:GetAttribute(attributeName) or false
	end

	return false
end

local function playSoundFromId(p, humanoidRootPart2, value, value2)
	local v8 = Audio:Play(p, {
		Name = "TempDyleSound",
		Volume = value or 0.7,
		PlaybackSpeed = value2 or 1,
		RollOffMode = Enum.RollOffMode.Linear,
		RollOffMinDistance = 10,
		RollOffMaxDistance = 100,
		Parent = humanoidRootPart2 or humanoidRootPart
	})

	if v8 then
		SoundGroupManager.AssignSound(v8, "MonsterState")
	end

	return v8
end

local function playRandomSound(list, p, p2)
	if typeof(list) == "table" then
		if #list == 0 then
			return
		else
			list = list[math.random(1, #list)]
		end
	end

	local v8 = not p2 and 1 or math.random(95, 105) / 100
	return (playSoundFromId(list, humanoidRootPart, p, v8))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shouldPlayFootstep()
	local state = getState("Chasing") -- equivalent call inferred; original call site unknown
	local state2 = getState("Alerted") -- equivalent call inferred; original call site unknown
	local state3 = getState("Wandering") -- equivalent call inferred; original call site unknown
	return state or state2 or state3 and not state2
end

local function playFootstepSound()
	if flag then
		return
	end

	flag = true

	if not humanoidRootPart then
		flag = false
		return
	end

	local v8 = Audio:Play("Sounds.Twisted.Dyle.RandomFootstep", {
		Name = "DylePlaySound",
		PlaybackSpeed = math.random(95, 105) / 100,
		Volume = 1.5,
		Parent = humanoidRootPart
	})

	if v8 then
		SoundGroupManager.AssignSound(v8, "Footsteps")
	end

	if v5 and particleEmitter then
		particleEmitter:Emit(1)
	elseif not v5 and particleEmitter2 then
		particleEmitter2:Emit(1)
	end

	v5 = not v5
	task.delay(0.05, function()
		flag = false
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleArmParticles(enabled)
	if v6 then
		for _, v8 in pairs(v6) do
			v8.Enabled = enabled
		end
	end

	if v7 then
		for _, v8 in pairs(v7) do
			v8.Enabled = enabled
		end
	end
end

local function setupAnimationMarkers(object)
	if not (object and object.Animation) then
		return
	end

	local animationId = object.Animation.AnimationId or ""
	local name = object.Animation.Name or ""
	local v8 = name:lower():match("walk") or animationId:lower():match("walk")
	local v9 = name:lower():match("run") or animationId:lower():match("run")

	if not (v8 or v9) then
		return
	end

	local success, result = pcall(function()
		return object:GetMarkerReachedSignal("StepSound")
	end)

	if success and result then
		local connection = result:Connect(function()
			if shouldPlayFootstep() then
				playFootstepSound()
			end
		end)
		table.insert(v2, connection)
	end
end

local function initializeDyle(instance)
	v = instance

	if instance:WaitForChild("Chaser", 10) then
		humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 5)
		humanoid = instance:WaitForChild("Humanoid", 5)

		if humanoid then
			animator = humanoid:WaitForChild("Animator", 5)
		end

		if humanoidRootPart and humanoid and animator then
			local particles = humanoidRootPart:FindFirstChild("Particles")

			if particles then
				particleEmitter = particles:FindFirstChild("ParticleEmitter")
			end

			local particles2 = humanoidRootPart:FindFirstChild("Particles2")

			if particles2 then
				particleEmitter2 = particles2:FindFirstChild("ParticleEmitter")
			end

			attack = humanoidRootPart:FindFirstChild("Attack")
			song = humanoidRootPart:FindFirstChild("Song")

			if song then
				song.Volume = 0.3
				song.RollOffMaxDistance = 250
				song.RollOffMinDistance = 1
				song.RollOffMode = Enum.RollOffMode.Linear
			end

			if attack then
				attack.Volume = 0.3
			end

			local quickLinks = instance:FindFirstChild("QuickLinks")

			if quickLinks then
				local leftLowerArm = quickLinks:FindFirstChild("LeftLowerArm")
				local rightLowerArm = quickLinks:FindFirstChild("RightLowerArm")
				local particles3 = leftLowerArm and leftLowerArm.Value and leftLowerArm.Value:FindFirstChild("Particles")

				if particles3 then
					v6 = {}
					local particleEmitter3 = particles3:FindFirstChild("ParticleEmitter")
					local particleEmitter22 = particles3:FindFirstChild("ParticleEmitter2")

					if particleEmitter3 then
						table.insert(v6, particleEmitter3)
					end

					if particleEmitter22 then
						table.insert(v6, particleEmitter22)
					end
				end

				local particles4 = rightLowerArm and rightLowerArm.Value and rightLowerArm.Value:FindFirstChild("Particles")

				if particles4 then
					v7 = {}
					local particleEmitter3 = particles4:FindFirstChild("ParticleEmitter")
					local particleEmitter22 = particles4:FindFirstChild("ParticleEmitter2")

					if particleEmitter3 then
						table.insert(v7, particleEmitter3)
					end

					if particleEmitter22 then
						table.insert(v7, particleEmitter22)
					end
				end
			end

			if song then
				song:Play()
			end

			local animationPlayedConnection = animator.AnimationPlayed:Connect(function(p)
				if p and p.Animation then
					setupAnimationMarkers(p)
				end
			end)
			table.insert(v2, animationPlayedConnection)

			for _, v8 in pairs(animator:GetPlayingAnimationTracks()) do
				setupAnimationMarkers(v8)
			end

			local attackingChangedConnection = instance:GetAttributeChangedSignal("Attacking"):Connect(function()
				-- equivalent call inferred; original call site unknown
				if getState("Attacking") then
					playRandomSound(v3, 2.5, true)

					if attack and not attack.Playing then
						attack:Play()
					end

					task.spawn(function()
						task.wait(0.1)
						toggleArmParticles(true) -- equivalent call inferred; original call site unknown
						task.wait(1)
						toggleArmParticles(false) -- equivalent call inferred; original call site unknown
					end)
				end
			end)
			table.insert(v2, attackingChangedConnection)
			local lostInterestChangedConnection = instance:GetAttributeChangedSignal("LostInterest"):Connect(function()
				-- equivalent call inferred; original call site unknown
				if getState("LostInterest") then
					local v8 = math.random(95, 105) / 100
					playSoundFromId("Sounds.Twisted.Dyle.LostInterest", humanoidRootPart, 0.7, v8)
				end
			end)
			table.insert(v2, lostInterestChangedConnection)
			local alertedChangedConnection = instance:GetAttributeChangedSignal("Alerted"):Connect(function()
				-- equivalent call inferred; original call site unknown
				if getState("Alerted") then
					local v8 = v3

					if typeof(v8) == "table" then
						if #v8 == 0 then
							return
						else
							v8 = v8[math.random(1, #v8)]
						end
					end

					local v9 = math.random(95, 105) / 100
					playSoundFromId(v8, humanoidRootPart, 0.6, v9)
				end
			end)
			table.insert(v2, alertedChangedConnection)
			local heartbeatConnection = RunService.Heartbeat:Connect(function()
				local now2 = tick()
				local state = getState("Attacking") -- equivalent call inferred; original call site unknown
				local state2 = getState("Chasing") -- equivalent call inferred; original call site unknown
				local state3 = getState("Alerted") -- equivalent call inferred; original call site unknown

				if state or state2 or state3 then
					now = now2
				elseif now2 - now >= 8 and not v4 then
					v4 = true
					now = now2
					local v8 = math.random(95, 105) / 100
					local v9 = playSoundFromId("Sounds.Twisted.Dyle.Idle", humanoidRootPart, 0.6, v8)

					if not v9 then
						v4 = false
						return
					end

					v9.Ended:Once(function()
						v4 = false
					end)
					v9.Destroying:Once(function()
						v4 = false
					end)
				end
			end)
			table.insert(v2, heartbeatConnection)
		else
			warn("DyleSoundController: Missing components for", instance.Name)
			v = nil
		end
	else
		warn("DyleSoundController: Chaser folder not found, controller disabled")
		v = nil
	end
end

local function cleanupDyle()
	for _, connection in pairs(v2) do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		end
	end

	v2 = {}
	v = nil
	humanoidRootPart = nil
	humanoid = nil
	animator = nil
	particleEmitter = nil
	particleEmitter2 = nil
	v6 = nil
	v7 = nil
	song = nil
	attack = nil
	v4 = false
	v5 = false
	flag = false
end

local function onDescendantAdded(instance)
	if instance.Name == "Chaser" then
		local parent = instance.Parent

		if parent and parent:IsA("Model") and parent.Name == "DyleMonster" then
			task.wait(0.1)
			initializeDyle(parent)
		end
	end
end

local function onDescendantRemoved(p)
	if p == v then
		cleanupDyle()
	end
end

workspace.DescendantAdded:Connect(onDescendantAdded)
workspace.DescendantRemoving:Connect(onDescendantRemoved)
task.spawn(function()
	for _, model in ipairs(workspace:GetDescendants()) do
		if not (model:IsA("Model") and model.Name == "DyleMonster" and model:FindFirstChild("Chaser")) then
			continue
		end

		initializeDyle(model)
		break
	end
end)