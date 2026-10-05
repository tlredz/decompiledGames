local RunService = game:GetService("RunService")
local CooldownAcceleration = {
	Attribute = "CooldownAccelMultiplier"
}
local attribute = CooldownAcceleration.Attribute
local object = setmetatable({}, {
	__mode = "k"
})
local heartbeatConnection = nil

local function computeMultiplier(effects)
	local total = 0
	local v = false

	for _, item in pairs(effects) do
		local v2 = 0

		for _, v3 in pairs(item) do
			if v2 < v3 then
				v2 = v3
			end
		end

		if not (v2 > 0) then
			continue
		end

		total += v2
		v = true
	end

	return v and total or 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function publish(instance, p)
	pcall(function()
		instance:SetAttribute(attribute, p > 1 and p or nil)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh(instance)
	local v = object[instance]

	if not v then
		return
	end

	local multiplier = computeMultiplier(v.effects)

	if multiplier <= 1 then
		object[instance] = nil
		publish(instance, 1) -- equivalent call inferred; original call site unknown
	else
		if multiplier == v.multiplier then
			return
		end

		v.multiplier = multiplier
		publish(instance, multiplier) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopLoopIfIdle()
	if heartbeatConnection and next(object) == nil then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function heartbeat(p)
	for k, v in pairs(object) do
		if k.Parent then
			local abilities = k:FindFirstChild("Abilities")
			local ability1 = abilities and abilities:FindFirstChild("Ability1")
			local currentCooldown = ability1 and ability1:FindFirstChild("CurrentCooldown")

			if currentCooldown and currentCooldown.Value > 0 then
				currentCooldown.Value = math.max(0, currentCooldown.Value - p * (v.multiplier - 1))
			end
		else
			object[k] = nil
		end
	end

	stopLoopIfIdle() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureLoop()
	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(heartbeat)
	end
end

function CooldownAcceleration.Apply(instance, value, value2, p)
	if typeof(instance) ~= "Instance" or (type(value) ~= "string" or value == "") then
		return
	end

	if type(value2) ~= "number" or value2 <= 1 then
		return
	end

	local v = p or value
	local v2 = object[instance]

	if not v2 then
		v2 = {
			effects = {},
			multiplier = 1
		}
		object[instance] = v2
	end

	local effect = v2.effects[value]

	if not effect then
		effect = {}
		v2.effects[value] = effect
	end

	effect[v] = value2
	refresh(instance) -- equivalent call inferred; original call site unknown
	ensureLoop() -- equivalent call inferred; original call site unknown
end

function CooldownAcceleration.Remove(instance, value, p)
	if not (typeof(instance) == "Instance" and type(value) == "string") then
		return
	end

	local v = object[instance]

	if not v then
		return
	end

	local effect = v.effects[value]

	if not effect then
		return
	end

	effect[p or value] = nil

	if next(effect) == nil then
		v.effects[value] = nil
	end

	refresh(instance) -- equivalent call inferred; original call site unknown
	stopLoopIfIdle() -- equivalent call inferred; original call site unknown
end

function CooldownAcceleration.ClearCharacter(instance)
	if not (typeof(instance) == "Instance" and object[instance]) then
		return
	end

	object[instance] = nil
	publish(instance, 1) -- equivalent call inferred; original call site unknown
	stopLoopIfIdle() -- equivalent call inferred; original call site unknown
end

function CooldownAcceleration.GetMultiplier(instance)
	local v

	if typeof(instance) == "Instance" then
		v = object[instance]
	else
		v = false
	end

	return v and v.multiplier or 1
end

return CooldownAcceleration