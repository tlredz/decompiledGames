local Ticker = require(script.Parent:WaitForChild("Ticker"))
local Store = require(script.Parent:WaitForChild("Store"))
local Spring = require(script.Parent:WaitForChild("Spring"))
local defaults = {
	Amplitude = 10,
	Rotation = 4,
	Frequency = 22,
	Decay = 1.8,
	Exponent = 2,
	Mode = "Both",
	Scale = 0,
	ScaleName = "ShakeScale"
}
local Shake = {
	Defaults = defaults
}
local v2 = Store.new()
local total = 0
local class = {}
class.__index = class

local function inLayout(obj)
	local parent = obj.Parent

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

function class:_capture()
	if self.homed then
		return
	end

	self.homed = true
	self.homePosition = self.obj.Position
	self.homeRotation = self.obj.Rotation
	self.canMove = self.mode ~= "Rotation" and not inLayout(self.obj)
end

function class:_restore()
	if not self.homed then
		return
	end

	self.homed = false

	if self.canMove then
		self.obj.Position = self.homePosition
	end

	if self.mode ~= "Position" then
		self.obj.Rotation = self.homeRotation
	end

	if self.scaleObject then
		self.scaleObject.Scale = 1
	end
end

function class:_step(p)
	local trauma = self.trauma

	if not self.hold then
		trauma = math.max(0, trauma - self.opts.Decay * p)
		self.trauma = trauma
	end

	if trauma <= 0.0005 then
		self:_restore()

		if not self.hold then
			self:_sleep()
		end
	else
		self:_capture()
		self.clock += p * self.opts.Frequency
		local clock = self.clock
		local v3 = trauma ^ self.opts.Exponent

		if self.canMove then
			local v4 = self.opts.Amplitude * v3
			self.obj.Position = self.homePosition + UDim2.fromOffset(
				math.noise(self.seed, clock) * 2 * v4,
				math.noise(self.seed + 31.7, clock) * 2 * v4
			)
		end

		if self.mode ~= "Position" then
			self.obj.Rotation = self.homeRotation + math.noise(self.seed + 87.3, clock) * 2 * self.opts.Rotation * v3
		end

		if self.scaleObject then
			self.scaleObject.Scale = 1 + self.opts.Scale * v3
		end
	end
end

function class:_wake()
	if self.ticker then
		return
	end

	self.ticker = Ticker.whileVisible(self.obj, function(p)
		self:_step(p)
	end, 0, function()
		self:_restore()
	end)
end

function class:_sleep()
	if self.ticker then
		self.ticker:Stop()
		self.ticker = nil
	end
end

function class:Set(value)
	self.trauma = math.clamp(value, 0, 1)

	if self.trauma > 0 then
		self:_wake()
	end

	return self
end

function class:Add(value)
	return self:Set(self.trauma + (value or 0.3))
end

function class.Get(p)
	return p.trauma
end

function class:Hold(p)
	self.hold = p ~= false

	if self.hold then
		self:_wake()
	end

	return self
end

function class:Stop()
	self.hold = false
	self.trauma = 0
	self:_restore()
	self:_sleep()

	if v2[self.obj] == self then
		v2[self.obj] = nil
	end
end

class.Destroy = class.Stop

local function shakerFor(obj, items)
	local v3 = v2[obj]

	if v3 then
		if items then
			for k, item in pairs(items) do
				v3.opts[k] = item
			end

			v3.mode = v3.opts.Mode
		end

		return v3
	else
		local object = setmetatable(items and table.clone(items) or {}, {
			__index = defaults
		})
		total += 13.37
		local self = setmetatable({
			obj = obj,
			opts = object,
			mode = object.Mode,
			trauma = 0,
			clock = 0,
			seed = total,
			hold = false,
			homed = false,
			ticker = nil
		}, class)

		if object.Scale > 0 then
			self.scaleObject = Spring.scale(obj, object.ScaleName)
		end

		v2[obj] = self
		return self
	end
end

function Shake.trauma(obj, p2)
	return (shakerFor(obj, p2))
end

function Shake.burst(obj, value, p2)
	return shakerFor(obj, p2):Add(value or 0.5)
end

function Shake.rumble(obj, value, p2)
	return shakerFor(obj, p2):Set(value or 0.4):Hold(true)
end

function Shake.stop(p)
	local v3 = v2[p]

	if v3 then
		v3:Stop()
	end
end

function Shake.get(p)
	return v2[p]
end

return Shake