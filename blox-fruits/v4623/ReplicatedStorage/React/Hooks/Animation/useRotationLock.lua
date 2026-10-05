local React = require(game.ReplicatedStorage.Packages.React)
return function(instance, flag: boolean)
	React.useEffect(function()
		if not instance then
			return function() end
		end

		if not flag then
			return function() end
		end

		local absoluteRotationChangedConnection = instance:GetPropertyChangedSignal("AbsoluteRotation"):Connect(function()
			if instance.AbsoluteRotation ~= 0 then
				instance.Rotation = 0
			end
		end)
		instance.Rotation = 0
		return function()
			absoluteRotationChangedConnection:Disconnect()
		end
	end, { instance, flag })
end