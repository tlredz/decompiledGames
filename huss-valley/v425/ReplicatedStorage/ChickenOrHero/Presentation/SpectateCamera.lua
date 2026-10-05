local createVector = vector.create
local SpectateConfig = require(script.Parent.SpectateConfig)
local SpectateGeometry = require(script.Parent.SpectateGeometry)
local SpectateCamera = {}
SpectateCamera.__index = SpectateCamera

function SpectateCamera.new(p, area)
	local angles, v = SpectateGeometry.angles(p)
	return (setmetatable({
		area = area,
		position = SpectateGeometry.clamp(p.Position, area),
		yaw = angles,
		pitch = v,
		yawGoal = angles,
		pitchGoal = v,
		distance = SpectateConfig.OrbitDistance,
		distanceGoal = SpectateConfig.OrbitDistance,
		velocity = createVector(0, 0, 0)
	}, SpectateCamera))
end

function SpectateCamera:look(p)
	self.yawGoal -= p.X
	self.pitchGoal = math.clamp(self.pitchGoal - p.Y, SpectateConfig.MinPitch, SpectateConfig.MaxPitch)
end

function SpectateCamera:zoom(p2)
	self.distanceGoal = math.clamp(self.distanceGoal + p2, SpectateConfig.MinDistance, SpectateConfig.MaxDistance)
end

function SpectateCamera:resetPosition(p)
	self.position = SpectateGeometry.clamp(p.Position, self.area)
	self.velocity = createVector(0, 0, 0)
	local angles, pitch = SpectateGeometry.angles(p)
	self.yaw = angles
	self.pitch = pitch
	self.yawGoal = self.yaw
	self.pitchGoal = self.pitch
end

function SpectateCamera:cast(p, p2, p3)
	if p2.Magnitude < 0.001 then
		return
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	local clone = table.clone(p3)

	for _ = 1, 12 do
		raycastParams.FilterDescendantsInstances = clone
		local spherecast = workspace:Spherecast(p, SpectateConfig.CameraRadius, p2, raycastParams)

		if not spherecast then
			return
		end

		if spherecast.Instance:IsA("BasePart") and spherecast.Instance.Transparency >= 0.95 then
			table.insert(clone, spherecast.Instance)
		else
			return spherecast
		end
	end

	return nil
end

function SpectateCamera:travel(p, p2, p3, p4)
	local v = p2 - p
	local v2 = self:cast(p, v, p3)

	if not v2 then
		return SpectateGeometry.clamp(p2, self.area)
	end

	local v3 = p + v.Unit * math.max(0, v2.Distance - 0.08)

	if not p4 then
		return SpectateGeometry.clamp(v3, self.area)
	end

	local vector2 = p2 - v3
	local v4 = vector2 - v2.Normal * vector2:Dot(v2.Normal)
	local v5 = self:cast(v3, v4, p3)

	if v5 then
		v4 = v4.Unit * math.max(0, v5.Distance - 0.08) or v4
	end

	v3 += v4
	return SpectateGeometry.clamp(v3, self.area)
end

function SpectateCamera:step(p, p2, data, p3, value, p4)
	local v = math.clamp(value, 0, 0.1)
	local alpha = SpectateGeometry.alpha(SpectateConfig.LookSmoothness, v)
	self.yaw += (self.yawGoal - self.yaw) * alpha
	self.pitch += (self.pitchGoal - self.pitch) * alpha
	self.distance += (self.distanceGoal - self.distance) * alpha
	local cframe = CFrame.fromOrientation(self.pitch, self.yaw, 0)
	local focus

	if p == "Free" then
		local unit = cframe:VectorToWorldSpace((Vector3.new(data.X, 0, data.Z))) + createVector(0, 1, 0) * data.Y

		if unit.Magnitude > 1 then
			unit = unit.Unit
		end

		local v2 = unit * (p3 and SpectateConfig.FastSpeed or SpectateConfig.Speed) * math.clamp(
			self.speedScale or 1,
			0.25,
			2
		)
		self.velocity = self.velocity:Lerp(v2, SpectateGeometry.alpha(SpectateConfig.Acceleration, v))
		self.position = self:travel(
			self.position,
			SpectateGeometry.clamp(self.position + self.velocity * v, self.area),
			p4,
			true
		)
		focus = self.position + cframe.LookVector * 15
	else
		self.velocity = createVector(0, 0, 0)
		local focus2 = p2 and p2.Position + createVector(0, 1.5, 0) or self.focus or self.area.cf.Position

		if self.focus and not ((focus2 - self.focus).Magnitude > 50) then
			self.focus = self.focus:Lerp(focus2, SpectateGeometry.alpha(SpectateConfig.FollowSmoothness, v))
		else
			self.focus = focus2
		end

		focus = self.focus
		local clamped = SpectateGeometry.clamp(focus, self.area)
		local travel = self:travel(
			clamped,
			SpectateGeometry.clamp(focus - cframe.LookVector * self.distance, self.area),
			p4,
			false
		)
		self.position = self:travel(
			clamped,
			self.position:Lerp(travel, SpectateGeometry.alpha(SpectateConfig.FollowSmoothness, v)),
			p4,
			false
		)

		if (focus - self.position).Magnitude > 0.01 then
			cframe = CFrame.lookAt(self.position, focus).Rotation
		end
	end

	return CFrame.new(self.position) * cframe, CFrame.new(focus)
end

return SpectateCamera