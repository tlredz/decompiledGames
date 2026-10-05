local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HapticService = game:GetService("HapticService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local animateTower = ReplicatedStorage:WaitForChild("Events"):WaitForChild("AnimateTower")
local v = nil

local function shellFor(p)
	if v == nil then
		local success, result = pcall(function()
			return require(ReplicatedStorage.Modules.ClientUI.ShellProjector)
		end)
		v = success and result or false
	end

	if v then
		return v.shellFor(p)
	end

	return nil
end

local modules = ReplicatedStorage:WaitForChild("Modules")
local SoundGroupManager = require(modules:WaitForChild("Audio"):WaitForChild("SoundGroupManager"))
local MonsterSoundController = require(modules:WaitForChild("ClientUI"):WaitForChild("MonsterSoundController"))
local v2 = {}

local function waxAnimDebugOn()
	local info = workspace:FindFirstChild("Info")
	return info ~= nil and info:GetAttribute("WaxAnimDebug") == true
end

local function dumpWaxTracks(instance, p)
	local info = workspace:FindFirstChild("Info")
	local v3

	if info == nil then
		v3 = false
	else
		v3 = info:GetAttribute("WaxAnimDebug") == true
	end

	if not (v3 and (instance and instance.Parent and instance.Name:find("Waxwell"))) then
		return
	end

	local humanoid = instance:FindFirstChild("Humanoid") or instance:FindFirstChild("AnimationController")
	local animator = humanoid and (humanoid:FindFirstChildOfClass("Animator") or humanoid)

	if not animator then
		return
	end

	local v4 = {}

	for _, v5 in ipairs(animator:GetPlayingAnimationTracks()) do
		table.insert(v4, string.format("%s(pri=%s w=%.2f)", v5.Name, v5.Priority.Name, v5.WeightCurrent))
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local v5

	if humanoidRootPart then
		local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
		v5 = math.sqrt(assemblyLinearVelocity.X * assemblyLinearVelocity.X + assemblyLinearVelocity.Z * assemblyLinearVelocity.Z)
	else
		v5 = 0
	end

	print(string.format(
		"[WAX-ANIM-DBG] %s %s | ChaseState=%s vel=%.1f | tracks: %s",
		instance.Name,
		p,
		tostring(instance:GetAttribute("ChaseState")),
		v5,
		#v4 > 0 and table.concat(v4, ", ") or "NONE"
	))
end

SoundGroupManager.Initialize()
SoundGroupManager.ConfigureSoundService("Medium")
local v3 = {}
local v4 = {}

local function initializeMonsterSoundController(p)
	if v2[p] then
		return
	end

	local v5 = MonsterSoundController.new(p, {
		DebugEnabled = false
	})

	if v5 then
		v2[p] = v5
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupMonsterSoundController(p)
	if v2[p] then
		v2[p]:cleanup()
		v2[p] = nil
	end
end

local function watchMonsterSounds(instance)
	if v3[instance] then
		return
	end

	v3[instance] = true
	local connection = SoundGroupManager.WatchMonsterSounds(instance)
	local v5 = not v2[instance] and MonsterSoundController.new(instance, {
		DebugEnabled = false
	})

	if v5 then
		v2[instance] = v5
	end

	if connection then
		instance.AncestryChanged:Connect(function()
			if not instance.Parent then
				connection:Disconnect()
				v3[instance] = nil
				cleanupMonsterSoundController(instance) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

local function isMonster(instance)
	return instance:FindFirstChild("Chaser")
end

task.spawn(function()
	for _, model in ipairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model:FindFirstChild("Chaser") then
			watchMonsterSounds(model)
		end
	end
end)
workspace.DescendantAdded:Connect(function(descendant)
	if descendant.Name == "Chaser" then
		local parent = descendant.Parent

		if parent and parent:IsA("Model") then
			watchMonsterSounds(parent)
		end
	end
end)

local function watchPlayerSounds(character)
	if not character or v4[character] then
		return
	end

	v4[character] = true
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild(
		"HumanoidRootPart",
		5
	)

	if not humanoidRootPart then
		return
	end

	for _, sound in ipairs(humanoidRootPart:GetChildren()) do
		if sound:IsA("Sound") then
			SoundGroupManager.AutoAssignSound(sound)
		end
	end

	local childAddedConnection = humanoidRootPart.ChildAdded:Connect(function(sound)
		if sound:IsA("Sound") then
			SoundGroupManager.AutoAssignSound(sound)
		end
	end)
	character.AncestryChanged:Connect(function()
		if not character.Parent then
			childAddedConnection:Disconnect()
			v4[character] = nil
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupLocalPlayerSoundWatcher()
	local character = localPlayer.Character

	if character then
		watchPlayerSounds(character)
	end

	localPlayer.CharacterAdded:Connect(function(character2)
		watchPlayerSounds(character2)
	end)
end

local function watchAllPlayerSounds()
	for _, v5 in ipairs(Players:GetPlayers()) do
		if v5.Character then
			watchPlayerSounds(v5.Character)
		end

		v5.CharacterAdded:Connect(function(character)
			watchPlayerSounds(character)
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			watchPlayerSounds(character)
		end)
	end)
end

task.spawn(function()
	setupLocalPlayerSoundWatcher() -- equivalent call inferred; original call site unknown
	watchAllPlayerSounds()
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function isFootstepRumbleEnabled()
	local character = localPlayer.Character

	if character and character:GetAttribute("FootstepRumbleEnabled") == false then
		return false
	end

	return localPlayer:GetAttribute("FootstepRumbleEnabled") ~= false
end

local function pulseControllerForLethalFootstep()
	-- equivalent call inferred; original call site unknown
	if not isFootstepRumbleEnabled() then
		return
	end

	if UserInputService.GamepadEnabled and pcall(function()
		HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0.02)
	end) then
		task.delay(0.08, function()
			pcall(function()
				HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
			end)
		end)
	end
end

local v5 = {}
local v6 = {}

local function setupAnimationMarkers(instance, track, name)
	local match = name:lower():match("walk")
	local match2 = name:lower():match("run")

	if not (match or match2) then
		return
	end

	if not pcall(function()
		return track:GetMarkerReachedSignal("StepSound")
	end) then
		return
	end

	if not v6[instance] then
		v6[instance] = {}
	end

	if v6[instance][name] then
		return
	end

	local connection = track:GetMarkerReachedSignal("StepSound"):Connect(function()
		if instance:GetAttribute("IsLethal") then
			pulseControllerForLethalFootstep()
		end
	end)
	v6[instance][name] = connection
end

local function setAnimation(instance, name, animationId)
	if not instance then
		return nil
	end

	local animationController = instance:FindFirstChild("AnimationController") or instance:FindFirstChild("Humanoid")

	if animationController then
		local animations = instance:FindFirstChild("Animations")

		if animations then
			local v7 = animations:FindFirstChild(name)

			if name == "Ability" or name == "AbilityNoLegs" then
				print("[EggsonAnim] setAnimation:", name, "found:", v7 ~= nil, "fallbackId:", animationId)
			end

			if not v7 and animationId then
				v7 = Instance.new("Animation")
				v7.Name = name
				v7.AnimationId = animationId
				v7.Parent = animations
				print("[EggsonAnim] setAnimation: created", name, "locally with ID", animationId)
			end

			if not v7 then
				return
			end

			if not v5[instance] then
				v5[instance] = {}
				instance.AncestryChanged:Connect(function()
					if not instance.Parent then
						if v5[instance] then
							for _, v8 in pairs(v5[instance]) do
								if not (v8 and typeof(v8) == "Instance") then
									continue
								end

								v8:Stop()
								v8:Destroy()
							end

							v5[instance] = nil
						end

						if v6[instance] then
							for _, connection in pairs(v6[instance]) do
								if connection then
									connection:Disconnect()
								end
							end

							v6[instance] = nil
						end
					end
				end)
			end

			local v8 = v5[instance][name]

			if v8 then
				if v8.Animation.AnimationId == v7.AnimationId and name ~= "Decode" then
					return v8
				end

				v8:Stop()
				v8:Destroy()
				v5[instance][name] = nil
			end

			local track

			if animationController.Name == "Humanoid" then
				track = (animationController:FindFirstChild("Animator") or Instance.new("Animator", animationController)):LoadAnimation(v7)
			else
				track = animationController:LoadAnimation(v7)
			end

			setupAnimationMarkers(instance, track, name)
			v5[instance][name] = track
			return track
		elseif name == "Ability" or name == "AbilityNoLegs" then
			warn("[EggsonAnim] setAnimation: no Animations folder on", instance.Name)
		end
	elseif name == "Ability" or name == "AbilityNoLegs" then
		warn("[EggsonAnim] setAnimation: no Humanoid/AnimationController on", instance.Name, "for anim", name)
	end
end

local function debugPrintTracks(_) end

local playAnimation

playAnimation = function(instance, name, p, priority, animationId)
	if v == nil then
		local success, result = pcall(function()
			return require(ReplicatedStorage.Modules.ClientUI.ShellProjector)
		end)
		v = success and result or false
	end

	local v7

	if v then
		v7 = v.shellFor(instance)
	end

	if v7 and v7.Parent then
		playAnimation(v7, name, p, priority, animationId)
	end

	local v8 = setAnimation(instance, name, animationId)

	if instance.Parent == nil then
		return
	end

	if name == "Ability" or name == "AbilityNoLegs" then
		print("[EggsonAnim] playAnimation:", name, "track:", v8 ~= nil, "priority:", priority, "stop:", p)
	end

	if not v8 then
		dumpWaxTracks(instance, "NO-TRACK " .. tostring(name))
		return
	end

	if p and p == true then
		v8:Stop()
	else
		if priority then
			v8.Priority = priority
		elseif name == "Ability" or name == "AbilityNoLegs" then
			local config = instance:FindFirstChild("Config")

			if (config and config:FindFirstChild("ModuleName") and config.ModuleName.Value) == "Eggson" then
				v8.Priority = Enum.AnimationPriority.Action4
				print("[EggsonAnim] Applied Action4 priority to", name, "via Config.ModuleName")
			end
		end

		if name == "Talk" and instance:GetAttribute("UseFacialRig") == true then
			v8.Looped = false

			if v8.Length == 0 then
				v8:GetPropertyChangedSignal("Length"):Once(function()
					v8.Looped = false
				end)
			end
		end

		if v8.IsPlaying then
			v8:Stop()
		end

		v8:Play()
		local match = name:lower():match("walk")
		local match2 = name:lower():match("run")

		if match or match2 then
			v8.TimePosition = math.random(0, 100) / 100 * v8.Length
		end
	end

	local _ = instance:FindFirstChild("Humanoid") or instance:FindFirstChild("AnimationController")
	local info = workspace:FindFirstChild("Info")
	local v9

	if info == nil then
		v9 = false
	else
		v9 = info:GetAttribute("WaxAnimDebug") == true
	end

	if not v9 then
		return
	end

	task.delay(0.25, dumpWaxTracks, instance, (p and "stop " or "play ") .. name)
end

local handleAnimationStop

handleAnimationStop = function(instance, p)
	if not instance then
		return
	end

	if v == nil then
		local success, result = pcall(function()
			return require(ReplicatedStorage.Modules.ClientUI.ShellProjector)
		end)
		v = success and result or false
	end

	local v7

	if v then
		v7 = v.shellFor(instance)
	end

	if v7 and v7.Parent then
		handleAnimationStop(v7, p)
	end

	local humanoid = instance:FindFirstChild("Humanoid")

	if instance:FindFirstChild("AnimationController") then
		humanoid = instance:WaitForChild("AnimationController")
	elseif instance:FindFirstChild("Humanoid") then
		humanoid = instance:WaitForChild("Humanoid")
	end

	if humanoid == nil then
		return
	end

	local info = workspace:FindFirstChild("Info")
	local v8

	if info == nil then
		v8 = false
	else
		v8 = info:GetAttribute("WaxAnimDebug") == true
	end

	if v8 then
		task.delay(0.25, dumpWaxTracks, instance, "stopEvt " .. tostring(p))
	end

	if humanoid.Name == "Humanoid" then
		local animator = instance:WaitForChild("Humanoid"):FindFirstChildOfClass("Animator")

		if p == "AllAnims" then
			for _, v9 in pairs(animator:GetPlayingAnimationTracks()) do
				v9:Stop()
			end

			if v5[instance] then
				for _, v9 in pairs(v5[instance]) do
					if v9 and typeof(v9) == "Instance" then
						v9:Stop()
					end
				end
			end
		else
			if v5[instance] and v5[instance][p] then
				v5[instance][p]:Stop()
				return
			end

			for _, v9 in pairs(animator:GetPlayingAnimationTracks()) do
				if v9.Animation and v9.Animation.Name == p then
					v9:Stop()
				end
			end
		end
	else
		local animationController = instance:WaitForChild("AnimationController")

		if p == "AllAnims" then
			for _, v9 in pairs(animationController:GetPlayingAnimationTracks()) do
				v9:Stop()
			end

			if v5[instance] then
				for _, v9 in pairs(v5[instance]) do
					if v9 and typeof(v9) == "Instance" then
						v9:Stop()
					end
				end
			end
		else
			if v5[instance] and v5[instance][p] then
				v5[instance][p]:Stop()
				return
			end

			for _, v9 in pairs(animationController:GetPlayingAnimationTracks()) do
				if v9.Animation and v9.Animation.Name == p then
					v9:Stop()
				end
			end
		end
	end
end

ReplicatedStorage.Events.AnimationStop.OnClientEvent:Connect(handleAnimationStop)
ReplicatedStorage.Events.AnimationSpeed.OnClientEvent:Connect(function(instance, p)
	if not instance then
		return
	end

	local humanoid = instance:FindFirstChild("Humanoid")

	if instance:FindFirstChild("AnimationController") then
		humanoid = instance:WaitForChild("AnimationController")
	elseif instance:FindFirstChild("Humanoid") then
		humanoid = instance:WaitForChild("Humanoid")
	end

	if not humanoid then
		return
	end

	if humanoid.Name == "Humanoid" then
		local animator = instance:WaitForChild("Humanoid"):FindFirstChildOfClass("Animator")

		for _, v7 in pairs(animator:GetPlayingAnimationTracks()) do
			v7:AdjustSpeed(p)
		end
	else
		local animationController = instance:WaitForChild("AnimationController")

		for _, v7 in pairs(animationController:GetPlayingAnimationTracks()) do
			v7:AdjustSpeed(p)
		end
	end
end)
animateTower.OnClientEvent:Connect(function(instance, p, _, _, p2, p3)
	if not instance then
		return
	end

	if p == "Ability" or p == "AbilityNoLegs" then
		print(
			"[EggsonAnim] AnimateTower received:",
			p,
			"tower:",
			instance and instance.Name,
			"priority:",
			p2,
			"fallbackId:",
			p3
		)
	end

	if p ~= "ForceLoad" then
		playAnimation(instance, p, nil, p2, p3)
		return
	end

	local animations = instance:FindFirstChild("Animations")

	if animations then
		for _, animation in ipairs(animations:GetChildren()) do
			if not animation:IsA("Animation") then
				continue
			end

			local v7 = setAnimation(instance, animation.Name)

			if v7 then
				v7:Stop()
			end
		end
	end
end)
local v7 = {
	idle = "Idle",
	walk = "Walk",
	run = "Run",
	attack = "Attack",
	lost = "LostInterest"
}
local v8 = {}

local function watchMonsterChaseState(instance)
	if v8[instance] then
		return
	end

	v8[instance] = true
	local chaseState = instance:GetAttribute("ChaseState")

	if chaseState and v7[chaseState] then
		task.defer(function()
			if instance and instance.Parent then
				playAnimation(instance, v7[chaseState])
			end
		end)
	end

	local chaseStateChangedConnection = instance:GetAttributeChangedSignal("ChaseState"):Connect(function()
		local chaseState2 = instance:GetAttribute("ChaseState")

		if chaseState2 and v7[chaseState2] then
			playAnimation(instance, v7[chaseState2])
		end
	end)
	instance.AncestryChanged:Connect(function()
		if not instance.Parent then
			if chaseStateChangedConnection then
				chaseStateChangedConnection:Disconnect()
			end

			v8[instance] = nil
		end
	end)
end

task.spawn(function()
	for _, model in ipairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model:FindFirstChild("Chaser") then
			watchMonsterChaseState(model)
		end
	end
end)
workspace.DescendantAdded:Connect(function(descendant)
	if descendant.Name == "Chaser" then
		local parent = descendant.Parent

		if parent and parent:IsA("Model") then
			watchMonsterChaseState(parent)
		end
	end
end)