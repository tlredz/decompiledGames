local EclipseMonster = {
	Name = "Twisted Eclipse",
	Rarity = "Rare",
	Icon = "rbxassetid://117268425407246",
	Holiday = true,
	Halloween = true,
	VisionRadius = 60,
	InstantRadius = 30,
	WalkSpeed = 10,
	RunSpeed = 19,
	InterestTime = 2,
	HearingRadius = 125,
	Damage = 1,
	WaitTime = 1,
	LineOfSight = 0.4,
	KillRadius = 3.33,
	HitCooldown = 3,
	ChaseAbility = false,
	AbilityCooldown = 0,
	UseBehaviorTree = true,
	HowlTexture = "rbxassetid://73377692523116",
	HowlSound = "Sounds.Effects.EclipseHowl",
	HowlAnimation = "rbxassetid://77203626514357",
	HowlDuration = 2.5
}

local function getHowlInstance(instance)
	local EclipseHowl = require(game.ReplicatedStorage.MonsterModules.EclipseHowl)
	EclipseMonster.HowlInstances = EclipseMonster.HowlInstances or {}
	local howlInstance = EclipseMonster.HowlInstances[instance]

	if not howlInstance then
		howlInstance = EclipseHowl.new(instance, {
			HowlSound = EclipseMonster.HowlSound,
			HowlAnimation = EclipseMonster.HowlAnimation,
			HowlDuration = EclipseMonster.HowlDuration
		})
		EclipseMonster.HowlInstances[instance] = howlInstance
	end

	return howlInstance
end

local function performHowl(_, instance, instance2)
	local success, result = pcall(function()
		if not (instance2 and instance2.Parent) then
			warn("EclipseMonster: howl fired with invalid target")
			return
		end

		if not instance:GetAttribute("Chasing") then
			return
		end

		local lastHowlTarget = instance:GetAttribute("LastHowlTarget")
		local isCurrentlyChasing = instance:GetAttribute("IsCurrentlyChasing")

		if lastHowlTarget == instance2.Name and isCurrentlyChasing then
			return
		end

		instance:SetAttribute("IsCurrentlyChasing", true)
		local howlInstance = getHowlInstance(instance)

		if howlInstance then
			howlInstance:performHowl(instance2)
			instance:SetAttribute("LastHowlTarget", instance2.Name)
		end

		local chasingChangedConnection = nil
		chasingChangedConnection = instance:GetAttributeChangedSignal("Chasing"):Connect(function()
			if not instance:GetAttribute("Chasing") then
				instance:SetAttribute("IsCurrentlyChasing", false)

				if chasingChangedConnection then
					chasingChangedConnection:Disconnect()
				end
			end
		end)
	end)

	if not success then
		warn("EclipseMonster: Failed to use howl ability:", result)
	end
end

EclipseMonster.Abilities = {
	{
		kind = "worldEvent",
		name = "howl",
		condition = "onChaseStart",
		effect = performHowl
	}
}
EclipseMonster.SpecialAnimatorData = {
	Module = "MonsterModules/SpecialAnimator",
	Config = {
		AttackTexture = "rbxassetid://129045968148662",
		BlinkTexture = "rbxassetid://88045517554273",
		NormalTexture = "rbxassetid://83045071460678",
		HowlTexture = EclipseMonster.HowlTexture
	}
}

function EclipseMonster.SpecialAnimator(p)
	local SpecialAnimator = require(game.ReplicatedStorage.MonsterModules.SpecialAnimator)
	SpecialAnimator.new(p, EclipseMonster.SpecialAnimatorData.Config)
end

function EclipseMonster.Cleanup(instance)
	local v = EclipseMonster.HowlInstances and EclipseMonster.HowlInstances[instance]

	if EclipseMonster.HowlInstances then
		EclipseMonster.HowlInstances[instance] = nil
	end

	if v and v.cleanup then
		v:cleanup()
	end

	instance:SetAttribute("LastHowlTarget", nil)
	instance:SetAttribute("IsCurrentlyChasing", nil)
end

return EclipseMonster