local React = require(game.ReplicatedStorage.Packages.React)
local useAll = require(game.ReplicatedStorage.React.Hooks.Island.useAll)
return function(p, p2: string?)
	local v = useAll()
	return React.useMemo(function()
		if not (p and p2) then
			return
		end

		for _, v2 in v do
			if v2.Index.Key == p2 and v2.Index.Map == p then
				return v2
			end
		end

		return nil
	end, { p, p2, v })
end