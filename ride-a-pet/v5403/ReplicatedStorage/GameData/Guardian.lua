local v = {
	SpawnTag = "GuardianSpawn",
	BoundsTag = "GuardianBounds",
	RigTag = "VolkarisLair",
	Eggs = table.freeze({
		["Volcanic Egg"] = true
	}),
	WakeSeconds = 1.6,
	ChaseSpeed = 85,
	ReturnSpeed = 60,
	Responsiveness = 25,
	TurnRate = 240,
	FacingOffset = 0,
	CatchRadius = 22,
	CatchImmunitySeconds = 6,
	HomeRadius = 6,
	MaxChaseSeconds = 120,
	LeashRadius = 600,
	CrumbSpacing = 12,
	CrumbInterval = 0.1,
	LookaheadRadius = 45,
	DirectRadius = 60,
	MaxCrumbs = 64,
	LeadSeconds = 0.25,
	BrainHz = 15,
	AlertSeconds = 8,
	PulseCount = 5,
	PulseSeconds = 1.5,
	AlertColor = Color3.fromRGB(255, 40, 40),
	FireballAsset = "Fireball",
	FireballInterval = 3,
	FirstFireballDelay = 1.5,
	FireballWindup = 0.4,
	FireballSpeed = 160,
	FireballHitRadius = 7,
	FireballRange = 500,
	FireballMinDistance = 45,
	FireballMaxDistance = 400,
	FireballLeadAccuracy = 0.75,
	FireballMaxLeadSeconds = 2,
	FireballSpread = 6,
	RagdollSeconds = 2.5,
	KnockbackSpeed = 90,
	KnockbackLift = 45,
	Box = function(instance)
		return {
			Inverse = instance.CFrame:Inverse(),
			Half = instance.Size / 2
		}
	end,
	InBox = function(p, vector: Vector3)
		local vector2 = p.Inverse * vector
		local half = p.Half
		return math.abs(vector2.X) <= half.X and math.abs(vector2.Y) <= half.Y and math.abs(vector2.Z) <= half.Z
	end
}

function v.IsInside(items, vector: Vector3)
	for _, item in items do
		if v.InBox(item, vector) then
			return true
		end
	end

	return false
end

return table.freeze(v)