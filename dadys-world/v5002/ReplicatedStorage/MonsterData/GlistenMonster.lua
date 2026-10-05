local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GlistenMonster = {
	Name = "Twisted Glisten",
	Rarity = "Rare",
	Icon = "rbxassetid://18818639838",
	UseBehaviorTree = true,
	VisionRadius = 60,
	InstantRadius = 25,
	WalkSpeed = 6,
	RunSpeed = 16,
	InterestTime = 3,
	HearingRadius = 100,
	Damage = 1,
	WaitTime = 4,
	LineOfSight = 0.4,
	KillRadius = 3.3,
	HitCooldown = 2,
	ChaseAbility = false,
	AbilityCooldown = 0,
	NoChase = false,
	SuppressChasingUntilActivated = true,
	ActivatedWalkSpeed = 15,
	ActivatedRunSpeed = 24,
	ActivatedWaitTime = 0,
	ActivatedWalkAnimationId = "rbxassetid://106872925454867",
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			GlistenFaceStates = true,
			ExtraSAStates = { "Passive", "Angry" },
			PassiveTexture = "rbxassetid://75082799086703",
			NormalTexture = "rbxassetid://134955044460866",
			AngryTexture = "rbxassetid://107669102763764",
			AttackTexture = "rbxassetid://118569816484576",
			BlinkTexture = "rbxassetid://134972522100811"
		}
	}
}

function GlistenMonster.SpecialAnimator(p)
	local SpecialAnimator = require(ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, GlistenMonster.SpecialAnimatorData.Config)
end

GlistenMonster.RageBarInstances = {}

function GlistenMonster.SpecialSetup(instance)
	if instance:GetAttribute("GlistenInitialized") then
		local rageBarInstance = GlistenMonster.RageBarInstances[instance]

		if rageBarInstance and rageBarInstance.character and rageBarInstance.character.Parent then
			return rageBarInstance
		end

		warn("GlistenMonster: Stale instance detected, reinitializing")
		GlistenMonster.RageBarInstances[instance] = nil
	end

	instance:SetAttribute("GlistenInitialized", true)
	instance:SetAttribute("SuppressChasingUntilActivated", true)
	instance:SetAttribute("GlistenActivated", false)
	local GlistenRageBar = require(ReplicatedStorage.MonsterModules.GlistenRageBar)
	local v = GlistenRageBar.new(instance, {
		DetectionRadius = GlistenMonster.InstantRadius
	})

	if v then
		GlistenMonster.RageBarInstances[instance] = v
	end

	return v
end

function GlistenMonster.Cleanup(instance)
	local rageBarInstance = GlistenMonster.RageBarInstances[instance]

	if rageBarInstance and rageBarInstance.cleanup then
		rageBarInstance:cleanup()
	end

	GlistenMonster.RageBarInstances[instance] = nil
	instance:SetAttribute("GlistenInitialized", nil)
end

return GlistenMonster