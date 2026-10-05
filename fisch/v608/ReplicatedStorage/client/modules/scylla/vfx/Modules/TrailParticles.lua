local RunService = game:GetService("RunService")
game:GetService("Debris")
local Instance = require(script.Instance)
local Part = require(script.Part)
local TrailParticles = {}
TrailParticles.__index = TrailParticles
math.randomseed(os.time())

local function ReconcileInv(p, items)
	for k, item in pairs(items) do
		if p[k] then
			p[k] = item
		end
	end

	return p
end

local function gaussianRandom(p, p2)
	local v, v2

	repeat
		v = 2 * math.random() - 1
		local v3 = 2 * math.random() - 1
		v2 = math.pow(v, 2) + math.pow(v3, 2)
	until v2 ~= 0 and v2 < 1

	local v3 = math.sqrt(math.log(v2) * -2 / v2)
	return p + p2 * v * v3
end

function randomPointInSphere(p)
	local v = 6.283185307179586 * math.random()
	local v2 = math.acos(2 * math.random() - 1)
	local v3 = math.min(gaussianRandom(0, p / 3), p)
	return v3 * math.sin(v2) * math.cos(v), v3 * math.sin(v2) * math.sin(v), v3 * math.cos(v2)
end

function TrailParticles.new(amount: number, instance, vector: Vector3, vector2: Vector3)
	assert(type(amount) == "number", "amount must be a number")
	assert(typeof(instance) == "Instance", "part must be an instance")
	assert(typeof(vector) == "Vector3", "origin must be a Vector3")
	assert(typeof(vector2) == "Vector3", "direction must be a Vector3")
	return (setmetatable({
		RenderPriority = Enum.RenderPriority.Last.Value,
		Origin = vector,
		Direction = vector2,
		XAngle = 30,
		YAngle = 30,
		ZAngle = 0,
		Radius = 10,
		DirectionRelativeToOrigin = false,
		Amount = amount,
		Part = instance,
		_running = false,
		_renderName = ("WindParticles_%s"):format((tostring(os.clock()))),
		_instances = {},
		_removeInstances = {},
		_rng = Random.new(os.clock())
	}, TrailParticles))
end

function TrailParticles:Start()
	if self._running then
		return
	end

	self._running = true
	RunService:BindToRenderStep(self._renderName, self.RenderPriority, function(p)
		debug.profilebegin("particle simulation")
		self:Update(p)
		debug.profileend()
	end)
end

function TrailParticles:Simulate(p)
	assert(type(p) == "table", "properties must be of type WindInstance")

	for _ = 1, self.Amount do
		local element = Part.new(self.Part)
		element:UpdateCFrame(CFrame.new(self.Origin, self.Direction))

		if self.DirectionRelativeToOrigin then
			element:UpdateCFrame(element.CFrame * CFrame.new(randomPointInSphere(self.Radius)))
			element:UpdateCFrame(CFrame.lookAt(element.CFrame.Position, self.Origin) * CFrame.Angles(
				3.141592653589793,
				0,
				0
			))
		else
			element:UpdateCFrame(element.CFrame * CFrame.new(randomPointInSphere(self.Radius)) * CFrame.Angles(
				math.rad((self._rng:NextNumber(-self.XAngle, self.XAngle))),
				math.rad((self._rng:NextNumber(-self.YAngle, self.YAngle))),
				(math.rad(self.ZAngle))
			))
		end

		local v2 = Instance.new(p.Velocity)

		for k, v3 in pairs(p) do
			if v2[k] then
				v2[k] = v3
			end
		end

		v2.Velocity *= self._rng:NextNumber(v2.MinSpeedMult, v2.MaxSpeedMult)
		v2.Lifetime = self._rng:NextNumber(v2.FadeIn, v2.FadeOut)
		v2.Element = element
		self._instances[#self._instances + 1] = v2
	end
end

function TrailParticles:Update(p2)
	local _instances = self._instances

	for i = 1, #_instances do
		local _instance = _instances[i]

		if _instance.Active == false then
			self._removeInstances[#self._removeInstances + 1] = i
		else
			_instance:Update(p2)
		end
	end

	for i = #self._removeInstances, 1, -1 do
		local _removeInstance = self._removeInstances[i]
		table.remove(_instances, _removeInstance)
		self._removeInstances[i] = nil
	end
end

function TrailParticles:Stop()
	if not self._running then
		return
	end

	RunService:UnbindFromRenderStep(self._renderName)
	self._running = false
end

function TrailParticles:Destroy()
	self:Stop()

	for _, _instance in self._instances do
		_instance:Destroy()
	end

	self._instances = nil
end

setmetatable(TrailParticles, {
	__index = function(_, p)
		error(string.format("%q is not a valid member of %q", tostring(p), script.Name), 2)
	end
})
return TrailParticles