local createVector = vector.create
local DyleMonster = {
	RageBarInstances = {},
	Name = "Twisted Dyle",
	Rarity = "Lethal",
	Icon = "rbxassetid://89756984894673",
	VisionRadius = 70,
	InstantRadius = 35,
	WalkSpeed = 9,
	RunSpeed = 16,
	InterestTime = 1,
	HearingRadius = 9999,
	Damage = 99,
	WaitTime = 3,
	LineOfSight = 0.4,
	KillRadius = 8.5,
	HitCooldown = 5,
	Lethal = true,
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	NoTargetOverride = true,
	LostInterestAnimationTime = 2.5,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			NormalTexture = "rbxassetid://99764316965760",
			BlinkTexture = "rbxassetid://119787033030206",
			AttackTexture = "rbxassetid://96692852316010"
		}
	},
	ClockAnimationData = {
		FC_SlowSpeed = "rbxassetid://92405825685826",
		FC_NormalSpeed = "rbxassetid://86153924241292",
		FC_FastSpeed = "rbxassetid://87060532656442",
		AnimationSpeedThresholds = {
			slow = 0.33,
			normal = 0.66
		}
	},
	MaxSpeedMultiplier = 2.5,
	SpeedBuildRate = 0.08,
	SpeedDecayRate = 0.025,
	DecayDelay = 3,
	GaugeFillRate = nil,
	StopOnGenerators = false,
	GeneratorDetectionRange = 80,
	GeneratorFreezeTime = 2.5,
	ResetSpeedOnAttack = true,
	AttackSpeedResetDelay = 0,
	ClockHandsEnabled = true,
	DynamicMusicEnabled = true,
	MaxMusicPitch = 1.75,
	MusicPitchThreshold = 50,
	GaugeType = "DyleRageBar",
	GaugeSize = 8,
	GaugeShakeThreshold = 70,
	GaugeFlickerThreshold = 80,
	GaugePulseThreshold = 90,
	ParticleEffectsEnabled = false,
	SmartBoneEnabled = true,
	RotationSmoothingEnabled = false,
	RotationSmoothingFactor = 0.22,
	VisualRotationSmoothingEnabled = false,
	VisualRotationMaxSpeed = 0.7853981633974483,
	VisualRotationResponsiveness = 2,
	SmartBoneDynamic = false,
	SmartBoneSpeedMultiplier = 0.5,
	SmartBoneAttackForce = 2,
	HasCustomSoundScript = true,
	OverrideDefaultSounds = {
		attack = true,
		idle = true,
		lostInterest = true
	}
}

function DyleMonster.UpdateClockFaceAnimation(instance, p)
	if not DyleMonster.ClockHandsEnabled then
		return
	end

	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local v = humanoid:FindFirstChild("Animator")

	if not v then
		v = Instance.new("Animator")
		v.Parent = humanoid
	end

	local currentClockAnimation = instance:GetAttribute("CurrentClockAnimation")
	local fC_SlowSpeed, v2

	if p < (DyleMonster.ClockAnimationData.AnimationSpeedThresholds.slow or 0.33) then
		fC_SlowSpeed = DyleMonster.ClockAnimationData.FC_SlowSpeed
		v2 = "SlowSpeed"
	elseif p < (DyleMonster.ClockAnimationData.AnimationSpeedThresholds.normal or 0.66) then
		fC_SlowSpeed = DyleMonster.ClockAnimationData.FC_NormalSpeed
		v2 = "NormalSpeed"
	else
		fC_SlowSpeed = DyleMonster.ClockAnimationData.FC_FastSpeed
		v2 = "FastSpeed"
	end

	if currentClockAnimation == v2 then
		return
	end

	local playingAnimationTracks = v:GetPlayingAnimationTracks()

	for _, playingAnimationTrack in ipairs(playingAnimationTracks) do
		if not (playingAnimationTrack.Animation and (playingAnimationTrack.Animation.AnimationId == DyleMonster.ClockAnimationData.FC_SlowSpeed or playingAnimationTrack.Animation.AnimationId == DyleMonster.ClockAnimationData.FC_NormalSpeed or playingAnimationTrack.Animation.AnimationId == DyleMonster.ClockAnimationData.FC_FastSpeed)) then
			continue
		end

		playingAnimationTrack:Stop(0.5)
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = fC_SlowSpeed
	local track = v:LoadAnimation(animation)
	track.Priority = Enum.AnimationPriority.Action
	track.Looped = true
	track:Play(0.5)
	instance:SetAttribute("CurrentClockAnimation", v2)
end

function DyleMonster.UpdateMusicTempo(instance, p)
	if not DyleMonster.DynamicMusicEnabled then
		warn("DyleMonster: DynamicMusicEnabled is false")
		return
	end

	local music

	if instance:FindFirstChild("Head") then
		music = instance.Head:FindFirstChild("Music") or instance.Head:FindFirstChild("ChaseMusic") or instance.Head:FindFirstChild("Song") or instance.Head:FindFirstChild("Sound")
	end

	if not music and instance:FindFirstChild("HumanoidRootPart") then
		music = instance.HumanoidRootPart:FindFirstChild("Song") or instance.HumanoidRootPart:FindFirstChild("Music") or instance.HumanoidRootPart:FindFirstChild("ChaseMusic") or instance.HumanoidRootPart:FindFirstChild("Sound")
	end

	if not music and instance:FindFirstChild("Sounds") then
		for _, sound in pairs(instance.Sounds:GetChildren()) do
			if not (sound:IsA("Sound") and (sound.Name == "Music" or sound.Name == "ChaseMusic" or sound.Name == "Song" or sound.IsPlaying)) then
				continue
			end

			music = sound
			break
		end
	end

	if not music then
		return
	end

	if music and music:IsA("Sound") then
		local v = p * 100
		local musicPitchThreshold = DyleMonster.MusicPitchThreshold or 50
		local v2

		if musicPitchThreshold <= v then
			local maxMusicPitch = DyleMonster.MaxMusicPitch or 1.75
			local v3 = (v - musicPitchThreshold) / (100 - musicPitchThreshold)
			v2 = 1 + (maxMusicPitch - 1) * v3
		else
			v2 = 1
		end

		if p < 0.01 then
			music.PlaybackSpeed = 1
		else
			local playbackSpeed = music.PlaybackSpeed or 1
			music.PlaybackSpeed = playbackSpeed + (v2 - playbackSpeed) * 0.25
		end

		local v3 = music:FindFirstChild("ReverbSoundEffect")

		if p > 0.8 then
			if not v3 then
				v3 = Instance.new("ReverbSoundEffect")
				v3.Parent = music
			end

			v3.DryLevel = -6 * p
			v3.WetLevel = -12 * (1 - p)
		elseif v3 then
			v3:Destroy()
		end
	end
end

function DyleMonster.GetSpecialSetupData()
	return {
		Module = DyleMonster.GaugeType,
		Config = {
			MaxSpeed = 60,
			BaseSpeed = DyleMonster.WalkSpeed,
			RunSpeed = DyleMonster.RunSpeed,
			MaxSpeedMultiplier = DyleMonster.MaxSpeedMultiplier,
			SpeedBuildRate = DyleMonster.SpeedBuildRate,
			SpeedDecayRate = DyleMonster.SpeedDecayRate,
			DecayDelay = DyleMonster.DecayDelay,
			GaugeFillRate = DyleMonster.GaugeFillRate,
			UseStandardAnimations = true,
			ScaleAnimationTempo = true,
			ResetSpeedOnAttack = DyleMonster.ResetSpeedOnAttack,
			AttackSpeedResetDelay = DyleMonster.AttackSpeedResetDelay,
			GaugeSize = DyleMonster.GaugeSize,
			GaugeShakeThreshold = DyleMonster.GaugeShakeThreshold,
			GaugeFlickerThreshold = DyleMonster.GaugeFlickerThreshold,
			GaugePulseThreshold = DyleMonster.GaugePulseThreshold
		}
	}
end

DyleMonster.SpecialSetupData = DyleMonster.GetSpecialSetupData()

function DyleMonster.SetupVisualRotationSmoothing(instance)
	local RunService = game:GetService("RunService")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local rootPart = instance:FindFirstChild("RootPart")

	if not (humanoidRootPart and rootPart) then
		warn("DyleMonster: Missing HumanoidRootPart or RootPart for visual rotation smoothing")
		return
	end

	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.Name = "VisualRotationSmoothing"
	bodyAngularVelocity.MaxTorque = createVector(0, 4000, 0)
	bodyAngularVelocity.AngularVelocity = createVector(0, 0, 0)
	bodyAngularVelocity.Parent = rootPart
	local v = 0
	local v2 = {}
	v2.heartbeat = RunService.Heartbeat:Connect(function(_)
		if instance.Parent and humanoidRootPart.Parent and rootPart.Parent then
			local lookVector = humanoidRootPart.CFrame.LookVector
			local v3 = math.atan2(lookVector.X, lookVector.Z)
			local lookVector2 = rootPart.CFrame.LookVector
			v = math.atan2(lookVector2.X, lookVector2.Z)
			local v4 = v3 - v

			while v4 > 3.141592653589793 do
				v4 -= 6.283185307179586
			end

			while v4 < -3.141592653589793 do
				v4 += 6.283185307179586
			end

			local visualRotationResponsiveness = DyleMonster.VisualRotationResponsiveness or 2
			local visualRotationMaxSpeed = DyleMonster.VisualRotationMaxSpeed or 0.7853981633974483
			local v5 = math.clamp(v4 * visualRotationResponsiveness, -visualRotationMaxSpeed, visualRotationMaxSpeed)
			bodyAngularVelocity.AngularVelocity = Vector3.new(0, v5, 0)
		else
			for _, connection in pairs(v2) do
				if connection then
					connection:Disconnect()
				end
			end
		end
	end)
	v2.ancestryChanged = instance.AncestryChanged:Connect(function()
		if not instance.Parent then
			for _, connection in pairs(v2) do
				if connection then
					connection:Disconnect()
				end
			end

			if bodyAngularVelocity and bodyAngularVelocity.Parent then
				bodyAngularVelocity:Destroy()
			end
		end
	end)
	instance:SetAttribute("DyleRotationConnectionsActive", true)
end

function DyleMonster.SpecialSetup(instance)
	local CollectionService = game:GetService("CollectionService")
	CollectionService:AddTag(instance, "DyleMonster")

	if DyleMonster.RotationSmoothingEnabled then
		if DyleMonster.RotationSmoothingFactor then
			instance:SetAttribute("CustomRotationSmoothing", DyleMonster.RotationSmoothingFactor)
		end
	else
		instance:SetAttribute("DisableRotationSmoothing", true)
	end

	if DyleMonster.VisualRotationSmoothingEnabled then
		DyleMonster.SetupVisualRotationSmoothing(instance)
	end

	DyleMonster.SpecialSetupData = DyleMonster.GetSpecialSetupData()

	if not (DyleMonster.SpecialSetupData and DyleMonster.SpecialSetupData.Module) then
		return nil
	end

	local monsterModules = game.ReplicatedStorage:FindFirstChild("MonsterModules")

	if not monsterModules then
		warn("SpecialSetup: MonsterModules folder not found")
		return nil
	end

	local child = monsterModules:FindFirstChild(DyleMonster.SpecialSetupData.Module)

	if not child then
		warn("SpecialSetup: Module not found -", DyleMonster.SpecialSetupData.Module, "in MonsterModules")
		return nil
	end

	local success, result = pcall(require, child)

	if not success then
		warn("SpecialSetup: Failed to load module -", DyleMonster.SpecialSetupData.Module, "-", result)
		return nil
	end

	if not result.new then
		warn("SpecialSetup: Module missing 'new' function -", DyleMonster.SpecialSetupData.Module)
		return nil
	end

	local v = result.new(instance, DyleMonster.SpecialSetupData.Config)

	if v then
		DyleMonster.RageBarInstances[instance] = v
	end

	return v
end

function DyleMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, DyleMonster.SpecialAnimatorData.Config)
end

function DyleMonster.Cleanup(instance)
	local rageBarInstance = DyleMonster.RageBarInstances[instance]

	if rageBarInstance and rageBarInstance.cleanup then
		rageBarInstance:cleanup()
	end

	DyleMonster.RageBarInstances[instance] = nil
	local CollectionService = game:GetService("CollectionService")

	if CollectionService:HasTag(instance, "DyleMonster") then
		CollectionService:RemoveTag(instance, "DyleMonster")
	end

	instance:SetAttribute("DyleRotationConnectionsActive", nil)
end

return DyleMonster