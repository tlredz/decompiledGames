local Promise = require(script.Parent.Parent.Promise)

local function unwrap(object, ...)
	if Promise.is(object) then
		return object:expect()
	end

	return object, ...
end

return unwrap