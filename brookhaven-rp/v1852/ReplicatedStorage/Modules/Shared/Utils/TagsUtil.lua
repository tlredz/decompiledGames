return {
	FindAncestorByTag = function(parent, tag: string)
		while parent ~= nil and not parent:HasTag(tag) do
			parent = parent.Parent
		end

		return parent
	end
}