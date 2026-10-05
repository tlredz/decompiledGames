local isImmutable = require(script.Parent.isImmutable)
local isDataStructure = require(script.Parent.isDataStructure)
local shallowCopy = require(script.Parent.shallowCopy)
return function(list, p)
	if not isDataStructure(list) then
		error("Cannot update non-data-structure value: " .. tostring(list))
	end

	if isImmutable(list) then
		if not list.remove then
			error("Cannot update immutable value without .remove() method: " .. tostring(list))
		end

		return list:remove(p)
	else
		if not list[p] then
			return list
		end

		local v = shallowCopy(list)

		if #v > 0 then
			table.remove(list, p)
			return v
		end

		list[p] = nil
		return v
	end
end