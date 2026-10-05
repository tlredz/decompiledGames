local Ripple = require(script.Parent.Parent.Ripple)
local Vide = require(script.Parent.Parent.Vide)

local function useTween(p, p2)
	local tween = Ripple.createTween(p, p2)
	local source = Vide.source(p)

	if not p2 or p2.start ~= false then
		tween:start()
	end

	local v = tween:onChange(source)
	Vide.cleanup(function()
		v()
		tween:stop()
	end)
	return source, tween
end

return useTween