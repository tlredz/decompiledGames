local TishaMonster = {
	Name = "Twisted Tisha",
	Rarity = "Common",
	Icon = "rbxassetid://78043428789711",
	Render = "rbxassetid://97876316607656",
	UseBehaviorTree = true,
	HearingPriority = "high",
	VisionRadius = 60,
	InstantRadius = 26,
	WalkSpeed = 10,
	RunSpeed = 18,
	InterestTime = 1.5,
	HearingRadius = 125,
	LineOfSight = 0.4,
	Damage = 1,
	KillRadius = 3.33,
	HitCooldown = 3,
	ChaseAbility = false,
	AbilityCooldown = 0,
	WaitTime = 10,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://80260160162145",
			NormalTexture = "rbxassetid://121532992671608",
			AttackTexture = "rbxassetid://107663084882512"
		}
	}
}

function TishaMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, TishaMonster.SpecialAnimatorData.Config)
end

TishaMonster.GrowsPuddles = true
TishaMonster.PuddleGrowScanRange = 80
TishaMonster.PuddleGrowCooldown = 45
TishaMonster.PuddleGrowSameSpotCooldown = 30
TishaMonster.PuddleGrowEdgeInset = 1
TishaMonster.PuddleVisitArrivalRadius = 6
TishaMonster.PuddleIdleExclusionRadius = 12
TishaMonster.CleansMachineArt = true
TishaMonster.MachineCleanRange = 60
TishaMonster.MachineCleanCooldown = 60
TishaMonster.MachineCleanChannel = 4
TishaMonster.MachineCleanArrivalRadius = 8
TishaMonster.MachineCleanMinArtAge = 30

function TishaMonster.PuddleVisitFind(p)
	local ServerScriptService = game:GetService("ServerScriptService")
	return require(ServerScriptService.MonsterAI.Modules.TishaPuddleController).findGrowTarget(p)
end

function TishaMonster.PuddleVisitAnim(p)
	local ServerScriptService = game:GetService("ServerScriptService")
	require(ServerScriptService.MonsterAI.Modules.TishaPuddleController).beginGrow(p)
end

return TishaMonster