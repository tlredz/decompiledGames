require(script.Parent.Parent.types.Save)
require(script.Parent.Parent.types.Strip)
local PropertyRegistry = require(script.Parent.PropertyRegistry)
local v = {
	property = {
		typeName = "property",
		catchUpPolicies = { "latest" },
		createRuntime = function(p, callback)
			return PropertyRegistry.createRuntime(p, callback)
		end,
		getAssets = function(p)
			return PropertyRegistry.getAssets(p)
		end,
		preload = function(p)
			PropertyRegistry.preload(p)
		end
	}
}
local StripRegistry = {}

function StripRegistry.get(p: string)
	return v[p]
end

function StripRegistry.getAssets(p)
	local v2 = v[p.type]

	if v2 == nil then
		return {}
	end

	return v2.getAssets(p)
end

function StripRegistry.preload(p)
	local v2 = v[p.type]

	if v2 ~= nil then
		v2.preload(p)
	end
end

return StripRegistry