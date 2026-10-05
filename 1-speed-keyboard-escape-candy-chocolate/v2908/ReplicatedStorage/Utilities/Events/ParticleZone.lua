local ParticleZone = {}
ParticleZone.__index = ParticleZone

function ParticleZone.new(p)
	local object = setmetatable({}, ParticleZone)
	object._diameter = p and p.diameter or 50
	object.part = nil
	return object
end

function ParticleZone:setup(maid, p2)
	local _diameter = self._diameter
	local part = maid:Add(Instance.new("Part"))
	part.Name = "ParticleZone"
	part.Size = Vector3.new(_diameter, _diameter, _diameter)
	part.Shape = Enum.PartType.Ball
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = p2 or CFrame.new()
	part.Parent = workspace
	self.part = part
	return part
end

function ParticleZone.update(p, position)
	if p.part and p.part.Parent then
		p.part.CFrame = CFrame.new(position)
	end
end

return ParticleZone