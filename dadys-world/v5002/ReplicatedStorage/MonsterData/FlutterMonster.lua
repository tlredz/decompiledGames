local FlutterMonster = {
	Name = "Twisted Flutter",
	Rarity = "Rare",
	Icon = "rbxassetid://18239227410",
	VisionRadius = 65,
	InstantRadius = 30,
	WalkSpeed = 18,
	RunSpeed = 18.5,
	InterestTime = 2,
	HearingRadius = 135,
	Damage = 1,
	WaitTime = 0,
	LineOfSight = 0.4,
	KillRadius = 3.333,
	HitCooldown = 3,
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			AttackTexture = "rbxassetid://95220072771693",
			BlinkTexture = "rbxassetid://109273272441017",
			NormalTexture = "rbxassetid://139098670279137"
		}
	}
}

function FlutterMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, FlutterMonster.SpecialAnimatorData.Config)
end

return FlutterMonster