local React = require(game.ReplicatedStorage.Packages.React)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
return function(callback, p)
	local v = useDrawContext()
	React.useEffect(function()
		if v == "Offscreen" then
			return function() end
		end

		return callback() or function() end
	end, v == "Offscreen" and {} or p)
end