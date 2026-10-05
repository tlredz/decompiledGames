local isImmutable = require(script.Parent.isImmutable)
local isDataStructure = require(script.Parent.isDataStructure)
return function(object, p)
	if isImmutable(object) then
		return (object:has(p))
	end

	return isDataStructure(object) and object[p] ~= nil
end