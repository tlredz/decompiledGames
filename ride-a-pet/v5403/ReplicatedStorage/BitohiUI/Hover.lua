local Ticker = require(script.Parent:WaitForChild("Ticker"))
local Hover = {}
local defaults = {
	Distance = 5,
	Duration = 1.6,
	Sway = 0,
	Vary = 0.3
}
Hover.Defaults = defaults
local random = Random.new()

local function inLayout(instance)
	local parent = instance.Parent

	if not parent then
		return false
	end

	for _, uIGridStyleLayout in ipairs(parent:GetChildren()) do
		if uIGridStyleLayout:IsA("UIGridStyleLayout") then
			return true
		end
	end

	return false
end

local class = {}
class.__index = class

function class:Add(instance, options)
	if self.byObject[instance] then
		return self
	end

	if inLayout(instance) then
		warn(("[Hover] %s sits under a layout; bob its inner frame instead"):format(instance:GetFullName()))
		return self
	end

	local v2 = options or {}
	local vary = v2.Vary or self.opts.Vary or defaults.Vary
	local distance = v2.Distance or self.opts.Distance or defaults.Distance
	local duration = v2.Duration or self.opts.Duration or defaults.Duration
	local sway = v2.Sway or self.opts.Sway or defaults.Sway
	local v3 = {
		obj = instance,
		home = instance.Position,
		homeRotation = instance.Rotation,
		distance = 0,
		rate = 0,
		sway = 0,
		swayRate = 0,
		phase = 0
	}

	if not (vary <= 0) then
		distance *= 1 + random:NextNumber(-vary, vary)
	end

	v3.distance = distance
	local v5

	if vary <= 0 then
		v5 = duration
	else
		v5 = duration * (1 + random:NextNumber(-vary, vary))
	end

	local v6 = math.max(0.01, v5)
	v3.rate = 3.141592653589793 / v6
	v3.sway = sway
	local swayDuration = v2.SwayDuration

	if not swayDuration then
		if not (vary <= 0) then
			duration *= 1 + random:NextNumber(-vary, vary)
		end

		swayDuration = duration * 1.35
	end

	local v8 = math.max(0.01, swayDuration)
	v3.swayRate = 3.141592653589793 / v8
	v3.phase = v2.Phase or random:NextNumber(0, 6.283185307179586)
	self.members[#self.members + 1] = v3
	self.byObject[instance] = v3
	self:_wake()
	return self
end

function class:Remove(p)
	local v2 = self.byObject[p]

	if not v2 then
		return
	end

	local index = table.find(self.members, v2)

	if index then
		table.remove(self.members, index)
	end

	self.byObject[p] = nil

	if v2.obj.Parent then
		v2.obj.Position = v2.home

		if v2.sway > 0 then
			v2.obj.Rotation = v2.homeRotation
		end
	end

	if #self.members == 0 then
		self:_sleep()
	end
end

function class:Clear()
	for i = #self.members, 1, -1 do
		self:Remove(self.members[i].obj)
	end
end

function class.Rehome(p)
	for _, member in ipairs(p.members) do
		member.home = member.obj.Position
		member.homeRotation = member.obj.Rotation
	end
end

function class:_park()
	for _, member in ipairs(self.members) do
		if not member.obj.Parent then
			continue
		end

		member.obj.Position = member.home

		if member.sway > 0 then
			member.obj.Rotation = member.homeRotation
		end
	end
end

function class:_wake()
	if self.ticker or #self.members == 0 then
		return
	end

	local members = self.members
	self.ticker = Ticker.whileVisible(self.root, function(p)
		self.clock += p
		local clock = self.clock

		for i = 1, #members do
			local member = members[i]
			local obj = member.obj

			if not obj.Parent then
				continue
			end

			obj.Position = member.home + UDim2.fromOffset(
				0,
				-member.distance * math.cos(clock * member.rate + member.phase)
			)

			if member.sway > 0 then
				obj.Rotation = member.homeRotation + member.sway * math.sin(clock * member.swayRate + member.phase)
			end
		end
	end, 0, function()
		self:_park()
	end)
end

function class:_sleep()
	if self.ticker then
		self.ticker:Stop()
		self.ticker = nil
	end
end

function class:Stop()
	self:Clear()
	self:_sleep()
end

class.Destroy = class.Stop

function Hover.group(root, options)
	return (setmetatable({
		root = root,
		opts = options or {},
		members = {},
		byObject = {},
		clock = random:NextNumber(0, 100),
		ticker = nil
	}, class))
end

function Hover.bind(p, p2)
	local group = Hover.group(p, p2)
	group:Add(p, p2)
	return function()
		group:Stop()
	end
end

return Hover