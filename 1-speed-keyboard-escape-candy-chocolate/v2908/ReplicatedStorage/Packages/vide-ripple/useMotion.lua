local Ripple = require(script.Parent.Parent.Ripple)
local Vide = require(script.Parent.Parent.Vide)

local function useMotion(p, p2)
	local motion = Ripple.createMotion(p, p2)
	local source = Vide.source(p)

	if not p2 or p2.start ~= false then
		motion:start()
	end

	local v = motion:onChange(source)
	Vide.cleanup(function()
		v()
		motion:stop()
	end)
	return source, motion
end

return useMotion