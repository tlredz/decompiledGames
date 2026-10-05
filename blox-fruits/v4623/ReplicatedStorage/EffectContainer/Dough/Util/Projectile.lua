local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
local Effect = require(ReplicatedStorage.Effect)
local Util = require(ReplicatedStorage.Util)
local Pool = require(ReplicatedStorage.Pool)
local sine = Util.Sine
local FABRIK = Util.FABRIK
local misc = Util.Misc
local _ = Util.DistributedLoop
local _ = misc.LoadTexture
local doughExplosionsDripScatter = Effect.new("Dough.Explosions.DripScatter")
local doughShockwaves2 = Effect.new("Dough.Shockwaves.2")
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
local models = dough:WaitForChild("Models")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local _ = {
	"rbxassetid://8428219703",
	"rbxassetid://8428219307",
	"rbxassetid://8428218923",
	"rbxassetid://8428218491",
	"rbxassetid://8428217936",
	"rbxassetid://8428217541",
	""
}

local function popShot(worldCFrame, value)
	local magnitude = (currentCamera.CFrame.p - worldCFrame.p).Magnitude

	if 225 + 5 * value < magnitude then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.WorldCFrame = worldCFrame
	local v = 0.5
	local v2 = value or 1
	local clones = {}

	for _, child in pairs(dough.Particles.Misc.Shoot:GetChildren()) do
		local clone = child:Clone()
		v = math.max(v, clone.Lifetime.Max)
		misc.ScaleParticle(clone, v2)
		clone.Parent = attachment
		table.insert(clones, clone)
	end

	attachment.Parent = workspace.Terrain

	for _, v3 in pairs(clones) do
		local emit = v3:GetAttribute("Emit") or 1
		local enable = v3:GetAttribute("Enable")
		v3:Emit(emit)

		if not enable then
			continue
		end

		v += enable
		local v4 = v3
		local v5 = enable
		task.spawn(function()
			v4.Enabled = true
			task.wait(v5)
			v4.Enabled = false
		end)
	end

	Util.Debris:AddItem(attachment, v + 0.1)
end

local _ = models.Projectile.Size
local v = {}
local v2 = {}
local v3 = Pool.new(string.format("Dough/%s/%s", script.Parent.Name, script.Name))

function v2.new(instance, scale, state)
	if typeof(scale) ~= "Vector2" then
		if typeof(scale) == "number" then
			scale = ((instance.Size * createVector(0, 0, 1)).Magnitude + (instance.Size * createVector(1, 1, 0)).Magnitude) * scale * 1 / 4.827018558979034
		else
			scale = instance.Size.Magnitude * 1 / 4.827018558979034
		end
	end

	if v[instance] then
		v[instance]:scale(scale)
		return v[instance]
	end

	local clone = models.Projectile:Clone()
	clone.CFrame = instance.CFrame
	local bones = {}
	local attachments = {}
	local maxParticleLifetime = 0
	local particles = {}

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Bone") then
			table.insert(bones, {
				Bone = descendant,
				CFrame = descendant.CFrame,
				Rotation = descendant.CFrame - descendant.CFrame.p,
				Length = descendant.Position.Magnitude
			})
		end

		if descendant:IsA("Attachment") then
			table.insert(attachments, {
				Attachment = descendant,
				Position = descendant.Position
			})
		end

		if not descendant:IsA("ParticleEmitter") then
			continue
		end

		maxParticleLifetime = math.max(maxParticleLifetime, descendant.Lifetime.Max)
		table.insert(particles, {
			Particle = descendant,
			Data = {
				Size = descendant.Size.Keypoints,
				Speed = descendant.Speed,
				Acceleration = descendant.Acceleration
			}
		})
	end

	if state then
		state.StartTime = tick()
		state.TimeDifference = math.max(0, (state.StartTime - state.Timestamp) / 2 - 0.03333333333333333)
		state.LastCFrame = instance.CFrame
		state.LastVector = state.LastCFrame.LookVector
		state.LastCFrame += state.LastVector * state.Speed * state.TimeDifference
		state.LastPosition = state.LastCFrame.p
	end

	Random.new()
	local object = setmetatable({
		Data = state,
		Scale = scale,
		LastDrip = 0,
		MaxParticleLifetime = maxParticleLifetime,
		Attach = instance,
		Part = clone,
		Particles = particles,
		Attachments = attachments,
		Bones = bones,
		Waves = {
			sine.new(0.3333333333333333, 0.5, -3.141592653589793),
			sine.new(0.3333333333333333, 1.5, 0),
			sine.new(0.3333333333333333, 2, 3.141592653589793)
		},
		Phase = 0,
		PhaseSpeed = 1.5
	}, {
		__index = v2
	})
	object.fadeIn = 0.15
	object.initialScale = object.Scale
	object.finalScale = object.Scale

	if typeof(object.initialScale) == "Vector2" then
		object.initialScale *= Vector2.new(1, 0.01)
	else
		object.initialScale *= 0.01
	end

	v[instance] = object
	v3:add(object)
	object:scale(object.initialScale)
	object:update()
	object:ignite(true)
	local model = Instance.new("Model")
	model.Name = "Dough/Projectile"
	model.PrimaryPart = clone
	clone.Parent = model
	model.Parent = _WorldOrigin
	object.Model = model
	local v8 = (typeof(object.finalScale) == "Vector2" and object.finalScale.X or object.finalScale) * 0.325
	local v9 = instance.CFrame * CFrame.new(0, 0, -clone.Size.Z / 4)
	local magnitude = (v9.p - currentCamera.CFrame.p).Magnitude
	local v10 = 50 + v8 * 2

	if magnitude < v10 then
		math.min(1, magnitude / v10)
		Effect.new("ShakeCam"):replicate({
			Magnitude = 7,
			Roughness = 5,
			FadeIn = 0.2,
			FadeOut = 0.9,
			PosInfluence = createVector(0.1, 0.1, 0.1),
			RotInfluence = createVector(0, 0, 1),
			Power = 1 - magnitude / v10 * 0.5
		})
	end

	if (currentCamera.CFrame.p - v9.p).Magnitude < 75 + v8 * 3 then
		doughExplosionsDripScatter:replicate({
			CFrame = v9 * CFrame.new(0, 0, clone.Size.Z / 4) * CFrame.Angles(3.141592653589793, 0, 0),
			Spread = Vector2.new(90, 90),
			Scale = v8 / 1.1,
			Drag = 2,
			Distance = 10 + v8 * 4,
			Rate = 5,
			Gravity = 0.75,
			Time = 0.45,
			Influence = { 0.5, 1.5 }
		})
	end

	task.spawn(function()
		for i = 1, 2 do
			local scale2 = (2.5 + v8 * 3.25) * ((4 - i) / 2 + 0.5)
			doughShockwaves2:replicate({
				CFrame = v9 * CFrame.Angles(1.5707963267948966, 0, 0) + v9.LookVector * scale2 / 1.75 * i - v9.LookVector * clone.Size.Z / 2,
				VectorOffset = v9.LookVector * scale2 / 2 * (i / 1.5 + 0.5),
				Scale = scale2,
				Speed = -1.5,
				Duration = (3 - i) * 0.1 / 2 + 0.1,
				Color = Color3.fromRGB(500, 500, 500)
			})
			task.wait(0.016666666666666666)
		end
	end)
	popShot(v9 * CFrame.new(0, 0, clone.Size.Z / 4), v8)
	return object
end

function v2:build()
	local scale = self.Scale

	if typeof(self.Scale) == "Vector2" then
		scale = self.Scale.Y
	elseif typeof(self.Scale) == "number" then
		scale = self.Scale * 2
	end

	local position = self.Part.Position
	local v4 = self.Part.CFrame * (self.Bones[1].CFrame.p * (2.9366422295570374 / scale))
	local v5 = self.Part.CFrame * Vector3.new(0, 0, -self.Part.Size.Z / 2)
	local magnitude = (position - v4).Magnitude
	local magnitude2 = (v5 - position).Magnitude
	self.DistanceFromRootToMidpoint = magnitude
	self.DistanceFromMidpointToApex = magnitude2
	local v6 = { self.Data.LastPosition }
	local total = 0
	local lengths = {}

	for k, bone in pairs(self.Bones) do
		local v8 = bone.Length / 2.9366422295570374 * scale
		total += v8
		lengths[k] = v8
		v6[k + 1] = v6[k] - self.Data.LastVector * v8
	end

	if self.Chain then
		self.Chain.lengths = lengths
		self.Chain.totallength = total
	else
		local v8 = CFrame.new(Vector3.new(), self.Data.LastVector) + self.Data.LastPosition
		self.Chain = FABRIK.new(v6, v8 * Vector3.new(0, 0, -total))
	end
end

function v2:update(lastCFrame)
	local chain = self.Chain

	if not chain then
		return
	end

	if lastCFrame then
		self.Data.LastCFrame = lastCFrame
	else
		local lastVector = self.Data.LastVector
		local lastPosition = self.Data.LastPosition
		lastCFrame = CFrame.new(Vector3.new(), lastVector) + lastPosition
	end

	chain.origin = lastCFrame.p
	chain:forward()
	chain.target = chain.joints[#chain.joints]
	local cframe = CFrame.new(chain.origin, chain.joints[2])
	local v4 = cframe * CFrame.new(0, 0, -self.DistanceFromRootToMidpoint) * CFrame.Angles(0, 3.141592653589793, 0)
	self.Part.CFrame = v4 * CFrame.new(0, 0, (chain.joints[2] - chain.joints[1]).Magnitude / 2)

	for k, joint in pairs(chain.joints) do
		local v5

		if k < #chain.joints then
			v5 = k + 1
		else
			v5 = false
		end

		if not v5 then
			continue
		end

		local joint2 = chain.joints[v5]
		local v6 = joint2 - joint
		local cframe2 = CFrame.new(joint + v6 / 2, joint2)
		CFrame.new()
		local v7

		if k > 1 then
			v7 = v4

			for i = 1, k - 1 do
				v7 *= self.Bones[i].Rotation
			end
		else
			v7 = v4
		end

		local objectSpace = cframe:ToObjectSpace(v7 * self.Bones[k].Rotation)
		local v8 = objectSpace - objectSpace.p
		self.Bones[k].Bone.WorldCFrame = cframe2 * v8
	end
end

function v2:Destroy(p)
	if self.Destroyed then
		return
	end

	if p then
		p.StartTime = tick()
	end

	self.Destroyed = p or true
	self:ignite(false)
	Util.Debris:AddItem(self.Part, math.max(self.MaxParticleLifetime, self.Destroyed.FadeOut) + 0.1)
	v[self.Attach] = nil
end

function v2:scale(scale)
	if not scale then
		return
	end

	self.Scale = scale
	local v4 = 0

	if typeof(scale) == "Vector2" then
		v4 = scale.X * 1 / 1.890376329421997
	elseif typeof(scale) == "number" then
		v4 = scale * 1 / 1.890376329421997
	end

	self.Part.Size = createVector(1.8903763, 1.8903763, 5.8732843) * v4
	self:build()

	for _, attachment in pairs(self.Attachments) do
		attachment.Attachment.Position = attachment.Position * v4
	end

	for _, particle in pairs(self.Particles) do
		misc.ScaleParticle(particle.Particle, v4, particle.Data)
	end
end

function v2:ignite(enabled)
	for _, particle in pairs(self.Particles) do
		particle.Particle.Enabled = enabled
	end
end

v3:setAction(function(object, p)
	local DISTANCE_THRESHOLD = 0.1
	local now = tick()

	for _, v4 in pairs(object.Pool) do
		local X, Y

		if typeof(v4.finalScale) == "Vector2" then
			X = v4.finalScale.X
			Y = v4.finalScale.Y
		else
			X = v4.finalScale
			Y = v4.finalScale * 2
		end

		local total = 0

		for _, wave in pairs(v4.Waves) do
			total += wave:calculate(v4.Phase)
		end

		local vector2 = Vector3.new(Y * total * 1 / 2, 0, 0)

		if v4.DestroyFully or not (v4.Part and v4.Part:IsDescendantOf(workspace)) then
			v4.Model:Destroy()
			object:remove(v4)
		else
			if v4.Destroyed then
				local v5 = v4.Destroyed.Hit and 1 or 0
				local v6 = math.min(1, (now - v4.Destroyed.StartTime) / v4.Destroyed.FadeOut)
				local quart = Util.Tween.ease.out.quart(v6, 0, 1, 1)
				local quart2 = Util.Tween.ease.out.quart(v6, 1, -1, 1)
				local sine2 = Util.Tween.ease["in"].sine(v6, 0, 1, 1)
				local quart3 = Util.Tween.ease["in"].quart(v6, 0, 1, 1)
				local v7 = vector2 * quart2
				local finalScale = v4.finalScale

				if typeof(v4.finalScale) == "Vector2" then
					finalScale = finalScale:Lerp(v4.finalScale * Vector2.new(0.01, 1), sine2)
				elseif typeof(v4.finalScale) == "number" then
					finalScale = Util.Tween.point(finalScale, v4.finalScale * 0.01, sine2)
				end

				local unit = (v4.Destroyed.CFrame.p - v4.Data.LastPosition).Unit
				local cross = unit:Cross(v4.Destroyed.Normal)
				local vector3

				if cross.Magnitude > DISTANCE_THRESHOLD then
					vector3 = cross.Unit
				else
					vector3 = v4.Destroyed.CFrame.RightVector
				end

				local v8 = -vector3:Cross(createVector(0, 1, 0))

				if v8.Magnitude > DISTANCE_THRESHOLD then
					unit = v8.Unit
				end

				local v9 = Y + X / 2
				local v10 = unit * ((v4.Destroyed.CFrame.p - v4.Data.LastPosition):Dot(unit) + v9 * (1 - v5))
				local v11 = (v4.Data.LastPosition + v10 - v4.Destroyed.CFrame.p).Magnitude + v9 * v5
				local v12 = -v4.Destroyed.Normal * v11
				local v13 = v4.Data.LastPosition + v10 * quart + v12 * quart3
				local unit2 = v4.Data.LastVector:Lerp((v13 - v4.Data.LastPosition).Unit, p * 12).Unit
				local v14 = CFrame.new(Vector3.new(), unit2) + v13
				v4:scale(finalScale)
				v4:update(v14 * CFrame.new(v7))

				if v6 == 1 then
					v4.DestroyFully = true
				end
			else
				local v5 = math.min(1, (now - v4.Data.StartTime) / v4.fadeIn)
				local quad = Util.Tween.ease["in"].quad(v5, 0, 1, 1)
				local initialScale = v4.initialScale
				local v6 = vector2 * quad

				if typeof(v4.finalScale) == "Vector2" then
					initialScale = initialScale:Lerp(v4.finalScale, quad)
				elseif typeof(v4.finalScale) == "number" then
					initialScale = Util.Tween.point(initialScale, v4.finalScale, quad)
				end

				local lookVector = v4.Attach.CFrame.LookVector
				local _ = v4.Attach.CFrame.p
				local lastVector = v4.Data.LastVector
				local lastPosition = v4.Data.LastPosition + lastVector * v4.Data.Speed * p
				local v8 = CFrame.new(Vector3.new(), lastVector) + lastPosition

				if (v4.Data.LastPosition - lastPosition).Magnitude >= v4.Data.Speed * 0.5 * p then
					local rayCastWhitelist, _, v9 = Util.RayCastWhitelist(
						v4.Data.LastPosition,
						lastPosition - v4.Data.LastPosition,
						{ workspace.Map }
					)

					if rayCastWhitelist then
						local cross = lookVector:Cross(v9)
						local v10 = -(not (cross.Magnitude > DISTANCE_THRESHOLD) and createVector(1, 0, 0) or cross.Unit):Cross(v9)
						local v11 = not (v10.Magnitude > DISTANCE_THRESHOLD) and createVector(-0, -0, -1) or v10.Unit
						lastPosition = v4.Data.LastPosition + v11 * v4.Data.Speed * p
					end

					if now - v4.LastDrip >= 0.03333333333333333 then
						Effect.new("Dough.Misc.Drip.Generic"):replicate({
							Type = "Generic",
							Root = v4.Part
						})
						v4.LastDrip = now
					end
				end

				v4:scale(initialScale)
				v4:update(v8 * CFrame.new(v6))
				v4.Data.LastVector = v4.Data.LastVector:Lerp(lookVector, p * 12).Unit
				v4.Data.LastPosition = lastPosition
			end

			v4.Phase += v4.PhaseSpeed * p
		end
	end
end)
return (setmetatable({}, {
	__index = function(_, value)
		if value:lower() == "get" then
			return function(...)
				local v4 = { ... }
				local v5 = v4[1]

				if typeof(v5) == "table" then
					v5 = v4[2]
				end

				return v[v5]
			end
		end

		if v2[value] then
			return v2[value]
		end
	end
}))