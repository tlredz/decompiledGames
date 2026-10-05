local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.Option)
return function(duration: number, _: number?, flag: boolean?)
	local state, setState = React.useState(false)
	React.useEffect(function()
		if flag == false then
			return function() end
		end

		local thread = task.delay(duration, function()
			setState(true)
		end)
		return function()
			task.cancel(thread)
		end
	end, { flag })

	if flag == false then
		state = false
	end

	return state
end