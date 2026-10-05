game:GetService("ReplicatedStorage")
require("../util")
local Pancake = {}

function Pancake.MutateModel(p, p2)
	local center = p.Center

	local function weldModel()
		for _, part in ipairs(p.Model:GetDescendants()) do
			if not (part:IsA("BasePart") and part ~= center) then
				continue
			end

			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = center
			weldConstraint.Part1 = part
			weldConstraint.Parent = center
		end
	end

	weldModel()
	local position = p.Model:GetPivot().Position
	local scale = p2.Scale

	for _, part in ipairs(p.Model:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local v = part.Position - position
		local vector = Vector3.new(part.Size.X * scale.X, part.Size.Y * scale.Y, part.Size.Z * scale.Z)
		local vector2 = Vector3.new(v.X * scale.X, v.Y * scale.Y, v.Z * scale.Z)
		part.Size = vector

		for _, weldConstraint in ipairs(part:GetDescendants()) do
			if weldConstraint:IsA("WeldConstraint") then
				weldConstraint.Enabled = false
			end
		end

		part.Position = position + vector2

		for _, weldConstraint in ipairs(part:GetDescendants()) do
			if weldConstraint:IsA("WeldConstraint") then
				weldConstraint.Enabled = true
			end
		end
	end

	local v = (center.Size.Y / scale.Y - center.Size.Y) / 2
	local v2 = p.Model:GetPivot() * CFrame.new(0, -v, 0)
	p.Model:PivotTo(v2)
end

function Pancake.new(p)
	p.Type = "Pancake"
	return p
end

return Pancake