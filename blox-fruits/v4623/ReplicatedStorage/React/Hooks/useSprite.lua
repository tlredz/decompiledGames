local React = require(game.ReplicatedStorage.Packages.React)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
return function(p: string?)
	return React.useMemo(function()
		if p == nil then
			return nil
		end

		return Spritesheets.MAP[p]
	end, { p })
end