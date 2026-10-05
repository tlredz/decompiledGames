local class = {}
class.__index = class

function class.__tostring(p)
	return (`SimpleError<"{p.Type}">("{p.Message}")`)
end

return {
	new = function(p, message: string)
		local v = {
			Type = p,
			Message = message
		}
		setmetatable(v, class)
		table.freeze(v)
		return v
	end
}