local React = require(game.ReplicatedStorage.Packages.React)
return function(duration: number)
	local ref = React.useRef(false)
	return ref, (React.useCallback(function()
		if ref.current then
			return
		end

		ref.current = true
		task.delay(duration, function()
			ref.current = false
		end)
	end, { duration }))
end