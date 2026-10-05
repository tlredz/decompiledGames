local GingerMonster = {
	Name = "Twisted Ginger",
	Rarity = "Uncommon",
	Icon = "rbxassetid://91212033862550",
	Holiday = true,
	Christmas = true,
	VisionRadius = 65,
	InstantRadius = 28,
	WalkSpeed = 7.5,
	RunSpeed = 14,
	InterestTime = 10,
	HearingRadius = 110,
	Damage = 1,
	WaitTime = 1.1,
	LineOfSight = 0.45,
	KillRadius = 3.33,
	HitCooldown = 3,
	ChaseAbility = nil,
	AbilityCooldown = nil,
	UseBehaviorTree = true,
	Trinket = "PeppermintIcing",
	Render = "rbxassetid://17632349158",
	Description = "This Twisted may be slow, but don't let your guard down too quickly! She is relentless in tracking her targets down with a notable persistence. Make sure you stay out of sight long enough to lose her interest!",
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://79391223654035",
			NormalTexture = "rbxassetid://76696872280169",
			AttackTexture = "rbxassetid://81230616805558"
		}
	}
}

function GingerMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, GingerMonster.SpecialAnimatorData.Config)
end

return GingerMonster