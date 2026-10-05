local React = require(game.ReplicatedStorage.Packages.React)
return function(p: number, duration: number, _: number?, flag: boolean?)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if flag == false or not ((state or 0) < p) then
			return function() end
		end

		local thread = task.delay(duration, function()
			setState((state or 0) + 1)
		end)
		return function()
			task.cancel(thread)
		end
	end, { flag, state, p })

	if flag == false then
		state = nil
	end

	return state
end