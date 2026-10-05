local React = require(game.ReplicatedStorage.Packages.React)
return function(p)
	local state, setState = React.useState(p)
	local flag = true
	React.useEffect(function()
		return function()
			flag = false
		end
	end, {})
	return state, function(p2, duration: number?)
		if duration and duration > 0 then
			return task.delay(duration, function()
				if flag then
					setState(p2)
				end
			end)
		end

		return task.spawn(function()
			setState(p2)
		end)
	end
end