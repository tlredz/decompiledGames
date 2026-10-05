local ReplicatedStorage = game:GetService("ReplicatedStorage")
require("../util")
local accessories = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("mutations"):WaitForChild("accessories")
local AddAccessory = {}

function AddAccessory.MutateModel(data, data2)
	if not accessories:FindFirstChild(data2.TemplateName) then
		warn((`[AddAccessory] No mutation accessory named "{data2.TemplateName}" found!`))
		return
	end

	local extentsSize = data2.SizeMode == "ExtentsSize" and data.ExtentsSize or data.Hitbox and data.Hitbox.Size or data.ExtentsSize
	local clone = accessories:WaitForChild(data2.TemplateName):Clone()
	local offset = data2.Offset or CFrame.identity

	if data2.OffsetExtents then
		offset += data2.OffsetExtents * extentsSize
	end

	if data2.RelativeTo == "Center" then
		local magnitude = (extentsSize * data2.SizeMultiplier or 1).Magnitude
		clone.Size *= magnitude
		clone.PivotOffset = clone.PivotOffset.Rotation * CFrame.new(clone.PivotOffset.Position * magnitude)
		clone:PivotTo(data.Center.CFrame * offset)
	else
		local magnitude = (extentsSize * data2.SizeMultiplier or 1).Magnitude

		if data.HeadTop then
			magnitude = ((data.HeadTop.Position - data.HeadBottom.Position) * (data2.SizeMultiplier or 1)).Magnitude
		end

		clone.Size *= magnitude
		clone.PivotOffset = clone.PivotOffset.Rotation * CFrame.new(clone.PivotOffset.Position * magnitude)

		if data2.RelativeTo == "HeadTop" and data.HeadTop then
			clone:PivotTo(data.HeadTop.CFrame * offset)
		else
			clone:PivotTo(data.HeadBottom.WorldCFrame * offset)
		end
	end

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = data.Center
	weldConstraint.Part1 = clone
	weldConstraint.Parent = clone
	clone.Parent = data.Model
end

function AddAccessory.new(p)
	p.Type = "AddAccessory"
	return p
end

return AddAccessory