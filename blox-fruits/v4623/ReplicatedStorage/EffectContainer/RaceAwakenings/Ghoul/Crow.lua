local Util = require(game.ReplicatedStorage:WaitForChild("Util"))
local misc = Util.Misc
local FX = require(game.ReplicatedStorage.FX)
workspace:WaitForChild("_WorldOrigin")
local model = FX:WaitForChild("RaceAwakenings").Ghoul.Crow.Model
local Crow = {}

function Crow.new()
	local v = {
		Scale = 1,
		Model = model:Clone()
	}
	v.Root = v.Model.PrimaryPart
	v.Parts = {}
	return setmetatable(v, {
		__index = Crow
	}):__build()
end

function Crow:__build()
	self.Particles = {}

	for _, emitter in pairs(self.Model:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			table.insert(self.Particles, {
				Particle = emitter,
				Data = {
					Size = emitter.Size.Keypoints,
					Speed = emitter.Speed,
					Acceleration = emitter.Acceleration
				}
			})
		end
	end

	for _, part in pairs(self.Model:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local identity = CFrame.identity

		if part ~= self.Root then
			identity = self.Root.CFrame:ToObjectSpace(part.CFrame)
		end

		local v = {
			Part = part,
			Mesh = part:FindFirstChild("Mesh")
		}
		v.MeshScale = v.Mesh.Scale
		v.Trail = part:FindFirstChild("Trail")
		v.ScaleOffset = identity
		v.Offset = CFrame.identity
		v.Attachments = {}

		for _, attachment in pairs(part:GetChildren()) do
			if attachment:IsA("Attachment") then
				table.insert(v.Attachments, {
					Attachment = attachment,
					Position = attachment.Position
				})
			end
		end

		self.Parts[part.Name] = v
	end

	return self
end

function Crow:SetScale(p)
	self.Scale = p or self.Scale
	local root = self.Root
	local parts = self.Parts
	local _ = self.Particles

	for _, particle in pairs(self.Particles) do
		misc.ScaleParticle(particle.Particle, p, particle.Data)
	end

	for _, part in pairs(parts) do
		part.Mesh.Scale = part.MeshScale * p

		if part.Part ~= root then
			part.Part.CFrame = root.CFrame * part.Offset * misc.ScaleCFrame(part.ScaleOffset, p)
		end

		for _, attachment in pairs(part.Attachments) do
			attachment.Attachment.Position = attachment.Position * p
		end
	end
end

function Crow.SetCFrame(p, cframe)
	p.Model:SetPrimaryPartCFrame(cframe)
end

function Crow.Flap(data, p)
	local root = data.Root
	local parts = data.Parts
	local mapped = misc.map(p, 0, 1, -0.7853981633974483, 0.7853981633974483)

	for _, part in pairs(parts) do
		if part.Part == root then
			continue
		end

		local v = part.Part.Name:find("Left") and 1 or -1
		part.Offset = CFrame.Angles(0, 0, v * mapped)
		part.Part.CFrame = root.CFrame * part.Offset * misc.ScaleCFrame(part.ScaleOffset, data.Scale)
	end
end

function Crow.Hide(p, p2)
	for _, part in pairs(p.Parts) do
		part.Part.Transparency = p2 and 1 or 0
	end
end

function Crow.Pop(p, p2)
	local v = 0

	for _, particle in pairs(p.Particles) do
		if p2 then
			misc.ScaleParticle(particle.Particle, p2, particle.Data)
		end

		v = math.max(v, particle.Particle.Lifetime.Max)
		particle.Particle:Emit(particle.Particle:GetAttribute("EmitCount") or 1)
	end

	local random = Random.new()
	Util.Sound:Play("WingFlap", p.Root.Position, 17.5, random:NextNumber(0.5, 0.75))
	return v
end

function Crow:Destroy()
	self.Model:Destroy()
end

return Crow