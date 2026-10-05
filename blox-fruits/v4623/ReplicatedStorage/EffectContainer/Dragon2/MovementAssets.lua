local function connectAttachments(folder, attachment, attachment2)
	for _, effect in folder:GetDescendants() do
		if effect:IsA("Beam") then
			effect.Attachment0 = attachment
			effect.Attachment1 = attachment2
		elseif effect:IsA("Trail") then
			effect.Attachment0 = attachment
			effect.Attachment1 = attachment2
		end
	end
end

local MovementAssets = {}

function MovementAssets.cloneStartBeam(instance)
	local clone = instance:Clone()
	connectAttachments(clone, clone:FindFirstChild("Attach0"), clone:FindFirstChild("Attach1"))
	return clone
end

function MovementAssets.cloneDash(instance, cframe: CFrame)
	local clone = instance:Clone()
	clone.Anchored = true
	clone.Massless = true

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.Massless = true
		elseif descendant:IsA("JointInstance") then
			descendant:Destroy()
		end
	end

	local trails = clone:FindFirstChild("Trails")
	connectAttachments(trails, trails:FindFirstChild("TrailAttach0"), trails:FindFirstChild("TrailAttach1"))
	local model = Instance.new("Model")
	model.Name = clone.Name
	clone.Parent = model
	model.PrimaryPart = clone
	model:PivotTo(cframe)
	return model
end

return MovementAssets