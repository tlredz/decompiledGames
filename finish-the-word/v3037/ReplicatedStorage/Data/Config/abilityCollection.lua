local import = _G.import("iterator")
local import2 = _G.import("dictUtil")
local v = _G.import("collection")("Ability", script)
v:require(function(_, p)
	p.Instance = p.Instance or function()
		return {}
	end
end)

function v.getAbilities(object, p)
	return import(ipairs(p.Abilities)):map(function(_, p2)
		return import2.merge(object:get(p2.Id).Info, p2)
	end)
end

return v