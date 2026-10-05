local import = _G.import("collection")
local import2 = _G.import("iterator")
local v = import("Data", script)

function v.getCategories(_)
	return import2.values(script:GetChildren()):map(function(p)
		return p.Name
	end):array()
end

function v.getCategorySettings(_, p)
	return require(script[p])
end

return v