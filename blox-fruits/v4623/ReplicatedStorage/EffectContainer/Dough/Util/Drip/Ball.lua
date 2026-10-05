local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local dough = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(ReplicatedStorage.Util)
local misc = Util.Misc
local blob = dough.Models.Blob
local core = script:WaitForChild("Core")
local Effect = require(ReplicatedStorage.Effect)
local doughMiscDripGeneric = Effect.new("Dough.Misc.Drip.Generic")

local function calculatePoints(p, scale, p2)
	local v = math.floor((math.sqrt(p2)))
	local result = {}

	for i = 1, v do
		local v2 = 6.283185307179586 * (i / v)

		for i2 = 1, v do
			local v3 = 6.283185307179586 * (i2 / v)
			table.insert(
				result,
				p + Vector3.new(math.cos(v2) * math.cos(v3), math.sin(v3), math.sin(v2) * math.cos(v3)).Unit * scale
			)
		end
	end

	return result
end

local function spherePoint(vector2, scale, p, mapped)
	local random = Random.new()
	local v = p or 6.283185307179586 * random:NextNumber()
	local v2 = mapped or 6.283185307179586 * random:NextNumber()
	return vector2 + (scale or 1) * Vector3.new(math.cos(v) * math.cos(v2), math.sin(v2), math.sin(v) * math.cos(v2)).Unit
end

local function scaleBlob(p, value, p2, _)
	if not p.Parent then
		return
	end

	p.Size = (p2 or createVector(1, 1, 1)) * (value or 1)
end

local Ball = {}

function Ball.new(data)
	return setmetatable({
		Anchor = data.Anchor,
		CFrame = data.CFrame or CFrame.new(),
		Scale = data.Scale or data.Radius or 1,
		OutlineScale = data.OutlineScale,
		LastScale = 0,
		FadeIn = data.FadeIn or 0.5,
		Lifetime = data.Lifetime or 1,
		FadeOut = data.FadeOut or 0.25,
		AnimationSpeed = data.AnimationSpeed or 1
	}, {
		__index = Ball
	}):__build()
end

function Ball:__getCFrame()
	local cframe = CFrame.new()

	if typeof(self.Anchor) ~= "Instance" or not self.Anchor:IsDescendantOf(workspace) then
		return (self.LastCFrame or cframe) * self.CFrame
	end

	if self.Anchor:IsA("Attachment") then
		cframe = self.Anchor.WorldCFrame
	else
		cframe = self.Anchor.CFrame
	end

	self.LastCFrame = cframe
	return (self.LastCFrame or cframe) * self.CFrame
end

function Ball:__build()
	local cframe = self:__getCFrame()
	local v = calculatePoints(cframe.p, self.Scale, 25)
	local _ = CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(0, 3.141592653589793, 0)
	local model = Instance.new("Model")
	model.Name = script.Name
	local clone = core:Clone()
	clone.Parent = model
	model.PrimaryPart = clone
	local particles = {}

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		self.MaxParticleLifetime = math.max(self.MaxParticleLifetime or 0, emitter.Lifetime.Max)
		table.insert(particles, {
			Object = emitter,
			Data = {
				Size = emitter.Size.Keypoints,
				Speed = emitter.Speed,
				ZOffset = emitter.ZOffset,
				Acceleration = emitter.Acceleration
			}
		})
	end

	local blobs = {}

	for i = 1, #v do
		local v4 = v[i]
		local v5 = v4 - cframe.p
		local clone2 = blob:Clone()
		clone2.CFrame = CFrame.new(Vector3.new(), v5.Unit) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		) + v4
		clone2.Parent = model
		local pointToObjectSpace = cframe:PointToObjectSpace(clone2.Position)
		local v6 = math.atan2(pointToObjectSpace.Z, pointToObjectSpace.X)
		local pointToObjectSpace2 = (cframe * CFrame.new(Vector3.new(), createVector(0, 1, 0))):PointToObjectSpace(clone2.Position)
		local v7 = math.atan2(-pointToObjectSpace2.Z, pointToObjectSpace2.X)
		local mapped = misc.map(v7, 1.4922565104551517, -1.4922565104551517, 0, 1)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getOffset(value)
			local mapped2 = misc.map(value or 0, 0, 1, 1.4922565104551517, -1.4922565104551517)
			return (spherePoint(Vector3.new(), self.Scale, v6, mapped2))
		end

		local v9 = v6

		local function align(value)
			local __getCFrame = self:__getCFrame()
			local offset = getOffset(value) -- equivalent call inferred; original call site unknown
			local v11 = __getCFrame * offset
			local objectSpace = misc.AlignCFrame(__getCFrame, createVector(0, 1, 0)):ToObjectSpace(CFrame.new(
				__getCFrame.p + offset,
				__getCFrame.p
			))
			local v12 = CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			)
			local cFrame = __getCFrame * objectSpace * v12
			math.sin(3.141592653589793 * value)
			local object = clone2
			local scale = self.Scale
			local outlineScale = self.OutlineScale

			if object.Parent then
				object.Size = createVector(1.26, 0.67, 1.5) * (scale or 1)
			end

			clone2.CFrame = cFrame
		end

		local align2 = align
		table.insert(blobs, {
			CurrentAngle = mapped,
			Object = clone2,
			Update = function(self, p2)
				self.CurrentAngle = self.CurrentAngle % 1 + p2
				align2(self.CurrentAngle)
			end
		})
	end

	self.Blobs = blobs
	self.Model = model
	self.Particles = particles
	self.Model.Parent = _WorldOrigin
	self.Sound = Util.Sound:Play("Dough.DoughAmbienceLoop", clone, nil, 5.287 / (self.FadeIn + self.FadeOut))
	return self
end

function Ball:enable(enabled)
	if enabled then
		if self.Enabled then
			return
		else
			self.Enabled = true
		end
	elseif self.Enabled then
		self.Enabled = false
	else
		return
	end

	for _, particle in pairs(self.Particles) do
		local _ = particle.Object:GetAttribute("Emit") or particle.Object:GetAttribute("EmitCount")
		particle.Object.Enabled = enabled
	end
end

function Ball:update(value)
	if self.Destroying then
		return
	end

	self.Model.PrimaryPart.Size = createVector(1.25, 1.25, 1.25) * self.Scale * 2
	self.Model.PrimaryPart.CFrame = self:__getCFrame()
	self.Model.PrimaryPart.Attachment.CFrame = CFrame.new(0, self.Model.PrimaryPart.Size.Y / 2, 0)
	doughMiscDripGeneric:replicate({
		Root = self.Model.PrimaryPart,
		Scale = self.Scale,
		Speed = 25,
		OozeDuration = 1
	})
	local v = value or 0.016666666666666666

	for _, blob2 in pairs(self.Blobs) do
		blob2:Update(v * self.AnimationSpeed)
	end

	if self.LastScale < self.Scale then
		for _, particle in pairs(self.Particles) do
			misc.ScaleParticle(particle.Object, self.Scale * 2, particle.Data)
		end

		self.LastScale = self.Scale
	end
end

function Ball:Destroy()
	self.Destroying = true
	self:enable(false)
	Util.Sound:FadeOut(self.Sound, self.MaxParticleLifetime)
	Util.Debris:AddItem(self.Model, self.MaxParticleLifetime)
	self.Blobs = {}
	self.Particles = {}
end

return Ball