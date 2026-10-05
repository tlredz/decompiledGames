local SoulvesterMonster = {
	Name = "Twisted Soulvester",
	Rarity = "Uncommon",
	Icon = "rbxassetid://112352886297624",
	VisionRadius = 60,
	InstantRadius = 26,
	WalkSpeed = 8,
	RunSpeed = 16,
	InterestTime = 3.5,
	HearingRadius = 125,
	Damage = 1,
	LineOfSight = 0.4,
	KillRadius = 3.33,
	HitCooldown = 3,
	Holiday = true,
	Halloween = true,
	WaitTime = 10,
	UseBehaviorTree = true
}
local object = setmetatable({}, {
	__mode = "k"
})

local function generatorStandPart(child)
	local teleportPositions = child:FindFirstChild("TeleportPositions")
	local teleportPosition = teleportPositions and teleportPositions:FindFirstChild("TeleportPosition")

	if teleportPosition and teleportPosition:IsA("BasePart") then
		return teleportPosition
	end

	if child:IsA("Model") then
		return child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
	end

	return child:IsA("BasePart") and child or nil
end

function SoulvesterMonster.SelectPatrolWaypoint(_, p)
	local parent = p and p.Parent and p.Parent.Parent
	local generators = parent and parent:FindFirstChild("Generators")

	if not generators then
		return nil
	end

	local v = object[p]
	local v2 = {}

	for _, child in ipairs(generators:GetChildren()) do
		local stand = generatorStandPart(child)

		if stand then
			table.insert(v2, {
				generator = child,
				stand = stand
			})
		end
	end

	if #v2 == 0 then
		return nil
	end

	if #v2 > 1 and v then
		for i, v4 in ipairs(v2) do
			if v4.generator ~= v then
				continue
			end

			table.remove(v2, i)
			break
		end
	end

	local v3 = v2[math.random(1, #v2)]
	object[p] = v3.generator
	return v3.stand
end

SoulvesterMonster.PatrolCompanion = "ConnieMonster"
SoulvesterMonster.CompanionRole = "follower"
SoulvesterMonster.CompanionFollowDistance = 12

function SoulvesterMonster.CustomPatrol(p)
	return p.PatrolModule.buildCompanionPatrol(p)
end

SoulvesterMonster.SpecialAnimatorData = {
	Module = "MonsterModules/SpecialAnimator",
	Config = {
		AttackTexture = "rbxassetid://71124019437063",
		BlinkTexture = "rbxassetid://70917867889992",
		NormalTexture = "rbxassetid://75956501547734"
	}
}

function SoulvesterMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, SoulvesterMonster.SpecialAnimatorData.Config)
end

return SoulvesterMonster