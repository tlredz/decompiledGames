return {
	__index = {
		Delete = function(p)
			if p.Object:IsDescendantOf(p.Parent) then
				p.Object:Destroy()
			end
		end
	}
}