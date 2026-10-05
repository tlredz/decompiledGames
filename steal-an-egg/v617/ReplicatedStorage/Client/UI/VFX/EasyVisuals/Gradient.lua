local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local StopRamp = require(script.Parent.StopRamp)
local t = require(ReplicatedStorage.Packages.t)
local heartbeat = RunService.Heartbeat
local v = {
	TextLabel = true,
	TextBox = true,
	TextButton = true
}
local class = {}
class.__index = class
class.__class = "Gradient"
local strict = t.strict(t.union(t.instanceIsA("GuiObject"), t.instanceIsA("UIStroke")))
local strict2 = t.strict(t.number)
local strict3 = t.strict(t.ColorSequence)
local strict4 = t.strict(t.union(t.number, t.NumberSequence))

local function flatAlpha(p: number)
	return NumberSequence.new({ NumberSequenceKeypoint.new(0, p), NumberSequenceKeypoint.new(1, p) })
end

local function settle(value: number)
	return (math.clamp(value, 0, 1))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function newSweep(response: number)
	return {
		now = 0,
		goal = nil,
		rate = 0,
		rateGoal = 0,
		response = response
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function holdAt(p, goal: number, value: number)
	p.goal = goal
	p.rate = 0
	p.rateGoal = 0
	p.response = math.clamp(value, 0, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function driftAt(p, rateGoal: number, value: number)
	p.rateGoal = rateGoal
	p.goal = nil
	p.response = math.clamp(value, 0, 1)
end

local function step(state, p: number)
	local goal = state.goal

	if goal then
		state.now += (goal - state.now) * state.response
		return state.now
	end

	state.rate += (state.rateGoal - state.rate) * state.response * p
	state.now += state.rate * p
	return state.now
end

local function borrowGradient(instance)
	local uIGradient = instance:FindFirstChildWhichIsA("UIGradient")

	if uIGradient then
		return uIGradient
	end

	return Instance.new("UIGradient")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function release(state)
	state.driver:Disconnect()

	if state.gradient then
		state.gradient:Destroy()
		state.gradient = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolvePalette(state)
	local drift = StopRamp.Drift(state.palette.Keypoints, StopRamp.Colour, state.phase.now, 5, 100)
	state.paletteResolved = ColorSequence.new(drift)
	return state.paletteResolved
end

local function resolveAlpha(state)
	local keypoints = state.alphaStopsGoal.Keypoints

	if #keypoints == 2 and keypoints[1].Value == keypoints[2].Value then
		state.alphaResolved = state.alphaStopsGoal
		return state.alphaStopsGoal
	end

	local keypoints2 = state.alphaStops.Keypoints
	local drift = StopRamp.Drift(keypoints2, StopRamp.Alpha, state.alphaPhase.now, #keypoints2 + 1, 1e999)
	state.alphaResolved = NumberSequence.new(drift)
	return state.alphaResolved
end

local function advance(object, frameDebt: number)
	if object.paletteBlend == 1 then
		object.palette = object.paletteGoal
	else
		object.palette = ColorSequence.new(StopRamp.Restripe(
			object.paletteGoal.Keypoints,
			object.palette.Keypoints,
			object.paletteBlend,
			StopRamp.Colour
		))
	end

	if object.alphaBlend == 1 then
		object.alphaStops = object.alphaStopsGoal
	end

	local gradient = object.gradient
	local angle = object.angle
	local goal = angle.goal

	if goal then
		angle.now += (goal - angle.now) * angle.response
	else
		angle.rate += (angle.rateGoal - angle.rate) * angle.response * frameDebt
		angle.now += angle.rate * frameDebt
	end

	gradient.Rotation = angle.now
	local phase = object.phase
	local goal2 = phase.goal

	if goal2 then
		phase.now += (goal2 - phase.now) * phase.response
	else
		phase.rate += (phase.rateGoal - phase.rate) * phase.response * frameDebt
		phase.now += phase.rate * frameDebt
	end

	local _ = phase.now
	local alphaPhase = object.alphaPhase
	local goal3 = alphaPhase.goal

	if goal3 then
		alphaPhase.now += (goal3 - alphaPhase.now) * alphaPhase.response
	else
		alphaPhase.rate += (alphaPhase.rateGoal - alphaPhase.rate) * alphaPhase.response * frameDebt
		alphaPhase.now += alphaPhase.rate * frameDebt
	end

	local _ = alphaPhase.now
	gradient.Color = resolvePalette(object)
	gradient.Transparency = resolveAlpha(object)
end

function class.new(instance, sequence, value)
	strict(instance)
	strict3(sequence)
	strict4(value)
	assert(#sequence.Keypoints <= 19, (`a wash accepts at most {19} colour stops`))

	if typeof(value) == "NumberSequence" then
		assert(#value.Keypoints <= 19, (`a wash accepts at most {19} alpha stops`))
	end

	if typeof(value) == "number" then
		value = flatAlpha(value)
	end

	local object = setmetatable({
		host = instance,
		gradient = instance:FindFirstChildWhichIsA("UIGradient") or Instance.new("UIGradient"),
		driver = nil,
		isPaused = false,
		isTextHost = v[instance.ClassName] == true,
		frameDebt = 0.05,
		palette = sequence,
		paletteGoal = sequence,
		paletteResolved = nil,
		paletteBlend = 1,
		alphaStops = value,
		alphaStopsGoal = value,
		alphaResolved = nil,
		alphaBlend = 1,
		phase = newSweep(1),
		alphaPhase = newSweep(1),
		angle = newSweep(0),
		strandedAlphaGoal = nil,
		strandedAlphaResponse = nil
	}, class)
	object.driver = heartbeat:Connect(function(frameDebt: number)
		if object.isPaused then
			return
		end

		if Constants.IS_MOBILE then
			object.frameDebt += frameDebt

			if object.frameDebt < 0.05 then
				return
			end

			frameDebt = object.frameDebt
			object.frameDebt = 0
		end

		debug.profilebegin("EasyVisuals/wash")

		if object.host and object.host.Parent ~= nil then
			advance(object, frameDebt)
			debug.profileend()
		else
			release(object) -- equivalent call inferred; original call site unknown
		end
	end)
	object.gradient.Parent = object.host
	return object
end

function class:Destroy()
	release(self) -- equivalent call inferred; original call site unknown
end

function class:Suspend()
	self.isPaused = true
end

function class:Wake()
	self.isPaused = false
end

function class.SetRotation(p, goal: number, value: number?)
	strict2(goal)
	strict2(value)
	holdAt(p.angle, goal, value) -- equivalent call inferred; original call site unknown
end

function class.Spin(p, rateGoal: number, value: number?)
	strict2(rateGoal)
	strict2(value)
	driftAt(p.angle, rateGoal, value) -- equivalent call inferred; original call site unknown
end

function class.PhaseTo(p, goal: number, value: number?)
	strict2(goal)
	strict2(value)
	holdAt(p.phase, goal, value) -- equivalent call inferred; original call site unknown
end

function class.Drift(p, rateGoal: number, value: number?)
	strict2(rateGoal)
	strict2(value)
	driftAt(p.phase, rateGoal, value) -- equivalent call inferred; original call site unknown
end

function class.AlphaPhaseTo(p, goal: number, value: number)
	strict2(goal)
	strict2(value)
	holdAt(p.alphaPhase, goal, value) -- equivalent call inferred; original call site unknown
end

function class.AlphaDrift(p, rateGoal: number, value: number)
	strict2(rateGoal)
	strict2(value)
	driftAt(p.alphaPhase, rateGoal, value) -- equivalent call inferred; original call site unknown
end

function class:Recolor(paletteGoal, value: number?)
	strict3(paletteGoal)
	self.paletteBlend = value or 1
	self.paletteGoal = paletteGoal
	return self.paletteGoal
end

function class:Refade(strandedAlphaGoal, value: number)
	assert(strandedAlphaGoal, "a wash needs alpha stops to fade toward")
	strict2(value)

	if typeof(strandedAlphaGoal) == "number" then
		self.strandedAlphaGoal = flatAlpha(strandedAlphaGoal)
	elseif typeof(strandedAlphaGoal) == "NumberSequence" then
		self.strandedAlphaGoal = strandedAlphaGoal
	else
		warn("a wash was handed alpha stops that were neither a number nor a NumberSequence")
	end

	self.strandedAlphaResponse = math.clamp(value, 0, 1)
end

return table.freeze(class)