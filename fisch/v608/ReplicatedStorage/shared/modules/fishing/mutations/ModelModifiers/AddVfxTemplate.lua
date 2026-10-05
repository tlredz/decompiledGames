local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require("../util")
local vfx = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("mutations"):WaitForChild("vfx")
local AddVfxTemplate = {}

function AddVfxTemplate.MutateModel(data, data2)
	if not vfx:FindFirstChild(data2.TemplateName) then
		warn((`[AddVfxTemplate] No mutation template named "{data2.TemplateName}" found!`))
		return
	end

	local extentsSize = data2.SizeMode == "ExtentsSize" and data.ExtentsSize or data.Hitbox and data.Hitbox.Size or data.ExtentsSize
	local clone = vfx:WaitForChild(data2.TemplateName):Clone()
	local size = clone.Size
	clone.Size = extentsSize * (data2.BoxSizeMultiplier or 1)
	clone.weld.Part1 = clone
	clone.weld.Part0 = data.Center

	if data2.ReplaceColor then
		for _, effect in clone:GetDescendants() do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Color = data2.ReplaceColor
			end
		end
	end

	local v = extentsSize * (data2.ParticleSizeMultiplier or 1)
	local v2 = v * (data2.AttachmentSizeMultiplier or createVector(1, 1, 1))
	local v3 = math.max(v.X, v.Y, v.Z)
	local v4 = math.min(v.X, v.Y, v.Z)

	if data2.ParticleSizeMode ~= "None" then
		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("ParticleEmitter") then
				if data2.ParticleSizeMode == "Rate" then
					descendant.Rate *= v3
				else
					local numberSequenceKeypoints = table.create(#descendant.Size.Keypoints)

					for _, keypoint in descendant.Size.Keypoints do
						table.insert(
							numberSequenceKeypoints,
							NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * v3, keypoint.Envelope * v)
						)
					end

					descendant.Size = NumberSequence.new(numberSequenceKeypoints)
				end
			elseif descendant:IsA("Beam") then
				descendant.CurveSize0 *= v3
				descendant.CurveSize1 *= v3
				descendant.Width0 *= v3
				descendant.Width1 *= v3
				descendant.TextureLength *= v3
			elseif descendant:IsA("Trail") then
				descendant.TextureLength *= v3
				descendant.MinLength *= v3
				descendant.MaxLength *= v3
			elseif descendant:IsA("Attachment") then
				if data2.AttachmentSizeMode == "Nonuniform" then
					descendant.Position *= Vector3.new(v2.X / size.X, v2.Y / size.Y, v2.Z / size.Z)
				else
					descendant.Position *= math.max(v2.X, v2.Y, v2.Z)
				end
			end
		end
	end

	if data2.CustomTransform then
		data2.CustomTransform(data, clone, v3, v4)
	end

	clone.Parent = data.Model
end

function AddVfxTemplate.new(p)
	p.Type = "AddVfxTemplate"
	return p
end

return AddVfxTemplate