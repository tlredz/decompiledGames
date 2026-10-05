game:GetService("ReplicatedStorage")
local BobetteMonster = {
	Name = "Twisted Bobette",
	Rarity = "MainCharacter",
	Holiday = true,
	Christmas = true,
	Icon = "rbxassetid://125341856238798",
	VisionRadius = 80,
	InstantRadius = 40,
	WalkSpeed = 8,
	RunSpeed = 25,
	InterestTime = 2.5,
	HearingRadius = 180,
	Damage = 1,
	WaitTime = 1.8,
	LineOfSight = 0.5,
	KillRadius = 4,
	HitCooldown = 6,
	UseBehaviorTree = true,
	LostInterestAnimationTime = 2.5,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://86415912887493",
			NormalTexture = "rbxassetid://106808050725177",
			AttackTexture = "rbxassetid://74918395825201"
		}
	}
}

function BobetteMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, BobetteMonster.SpecialAnimatorData.Config)
end

return BobetteMonster