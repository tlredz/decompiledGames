local VeeMonster = {
	Name = "Twisted Vee",
	Rarity = "MainCharacter",
	Icon = "rbxassetid://17320166218",
	VisionRadius = 60,
	InstantRadius = 30,
	WalkSpeed = 10,
	RunSpeed = 18,
	InterestTime = 3,
	HearingRadius = 9999,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 4,
	HitCooldown = 2,
	ChaseAbility = true,
	AbilityCooldown = 10,
	AbilityLineOfSight = true,
	UseBehaviorTree = true
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local popUpEvent = ReplicatedStorage.Events.PopUpEvent

function VeeMonster.UseChaseAbility(instance, instance2, _)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	instance2:WaitForChild("HumanoidRootPart")
	local DebuffManager = require(game.ReplicatedStorage.Modules.Gameplay.DebuffManager)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance2)

	if playerFromCharacter then
		popUpEvent:FireClient(
			playerFromCharacter,
			instance.TargetAbilityConfig:GetChildren()[math.random(1, #instance.TargetAbilityConfig:GetChildren())].Texture
		)
	end

	DebuffManager.ApplySlowness(instance2, 2, 5, {
		allowRefreshOnEqual = false
	})
	local bark = humanoidRootPart:WaitForChild("Bark")
	bark:Stop()
	bark:Play()
end

VeeMonster.SpecialAnimatorData = {
	Module = "MonsterModules/SpecialAnimator",
	Config = {
		BlinkTexture = "rbxassetid://119960326838607",
		NormalTexture = "rbxassetid://115036728029758",
		AttackTexture = "rbxassetid://138767367991230 ",
		EmissiveBlink = true,
		BlinkHoldTime = 0.6
	}
}

function VeeMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, VeeMonster.SpecialAnimatorData.Config)
end

return VeeMonster