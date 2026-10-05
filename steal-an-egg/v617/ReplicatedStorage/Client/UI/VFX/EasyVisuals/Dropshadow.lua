local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local t = require(ReplicatedStorage.Packages.t)
local heartbeat = RunService.Heartbeat
local color = Color3.new()
local uDim = UDim2.new(1, 0, 1, 0)
local vector = Vector2.new(-4, 4)
local vector2 = Vector2.new()
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
local strict4 = t.strict(t.Vector2)

-- equivalent calls inferred from this helper; original call sites unknown
local function aim(p, goal, value: number)
	p.goal = goal
	p.response = math.clamp(value, 0, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stepLerpable(state)
	state.now = state.now:Lerp(state.goal, state.response)
	return state.now
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stepNumber(alpha)
	alpha.now += (alpha.goal - alpha.now) * alpha.response
	return alpha.now
end

-- equivalent calls inferred from this helper; original call sites unknown
local function asPlacement(point: Vector2)
	return UDim2.new(0, point.X, 0, point.Y)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function release(state)
	state.driver:Disconnect()

	if state.shadow then
		state.shadow:Destroy()
		state.shadow = nil
	end
end

local function advance(object)
	local textColor = stepLerpable(object.tint) -- equivalent call inferred; original call site unknown
	local now = stepLerpable(object.offset) -- equivalent call inferred; original call site unknown
	local position = asPlacement(now) -- equivalent call inferred; original call site unknown
	local textTransparency = stepNumber(object.alpha) -- equivalent call inferred; original call site unknown
	local shadow = object.shadow
	shadow.Position = position

	if object.isTextHost then
		shadow.Text = object.host.Text
		shadow.TextTransparency = textTransparency
		shadow.TextColor3 = textColor
	end

	shadow.ZIndex = object.host.ZIndex - 1
end

function class.new(instance, color2: Color3?, value: number?, point: Vector2?)
	strict(instance)

	if color2 then
		strict3(color2)
	end

	if value then
		strict2(value)
	end

	if point then
		strict4(point)
	end

	local object = setmetatable({
		host = instance,
		shadow = instance:Clone(),
		driver = nil,
		isPaused = false,
		isTextHost = v[instance.ClassName] == true,
		tint = {
			now = color2 or color,
			goal = color2 or color,
			response = 1
		},
		alpha = {
			now = value or 0,
			goal = value or 0,
			response = 1
		},
		offset = {
			now = point or vector,
			goal = point or vector2,
			response = 1
		}
	}, class)
	local shadow = object.shadow
	shadow.Size = uDim
	shadow:ClearAllChildren()
	local now = object.offset.now
	shadow.Position = UDim2.new(0, now.X, 0, now.Y)

	if object.isTextHost then
		shadow.TextColor3 = object.tint.now
	end

	shadow.Parent = object.host
	object.driver = heartbeat:Connect(function()
		debug.profilebegin("EasyVisuals/shadow")

		if object.isPaused then
			return
		end

		if object.host and object.host.Parent ~= nil then
			advance(object)
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

function class.EaseOffset(p, goal: Vector2, value: number)
	strict4(goal)
	strict2(value)
	aim(p.offset, goal, value) -- equivalent call inferred; original call site unknown
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