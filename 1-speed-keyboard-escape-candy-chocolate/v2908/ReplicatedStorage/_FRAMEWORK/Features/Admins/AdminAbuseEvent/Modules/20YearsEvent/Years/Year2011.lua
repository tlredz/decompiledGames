local DefaultYearMap = require(script.Parent.DefaultYearMap)
local MeteorSupport = require(script.Parent.MeteorSupport)
require(script.Parent.Parent.Types)
local WandererSupport = require(script.Parent.WandererSupport)
local Year2011 = {}

function Year2011.load(p, p2: number)
	local loaded, v = DefaultYearMap.load(p, 2011)

	if not loaded then
		return nil, v
	end

	local v2 = WandererSupport.start(p, p2, loaded.map)
	local v3 = MeteorSupport.start(p, p2, loaded.map)
	local cleanup = loaded.cleanup
	return {
		map = loaded.map,
		spawn = loaded.spawn,
		cleanup = function()
			v3()
			v2()
			cleanup()
		end
	}, nil
end

function Year2011.loadClient(p, p2: number)
	local v = WandererSupport.startClient(p2)
	local v2 = MeteorSupport.startClient(p, p2)
	return function()
		v2()
		v()
	end
end

return Year2011