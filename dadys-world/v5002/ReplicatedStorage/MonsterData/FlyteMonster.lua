local FlyteMonster = {
	Name = "Twisted Flyte",
	Rarity = "Uncommon",
	HolidayTwisted = true,
	EasterTwisted = true,
	Holiday = true,
	Easter = true,
	VisionRadius = 65,
	InstantRadius = 30,
	WalkSpeed = 17,
	RunSpeed = 17.5,
	InterestTime = 2,
	HearingRadius = 135,
	Damage = 1,
	WaitTime = 0,
	LineOfSight = 0.4,
	KillRadius = 3.333,
	HitCooldown = 3,
	Trinket = "Scrapbook",
	Icon = "rbxassetid://78483354652017",
	Render = "rbxassetid://94430577397945",
	Description = "This Twisted is as dangerous as it is agile, similar to Twisted Flutter. This Twisted uses wings to quickly patrol a floor, never stopping to rest, though he is unable to match the exact speeds of Twisted Flutter.",
	UseBehaviorTree = true,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://81061176779992",
			NormalTexture = "rbxassetid://122048062601151",
			AttackTexture = "rbxassetid://134241579595110"
		}
	}
}

function FlyteMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, FlyteMonster.SpecialAnimatorData.Config)
end

return FlyteMonster