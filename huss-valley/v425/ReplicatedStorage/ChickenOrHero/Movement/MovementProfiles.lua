local MovementConfig = require(script.Parent.MovementConfig)
local CrossingBalance = require(script.Parent.CrossingBalance)
local KnifePerks = require(script.Parent.Parent.Weapons.KnifePerks)
local clone = table.clone(MovementConfig)
clone.MaxSpeed = MovementConfig.MaxSpeed * MovementConfig.RunnerSpeedMultiplier
clone.Acceleration = MovementConfig.Acceleration * MovementConfig.RunnerAccelerationMultiplier
clone.TurnRetention90 = MovementConfig.RunnerTurnRetention90
table.freeze(clone)
local clone2 = table.clone(MovementConfig)
clone2.MaxSpeed = MovementConfig.MaxSpeed * MovementConfig.CatcherSpeedMultiplier
clone2.TurnRate = MovementConfig.CatcherTurnRate
clone2.SlowTurnRate = MovementConfig.CatcherSlowTurnRate
local clone3 = table.clone(MovementConfig.Dash)
clone3.Enabled = false
clone2.Dash = table.freeze(clone3)
table.freeze(clone2)
local v2 = {
	Runner = {},
	Catcher = {}
}

local function baseProfile(p, instance)
	local v3 = p == "Catcher" and clone2 or p == "Runner" and clone or MovementConfig

	if v3 == MovementConfig or not (instance and MovementConfig.CrossingBalance.Enabled) then
		return v3
	end

	local attribute = instance:GetAttribute(p == "Catcher" and "CrossingCatcherSpeedScale" or "CrossingRunnerSpeedScale")

	if type(attribute) ~= "number" or attribute ~= attribute then
		return v3
	end

	local v4 = math.floor(math.clamp(
		attribute,
		p ~= "Catcher" and 1 or 1 - MovementConfig.CrossingBalance.CatcherMaxReduction or 1,
		p ~= "Runner" and 1 or 1 + MovementConfig.CrossingBalance.RunnerMaxBonus or 1
	) * 10000 + 0.5)
	local v5 = v4 / 10000
	local pressure = 0

	if p == "Runner" then
		local crossingCatcherCount = instance:GetAttribute("CrossingCatcherCount")
		local crossingRunnerCount = instance:GetAttribute("CrossingRunnerCount")

		if type(crossingCatcherCount) == "number" and type(crossingRunnerCount) == "number" then
			pressure = CrossingBalance.calculate(crossingCatcherCount, crossingRunnerCount).pressure
		elseif MovementConfig.CrossingBalance.RunnerMaxBonus > 0 then
			pressure = (v5 - 1) / MovementConfig.CrossingBalance.RunnerMaxBonus
		end

		pressure = math.floor(math.clamp(pressure, 0, 1) * 10000 + 0.5) / 10000
	end

	if v4 == 10000 and pressure == 0 then
		return v3
	end

	local v6 = tostring(v4) .. ":" .. tostring(pressure)
	local v7 = v2[p][v6]

	if v7 then
		return v7
	end

	local clone4 = table.clone(v3)

	for _, v8 in {
		"MaxSpeed",
		"Acceleration",
		"Deceleration",
		"StopThreshold",
		"StallSpeed",
		"StallSpeedCap"
	} do
		clone4[v8] = v3[v8] * v5
	end

	if p == "Runner" then
		local crossingBalance = MovementConfig.CrossingBalance
		clone4.Acceleration *= 1 + crossingBalance.RunnerMaxAccelerationBonus * pressure
		clone4.Deceleration *= 1 + crossingBalance.RunnerMaxBrakingBonus * pressure
		clone4.TurnRetention90 = v3.TurnRetention90 + (crossingBalance.RunnerMaxTurnRetention - v3.TurnRetention90) * pressure
	end

	local clone5 = table.clone(v3.Dash)
	clone5.Distance = v3.Dash.Distance * v5
	clone4.Dash = table.freeze(clone5)
	local frozen = table.freeze(clone4)
	v2[p][v6] = frozen
	return frozen
end

local object = setmetatable({}, {
	__mode = "k"
})
return table.freeze({
	get = function(p, instance)
		local v3 = baseProfile(p, instance)
		local v4 = instance and instance:GetAttribute("GearSlow") == true
		local v5 = instance and instance:GetAttribute("GearBoost") == true
		local v6 = (p == "Runner" or p == "Catcher") and KnifePerks.get(instance) or KnifePerks.forSkin(nil)

		if not v4 and not v5 and v6.Key == "None" then
			return v3
		end

		local v7 = (v4 and "s" or "") .. (v5 and "b" or "") .. v6.Key
		local values = object[v3]

		if not values then
			values = {}
			object[v3] = values
		end

		if values[v7] then
			return values[v7]
		end

		local clone4 = table.clone(v3)
		clone4.MaxSpeed += v6.SpeedBonus

		if v6.CooldownReduction > 0 then
			local clone5 = table.clone(v3.Dash)
			clone5.Cooldown = math.max(0, clone5.Cooldown - v6.CooldownReduction)
			clone4.Dash = table.freeze(clone5)
		end

		if v4 then
			clone4.MaxSpeed *= 0.55
			clone4.Acceleration *= 0.7
		end

		if v5 then
			clone4.Acceleration *= 1.6
			clone4.TurnRetention90 = math.min(0.95, clone4.TurnRetention90 + 0.15)
		end

		values[v7] = table.freeze(clone4)
		return values[v7]
	end
})