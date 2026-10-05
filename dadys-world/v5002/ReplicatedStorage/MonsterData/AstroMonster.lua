local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AstroMonster = {
	Name = "Twisted Astro",
	Rarity = "MainCharacter",
	Icon = "rbxassetid://17615948235",
	VisionRadius = 70,
	InstantRadius = 30,
	WalkSpeed = 10,
	RunSpeed = 19,
	InterestTime = 3,
	HearingRadius = 9999,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 3,
	HitCooldown = 2,
	ChaseAbility = true,
	AbilityCooldown = 15,
	AbilityLineOfSight = true,
	UseBehaviorTree = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://124207271427886",
			NormalTexture = "rbxassetid://127034063576241",
			AttackTexture = "rbxassetid://94665415937008",
			EmissiveBlink = true
		}
	}
}
local DebuffManager = require(ReplicatedStorage.Modules.Gameplay.DebuffManager)

function AstroMonster.UseChaseAbility(instance, p)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")

	if p then
		DebuffManager.ApplyTiredness(p, 3, 10)
	end

	local bark = humanoidRootPart:FindFirstChild("Bark")

	if bark then
		bark:Stop()
		bark:Play()
	end
end

function AstroMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, AstroMonster.SpecialAnimatorData.Config)
end

return AstroMonster