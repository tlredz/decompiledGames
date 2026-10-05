local BoxtenMonster = {
	Name = "Twisted Boxten",
	Rarity = "Common",
	Icon = "rbxassetid://17173327545",
	VisionRadius = 60,
	InstantRadius = 26,
	WalkSpeed = 10,
	RunSpeed = 18,
	InterestTime = 1.5,
	HearingRadius = 125,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 3.33,
	HitCooldown = 3,
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://83999700660156",
			NormalTexture = "rbxassetid://78296400470576",
			AttackTexture = "rbxassetid://91036058226083"
		}
	}
}

function BoxtenMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, BoxtenMonster.SpecialAnimatorData.Config)
end

return BoxtenMonster