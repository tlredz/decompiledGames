local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local BlottMonster = {
	Name = "Twisted Blot",
	Rarity = "Rare",
	Icon = "rbxassetid://95105136839962",
	VisionRadius = 0,
	InstantRadius = 0,
	WalkSpeed = 0,
	RunSpeed = 0,
	InterestTime = 0,
	HearingRadius = 0,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0,
	KillRadius = 4,
	HitCooldown = 2,
	LostInterestAnimationTime = 0,
	ResearchRadius = 20,
	PatrolGroupTag = "BlottSiblings",
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			BlinkTexture = "rbxassetid://94533343995296",
			NormalTexture = "rbxassetid://88467880715704",
			AttackTexture = "rbxassetid://137066710753963"
		}
	},
	BlotHands = {
		Count = 2,
		Size = createVector(12, 5, 12),
		GroundOffset = 0,
		States = {
			EMERGING = "Emerging",
			IDLE = "Idle",
			ATTACKING = "Attacking",
			COOLDOWN = "Cooldown",
			RETURNING = "Returning",
			SEARCHING = "Searching"
		},
		EmergeDuration = 3.5,
		AttackStrikeTime = 0.3,
		CooldownDuration = 2,
		ReturnDuration = 2.5,
		AttackAnimationActualDuration = 1.5,
		TauntAnimationActualDuration = 1,
		InstanceRegistry = {},
		AggroCycleDuration = 60,
		IdleCycleDuration = 20,
		GlobalTauntCooldown = 12,
		LastGlobalTauntTime = 0,
		IdleBehaviour = {
			LookRadius = 40,
			FaceInterval = 0.15,
			TauntMin = 3,
			TauntMax = 7,
			TauntAnims = { "ComeHere", "HandSearching" },
			ComeHereRange = 30
		},
		AttackCooldowns = {},
		PlayerPriority = {},
		ActivePlayers = {},
		MaxQueueSize = 10,
		ZonePlayers = {},
		ActiveZones = {},
		AttackInFlight = {},
		Sounds = {
			Attack = "Sounds.Twisted.Blott.Attack",
			Emerge = "Sounds.Twisted.Blott.HandEmerge",
			Submerge = "Sounds.Twisted.Blott.HandSubmerge"
		}
	},
	SpecialBehavior = {
		HandAttackEnabled = true,
		HandAttackRadius = 5,
		IchorPoolEnabled = true,
		IchorPoolSize = createVector(5, 1, 5)
	}
}

function BlottMonster.SpecialAnimator(p)
	local SpecialAnimator = require(ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, BlottMonster.SpecialAnimatorData.Config)
end

function BlottMonster.SpecialChaser(p)
	local SpecialChaserHost = require(ServerScriptService.MonsterAI.BehaviorTree.SpecialChaserHost)
	SpecialChaserHost.start(p)
end

return BlottMonster