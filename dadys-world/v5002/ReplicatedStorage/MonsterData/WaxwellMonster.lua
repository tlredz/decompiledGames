local ServerStorage = game:GetService("ServerStorage")
local WaxwellMonster = {
	Name = "Twisted Waxwell",
	Rarity = "Rare",
	Icon = "rbxassetid://99884081850470",
	Render = "rbxassetid://74781158597225",
	Description = "This timid Twisted avoids Toons rather than chases after them. His flame steadily builds over time, but stops when any Toon is nearby. At full flame, he leaves a trail behind that grants other Twisteds the Ignited buff, increasing their vision radius and reducing their hit cooldown. This buff does not stack.",
	Trinket = "CherishedBlanket",
	UseBehaviorTree = true,
	VisionRadius = 90,
	InstantRadius = 20,
	WalkSpeed = 8,
	RunSpeed = 20,
	InterestTime = 3,
	HearingRadius = 60,
	Damage = 1,
	WaitTime = 4,
	LineOfSight = 0.4,
	KillRadius = 3.3,
	HitCooldown = 2,
	ChaseAbility = false,
	AbilityCooldown = 0,
	NoChase = false,
	SuppressChasingUntilActivated = true,
	AnimationOverrides = true,
	IdleAnimationId = "rbxassetid://105028326611083",
	LostInterestAnimationId = "rbxassetid://129459822159720",
	RunAnimationId = "rbxassetid://105969087767711",
	WalkAnimationId = "rbxassetid://121015259020386",
	ScaredMoodFx = {
		agro = {
			Idle = "rbxassetid://105028326611083",
			LostInterest = "rbxassetid://129459822159720",
			Run = "rbxassetid://105969087767711",
			Walk = "rbxassetid://121015259020386"
		},
		confident = {
			Idle = "rbxassetid://105028326611083",
			LostInterest = "rbxassetid://129459822159720",
			Run = "rbxassetid://105969087767711",
			Walk = "rbxassetid://105969087767711"
		},
		scared = {
			Idle = "rbxassetid://99122691822097",
			LostInterest = "rbxassetid://80629302857570",
			Walk = "rbxassetid://92113036864516",
			Run = "rbxassetid://105969087767711"
		},
		panic = {
			Idle = "rbxassetid://99122691822097",
			LostInterest = "rbxassetid://80629302857570",
			Walk = "rbxassetid://92113036864516",
			Run = "rbxassetid://126885482494103"
		}
	},
	ConfidentSpeed = 16,
	SpecialAnimatorData = {
		Module = "MonsterModules/SpecialAnimator",
		Config = {
			NormalTexture = "rbxassetid://104254782093753",
			BlinkTexture = "rbxassetid://127163171462529",
			AttackTexture = "rbxassetid://127014675750736"
		}
	}
}

function WaxwellMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, WaxwellMonster.SpecialAnimatorData.Config)
end

function WaxwellMonster.SpecialSetup(instance)
	instance:SetAttribute("SuppressChasingUntilActivated", true)
	instance:SetAttribute("TreeHandlesAlerts", true)
	local CowardMoodFx = require(ServerStorage.ServerMonsterModules.CowardMoodFx)
	CowardMoodFx.attach(instance, WaxwellMonster.ScaredMoodFx)
end

WaxwellMonster.Abilities = {
	{
		kind = "aura",
		name = "supportBuff",
		lane = "always",
		radius = 60,
		maxTargets = 6,
		tickRate = 0.25,
		stats = {
			attackspeed = 1.25,
			VisionRadius = 1.3
		}
	}
}
WaxwellMonster.FleesFromToons = true
WaxwellMonster.FleeRadius = 25
WaxwellMonster.AvoidRadius = 65
WaxwellMonster.FleeStopRadius = 75
WaxwellMonster.FleeDistance = 30
WaxwellMonster.HidesWhenScared = false

function WaxwellMonster.SelectPatrolWaypoint(list, instance)
	local _FleeExitT = instance and instance:GetAttribute("_FleeExitT")

	if not _FleeExitT or tick() - _FleeExitT > 20 then
		return nil
	end

	local _FleeExitThreatX = instance:GetAttribute("_FleeExitThreatX")
	local _FleeExitThreatZ = instance:GetAttribute("_FleeExitThreatZ")

	if not (_FleeExitThreatX and _FleeExitThreatZ) then
		return nil
	end

	local v = {}

	for _, part in ipairs(list) do
		if not part:IsA("BasePart") then
			continue
		end

		local v2 = part.Position.X - _FleeExitThreatX
		local v3 = part.Position.Z - _FleeExitThreatZ
		table.insert(v, {
			wp = part,
			dist = v2 * v2 + v3 * v3
		})
	end

	if #v == 0 then
		return nil
	end

	table.sort(v, function(a, b)
		return a.dist > b.dist
	end)
	return v[math.random(1, (math.min(3, #v)))].wp
end

return WaxwellMonster