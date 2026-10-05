return {
	ShouldConstruct = function(p)
		return not p.Instance:FindFirstAncestorOfClass("Tool")
	end
}