local createVector = vector.create
local RunService = game:GetService("RunService")
local random = Random.new()
local count = 0
local class = {}
class.__index = class

function class.new()
	local self = setmetatable({}, class)
	self.Amplitude = 1
	self.Frequency = 1
	self.FadeInTime = 1
	self.FadeOutTime = 1
	self.SustainTime = 0
	self.Sustain = false
	self.PositionInfluence = createVector(1, 1, 1)
	self.RotationInfluence = createVector(1, 1, 1)
	local timeFunction

	if RunService:IsRunning() then
		timeFunction = time
	else
		timeFunction = os.clock
	end

	self.TimeFunction = timeFunction
	self._timeOffset = random:NextNumber(-1000000, 1000000)
	self._startTime = 0
	self._running = false
	self._signalConnections = {}
	self._renderBindings = {}
	return self
end

function class.InverseSquare(vector2: Vector3, p: number)
	local v = p < 1 and 1 or p
	return vector2 * (1 / (v * v))
end

function class.NextRenderName()
	count += 1
	return ("__ouwmitshake_%.4i__"):format(count)
end

function class:Start()
	self._startTime = self.TimeFunction()
	self._running = true
end

function class:Stop()
	self._running = false

	for _, _renderBinding in self._renderBindings do
		RunService:UnbindFromRenderStep(_renderBinding)
	end

	table.clear(self._renderBindings)

	for _, _signalConnection in self._signalConnections do
		_signalConnection:Disconnect()
	end

	table.clear(self._signalConnections)
end

function class:IsShaking()
	return self._running
end

function class:StopSustain()
	local timeFunction = self.TimeFunction()
	self.Sustain = false
	self.SustainTime = timeFunction - self._startTime - self.FadeInTime
end

function class:Update()
	local flag = false
	local timeFunction = self.TimeFunction()
	local v = timeFunction - self._startTime
	local v2 = (timeFunction + self._timeOffset) / self.Frequency % 10000
	local v3 = 1
	local v4 = not (v < self.FadeInTime) and 1 or v / self.FadeInTime

	if not self.Sustain and self.FadeInTime + self.SustainTime < v then
		if self.FadeOutTime == 0 then
			flag = true
		else
			v3 = 1 - (v - self.FadeInTime - self.SustainTime) / self.FadeOutTime

			if not self.Sustain and self.FadeInTime + self.SustainTime + self.FadeOutTime <= v then
				flag = true
			end
		end
	end

	local v5 = Vector3.new(math.noise(v2, 0) / 2, math.noise(0, v2) / 2, math.noise(v2, v2) / 2) * self.Amplitude * math.min(
		v4,
		v3
	)

	if flag then
		self:Stop()
	end

	return self.PositionInfluence * v5, self.RotationInfluence * v5, flag
end

function class:OnSignal(object2, callback)
	local connection = object2:Connect(function()
		callback(self:Update())
	end)
	table.insert(self._signalConnections, connection)
	return connection
end

function class:BindToRenderStep(p: string, p2: number, callback)
	RunService:BindToRenderStep(p, p2, function()
		callback(self:Update())
	end)
	table.insert(self._renderBindings, p)
end

function class.Clone(p)
	local result = class.new()

	for _, v in {
		"Amplitude",
		"Frequency",
		"FadeInTime",
		"FadeOutTime",
		"SustainTime",
		"Sustain",
		"PositionInfluence",
		"RotationInfluence",
		"TimeFunction"
	} do
		result[v] = p[v]
	end

	return result
end

function class:Destroy()
	self:Stop()
end

return {
	new = class.new,
	InverseSquare = class.InverseSquare,
	NextRenderName = class.NextRenderName
}