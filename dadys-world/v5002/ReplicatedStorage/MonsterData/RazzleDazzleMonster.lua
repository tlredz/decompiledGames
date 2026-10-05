local RazzleDazzleMonster = {
	Name = "Twisted Razzle & Dazzle",
	Rarity = "Uncommon",
	Icon = "rbxassetid://17640490166",
	VisionRadius = 60,
	InstantRadius = 40,
	WalkSpeed = 10,
	RunSpeed = 18,
	InterestTime = 0.5,
	HearingRadius = 125,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4
}
RazzleDazzleMonster.KillRadius = RazzleDazzleMonster.InstantRadius
RazzleDazzleMonster.HitCooldown = 2
RazzleDazzleMonster.ChaseAbility = false
RazzleDazzleMonster.AbilityCooldown = nil
RazzleDazzleMonster.NoChase = true
RazzleDazzleMonster.ReturnTime = 15
RazzleDazzleMonster.SpecialAnimatorData = {
	Module = "MonsterModules/SpecialAnimator",
	Config = {
		BlinkTexture = "rbxassetid://110975665422305",
		NormalTexture = "rbxassetid://97599203561944",
		AttackTexture = "rbxassetid://106190055773782"
	}
}
return RazzleDazzleMonster