local function cloneAsModel(items, p: number)
	local model = Instance.new("Model")
	model:ScaleTo(p)
	local parents = {}

	for _, item in items do
		parents[item] = item.Parent
		item.Parent = model
	end

	local clone = model:Clone()

	for k, parent in parents do
		k.Parent = parent
	end

	return clone, clone:GetChildren()
end

return cloneAsModel