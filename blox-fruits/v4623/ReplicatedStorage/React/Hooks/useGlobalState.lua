local React = require(game.ReplicatedStorage.Packages.React)
local GlobalState = require(game.ReplicatedStorage.React.Contexts.GlobalState)
return function(p: string, p2)
	local v = React.useContext(GlobalState)
	local cache = v.Cache
	local hooks = v.Hooks
	local useState = React.useState
	local v2

	if hooks[p] == nil then
		v2 = p2
	else
		v2 = cache[p]
	end

	local state, setState = useState(v2)

	if hooks[p] == nil then
		hooks[p] = {}
		cache[p] = p2
	end

	React.useEffect(function()
		if hooks[p] == nil then
			hooks[p] = {}
		end

		table.insert(hooks[p], setState)
		return function()
			local index = table.find(hooks[p], setState)
			assert(index, (`couldn't find callback for "{p}"`))
			table.remove(hooks[p], index)

			if #hooks[p] == 0 then
				hooks[p] = nil
				cache[p] = nil
			end
		end
	end, { p, v })
	return state, function(p3)
		cache[p] = p3

		if not hooks[p] then
			setState(p3)
			return
		end

		for _, v3 in hooks[p] do
			local v4 = v3
			pcall(function()
				v4(p3)
			end)
		end
	end
end