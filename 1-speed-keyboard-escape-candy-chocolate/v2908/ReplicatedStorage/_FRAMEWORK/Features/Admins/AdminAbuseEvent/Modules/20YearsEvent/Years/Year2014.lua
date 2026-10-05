local DefaultYearMap = require(script.Parent.DefaultYearMap)
local OrbSupport = require(script.Parent.OrbSupport)
require(script.Parent.Parent.Types)
local Year2014 = {}

function Year2014.load(p, p2: number)
	local loaded, v = DefaultYearMap.load(p, 2014)

	if not loaded then
		return nil, v
	end

	local v2 = OrbSupport.start(p, p2, loaded.map)
	local cleanup = loaded.cleanup
	return {
		map = loaded.map,
		spawn = loaded.spawn,
		cleanup = function()
			v2()
			cleanup()
		end
	}, nil
end

function Year2014.loadClient(p, _: number)
	return OrbSupport.startClient(p)
end

return Year2014