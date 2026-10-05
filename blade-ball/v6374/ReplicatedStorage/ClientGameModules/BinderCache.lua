local v = {}
local BinderCache = {}

function BinderCache.Add(_, p, p2)
	v[p] = p2
end

function BinderCache.Get(_, p)
	return v[p]
end

return BinderCache