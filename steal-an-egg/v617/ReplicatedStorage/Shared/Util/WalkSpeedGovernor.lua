local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local t = require(ReplicatedStorage.Packages.t)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))
local strict = t.strict(intersection)
local strict2 = t.strict(t.optional(t.instanceIsA("Humanoid")))
local strict3 = t.strict(t.optional(t.string))
local strict4 = t.strict(t.string)
local WalkSpeedGovernor = {}
WalkSpeedGovernor.__index = WalkSpeedGovernor

local function foldModifiers(baseSpeed: number, modifiers)
	strict(baseSpeed)
	local v = {}
	local total = 0

	for _, v2 in ipairs(modifiers) do
		if v2.type == "positive" then
			total += v2.value
		elseif v2.type == "malus" then
			table.insert(v, v2.value)
		end
	end

	local v2 = baseSpeed * (total + 1)

	for _, v3 in ipairs(v) do
		v2 *= v3 + 1
	end

	return (math.max(0, v2))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refold(state)
	local v = foldModifiers(state.baseSpeed, state.modifiers)

	if math.abs(v - state.appliedSpeed) < 0.001 then
		return
	end

	state.appliedSpeed = v

	if state.humanoid then
		state.humanoid.WalkSpeed = v
	end
end

function WalkSpeedGovernor.new(p: number?)
	local v = p or Constants.BASE_WALK_SPEED
	strict(v)
	assert(v > 0)
	local self = setmetatable({}, WalkSpeedGovernor)
	self.baseSpeed = v
	self.appliedSpeed = v
	self.modifiers = {}
	self.humanoid = nil
	return self
end

function WalkSpeedGovernor.CurrentSpeed(p)
	return p.appliedSpeed
end

function WalkSpeedGovernor.BaseSpeed(p)
	return p.baseSpeed
end

function WalkSpeedGovernor.Modifiers(p)
	return p.modifiers
end

function WalkSpeedGovernor:Bind(humanoid)
	strict2(humanoid)

	if self.humanoid == humanoid then
		return
	end

	self.humanoid = humanoid

	if humanoid then
		humanoid.WalkSpeed = self.appliedSpeed
	end
end

function WalkSpeedGovernor:Rebase(baseSpeed: number)
	strict(baseSpeed)
	assert(baseSpeed > 0)

	if self.baseSpeed == baseSpeed then
		return
	end

	self.baseSpeed = baseSpeed
	refold(self) -- equivalent call inferred; original call site unknown
end

function WalkSpeedGovernor.Attach(state, id: string, p2: string, p3: number, source: string?)
	strict4(id)
	assert(p2 == "positive" or p2 == "malus")
	strict(p3)
	strict3(source)

	for _, modifier in ipairs(state.modifiers) do
		if modifier.id == id then
			error((`A modifier called {id} is already attached to this stat`))
		end
	end

	table.insert(state.modifiers, {
		id = id,
		type = p2,
		value = p3,
		source = source
	})
	refold(state) -- equivalent call inferred; original call site unknown
end

function WalkSpeedGovernor.HasModifier(p, p2: string)
	strict4(p2)

	for _, modifier in ipairs(p.modifiers) do
		if modifier.id == p2 then
			return true
		end
	end

	return false
end

function WalkSpeedGovernor:Detach(p: string)
	strict4(p)

	for i, modifier in ipairs(self.modifiers) do
		if modifier.id ~= p then
			continue
		end

		table.remove(self.modifiers, i)
		local v = foldModifiers(self.baseSpeed, self.modifiers)

		if math.abs(v - self.appliedSpeed) < 0.001 then
			break
		end

		self.appliedSpeed = v

		if self.humanoid then
			self.humanoid.WalkSpeed = v
		end

		break
	end
end

function WalkSpeedGovernor.DetachSource(state, p: string)
	strict4(p)
	local flag = false

	for i = #state.modifiers, 1, -1 do
		if state.modifiers[i].source ~= p then
			continue
		end

		table.remove(state.modifiers, i)
		flag = true
	end

	if flag then
		refold(state) -- equivalent call inferred; original call site unknown
	end
end

function WalkSpeedGovernor:Destroy()
	self.humanoid = nil
end

return WalkSpeedGovernor