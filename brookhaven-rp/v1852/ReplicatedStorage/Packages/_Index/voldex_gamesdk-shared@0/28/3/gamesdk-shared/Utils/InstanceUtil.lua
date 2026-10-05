return {
	createOrGetInstance = function(parent, name: string, className: string)
		local selected = parent:FindFirstChild(name) or Instance.new(className)
		selected.Name = name
		selected.Parent = parent
		return selected
	end
}