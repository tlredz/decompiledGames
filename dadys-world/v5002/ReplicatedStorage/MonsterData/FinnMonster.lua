local createVector = vector.create
local FinnMonster = {
	Name = "Twisted Finn",
	Rarity = "Uncommon",
	Icon = "rbxassetid://127272224875922",
	Render = "rbxassetid://76505472171120",
	VisionRadius = 55,
	InstantRadius = 26,
	WalkSpeed = 8.5,
	RunSpeed = 16,
	InterestTime = 1.5,
	HearingRadius = 125,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 3.333,
	HitCooldown = 3,
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	DropsIchor = true,
	IchorDropCap = 3,
	IchorDropCooldown = 25,
	IchorDropRadius = 40,
	IchorDropChannel = 2,
	PourTossExtraChannel = 1.6,
	UseThrowAnimMarkers = true,
	IchorDirectedFallback = 40,
	SplashesPuddles = true,
	IchorSplashChannel = 4,
	IchorSplashCooldown = 12,
	IchorVisitCooldown = 18,
	IchorSameSpotCooldown = 30,
	PuddleVisitArrivalRadius = 6,
	EnrageMaxDuration = 45,
	VisitsBarnabyGens = true,
	BarnabyGenRadius = 40,
	BarnabyGenStandoff = 5,
	BarnabyGenChannel = 4,
	BarnabyGenAnimation = 110332686821812,
	BarnabyGenAnchorOffset = createVector(0, 0, 0.5),
	BarnabyGenAnchorRotation = createVector(0, 0, 0),
	WanderDivertFind = function(p)
		local ServerScriptService = game:GetService("ServerScriptService")
		return require(ServerScriptService.MonsterAI.Modules.IchorDropController).findDropTarget(p)
	end,
	WanderDivertAct = function(p, p2)
		local ServerScriptService = game:GetService("ServerScriptService")
		require(ServerScriptService.MonsterAI.Modules.IchorDropController).dropAt(p, p2)
	end,
	SplashFind = function(p)
		local ServerScriptService = game:GetService("ServerScriptService")
		return require(ServerScriptService.MonsterAI.Modules.IchorDropController).findSplashTarget(p)
	end,
	SplashAct = function(p, p2)
		local ServerScriptService = game:GetService("ServerScriptService")
		require(ServerScriptService.MonsterAI.Modules.IchorDropController).splashAt(p, p2)
	end,
	WanderDivertAnim = function(p)
		local ServerScriptService = game:GetService("ServerScriptService")
		require(ServerScriptService.MonsterAI.Modules.IchorDropController).playDropAnim(p)
	end
}

function FinnMonster:WanderDivertChannel()
	return (FinnMonster.IchorDropChannel or 0) + (not self._pendingDropWillSpawnTB and 0 or FinnMonster.PourTossExtraChannel or 0)
end

function FinnMonster.SplashAnim(p)
	local ServerScriptService = game:GetService("ServerScriptService")
	require(ServerScriptService.MonsterAI.Modules.IchorDropController).playSplashAnim(p)
end

function FinnMonster.PuddleVisitFind(p)
	local ServerScriptService = game:GetService("ServerScriptService")
	return require(ServerScriptService.MonsterAI.Modules.IchorDropController).findVisitTarget(p)
end

function FinnMonster.PuddleVisitAnim(p)
	local ServerScriptService = game:GetService("ServerScriptService")
	require(ServerScriptService.MonsterAI.Modules.IchorDropController).playVisitAnim(p)
end

function FinnMonster.PuddleVisitAct(p, p2)
	local ServerScriptService = game:GetService("ServerScriptService")
	require(ServerScriptService.MonsterAI.Modules.IchorDropController).visitAt(p, p2)
end

function FinnMonster.BarnabyGenFind(p)
	local ServerScriptService = game:GetService("ServerScriptService")
	return require(ServerScriptService.MonsterAI.Modules.BarnabyGenController).findTarget(p)
end

function FinnMonster.BarnabyGenAct(p, p2)
	local ServerScriptService = game:GetService("ServerScriptService")
	require(ServerScriptService.MonsterAI.Modules.BarnabyGenController).actAt(p, p2)
end

function FinnMonster.BarnabyGenInspectAnim(p)
	local ServerScriptService = game:GetService("ServerScriptService")
	require(ServerScriptService.MonsterAI.Modules.BarnabyGenController).playInspectAnim(
		p,
		FinnMonster.BarnabyGenAnimation
	)
end

FinnMonster.SpecialAnimatorData = {
	Module = "MonsterModules/SpecialAnimator",
	Config = {
		AttackTexture = "rbxassetid://105305265688218",
		BlinkTexture = "rbxassetid://93642474405819",
		NormalTexture = "rbxassetid://120588740333174"
	}
}

function FinnMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, FinnMonster.SpecialAnimatorData.Config)
end

return FinnMonster