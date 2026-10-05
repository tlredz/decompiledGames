local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local assets = FX:WaitForChild("Pain").Z.Assets
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Ghost = {}

function Ghost.new(p, items)
	local v = {
		Stage = 2,
		Scale = 1,
		Created = tick(),
		Angle = 0,
		AngleSpeed = 4
	}

	if typeof(items) == "table" then
		for k, item in pairs(items) do
			v[k] = item
		end
	end

	local ghostModel = assets:FindFirstChild("GhostModel")
	local ghostPart = assets:FindFirstChild("GhostPart")

	if not ghostModel then
		return
	end

	local clone = ghostModel:Clone()

	if not ghostPart then
		return
	end

	local clone2 = ghostPart:Clone()
	v.Model = clone
	v.EffectModel = clone2
	v.Consonants = {
		Attachments = {},
		Particles = {}
	}

	for _, descendant in pairs(v.EffectModel:GetDescendants()) do
		if descendant:IsA("Attachment") then
			table.insert(v.Consonants.Attachments, {
				Instance = descendant,
				Position = descendant.Position
			})
		elseif descendant:IsA("ParticleEmitter") then
			table.insert(v.Consonants.Particles, {
				Instance = descendant,
				Size = descendant.Size.Keypoints,
				Speed = descendant.Speed,
				Acceleration = descendant.Acceleration
			})
		end
	end

	v.AngryTrails = {}

	if v.Stage == 1 then
		for i = 1, 3 do
			local clone3 = assets.AngryEffectBig:Clone()

			for _, descendant in pairs(clone3:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					table.insert(v.Consonants.Particles, {
						Instance = descendant,
						Size = descendant.Size.Keypoints,
						Speed = descendant.Speed,
						Acceleration = descendant.Acceleration
					})
				elseif descendant:IsA("Attachment") then
					table.insert(v.Consonants.Attachments, {
						Instance = descendant,
						Position = descendant.Position
					})
				end
			end

			local v2 = 6.283185307179586 * i / 3 * random:NextNumber(0.75, 1.25)
			local offset = random:NextNumber(7, 9) * Vector3.new(math.cos(v2), 0, (math.sin(v2))).Unit
			table.insert(v.AngryTrails, {
				Part = clone3,
				Offset = offset,
				ZOffset = random:NextNumber(8, 12)
			})
		end
	end

	Util.SetParentOverrideWithColor(v.Model, _WorldOrigin, p, "PainFruitVFXColor")
	Util.SetParentOverrideWithColor(v.EffectModel, _WorldOrigin, p, "PainFruitVFXColor")
	return (setmetatable(v, {
		__index = Ghost
	}))
end

function Ghost.spawn(data, p, cFrame: CFrame)
	for _, angryTrail in pairs(data.AngryTrails) do
		angryTrail.Part.CFrame = cFrame
		Util.SetParentOverrideWithColor(angryTrail.Part, _WorldOrigin, p, "PainFruitVFXColor")
	end

	data.Model:SetPrimaryPartCFrame(cFrame)
	data.EffectModel.CFrame = cFrame * CFrame.new(0, 0, data.EffectModel.Size.Z / 8)
	Util.SetParentOverrideWithColor(data.Model, _WorldOrigin, p, "PainFruitVFXColor")
	Util.SetParentOverrideWithColor(data.EffectModel, _WorldOrigin, p, "PainFruitVFXColor")
end

function Ghost:scale(scale: number)
	self.Scale = scale

	if not self.Model then
		return
	end

	self.Model:ScaleTo(self.Scale)
	self.EffectModel.Size *= self.Scale

	for _, consonant in pairs(self.Consonants) do
		for _, v in pairs(consonant) do
			if v.Instance:IsA("Attachment") then
				v.Instance.Position = v.Position * self.Scale
			elseif v.Instance:IsA("ParticleEmitter") then
				Util.Misc.ScaleParticle(v.Instance, self.Scale, v)
			end
		end
	end
end

function Ghost:update(cFrame: CFrame, p: number)
	self.CFrame = cFrame
	self.Model:SetPrimaryPartCFrame(self.CFrame)
	self.EffectModel.CFrame = self.CFrame * CFrame.new(0, 0, self.EffectModel.Size.Z / 8)

	for k, angryTrail in pairs(self.AngryTrails) do
		local v = k % 2 == 0 and math.sin(self.Angle) or math.cos(self.Angle)
		angryTrail.Part.CFrame = self.CFrame * CFrame.new(0, 0, v * (5 + angryTrail.ZOffset * self.Scale)) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		) * CFrame.Angles(0, self.Angle, 0) * CFrame.new(angryTrail.Offset * self.Scale)
	end

	self.Angle = self.Angle % 6.283185307179586 + 3.141592653589793 * self.AngleSpeed * p
end

function Ghost:destroy()
	local v = 0

	for _, part in pairs(self.Model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end

	for _, effect in pairs(self.EffectModel:GetDescendants()) do
		if effect:IsA("ParticleEmitter") then
			v = math.max(v, effect.Lifetime.Max)
			effect.Enabled = false
		elseif effect:IsA("Trail") then
			v = math.max(v, effect.Lifetime)
		end
	end

	for _, angryTrail in pairs(self.AngryTrails) do
		for _, emitter in pairs(angryTrail.Part:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			v = math.max(v, emitter.Lifetime.Max)
			emitter.Enabled = false
		end
	end

	task.delay(v, function()
		self.Model:Destroy()
		self.EffectModel:Destroy()

		for _, angryTrail in pairs(self.AngryTrails) do
			angryTrail.Part:Destroy()
		end

		self.AngryTrails = {}
	end)
	self.Consonants = {
		Attachments = {},
		Particles = {}
	}
end

Ghost.Spawn = Ghost.spawn
Ghost.Scale = Ghost.scale
Ghost.Update = Ghost.update
Ghost.Destroy = Ghost.destroy
return Ghost