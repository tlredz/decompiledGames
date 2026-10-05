local createVector = vector.create
game:GetService("ReplicatedStorage")
require("../util")
local UpsideDown = {}

function UpsideDown.MutateModel(data, p)
	local v = not (data.Center and data.Handle) and createVector(0, 0, 0) or data.Handle.Position - data.Center.Position
	local v2 = {}

	for _, descendant in pairs(data.Model:GetDescendants()) do
		if not (descendant:IsA("WeldConstraint") or descendant:IsA("JointInstance")) then
			continue
		end

		table.insert(v2, {
			Part0 = descendant.Part0,
			Part1 = descendant.Part1,
			Constraint = descendant
		})
		descendant:Destroy()
	end

	data.Handle.CFrame = data.Handle.CFrame * CFrame.Angles(math.rad(p.Rotation), 0, 0) + v * -2

	for _, v3 in ipairs(v2) do
		local part0 = v3.Part0
		local part1 = v3.Part1

		if part0 and part1 and part0 ~= data.Handle and part1 ~= data.Handle then
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = part0
			weldConstraint.Part1 = part1
			weldConstraint.Parent = data.Model
		elseif part0 == data.Handle or part1 == data.Handle then
			if part0 == data.Handle then
				part0 = part1 or part0
			end

			if part0 then
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = data.Handle
				weldConstraint.Part1 = part0
				weldConstraint.Parent = data.Model
			end
		end
	end

	local model = data.Model:IsA("Tool") and data.Model or data.Model:FindFirstAncestorOfClass("Tool")

	if model and model:FindFirstChild("handle") then
		model.Grip *= CFrame.Angles(math.rad(p.Rotation), 0, 0)
	end
end

function UpsideDown.new(p)
	p.Type = "UpsideDown"
	return p
end

return UpsideDown