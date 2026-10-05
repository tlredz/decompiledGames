return {
	ShouldConstruct = function(p)
		if p.Instance:FindFirstAncestorOfClass("Tool") then
			return true
		end

		return false
	end
}