local store = require(script.Parent.store)
require(script.Parent.types)

local function atom(p, p2)
	local equals = p2 and p2.equals
	local atom2

	atom2 = function(...)
		if select("#", ...) == 0 then
			local index = store.capturing.index

			if index > 0 then
				store.capturing.stack[index][atom2] = true
			end

			return p
		else
			local v = store.peek(..., p)

			if p ~= v and not (equals and equals(p, v)) then
				p = v
				store.notify(atom2)
			end

			return p
		end
	end

	store.listeners[atom2] = setmetatable({}, {
		__mode = "v"
	})
	return atom2
end

return atom