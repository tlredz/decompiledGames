local React = require(game.ReplicatedStorage.Packages.React)
local use = require(game.ReplicatedStorage.React.Hooks.UID.use)
local v = {}
local v2 = {}
return function(p: string, flag: boolean)
	local state, setState = React.useState(false)
	local v3 = use()
	React.useEffect(function()
		if not flag then
			return function() end
		end

		if v2[p] == nil then
			v2[p] = {}
		end

		if v[p] == nil then
			v[p] = {}
		end

		table.insert(v[p], v3)

		if #v[p] == 1 then
			setState(true)
		end

		v2[p][v3] = setState
		return function()
			local index = table.find(v[p], v3)
			assert(index, "uid missing")
			table.remove(v[p], index)

			if #v[p] == 0 then
				if index == 1 then
					setState(false)
				end

				v[p] = nil
				v2[p][v3] = nil
				local flag2 = true

				for _, _ in v2[p] do
					flag2 = false
					break
				end

				if flag2 then
					v2[p] = nil
				end
			else
				local v4 = v[p][1]
				v2[p][v4](true)
			end
		end
	end, { p, v3, flag })
	return state
end