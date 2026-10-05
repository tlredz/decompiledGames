local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local t = require(ReplicatedStorage.Packages.t)
local heartbeat = RunService.Heartbeat
local scaledSize = Enum.StrokeSizingMode.ScaledSize
local color = Color3.new(1, 1, 1)
local v = {
	TextLabel = true,
	TextBox = true,
	TextButton = true
}
local class = {}
class.__index = class
local strict = t.strict(t.union(t.instanceIsA("GuiObject"), t.instanceIsA("UIStroke")))
local strict2 = t.strict(t.number)
local strict3 = t.strict(t.Color3)

-- equivalent calls inferred from this helper; original call sites unknown
local function track(p)
	return {
		now = p,
		goal = p,
		response = 1
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function aim(p, goal, value: number)
	p.goal = goal
	p.response = math.clamp(value, 0, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stepNumber(state, p: number)
	state.now += (state.goal - state.now) * state.response * p
	return state.now
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stepColor(tint, p: number)
	tint.now = tint.now:Lerp(tint.goal, tint.response * p)
	return tint.now
end

local function borrowOutline(instance)
	local uIStroke = instance:FindFirstChildWhichIsA("UIStroke")

	if uIStroke then
		return uIStroke
	end

	return Instance.new("UIStroke")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function release(state)
	state.driver:Disconnect()

	if state.outline then
		state.outline:Destroy()
		state.outline = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function advance(data, p: number)
	local outline = data.outline
	outline.Color = stepColor(data.tint, p)
	outline.Transparency = stepNumber(data.alpha, p)
	local thickness = stepNumber(data.width, p) -- equivalent call inferred; original call site unknown

	if outline.StrokeSizingMode ~= scaledSize then
		outline.Thickness = thickness
	end
end

function class.new(instance, p: number, color2: Color3?, value: number?)
	strict(instance)
	strict2(p)

	if color2 then
		strict3(color2)
	end

	if value then
		strict2(value)
	end

	local v2 = {
		host = instance,
		outline = instance:FindFirstChildWhichIsA("UIStroke") or Instance.new("UIStroke"),
		driver = nil,
		isPaused = false,
		isTextHost = v[instance.ClassName] == true,
		tint = track(color2 or color),
		alpha = track(value or 0),
		width = track(p)
	}
	local object = setmetatable(v2, class)
	object.outline.Parent = object.host
	object.driver = heartbeat:Connect(function(p2: number)
		debug.profilebegin("EasyVisuals/outline")

		if object.isPaused then
			return
		end

		if object.host and object.host.Parent ~= nil then
			advance(object, p2) -- equivalent call inferred; original call site unknown
			debug.profileend()
		else
			release(object) -- equivalent call inferred; original call site unknown
		end
	end)
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

function class.EaseWidth(p, goal: number, value: number)
	strict2(goal)
	strict2(value)
	aim(p.width, goal, value) -- equivalent call inferred; original call site unknown
end

function class.EaseAlpha(p, goal: number, value: number)
	strict2(goal)
	strict2(value)
	aim(p.alpha, goal, value) -- equivalent call inferred; original call site unknown
end

function class.EaseTint(p, goal: Color3, value: number)
	strict3(goal)
	strict2(value)
	aim(p.tint, goal, value) -- equivalent call inferred; original call site unknown
end

return table.freeze(class)