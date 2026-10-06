local atom = require(script.Parent.atom)
local store = require(script.Parent.store)
require(script.Parent.types)

local function computed(p, p2)
	local capture, v = store.capture(p)
	local current2 = atom(v, p2)
	local object = setmetatable({
		current = current2
	}, {
		__mode = "v"
	})
	local listener

	listener = function()
		local current = object.current

		if current then
			store.disconnect(capture, listener)
			capture, v = store.capture(p)
			store.connect(capture, listener, current)
			current(v)
		end
	end

	store.connect(capture, listener, current2)
	return current2
end

return computed