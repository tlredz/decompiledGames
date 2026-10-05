local BrightneyMonster = {
	Name = "Twisted Brightney",
	Rarity = "Uncommon",
	Icon = "rbxassetid://17632349232",
	VisionRadius = 65,
	InstantRadius = 26,
	WalkSpeed = 12,
	RunSpeed = 18,
	InterestTime = 2,
	HearingRadius = 150,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 3.3,
	HitCooldown = 3,
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://87391943581601",
			NormalTexture = "rbxassetid://129069459728831",
			AttackTexture = "rbxassetid://113642798633093"
		}
	}
}

function BrightneyMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, BrightneyMonster.SpecialAnimatorData.Config)
end

return BrightneyMonster