local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require("../util")
local Supersonic = {}

function Supersonic.MutateModel(data, _)
	local clone = ReplicatedStorage.resources.replicated.instances.mutations.vfx.Supersonic:Clone()
	clone.CFrame = data.Center.CFrame
	clone.Size = data.ExtentsSize
	local v = math.max(data.ExtentsSize.X, data.ExtentsSize.Y)
	local numberSequence = NumberSequence.new(v * 0.75, 0)
	local numberRange = NumberRange.new(data.ExtentsSize.Z / 2)
	clone.WhiteSwirl.Swirl.Size = numberSequence
	clone.WhiteSwirl.Swirl.Speed = numberRange
	clone.WhiteSwirl.CFrame = CFrame.new(0, 0, -data.ExtentsSize.Z / 2.25)
	clone.RedSwirl.Swirl.Size = numberSequence
	clone.RedSwirl.Swirl.Speed = numberRange
	clone.RedSwirl.CFrame = CFrame.new(0, 0, -data.ExtentsSize.Z / 2.25 + numberRange.Min / 10)
	local Y = data.ExtentsSize.Y
	local position = data.Mouth.Position + Vector3.new(
		0,
		(data.ExtentsSize.Y - math.max(data.Mouth.Position.Y, 0)) / 8,
		0
	)
	clone.RibbonBottom.Position = position
	clone.RibbonTop.Position = position + createVector(0, 0.9, -0.437) * Y / 2
	clone.RibbonTop.Beam.Width0 = Y / 2
	clone.RibbonTop.Beam.Width1 = Y / 2
	clone.weld.Part0 = data.Center
	clone.weld.Part1 = clone
	clone.Parent = data.Model
end

function Supersonic.new(p)
	p.Type = "Supersonic"
	return p
end

return Supersonic