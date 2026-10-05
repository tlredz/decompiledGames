local createVector = vector.create
game:GetService("RunService")
local Instance = {}
Instance.__index = Instance
local noise = math.noise
local random = Random.new(os.time())

function Instance.new(vector2: Vector3)
	return (setmetatable({
		Velocity = vector2,
		Element = nil,
		MinSpeedMult = 1,
		MaxSpeedMult = 1,
		FadeIn = 1,
		FadeOut = 1,
		NoiseStrength = function(_) end,
		VelocityDrag = function(_) end,
		Active = true,
		Seed = os.time(),
		Resolution = 2,
		Contrast = 1.1,
		TrailLife = 0.5,
		_t = 0,
		_rotationDirection = Vector3.new(
			random:NextInteger(-1, 1) + 0.01,
			random:NextInteger(-1, 1) + 0.01,
			random:NextInteger(-1, 1) + 0.01
		),
		_start = os.clock()
	}, Instance))
end

function Instance:Update(p: number)
	if not self.Element then
		error("Particle element missing or nil")
		return
	end

	if os.clock() - self._start >= self.Lifetime then
		self:Destroy()
	end

	local element = self.Element
	local v = math.rad(math.clamp(noise(element.CFrame.Rotation.X / self.Resolution + 0.1, self.Seed + self._t), -1, 1) * self.NoiseStrength(self.Contrast + self._t / 10)) * self._rotationDirection.X
	local v2 = math.rad(math.clamp(noise(element.CFrame.Rotation.Y / self.Resolution + 0.1, self.Seed + self._t), -1, 1) * self.NoiseStrength(self.Contrast + self._t / 10)) * self._rotationDirection.Y
	local v3 = math.rad(math.clamp(noise(element.CFrame.Rotation.Z / self.Resolution + 0.1, self.Seed + self._t), -1, 1) * self.NoiseStrength(self.Contrast + self._t / 10)) * self._rotationDirection.Z
	element:UpdateCFrame(element.CFrame * CFrame.new(-self.Velocity * p) * CFrame.Angles(v, v2, v3))
	self.Velocity = self.VelocityDrag(self.Velocity)

	if self.Velocity.X < 0 or self.Velocity.Y < 0 or self.Velocity.Z < 0 then
		self:Destroy()
	end

	self._t += 1
end

function Instance:Destroy()
	self.Active = false
	self.Velocity = createVector(0, 0, 0)
	self._rotationDirection = createVector(0, 0, 0)
	task.delay(self.TrailLife, function()
		self.Element:Destroy()
		self.Active = false
	end)
end

setmetatable(Instance, {
	__index = function(_, p)
		error(string.format("%q is not a valid member of %q", tostring(p), script.Name), 2)
	end
})
return Instance