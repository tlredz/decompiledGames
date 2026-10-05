local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.Future)
return function(object)
	local useState = React.useState
	local v

	if object then
		v = object:poll():asNullable()
	end

	local state, setState = useState(v)
	React.useEffect(function()
		local flag = false

		if object then
			task.spawn(function()
				local v2 = object:await()

				if flag then
					return
				end

				setState(v2)
			end)
			return function()
				flag = true
			end
		else
			setState(nil)
		end
	end, { object })
	return state
end