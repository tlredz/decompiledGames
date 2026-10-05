local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local GourdyMonster = {
	ModelComponents = {
		Humanoid = "Humanoid",
		HumanoidRootPart = "HumanoidRootPart",
		Head = "Head_geo",
		Torso = "Torso",
		Hat = "Hat",
		LeftArm = "LeftArm",
		RightArm = "RightArm",
		LeftLeg_Back = "LeftLeg_Back",
		LeftLeg_Front = "LeftLeg_Front",
		LeftLeg_Mid = "LeftLeg_Mid",
		RightLeg_Back = "RightLeg_Back",
		RightLeg_Front = "RightLeg_Front",
		RightLeg_Mid = "RightLeg_Mid",
		Animations = "Animations",
		Config = "Config",
		Chasing = "Chasing",
		Wandering = "Wandering",
		LostInterest = "LostInterest",
		Attacking = "Attacking"
	}
}

function GourdyMonster.GetComponent(instance, p)
	local modelComponent = GourdyMonster.ModelComponents[p]

	if modelComponent then
		return instance:FindFirstChild(modelComponent)
	end

	warn("GourdyMonster: Unknown component requested:", p)
	return nil
end

function GourdyMonster.WaitForComponent(instance, p, value)
	local modelComponent = GourdyMonster.ModelComponents[p]

	if modelComponent then
		return instance:WaitForChild(modelComponent, value or 10)
	end

	warn("GourdyMonster: Unknown component requested for waiting:", p)
	return nil
end

GourdyMonster.Name = "Twisted Gourdy"
GourdyMonster.Rarity = "MainCharacter"
GourdyMonster.Icon = "rbxassetid://77513590902874"
GourdyMonster.Holiday = true
GourdyMonster.Halloween = true
GourdyMonster.VisionRadius = 0
GourdyMonster.InstantRadius = 0
GourdyMonster.WalkSpeed = 0
GourdyMonster.RunSpeed = 0
GourdyMonster.InterestTime = 999
GourdyMonster.HearingRadius = 0
GourdyMonster.Damage = 1
GourdyMonster.WaitTime = 3
GourdyMonster.LineOfSight = 0.4
GourdyMonster.KillRadius = 4
GourdyMonster.HitCooldown = 1.5
GourdyMonster.LostInterestAnimationTime = 2
GourdyMonster.ChaseAbility = false
GourdyMonster.AbilityCooldown = 0
GourdyMonster.NoChase = false
GourdyMonster.UseBehaviorTree = true
GourdyMonster.MaxRage = 100
GourdyMonster.RageDecayTime = 105
GourdyMonster.RageDecayRate = 0.95238
GourdyMonster.DecayInterval = 0.5
GourdyMonster.InstantFillAmount = 100
GourdyMonster.RageReductionPerItem = 100
GourdyMonster.EmergenceWalkSpeed = 18
GourdyMonster.EmergenceRunSpeed = 26
GourdyMonster.EmergenceVisionRadius = 100
GourdyMonster.EmergenceInstantRadius = 35
GourdyMonster.EmergenceHearingRadius = 9999
GourdyMonster.EmergenceInterestTime = 3
GourdyMonster.EmergenceAnimationDuration = 2
GourdyMonster.UndergroundOffset = createVector(0, 5, 0)
GourdyMonster.FeedingDistance = 8
GourdyMonster.FeedingHoldDuration = 0.5
GourdyMonster.FeedingCooldown = 1
GourdyMonster.PlayerCountScaling = {
	TwoOrLess = 0.6,
	FourOrLess = 0.8,
	Normal = 1
}
GourdyMonster.SoundConfig = {
	IdleSounds = {
		"rbxassetid://72484225608128",
		"rbxassetid://81826567880809",
		"rbxassetid://124616591183337",
		"rbxassetid://76502667598545",
		"rbxassetid://135400770751856"
	},
	IdleVolume = 0.4,
	IdlePitch = 1,
	IdleLooped = false,
	IdleInterval = 8,
	EmergenceSoundId = "rbxassetid://126642167423259",
	EmergenceVolume = 0.8,
	EmergencePitch = 1,
	AttackSoundId = "rbxassetid://76359685337874",
	AttackVolume = 0.7,
	AttackPitch = 1,
	SpottedSounds = { "rbxassetid://92357728809456", "rbxassetid://97057202120321", "rbxassetid://108964547168210" },
	SpottedVolume = 0.6,
	SpottedPitch = 1,
	LostInterestSounds = {
		"rbxassetid://117469193849545",
		"rbxassetid://118621022288747",
		"rbxassetid://116941284531122"
	},
	LostInterestVolume = 0.5,
	LostInterestPitch = 1,
	FootstepSounds = {
		"rbxassetid://105855215583914",
		"rbxassetid://94607725831117",
		"rbxassetid://95890466844834",
		"rbxassetid://129503716657379"
	},
	FootstepVolume = 0.5,
	FootstepPitch = 1,
	GroundedHappySounds = {
		"rbxassetid://124652857974591",
		"rbxassetid://96532429796550",
		"rbxassetid://109021124027041"
	},
	GroundedHappyVolume = 0.5,
	GroundedHappyPitch = 1,
	GroundedAngrySounds = {
		"rbxassetid://126650917142241",
		"rbxassetid://79522767894636",
		"rbxassetid://122249629361838"
	},
	GroundedAngryVolume = 0.7,
	GroundedAngryPitch = 0.9
}
GourdyMonster.DebugEnabled = false

if GourdyMonster.DebugEnabled then
	GourdyMonster.RageDecayTime = 20
	GourdyMonster.DecayInterval = 0.1
end

GourdyMonster.GourdyTextureConfig = {
	Calm = {
		Normal = "NormalFace_Calm",
		Blink = "BlinkFace_Calm"
	},
	Rage = {
		Normal = "NormalFace_Rage",
		Blink = "BlinkFace_Rage",
		Attack = "AttackFace_Rage"
	},
	ClosedEyes = "BlinkFace_Calm"
}
GourdyMonster.SpecialAnimatorData = {
	Module = "MonsterModules/SpecialAnimator",
	Config = {
		BlinkTexture = "BlinkFace_Calm",
		NormalTexture = "NormalFace_Calm",
		AttackTexture = "AttackFace_Rage"
	}
}

function GourdyMonster.ResolveTextureId(instance, childName)
	local config = instance:FindFirstChild("Config")

	if config then
		local instance2 = config:FindFirstChild(childName)

		if instance2 then
			if instance2:IsA("StringValue") then
				return instance2.Value
			end

			if instance2:IsA("IntValue") or instance2:IsA("NumberValue") then
				return "rbxassetid://" .. instance2.Value
			end

			if instance2:IsA("Decal") then
				return instance2.Texture
			end

			if GourdyMonster.DebugEnabled then
				warn("GourdyMonster: Unknown texture value type:", instance2.ClassName)
			end
		elseif GourdyMonster.DebugEnabled then
			warn("GourdyMonster: Texture not found in Config:", childName)
			print("GourdyMonster: Available textures in Config:")

			for _, child in pairs(config:GetChildren()) do
				print("  -", child.Name, "(" .. child.ClassName .. ")")
			end
		end

		return nil
	else
		if GourdyMonster.DebugEnabled then
			warn("GourdyMonster: No Config folder found when resolving texture:", childName)
		end

		return nil
	end
end

function GourdyMonster.CloseEyes(instance)
	local success, result = pcall(function()
		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Attempting to close eyes for dramatic emergence")
		end

		local head_geo = instance:FindFirstChild("Head_geo")

		if not head_geo then
			warn("GourdyMonster: No Head_geo found for eye closing")
			return
		end

		local textureId = GourdyMonster.ResolveTextureId(instance, GourdyMonster.GourdyTextureConfig.ClosedEyes)

		if textureId then
			head_geo.TextureID = textureId
			instance:SetAttribute("EyesClosed", true)
			instance:SetAttribute("PauseBlinking", true)

			if GourdyMonster.DebugEnabled then
				print("GourdyMonster: Eyes closed successfully with texture:", textureId)
			end
		else
			warn("GourdyMonster: Could not resolve closed eyes texture:", GourdyMonster.GourdyTextureConfig.ClosedEyes)
		end
	end)

	if not success then
		warn("GourdyMonster: Failed to close eyes:", result)
	end
end

function GourdyMonster.SwitchToRageTextures(instance)
	local success, result = pcall(function()
		local v = GourdyMonster.SpecialAnimatorInstances and GourdyMonster.SpecialAnimatorInstances[instance]

		if v then
			if not instance:FindFirstChild("Config") then
				warn("GourdyMonster: No Config folder found for texture switch")
			elseif v.config then
				local textureId = GourdyMonster.ResolveTextureId(
					instance,
					GourdyMonster.GourdyTextureConfig.Rage.Normal
				)
				local textureId2 = GourdyMonster.ResolveTextureId(
					instance,
					GourdyMonster.GourdyTextureConfig.Rage.Blink
				)
				local textureId3 = GourdyMonster.ResolveTextureId(
					instance,
					GourdyMonster.GourdyTextureConfig.Rage.Attack
				)

				if textureId then
					v.config.NormalTexture = textureId
				end

				if textureId2 then
					v.config.BlinkTexture = textureId2
				end

				if textureId3 then
					v.config.AttackTexture = textureId3
				end

				if v.head and textureId then
					v.head.TextureID = textureId
				end

				instance:SetAttribute("EyesClosed", false)
				instance:SetAttribute("PauseBlinking", false)

				if GourdyMonster.DebugEnabled then
					print("GourdyMonster: Switched to RAGE texture set (eyes opened dramatically)")
					print("  Normal:", textureId or "FAILED")
					print("  Blink:", textureId2 or "FAILED")
					print("  Attack:", textureId3 or "FAILED")
				end
			end
		elseif GourdyMonster.DebugEnabled then
			print("GourdyMonster: No SpecialAnimator instance found for texture switch")
		end
	end)

	if not success then
		warn("GourdyMonster: Failed to switch to rage textures:", result)
	end
end

function GourdyMonster.SwitchToCalmTextures(instance)
	local success, result = pcall(function()
		local v = GourdyMonster.SpecialAnimatorInstances and GourdyMonster.SpecialAnimatorInstances[instance]

		if not v then
			return
		end

		if not instance:FindFirstChild("Config") then
			warn("GourdyMonster: No Config folder found for texture switch")
		elseif v.config then
			local textureId = GourdyMonster.ResolveTextureId(instance, GourdyMonster.GourdyTextureConfig.Calm.Normal)
			local textureId2 = GourdyMonster.ResolveTextureId(instance, GourdyMonster.GourdyTextureConfig.Calm.Blink)

			if textureId then
				v.config.NormalTexture = textureId
			end

			if textureId2 then
				v.config.BlinkTexture = textureId2
			end

			if v.head and textureId then
				v.head.TextureID = textureId
			end

			if GourdyMonster.DebugEnabled then
				print("GourdyMonster: Switched to CALM texture set")
				print("  Normal:", textureId or "FAILED")
				print("  Blink:", textureId2 or "FAILED")
			end
		end
	end)

	if not success then
		warn("GourdyMonster: Failed to switch to calm textures:", result)
	end
end

function GourdyMonster.SpawnInitialPuddle(_) end

function GourdyMonster.SpawnEmergenceParticles(instance)
	local success, result = pcall(function()
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			warn("GourdyMonster: No HumanoidRootPart for particle spawn")
			return
		end

		local parts = ReplicatedStorage:FindFirstChild("Parts")

		if parts then
			local gourdyEmergeParticles = parts:FindFirstChild("GourdyEmergeParticles")

			if gourdyEmergeParticles then
				local v = {
					gourdyEmergeParticles:FindFirstChild("Particles_1"),
					gourdyEmergeParticles:FindFirstChild("Particles_2")
				}
				local clones = {}

				for i, v2 in ipairs(v) do
					if v2 then
						local clone = v2:Clone()
						clone:PivotTo(humanoidRootPart.CFrame)
						local currentRoom = workspace:FindFirstChild("CurrentRoom")
						clone.Parent = currentRoom and currentRoom:FindFirstChildOfClass("Model") or workspace
						local playAnimation = clone:FindFirstChild("PlayAnimation", true)

						if playAnimation and (playAnimation:IsA("Script") or playAnimation:IsA("LocalScript")) then
							playAnimation.Disabled = false

							if GourdyMonster.DebugEnabled then
								print("GourdyMonster: Enabled PlayAnimation for Particles_" .. i)
							end
						else
							warn("GourdyMonster: PlayAnimation script not found in Particles_" .. i)
						end

						table.insert(clones, clone)

						if GourdyMonster.DebugEnabled then
							print(
								"GourdyMonster: Spawned emergence Particles_" .. i .. " at",
								humanoidRootPart.Position
							)
						end
					elseif GourdyMonster.DebugEnabled then
						print("GourdyMonster: Particles_" .. i .. " not found in GourdyEmergeParticles folder")
					end
				end

				task.spawn(function()
					local lastTime = tick()
					local isStationary = instance:FindFirstChild("IsStationary")

					while instance.Parent and tick() - lastTime < 15 and (not isStationary or isStationary.Value) and instance:FindFirstChild("IsStationary") do
						task.wait(0.1)
					end

					for _, v2 in ipairs(clones) do
						if not (v2 and v2.Parent) then
							continue
						end

						v2:Destroy()

						if GourdyMonster.DebugEnabled then
							print("GourdyMonster: Cleaned up emergence particle")
						end
					end

					task.wait(0.5)

					for _, v2 in ipairs(clones) do
						if not (v2 and v2.Parent) then
							continue
						end

						v2:Destroy()
						warn("GourdyMonster: Force cleaned up lingering emergence particle")
					end
				end)

				if GourdyMonster.DebugEnabled then
					print("GourdyMonster: Spawned", #clones, "emergence particle systems")
				end
			elseif GourdyMonster.DebugEnabled then
				print("GourdyMonster: GourdyEmergeParticles folder not found - skipping")
			end
		elseif GourdyMonster.DebugEnabled then
			warn("GourdyMonster: ReplicatedStorage.Parts not found - skipping particle spawn")
		end
	end)

	if not success then
		warn("GourdyMonster: Failed to spawn emergence particles:", result)
	end
end

function GourdyMonster.GetSpecialSetupData()
	return {
		Module = "GourdyRageBar",
		Config = {
			MaxRage = GourdyMonster.MaxRage,
			DecayTime = GourdyMonster.RageDecayTime,
			DecayInterval = GourdyMonster.DecayInterval,
			DecayAmount = GourdyMonster.RageDecayRate,
			InstantFillAmount = GourdyMonster.InstantFillAmount,
			RageReductionPerItem = GourdyMonster.RageReductionPerItem,
			EmergenceWalkSpeed = GourdyMonster.EmergenceWalkSpeed,
			EmergenceRunSpeed = GourdyMonster.EmergenceRunSpeed,
			EmergenceAnimationDuration = GourdyMonster.EmergenceAnimationDuration,
			UndergroundOffset = GourdyMonster.UndergroundOffset,
			FeedingDistance = GourdyMonster.FeedingDistance,
			FeedingHoldDuration = GourdyMonster.FeedingHoldDuration,
			FeedingCooldown = GourdyMonster.FeedingCooldown,
			PlayerCountScaling = GourdyMonster.PlayerCountScaling,
			SoundConfig = GourdyMonster.SoundConfig,
			DebugEnabled = GourdyMonster.DebugEnabled
		}
	}
end

GourdyMonster.SpecialSetupData = GourdyMonster.GetSpecialSetupData()

function GourdyMonster.SpecialSetup(parent)
	CollectionService:AddTag(parent, "GourdyMonster")

	if GourdyMonster.DebugEnabled then
		print("=== TWISTED GOURDY ===")
		print("SpecialSetup called for:", parent:GetFullName())
	end

	if parent:GetAttribute("GourdyInitialized") then
		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Already initialized. Skipping.")
		end

		return nil
	else
		parent:SetAttribute("GourdyInitialized", true)
		parent:SetAttribute("NoChaserIdleAnimation", true)
		GourdyMonster.SetupAnimations(parent)
		GourdyMonster.SpawnInitialPuddle(parent)
		GourdyMonster.InitializeState(parent)
		parent:SetAttribute("SmoothRotation", true)
		parent:SetAttribute("RotationSpeed", 5)
		local folder = Instance.new("Folder")
		folder.Name = "Chaser"
		folder.Parent = parent
		local boolValue = Instance.new("BoolValue")
		boolValue.Name = "Chasing"
		boolValue.Value = false
		boolValue.Parent = folder
		local boolValue2 = Instance.new("BoolValue")
		boolValue2.Name = "Wandering"
		boolValue2.Value = false
		boolValue2.Parent = folder
		local boolValue3 = Instance.new("BoolValue")
		boolValue3.Name = "LostInterest"
		boolValue3.Value = false
		boolValue3.Parent = folder
		local boolValue4 = Instance.new("BoolValue")
		boolValue4.Name = "Attacking"
		boolValue4.Value = false
		boolValue4.Parent = folder
		GourdyMonster.InitializeFeedingSystem(parent)
		GourdyMonster.PlayIdleSound(parent)
		GourdyMonster.SpecialSetupData = GourdyMonster.GetSpecialSetupData()

		if not (GourdyMonster.SpecialSetupData and GourdyMonster.SpecialSetupData.Module) then
			warn("GourdyMonster: No SpecialSetupData found")
			return nil
		end

		local monsterModules = ReplicatedStorage:FindFirstChild("MonsterModules")

		if not monsterModules then
			warn("GourdyMonster: MonsterModules folder not found")
			return nil
		end

		local child = monsterModules:FindFirstChild(GourdyMonster.SpecialSetupData.Module)

		if not child then
			warn("GourdyMonster: Module not found -", GourdyMonster.SpecialSetupData.Module, "in MonsterModules")
			return nil
		end

		local success, result = pcall(require, child)

		if not success then
			warn("GourdyMonster: Failed to load module -", GourdyMonster.SpecialSetupData.Module, "-", result)
			return nil
		end

		if not result.new then
			warn("GourdyMonster: Module missing 'new' function -", GourdyMonster.SpecialSetupData.Module)
			return nil
		end

		local v = result.new(parent, GourdyMonster.SpecialSetupData.Config)

		if not GourdyMonster.RageBarInstances then
			GourdyMonster.RageBarInstances = {}
		end

		GourdyMonster.RageBarInstances[parent] = v

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Initialized", GourdyMonster.SpecialSetupData.Module, "for", parent.Name)
		end

		return v
	end
end

function GourdyMonster.SpecialAnimator(instance)
	local success, result = pcall(function()
		local SpecialAnimator = require(ReplicatedStorage.MonsterModules.SpecialAnimator)
		local v = {}

		if instance:FindFirstChild("Config") then
			for k, v2 in pairs(GourdyMonster.SpecialAnimatorData.Config) do
				local textureId = GourdyMonster.ResolveTextureId(instance, v2)

				if textureId then
					v[k] = textureId

					if GourdyMonster.DebugEnabled then
						print("GourdyMonster: Resolved", v2, "to", textureId)
					end
				else
					v[k] = v2

					if GourdyMonster.DebugEnabled then
						warn("GourdyMonster: Failed to resolve texture", v2, "- using name as fallback")
					end
				end
			end
		else
			warn("GourdyMonster: No Config folder found in character model")

			for k, v2 in pairs(GourdyMonster.SpecialAnimatorData.Config) do
				v[k] = v2
			end
		end

		v.HeadComponentName = GourdyMonster.ModelComponents.Head
		local v2 = SpecialAnimator.new(instance, v)

		if not GourdyMonster.SpecialAnimatorInstances then
			GourdyMonster.SpecialAnimatorInstances = {}
		end

		GourdyMonster.SpecialAnimatorInstances[instance] = v2

		if GourdyMonster.DebugEnabled then
			print(
				"GourdyMonster: SpecialAnimator initialized for",
				instance.Name,
				"using head:",
				GourdyMonster.ModelComponents.Head
			)
		end
	end)

	if not success then
		warn("GourdyMonster: Failed to initialize SpecialAnimator:", result)
	end
end

function GourdyMonster.SetupAnimations(instance)
	local humanoid = instance:WaitForChild("Humanoid", 60)

	if not humanoid then
		warn("GourdyMonster: No humanoid found for animation setup - skipping animations")
		return
	end

	local v = humanoid:FindFirstChildOfClass("Animator")

	if not v then
		v = Instance.new("Animator")
		v.Parent = humanoid
	end

	task.wait()

	for _, v2 in pairs(v:GetPlayingAnimationTracks()) do
		v2:Stop()

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Stopped default animation:", v2.Animation and v2.Animation.AnimationId or "Unknown")
		end
	end

	local animations = instance:WaitForChild("Animations", 60)

	if not animations then
		warn("GourdyMonster: No Animations folder found after 60s - skipping animation setup")
		return
	end

	if not GourdyMonster.AnimationCache then
		GourdyMonster.AnimationCache = {}
	end

	GourdyMonster.AnimationCache[instance] = {}
	local groundedEmerge = animations:FindFirstChild("GroundedEmerge") or animations:FindFirstChild("Emerge")

	if groundedEmerge then
		GourdyMonster.AnimationCache[instance].Emerge = groundedEmerge

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Cached emergence animation object")
		end
	end

	local groundedIdle = animations:FindFirstChild("GroundedIdle") or animations:FindFirstChild("Idle")

	if groundedIdle then
		local track = v:LoadAnimation(groundedIdle)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Movement
		track:Play()

		if not GourdyMonster.AnimationTracks then
			GourdyMonster.AnimationTracks = {}
		end

		GourdyMonster.AnimationTracks[instance] = {
			GroundedIdle = track
		}
		instance:SetAttribute("GroundedIdlePlaying", true)

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Started grounded idle animation")
		end
	end
end

function GourdyMonster.PlayIdleSound(instance)
	local success, result = pcall(function()
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart or instance:GetAttribute("IdleSoundActive") then
			return
		end

		instance:SetAttribute("IdleSoundActive", true)

		local function cleanupOldIdleSounds()
			for _, sound in pairs(humanoidRootPart:GetChildren()) do
				if not sound:IsA("Sound") or sound.Name ~= "GourdyIdleSound" or sound.IsPlaying then
					continue
				end

				sound:Destroy()
			end
		end

		local function playRandomIdle()
			if not (instance.Parent and instance:GetAttribute("IdleSoundActive")) then
				return
			end

			cleanupOldIdleSounds()
			local count = 0

			for _, sound in pairs(humanoidRootPart:GetChildren()) do
				if sound:IsA("Sound") and sound.Name == "GourdyIdleSound" and sound.IsPlaying then
					count += 1
				end
			end

			if count >= 2 then
				if GourdyMonster.DebugEnabled then
					print("GourdyMonster: Skipping idle sound (limit reached)")
				end
			else
				Audio:Play("Sounds.Twisted.Gourdy.Idle", {
					Name = "GourdyIdleSound",
					Volume = GourdyMonster.SoundConfig.IdleVolume,
					PlaybackSpeed = GourdyMonster.SoundConfig.IdlePitch,
					Parent = humanoidRootPart
				})

				if GourdyMonster.DebugEnabled then
					print("GourdyMonster: Playing idle sound")
				end
			end
		end

		playRandomIdle()
		instance:SetAttribute("IdleSoundLoop", (task.spawn(function()
			while instance.Parent and instance:GetAttribute("IdleSoundActive") do
				task.wait(GourdyMonster.SoundConfig.IdleInterval)
				playRandomIdle()
			end
		end)))

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Started idle ambient sound system")
		end
	end)

	if not success then
		warn("GourdyMonster: Failed to start idle sound system:", result)
	end
end

function GourdyMonster.StopIdleSound(instance)
	local success, result = pcall(function()
		instance:SetAttribute("IdleSoundActive", false)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			for _, sound in pairs(humanoidRootPart:GetChildren()) do
				if not (sound.Name == "GourdyIdleSound" and sound:IsA("Sound")) then
					continue
				end

				sound:Stop()
				sound:Destroy()
			end
		end

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Stopped idle ambient sound system")
		end
	end)

	if not success then
		warn("GourdyMonster: Failed to stop idle sound system:", result)
	end
end

function GourdyMonster.PlayGroundedAngrySound(instance)
	local success, result = pcall(function()
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		for _, sound in pairs(humanoidRootPart:GetChildren()) do
			if sound:IsA("Sound") and sound.Name == "GourdyAngrySound" and sound.IsPlaying then
				return
			end
		end

		Audio:Play("Sounds.Twisted.Gourdy.GroundedAngry", {
			Name = "GourdyAngrySound",
			Volume = GourdyMonster.SoundConfig.GroundedAngryVolume,
			PlaybackSpeed = GourdyMonster.SoundConfig.GroundedAngryPitch,
			Parent = humanoidRootPart
		})

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Playing GroundedAngry sound at 50% rage threshold")
		end
	end)

	if not success then
		warn("GourdyMonster: Failed to play GroundedAngry sound:", result)
	end
end

function GourdyMonster.PlayGroundedHappySound(instance)
	local success, result = pcall(function()
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		for _, sound in pairs(humanoidRootPart:GetChildren()) do
			if sound:IsA("Sound") and sound.Name == "GourdyHappySound" and sound.IsPlaying then
				return
			end
		end

		Audio:Play("Sounds.Twisted.Gourdy.GroundedHappy", {
			Name = "GourdyHappySound",
			Volume = GourdyMonster.SoundConfig.GroundedHappyVolume,
			PlaybackSpeed = GourdyMonster.SoundConfig.GroundedHappyPitch,
			Parent = humanoidRootPart
		})

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Playing GroundedHappy sound when fed")
		end
	end)

	if not success then
		warn("GourdyMonster: Failed to play GroundedHappy sound:", result)
	end
end

function GourdyMonster.PlayHappyAnimation(instance)
	local success, result = pcall(function()
		local humanoid = instance:FindFirstChild("Humanoid")

		if not humanoid then
			return
		end

		local animator = humanoid:FindFirstChildOfClass("Animator")

		if not animator then
			return
		end

		local animations = instance:FindFirstChild("Animations")

		if not animations then
			return
		end

		local groundedHappy = animations:FindFirstChild("GroundedHappy")

		if groundedHappy then
			GourdyMonster.PlayGroundedHappySound(instance)
			local track = animator:LoadAnimation(groundedHappy)
			track.Looped = false
			track.Priority = Enum.AnimationPriority.Action
			track:Play()

			if GourdyMonster.DebugEnabled then
				print("GourdyMonster: Playing Happy animation with GroundedHappy sound")
			end
		elseif GourdyMonster.DebugEnabled then
			print("GourdyMonster: No GroundedHappy animation found in Animations folder")
		end
	end)

	if not success then
		warn("GourdyMonster: Failed to play Happy animation:", result)
	end
end

function GourdyMonster.PlayAngryAnimation(instance)
	local success, result = pcall(function()
		local humanoid = instance:FindFirstChild("Humanoid")

		if not humanoid then
			return
		end

		local animator = humanoid:FindFirstChildOfClass("Animator")

		if not animator then
			return
		end

		local animations = instance:FindFirstChild("Animations")

		if not animations then
			return
		end

		local groundedAngry = animations:FindFirstChild("GroundedAngry")

		if groundedAngry then
			GourdyMonster.PlayGroundedAngrySound(instance)
			local track = animator:LoadAnimation(groundedAngry)
			track.Looped = false
			track.Priority = Enum.AnimationPriority.Action
			track:Play()

			if GourdyMonster.DebugEnabled then
				print("GourdyMonster: Playing Angry animation with GroundedAngry sound at 50% rage")
			end
		elseif GourdyMonster.DebugEnabled then
			print("GourdyMonster: No GroundedAngry animation found in Animations folder")
		end
	end)

	if not success then
		warn("GourdyMonster: Failed to play Angry animation:", result)
	end
end

function GourdyMonster.InitializeState(parent)
	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "IsStationary"
	boolValue.Value = true
	boolValue.Parent = parent
	parent:SetAttribute("IsStationary", true)
	local stringValue = Instance.new("StringValue")
	stringValue.Name = "GourdyState"
	stringValue.Value = "Stationary"
	stringValue.Parent = parent
	GourdyMonster.ApplyStationaryStats(parent)

	if GourdyMonster.DebugEnabled then
		print("GourdyMonster: State system initialized")
	end
end

function GourdyMonster.ApplyStationaryStats(instance)
	local walkSpeed = instance:FindFirstChild("WalkSpeed")
	local runSpeed = instance:FindFirstChild("RunSpeed")
	local chaseAbility = instance:FindFirstChild("ChaseAbility")
	local noChase = instance:FindFirstChild("NoChase")

	if walkSpeed then
		walkSpeed.Value = GourdyMonster.WalkSpeed
	end

	if runSpeed then
		runSpeed.Value = GourdyMonster.RunSpeed
	end

	if chaseAbility then
		chaseAbility.Value = GourdyMonster.ChaseAbility
	end

	if noChase then
		noChase.Value = true
	end

	local chaser = instance:FindFirstChild("Chaser")

	if chaser then
		local patrolSpeed = chaser:FindFirstChild("PatrolSpeed")
		local runSpeed2 = chaser:FindFirstChild("RunSpeed")

		if patrolSpeed then
			patrolSpeed.Value = 0
		end

		if runSpeed2 then
			runSpeed2.Value = 0
		end

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Applied stationary stats to Chaser folder")
		end
	end

	if chaser then
		local chasing = chaser:FindFirstChild("Chasing")
		local wandering = chaser:FindFirstChild("Wandering")
		local lostInterest = chaser:FindFirstChild("LostInterest")
		local attacking = chaser:FindFirstChild("Attacking")

		if chasing then
			chasing.Value = false
		end

		if wandering then
			wandering.Value = false
		end

		if lostInterest then
			lostInterest.Value = false
		end

		if attacking then
			attacking.Value = false
		end

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Reset Chaser state values for stationary phase")
		end
	end

	if GourdyMonster.DebugEnabled then
		print("GourdyMonster: Applied stationary stats")
	end
end

function GourdyMonster.ApplyMobileStats(instance)
	GourdyMonster.StopIdleSound(instance)
	local walkSpeed = instance:FindFirstChild("WalkSpeed")
	local runSpeed = instance:FindFirstChild("RunSpeed")
	local chaseAbility = instance:FindFirstChild("ChaseAbility")
	local noChase = instance:FindFirstChild("NoChase")

	if walkSpeed then
		walkSpeed.Value = GourdyMonster.EmergenceWalkSpeed
	end

	if runSpeed then
		runSpeed.Value = GourdyMonster.EmergenceRunSpeed
	end

	if chaseAbility then
		chaseAbility.Value = true
	end

	if noChase then
		noChase.Value = false
	end

	instance:SetAttribute("IsStationary", false)
	local chaser = instance:WaitForChild("Chaser", 5)

	if chaser then
		local count = 0

		while count < 10 and not chaser:FindFirstChild("HearingRadius") do
			task.wait(0.1)
			count += 1
		end

		if count >= 10 then
			warn("GourdyMonster: Timeout waiting for MonsterAI to initialize stats!")
		end

		local patrolSpeed = chaser:FindFirstChild("PatrolSpeed")
		local runSpeed2 = chaser:FindFirstChild("RunSpeed")
		local visionRadius = chaser:FindFirstChild("VisionRadius")
		local instantRadius = chaser:FindFirstChild("InstantRadius")
		local hearingRadius = chaser:FindFirstChild("HearingRadius")
		local interestTime = chaser:FindFirstChild("InterestTime")

		if patrolSpeed then
			patrolSpeed.Value = GourdyMonster.EmergenceWalkSpeed
		else
			warn("GourdyMonster: PatrolSpeed not found in Chaser folder!")
		end

		if runSpeed2 then
			runSpeed2.Value = GourdyMonster.EmergenceRunSpeed
		else
			warn("GourdyMonster: RunSpeed not found in Chaser folder!")
		end

		if visionRadius then
			visionRadius.Value = GourdyMonster.EmergenceVisionRadius
		else
			warn("GourdyMonster: VisionRadius not found in Chaser folder!")
		end

		if instantRadius then
			instantRadius.Value = GourdyMonster.EmergenceInstantRadius
		else
			warn("GourdyMonster: InstantRadius not found in Chaser folder!")
		end

		if hearingRadius then
			if GourdyMonster.DebugEnabled then
				print(
					"GourdyMonster: Setting HearingRadius from",
					hearingRadius.Value,
					"to",
					GourdyMonster.EmergenceHearingRadius
				)
			end

			hearingRadius.Value = GourdyMonster.EmergenceHearingRadius

			if GourdyMonster.DebugEnabled then
				print("GourdyMonster: HearingRadius now:", hearingRadius.Value)
			end
		else
			warn("GourdyMonster: HearingRadius not found in Chaser folder!")
		end

		if interestTime then
			interestTime.Value = GourdyMonster.EmergenceInterestTime
		else
			warn("GourdyMonster: InterestTime not found in Chaser folder!")
		end

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Successfully applied mobile stats to Chaser folder")
		end
	else
		warn("GourdyMonster: Chaser folder not found in character! Cannot apply mobile stats!")
		print("GourdyMonster: Character children:")

		for _, child in pairs(instance:GetChildren()) do
			print("  -", child.Name, "(" .. child.ClassName .. ")")
		end
	end

	local chaser2 = instance:FindFirstChild("Chaser")

	if chaser2 then
		local chasing = chaser2:FindFirstChild("Chasing")
		local wandering = chaser2:FindFirstChild("Wandering")

		if chasing then
			chasing.Value = true
		end

		if wandering then
			wandering.Value = true
		end

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Updated Chaser state values for mobile phase")
		end
	end

	GourdyMonster.SwitchToRageTextures(instance)
	local monsterAI = instance:FindFirstChild("MonsterAI")

	if monsterAI and monsterAI:FindFirstChild("RefreshStats") then
		monsterAI.RefreshStats:Fire()
	end

	if GourdyMonster.DebugEnabled then
		print("GourdyMonster: Applied mobile stats and notified MonsterAI")
	end
end

function GourdyMonster.InitializeFeedingSystem(instance)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 60)

	if not humanoidRootPart then
		warn("GourdyMonster: No HumanoidRootPart found after 60s wait - attempting to continue anyway")
		humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			warn("GourdyMonster: Still no HumanoidRootPart - feeding system disabled")
			return
		end
	end

	if GourdyMonster.DebugEnabled then
		print("GourdyMonster: Found HumanoidRootPart, initializing feeding system")
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.Name = "GourdyFeedPrompt"
	proximityPrompt.ActionText = "Gift Item"
	proximityPrompt.ObjectText = "Twisted Gourdy"
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
	proximityPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	proximityPrompt.MaxActivationDistance = GourdyMonster.FeedingDistance
	proximityPrompt.HoldDuration = GourdyMonster.FeedingHoldDuration
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Enabled = true
	proximityPrompt.UIOffset = Vector2.new(0, 2)
	proximityPrompt.Parent = humanoidRootPart
	local serverTimeNowsByPlayer = {}
	proximityPrompt.Triggered:Connect(function(player)
		local serverTimeNow = workspace:GetServerTimeNow()

		if serverTimeNowsByPlayer[player] and serverTimeNow - serverTimeNowsByPlayer[player] < GourdyMonster.FeedingCooldown then
			return
		end

		serverTimeNowsByPlayer[player] = serverTimeNow
		instance:SetAttribute("LastFeedTime", serverTimeNow)
		GourdyMonster.HandleItemFeeding(instance, player)
		task.wait(GourdyMonster.FeedingCooldown)

		if instance and instance.Parent then
			instance:SetAttribute("LastFeedTime", nil)
		end
	end)
	local isStationary = instance:FindFirstChild("IsStationary")

	if isStationary then
		isStationary.Changed:Connect(function(p)
			if p then
				proximityPrompt.Enabled = true
				instance:SetAttribute("IsStationary", true)
			else
				proximityPrompt.Enabled = false
				instance:SetAttribute("IsStationary", false)
			end
		end)
	end

	instance:SetAttribute("IsStationary", true)

	if GourdyMonster.DebugEnabled then
		print("GourdyMonster: Feeding system initialized")
	end
end

function GourdyMonster.HandleItemFeeding(instance, p)
	local success, result = pcall(function()
		local isStationary = instance:FindFirstChild("IsStationary")

		if not (isStationary and isStationary.Value) then
			GourdyMonster.ShowMessage(
				p,
				"Too dangerous to approach while Gourdy is mobile!",
				Color3.fromRGB(255, 100, 100)
			)
			return
		end

		local child = workspace.InGamePlayers:FindFirstChild(p.Name)

		if not child then
			return
		end

		local inventory = child:FindFirstChild("Inventory")

		if not inventory then
			return
		end

		local v = GourdyMonster.TakeItemFromInventory(inventory)

		if v then
			GourdyMonster.ProcessSuccessfulFeeding(instance, p, v)
		else
			GourdyMonster.ShowMessage(p, "You have no items to feed to Twisted Gourdy!", Color3.fromRGB(255, 200, 100))
		end
	end)

	if not success then
		warn("GourdyMonster: Error in item feeding:", result)
	end
end

function GourdyMonster.TakeItemFromInventory(instance)
	for _, childName in pairs({
		"Slot1",
		"Slot2",
		"Slot3",
		"Slot4"
	}) do
		local child = instance:FindFirstChild(childName)

		if not (child and child.Value ~= "None") then
			continue
		end

		local value = child.Value
		child.Value = "None"

		if GourdyMonster.DebugEnabled then
			print("GourdyMonster: Took item from", childName, ":", value)
		end

		return value
	end

	return nil
end

function GourdyMonster.ProcessSuccessfulFeeding(p, p2, p3)
	local v = GourdyMonster.RageBarInstances and GourdyMonster.RageBarInstances[p]

	if v and v.fillRage then
		v:fillRage(p2)
	end

	GourdyMonster.PlayHappyAnimation(p)
	local v2 = "Fed " .. p3 .. " to Twisted Gourdy! Rage decreased!"
	GourdyMonster.ShowMessage(p2, v2, Color3.fromRGB(100, 255, 100))
	GourdyMonster.CreateFeedingVisualEffect(p)
	local events = ReplicatedStorage:FindFirstChild("Events")
	local itemPickupEvent = events and events:FindFirstChild("ItemPickupEvent")

	if itemPickupEvent then
		itemPickupEvent:Fire(p2)
	end

	if GourdyMonster.DebugEnabled then
		print("GourdyMonster: Successfully fed", p3, "to Gourdy by", p2.Name)
	end
end

function GourdyMonster.TestTextureTransitions(instance)
	if not GourdyMonster.DebugEnabled then
		warn("GourdyMonster: Enable DebugEnabled to use test functions")
		return
	end

	local success, result = pcall(function()
		print("=== GOURDY TEXTURE TRANSITION TEST ===")
		print("Testing CALM texture set...")
		GourdyMonster.SwitchToCalmTextures(instance)
		wait(2)
		print("Testing RAGE texture set...")
		GourdyMonster.SwitchToRageTextures(instance)
		wait(2)
		print("Testing state-based transitions...")
		local gourdyState = instance:FindFirstChild("GourdyState")

		if gourdyState then
			print("Current Gourdy state:", gourdyState.Value)
		end

		local chaser = instance:FindFirstChild("Chaser")
		local chasing = chaser and chaser:FindFirstChild("Chasing")

		if chasing then
			print("Chasing state:", chasing.Value)
		end

		print("=== TEXTURE TEST COMPLETE ===")
	end)

	if not success then
		warn("GourdyMonster: Texture test failed:", result)
	end
end

function GourdyMonster.ShowMessage(player, p, p2)
	local events = ReplicatedStorage:FindFirstChild("Events")
	local messageEvent = events and events:FindFirstChild("MessageEvent")

	if messageEvent then
		messageEvent:FireClient(player, p, p2 or Color3.fromRGB(255, 255, 255))
	end
end

function GourdyMonster.CreateFeedingVisualEffect(instance)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "FeedingEffect"
	attachment.Position = createVector(0, 2, 0)
	attachment.Parent = humanoidRootPart
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "FeedingParticles"
	particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 255, 100)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 255, 150)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 255, 200))
	})
	particleEmitter.Lifetime = NumberRange.new(0.5, 1.5)
	particleEmitter.Rate = 100
	particleEmitter.Speed = NumberRange.new(3, 6)
	particleEmitter.SpreadAngle = Vector2.new(45, 45)
	particleEmitter.VelocityInheritance = 0.2
	particleEmitter.EmissionDirection = Enum.NormalId.Top
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.8, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Parent = attachment
	task.wait(0.3)
	particleEmitter.Enabled = false
	task.wait(2)

	if attachment and attachment.Parent then
		attachment:Destroy()
	end
end

function GourdyMonster.Cleanup(instance)
	if not instance:GetAttribute("GourdyInitialized") then
		return
	end

	if CollectionService:HasTag(instance, "GourdyMonster") then
		CollectionService:RemoveTag(instance, "GourdyMonster")
	end

	local v = GourdyMonster.RageBarInstances and GourdyMonster.RageBarInstances[instance]

	if v and v.cleanup then
		v:cleanup()
	end

	if GourdyMonster.RageBarInstances then
		GourdyMonster.RageBarInstances[instance] = nil
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local gourdyFeedPrompt = humanoidRootPart and humanoidRootPart:FindFirstChild("GourdyFeedPrompt")

	if gourdyFeedPrompt then
		gourdyFeedPrompt:Destroy()
	end

	instance:SetAttribute("GourdyInitialized", nil)

	if GourdyMonster.SpecialAnimatorInstances then
		GourdyMonster.SpecialAnimatorInstances[instance] = nil
	end

	if GourdyMonster.DebugEnabled then
		print("GourdyMonster: Cleaned up systems for", instance.Name)
	end
end

return GourdyMonster