local v = {
	MaximumMutations = 1,
	List = {
		"Fire",
		"Water",
		"Lightning",
		"Ice",
		"Wind",
		"Earth",
		"Poison",
		"Light",
		"Dark",
		"Physical"
	},
	Config = {
		Fire = {
			Chance = 25,
			Duration = 5,
			MaxStacks = 5,
			DamagePercent = 15
		},
		Water = {
			FluxChance = 25
		},
		Lightning = {
			SpreadChance = 15,
			SpreadRadius = 25,
			SpreadDamagePercent = 100
		},
		Ice = {
			SlowPerStack = 14,
			MaxStacks = 7,
			ExplosionDamagePercent = 150,
			ExplosionImmunity = 1
		},
		Wind = {
			AttackSpeedPerStack = 5,
			MaxStacks = 10,
			MovementSpeedBonus = 20
		},
		Earth = {
			AttackSpeedPenalty = 50,
			DamageBonus = 100
		},
		Poison = {
			Chance = 30,
			Duration = 5,
			MaxStacks = 4,
			DamagePercent = 20
		},
		Physical = {
			CritChance = 15,
			CritMultiplier = 5
		},
		Light = {
			BlessingChance = 25,
			BlessingDuration = 5,
			BlessingSpeedBonus = 100
		},
		Dark = {
			ControlLossChance = 25,
			ControlLossDuration = 5,
			ControlLossSwing = 75
		}
	}
}

function v.GetConfig(p: string)
	return v.Config[p]
end

function v.Normalize(list)
	local result = {}

	if typeof(list) ~= "table" then
		return result
	end

	local v2 = {}

	for _, v3 in ipairs(list) do
		if typeof(v3) ~= "string" or not v.Config[v3] or v2[v3] then
			continue
		end

		v2[v3] = true
		table.insert(result, v3)

		if #result >= v.MaximumMutations then
			break
		end
	end

	return result
end

function v.GetKey(p)
	local normalized = v.Normalize(p)
	table.sort(normalized)
	return table.concat(normalized, "|")
end

function v.Roll(items, p: number?)
	local total = 0
	local v2 = {}

	for k, item in items do
		assert(v.Config[k] ~= nil, (`Unknown mutation: {k}`))
		local v3

		if typeof(item) == "number" and item == item and item >= 0 then
			v3 = item <= 100
		else
			v3 = false
		end

		assert(v3, "Invalid mutation chance")
		total += item
		table.insert(v2, k)
	end

	assert(total <= 100, "Mutation chances exceed 100%")
	table.sort(v2)
	local v3 = p or math.random() * 100
	local v4

	if v3 >= 0 then
		v4 = v3 < 100
	else
		v4 = false
	end

	assert(v4, "Mutation roll must be in [0, 100)")
	local total2 = 0

	for _, v5 in v2 do
		total2 += items[v5]

		if v3 < total2 then
			return { v5 }
		end
	end

	return {}
end

function v:ApplyBuff(name: string)
	if not self or self.Destroyed or self.MutationBuff or not table.find(self.Mutations or {}, name) then
		return
	end

	local v2 = v.Config[name]
	local blessingDuration = name == "Light" and v2.BlessingDuration or v2.ControlLossDuration

	if not blessingDuration then
		return
	end

	self.MutationBuff = {
		Name = name,
		ExpiresAt = os.clock() + blessingDuration
	}
end

function v:GetBuffContext()
	if not self or self.Destroyed then
		return nil
	end

	local mutationBuff = self.MutationBuff

	if not mutationBuff then
		return nil
	end

	if os.clock() >= mutationBuff.ExpiresAt or not table.find(self.Mutations or {}, mutationBuff.Name) then
		self.MutationBuff = nil
		return nil
	end

	local v2 = v.Config[mutationBuff.Name]

	if mutationBuff.Name == "Light" then
		return {
			SpeedBonus = v2.BlessingSpeedBonus
		}
	end

	return {
		Swing = (math.random() < 0.5 and -1 or 1) * v2.ControlLossSwing
	}
end

function v.ResolveDamage(options, p: number, p2, value: number?, value2: number?)
	local v2 = value or 0
	local critMultiplier = 2
	local v3 = false

	if table.find(options or {}, "Earth") then
		p *= 1 + v.Config.Earth.DamageBonus / 100
	end

	if table.find(options or {}, "Physical") then
		v2 += v.Config.Physical.CritChance
		critMultiplier = v.Config.Physical.CritMultiplier
	end

	if v2 > 0 and math.random() * 100 < math.clamp(v2, 0, 100) then
		p *= critMultiplier * (value2 or 1)
		v3 = true
	end

	if p2 and p2.Swing then
		p *= math.max(0, 1 + p2.Swing / 100)
	end

	return p, v3
end

function v.ResolveAttackSpeed(options, p: number, value: number?, p2)
	if table.find(options or {}, "Wind") then
		local wind = v.Config.Wind
		p /= 1 + math.clamp(value or 0, 0, wind.MaxStacks) * wind.AttackSpeedPerStack / 100
	end

	if table.find(options or {}, "Earth") then
		p *= 1 + v.Config.Earth.AttackSpeedPenalty / 100
	end

	if p2 and p2.SpeedBonus then
		p /= 1 + p2.SpeedBonus / 100
	end

	if not (p2 and p2.Swing) then
		return (math.max(p, 0.05))
	end

	local v2 = math.max(0, 1 + p2.Swing / 100)

	if v2 == 0 then
		return 1e999
	end

	p /= v2
	return (math.max(p, 0.05))
end

function v.ResolveMovementSpeed(options, p: number, p2)
	if table.find(options or {}, "Wind") then
		p *= 1 + v.Config.Wind.MovementSpeedBonus / 100
	end

	if p2 and p2.SpeedBonus then
		p *= 1 + p2.SpeedBonus / 100
	end

	return p
end

return table.freeze(v)