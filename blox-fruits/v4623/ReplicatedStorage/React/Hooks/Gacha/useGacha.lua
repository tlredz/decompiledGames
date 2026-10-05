local GachaClient = require(game.ReplicatedStorage.Controllers.GachaClient)
local React = require(game.ReplicatedStorage.Packages.React)
return function(p)
	local state, setState = React.useState(GachaClient.TryGetGacha(p))
	React.useEffect(function()
		local thread = task.spawn(function()
			setState(GachaClient.GetGachaAsync(p))
		end)
		return function()
			task.cancel(thread)
		end
	end, { p })
	return state
end