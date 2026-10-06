local PeodizLightning = {
	__index = require(script.Function)
}

function PeodizLightning.new(time, tween, p)
	p.Time = time
	p.Tween = tween
	setmetatable(p, PeodizLightning)
	return p
end

return PeodizLightning