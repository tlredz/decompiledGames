local createVector = vector.create
local _WorldOrigin = workspace._WorldOrigin
local debris = script.Debris
local v = { _WorldOrigin, workspace.Characters, workspace.Enemies }

local function fn(particle, p)
	local numberSequenceKeypoints = {}

	for _, keypoint in pairs(particle.Size.Keypoints) do
		table.insert(
			numberSequenceKeypoints,
			(NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope * p))
		)
	end

	particle.Speed = NumberRange.new(particle.Speed.Min * p, particle.Speed.Max * p)
	particle.Size = NumberSequence.new(numberSequenceKeypoints)
	particle.Acceleration *= p
end

local v2 = {}
local v3 = {}

local function obj(p, scale, p2, lifetime, data)
	local velocity = p.LookVector * p2
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CollisionGroup = "Debris"
	part.CanQuery = false
	part.Size = createVector(1, 1, 1)
	part.Color = data.Color
	part.Material = data.Material
	part.MaterialVariant = data.MaterialVariant
	part.CFrame = p * CFrame.new(0, 0, -scale.Z * 0.5)
	local blockMesh = Instance.new("BlockMesh", part)
	blockMesh.Scale = scale
	table.insert(v2, {
		obj = part,
		size = scale,
		cframe = p,
		velocity = velocity,
		time = os.clock(),
		lifetime = lifetime,
		prevcf = p,
		fadeTime = 0.4 + math.random() * 0.4,
		damp = 0.55
	})
	part.Parent = _WorldOrigin
end

local function createDebris(p, p2, p3, p4, p5, p6, value, p7)
	local magnitude = (p2 - workspace.CurrentCamera.CFrame.p).Magnitude

	if 500 + p4 * 5 < magnitude then
		return
	end

	local cframe = CFrame.lookAt(p2, p2 + p3)
	local v4 = value or 1.5707963267948966
	local v5 = p7 or { 1, 1 }

	for _ = 1, math.clamp(p4 / 10 * 5, 5, 20) * p5 do
		obj(
			cframe * CFrame.Angles((math.random() - 0.5) * v4, (math.random() - 0.5) * v4, 0) + cframe.RightVector * p4 * (math.random() - 0.5) + cframe.UpVector * p4 * (math.random() - 0.5),
			Vector3.new(0.5 + math.random(), 0.5 + math.random(), 0.5 + math.random()) * (1 + 0.25 * math.random() + p4 / 7.5),
			p6 * ((0.4 + math.random() * 0.6) * p4 / 40 + p4 / 30) * (v5[1] + (v5[2] - v5[1]) * math.random()),
			math.clamp(p4 / 10 * 2, 1, 3),
			p
		)
	end
end

local v4 = 0.016666666666666666

local function global()
	local RunService = game:GetService("RunService")
	local renderStepped = RunService.RenderStepped

	while true do
		local v5 = renderStepped:Wait()
		local v6 = createVector(0, 1, 0) * -workspace.Gravity
		local now = os.clock()

		for k, v7 in pairs(v3) do
			if v7.emit then
				v7.dust.Particle:Emit(v7.emit)
				v7.emit = nil
			end

			if not (now - v7.time > v7.lifetime) then
				continue
			end

			v7.dust:Destroy()
			table.remove(v3, k)
		end

		for k, v7 in pairs(v2) do
			local damp = v7.damp
			local v8 = now - v7.time
			v7.velocity += v6 * v5
			v7.velocity *= math.pow(damp, v5)
			local v9 = v7.obj.CFrame.Position + v7.velocity * v5

			if v8 < v7.lifetime then
				local v10 = v9 - v7.prevcf.Position
				local ray = Ray.new(v7.prevcf.Position, v10 + v10.Unit * v7.size / 2)
				local part, v11, v12 = workspace:FindPartOnRayWithIgnoreList(ray, v)

				if part then
					v7.cframe = CFrame.new(v11, v11 + v12) * CFrame.Angles(-1.5707963267948966, 0, 0)
					local v13 = 0.25 + v7.size.Magnitude / 15
					local clone = debris:Clone()
					clone.Particle.Color = ColorSequence.new(v7.obj.Color)
					fn(clone.Particle, v13)
					clone.Size = createVector(1, 0.33, 1) * v13 * 5
					clone.CFrame = v7.cframe
					table.insert(v3, {
						dust = clone,
						time = now,
						lifetime = clone.Particle.Lifetime.Max + 0.03333333333333333,
						emit = math.clamp(v13 * 10, 3, 30)
					})
					clone.Parent = _WorldOrigin
					local magnitude = v7.velocity.Magnitude

					if v7.obj.Mesh.Scale.Magnitude >= 20 and magnitude > 20 then
						local cframe = CFrame.Angles(0, 6.283185307179586 * math.random(), 1.5707963267948966)
						local v14 = v7.cframe * cframe
						local v15 = 3 + math.random()
						local v16 = v14 * CFrame.Angles(0, -3.141592653589793 / v15 - math.random(), 0)
						local v17 = v7.cframe * cframe
						local v18 = 3 + math.random()
						local v19 = v17 * CFrame.Angles(
							0,
							3.141592653589793 + 3.141592653589793 / v18 + math.random(),
							0
						)
						obj(
							v16,
							v7.size / (1.5 + math.random()),
							magnitude * (0.35 + math.random() * 0.3),
							v7.lifetime,
							v7.obj
						)
						obj(
							v19,
							v7.size / (1.5 + math.random()),
							magnitude * (0.35 + math.random() * 0.3),
							v7.lifetime,
							v7.obj
						)
					end

					v7.time = os.clock() - v7.lifetime
					v7.fadeTime = 0.016666666666666666
				end
			end

			v7.obj.CFrame = CFrame.lookAt(v9, v7.cframe.Position)
			v7.prevcf = v7.obj.CFrame

			if not (v7.lifetime < v8) then
				continue
			end

			v7.obj.Size = createVector(1, 1, 1) * math.max(0, 1 - (v8 - v7.lifetime) / v7.fadeTime)

			if not (v7.lifetime + v7.fadeTime < v8) then
				continue
			end

			v7.obj:Destroy()
			table.remove(v2, k)
		end

		v4 = v5
	end
end

local RunService = game:GetService("RunService")

if RunService:IsClient() then
	task.spawn(global)
end

return createDebris