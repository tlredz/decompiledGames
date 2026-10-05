local Ripple = require(script.Parent.Parent.Ripple)
local Vide = require(script.Parent.Parent.Vide)

local function useSpring(p, p2)
	local spring = Ripple.createSpring(p, p2)
	local source = Vide.source(p)

	if not p2 or p2.start ~= false then
		spring:start()
	end

	local v = spring:onChange(source)
	Vide.cleanup(function()
		v()
		spring:stop()
	end)
	return source, spring
end

return useSpring