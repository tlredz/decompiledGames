local ValueManager = {}
local RunService = game:GetService("RunService")
local random = math.random

local function sub(value, p)
	return value:sub(p, p)
end

local function randomid()
	local v = ("abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY0123456789-_*?/=()[]{}&%+^'!#$,.."):len() - 1
	local v2 = random(0, v)
	local v3 = ("abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY0123456789-_*?/=()[]{}&%+^'!#$,.."):sub(v2, v2)
	local v4 = random(0, v)
	local v5 = ("abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY0123456789-_*?/=()[]{}&%+^'!#$,.."):sub(v4, v4)
	local v6 = random(0, v)
	local v7 = ("abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY0123456789-_*?/=()[]{}&%+^'!#$,.."):sub(v6, v6)
	local v8 = random(0, v)
	local v9 = ("abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY0123456789-_*?/=()[]{}&%+^'!#$,.."):sub(v8, v8)
	local v10 = random(0, v)
	local v11 = ("abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY0123456789-_*?/=()[]{}&%+^'!#$,.."):sub(v10, v10)
	local v12 = random(0, v)
	local v13 = ("abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY0123456789-_*?/=()[]{}&%+^'!#$,.."):sub(v12, v12)
	local v14 = random(0, v)
	return v3 .. v5 .. v7 .. v9 .. v11 .. v13 .. ("abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY0123456789-_*?/=()[]{}&%+^'!#$,.."):sub(
		v14,
		v14
	)
end

local clock = os.clock
local v = {}
local v2 = {}
local sign = math.sign
local sqrt = math.sqrt
local exp = math.exp
local cos = math.cos
local sin = math.sin

function v:FullSpring()
	local styleK = self.StyleK
	local styleU = self.StyleU
	local fixdt = self.fixdt and self.fixdt or self.tick() - self.LastEdit
	self.LastEdit = self.tick()
	local v3 = nil
	local v4 = nil
	local v5 = nil
	local v6 = nil

	if styleU == 1 then
		local v7 = math.exp(-styleK * fixdt)
		v4 = fixdt * v7
		local v8 = v4 * styleK
		v3 = v8 + v7
		v5 = -styleK * v8
		v6 = -v8 + v7
	elseif styleU < 1 then
		local v7 = styleK * styleU
		local v9 = styleK * sqrt(1 - styleU * styleU)
		local v11 = exp(-v7 * fixdt)
		local v13 = cos(v9 * fixdt)
		local v15 = sin(v9 * fixdt)
		local v16 = 1 / v9
		local v17 = v11 * v15
		local v18 = v11 * v13
		local v19 = v11 * v7 * v15 * v16
		v3 = v18 + v19
		v4 = v17 * v16
		v5 = -v17 * v9 - v7 * v19
		v6 = v18 - v19
	elseif styleU > 1 then
		local v7 = -styleK * styleU
		local v9 = styleK * sqrt(styleU * styleU - 1)
		local v10 = v7 - v9
		local v11 = v7 + v9
		local v13 = exp(v10 * fixdt)
		local v15 = exp(v11 * fixdt)
		local v16 = 1 / (2 * v9)
		local v17 = v13 * v16
		local v18 = v15 * v16
		local v19 = v10 * v17
		local v20 = v11 * v18
		v3 = v17 * v11 - v20 + v15
		v4 = -v17 + v18
		v5 = (v19 - v20 + v15) * v11
		v6 = -v19 + v20
	end

	local v7 = self.Real - self.Target
	local velocity = self.Velocity
	self.Real = v7 * v3 + velocity * v4 + self.Target
	self.Velocity = v7 * v5 + velocity * v6
	return self.Real
end

function v:Linear(_)
	local v3 = self.tick() - self.LastEdit
	self.LastEdit = self.tick()
	local real = self.Real
	local target = self.Target
	local v4 = target - real

	if v4 == 0 then
		return real
	end

	local v5 = sign(v4)
	local v6 = real + v5 * self.StyleValue * v3

	if sign(target - v6) ~= v5 then
		self.Real = target
		return target
	end

	local real2 = math.clamp(v6, self.min, self.max)
	self.Real = real2
	return real2
end

function v:Approach(_)
	local v3 = self.tick() - self.LastEdit
	self.LastEdit = self.tick()
	local real = self.Real
	local target = self.Target
	local v4 = target - real

	if v4 == 0 then
		return real
	end

	local v5 = sign(v4)
	local v6 = real + v4 * self.StyleValue * v3

	if sign(target - v6) ~= v5 then
		self.Real = target
		return target
	end

	local real2 = math.clamp(v6, self.min, self.max)
	self.Real = real2
	return real2
end

function v:Spring(_)
	local v3 = self.tick() - self.LastEdit
	self.LastEdit = self.tick()
	local v4 = v3 < 0.1 and v3 or 0.1
	local real = self.Real
	local v5 = self.Target - real
	self.Velocity += v5 * self.StyleK * v4 - self.Velocity * self.StyleU * v4
	self.Real += self.Velocity * v4
	return self.Real
end

local v3 = { "Name", "Style" }

function checktab(p)
	for i = 1, #v3 do
		if not p[v3[i]] then
			error("Not a valid input, '" .. v3[i] .. "' is not given", 3)
		end
	end

	return true
end

function ValueManager.RemoveValue(p)
	v2[p] = nil
end

function ValueManager.GetValue(p)
	local v4 = v2[p]

	if not v4 then
		error("Name " .. p .. " does not exist", 2)
	end

	return v4.Real
end

function ValueManager.UpdateTarget(p, target, p2, p3)
	if p3 then
		if v2[p].Target ~= target then
			v2[p].StartTime = p2 and clock() + p2 or 0
		end
	else
		v2[p].StartTime = p2 and clock() + p2 or 0
	end

	v2[p].Target = target
	return v2[p].Real
end

function ValueManager.UpdateReal(p, real)
	v2[p].Real = real
end

function ValueManager:new()
	if not self.Name then
		self.Name = randomid()
	end

	checktab(self)

	if v2[self.Name] then
		warn("value already exists")
	end

	self.max = not self.max and 1e999 or self.max or 1e999
	self.min = not self.min and -1e999 or self.min or -1e999
	self.StartTime = self.StartTime or 0
	self.Real = self.Real or 0
	self.Target = self.Target or 0
	self.Velocity = self.Velocity or 0
	self.StyleK = self.StyleK or 1
	self.StyleU = self.StyleU or 1
	self.StyleValue = self.StyleValue or 1
	self.tick = self.tick or clock
	self.LastEdit = self.tick()
	v2[self.Name] = self

	function self.Update(p, p2, p3)
		return ValueManager.UpdateTarget(self.Name, p, p2, p3)
	end

	function self.Get()
		return self.Real
	end

	function self.GetAccurate()
		if self.StartTime <= self.tick() then
			return v[self.Style](self)
		end

		return self.Real
	end

	function self.Destroy(...)
		v2[self.Name] = nil
	end

	return self
end

ValueManager.NewValue = ValueManager.new
local v4 = {}

function ValueManager.EasyLoopAsync(dur, p2, cb, p4)
	local v5 = p4 or tostring(clock() * 10000)
	v4[v5] = {
		Dur = dur,
		F = p2,
		t = clock(),
		Cb = cb
	}
end

function ValueManager.EasyLoopAsyncEnd(p)
	v4[p] = nil
end

function ValueManager.EasyLoopYield(p, callback)
	local now = clock()
	local v5 = 0

	repeat
		callback(v5)
		RunService.Heartbeat:Wait()
		v5 = (clock() - now) / p
	until v5 >= 1

	callback(1)
end

function ValueManager:Wait()
	local now = clock()

	repeat
		RunService.Heartbeat:Wait()
	until (clock() - now) / self >= 1
end

coroutine.wrap(function()
	RunService.Heartbeat:Connect(function(dt)
		if dt > 0.4 then
			return
		end

		local now = clock()

		for _, v5 in pairs(v2) do
			if not (v5.StartTime <= v5.tick() and v5.auto ~= false) then
				continue
			end

			v5.PrevValue = v5.Real
			v[v5.Style](v5)

			if v5.OnUpdate then
				v5.OnUpdate(v5.PrevValue, v5.Real)
			end
		end

		for k, v5 in pairs(v4) do
			local v6 = (now - v5.t) / v5.Dur

			if v6 < 1 then
				v5.F(v6)
			else
				v5.F(1)

				if v5.Cb then
					v5.Cb()
				end

				v4[k] = nil
			end
		end
	end)
end)()
return ValueManager