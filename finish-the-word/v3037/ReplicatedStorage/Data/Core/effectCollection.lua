local import = _G.import("collection")
local import2 = _G.import("validUtil")
local v = import("Stat", script)
v:require(function(_, p)
	import2.assertFields(p, "reduce", "apply")
end)
return v