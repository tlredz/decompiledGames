local v = {}
return (setmetatable({
	Interact = Instance.new("BindableEvent")
}, {
	__index = function(_, p)
		if v[p] then
			return v[p]
		end

		return function()
			warn((`Function {p} not found`))
		end
	end,
	__newindex = function(p, p2, p3)
		if rawget(p, p2) then
			rawset(p, p2, p3)
		else
			v[p2] = p3
		end
	end
}))