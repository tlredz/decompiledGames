local createVector = vector.create
local RunService = game:GetService("RunService")

-- equivalent calls inferred from this helper; original call sites unknown
local function getOrbitPosition(p, orbitRadius, timeElapsed, rotationSpeed)
	local v = timeElapsed * rotationSpeed
	local v2 = math.sin(timeElapsed * rotationSpeed * 0.5)
	return p * Vector3.new(math.cos(v) * orbitRadius, math.sin(v2) * orbitRadius * 0.5, math.sin(v) * orbitRadius)
end

local GravityRock = {}
GravityRock.__index = GravityRock

function GravityRock.new(cFrame, options)
	local v = options or {}
	local v2 = {
		GravityStrength = v.GravityStrength or 50,
		OrbitRadius = v.OrbitRadius or 10,
		RotationSpeed = v.RotationSpeed or 10,
		DampingFactor = v.DampingFactor or 0.95,
		Velocity = v.Velocity or createVector(0, 0, 0),
		SpinSpeed = v.SpinSpeed or 15,
		SpinVariation = v.SpinVariation or 5.5,
		SpinFrequency = v.SpinFrequency or 5,
		Parent = v.Parent or workspace._WorldOrigin
	}
	local clone = script["rock" .. math.random(1, 3)]:Clone()
	clone.CFrame = cFrame
	local position = clone.Position
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { clone }
	local raycastResult = workspace:Raycast(position, createVector(0, -100, 0), raycastParams)

	if raycastResult and not v.ForceColor then
		local _ = raycastResult.Material
		local instance = raycastResult.Instance

		if instance and instance:IsA("BasePart") then
			clone.BrickColor = instance.BrickColor
		end
	elseif v.ForceColor then
		clone.Color = v.ForceColor
	end

	v2.Part = clone
	v2.RandomCFrame = v.Chaotic and CFrame.lookAt(
		createVector(0, 0, 0),
		Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5).Unit
	) or CFrame.identity
	v2.timeElapsed = 0
	local object = setmetatable(v2, GravityRock)
	clone:GetAttributeChangedSignal("Disconnected"):Once(function()
		if object.Connection then
			object.Connection:Disconnect()
			object.Connection = nil
		end
	end)
	return object
end

function GravityRock:Orbit(instance2)
	if self.Connection then
		self.Connection:Disconnect()
	end

	local part = self.Part
	part.Parent = self.Parent
	self.Connection = RunService.Heartbeat:Connect(function(dt)
		if not instance2:IsDescendantOf(workspace) then
			self:Destroy()
			return
		end

		self.timeElapsed += dt
		local gravityStrength = self.GravityStrength
		local orbitRadius = self.OrbitRadius
		local rotationSpeed = self.RotationSpeed
		local dampingFactor = self.DampingFactor
		local velocity = self.Velocity
		local spinSpeed = self.SpinSpeed
		local spinVariation = self.SpinVariation
		local spinFrequency = self.SpinFrequency
		local timeElapsed = self.timeElapsed
		local position = instance2.Position
		local v2 = position - part.Position
		local magnitude = v2.Magnitude

		if magnitude > 0.01 then
			velocity += v2.Unit * gravityStrength * dt
		end

		if orbitRadius < magnitude then
			local v3 = magnitude - orbitRadius
			velocity -= v2.Unit * v3 * 0.5 * dt
		end

		local v3 = velocity * dampingFactor
		local lerped = (part.Position + v3 * dt):Lerp(
			getOrbitPosition(CFrame.new(position) * self.RandomCFrame, orbitRadius, timeElapsed, rotationSpeed),
			0.1
		)
		local v6 = spinSpeed + math.sin(timeElapsed * 3.141592653589793 * spinFrequency) * spinVariation
		local v7 = part.CFrame - part.Position
		part.CFrame = CFrame.new(lerped) * v7 * CFrame.Angles(
			math.rad(v6 * dt),
			math.rad(v6 * dt * 0.5),
			(math.rad(v6 * dt))
		)
	end)
end

function GravityRock:Destroy()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	self.Part:Destroy()
end

return GravityRock