local React = require(game.ReplicatedStorage.Packages.React)
local useIndex = require(game.ReplicatedStorage.React.Hooks.Easter.useIndex)
return function()
	local v = useIndex()
	return React.useMemo(function()
		local count = 0

		for _, v2 in v do
			if v2.Count > 0 then
				count += 1
			end
		end

		return count
	end, { v })
end