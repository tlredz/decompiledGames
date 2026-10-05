local React = require(game.ReplicatedStorage.Packages.React)
return function(p, p2, p3)
	local state, setState = React.useState(p2)
	local v = React.useMemo(function()
		return p3[state]
	end, { state, p3 })
	local v2 = v and p and v[p]

	if v2 then
		setState(v2)
	end

	return state, v, setState
end