local isImmutable = require(script.Parent.isImmutable)
return function(object)
	if isImmutable(object) then
		return object:clone()
	end

	return table.clone(object)
end