local React = require(game.ReplicatedStorage.Packages.React)
return function(instance)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if not instance then
			setState(nil)
			return function() end
		end

		local childAddedConnection = instance.ChildAdded:Connect(function(_)
			setState(instance:GetChildren())
		end)
		local childRemovedConnection = instance.ChildRemoved:Connect(function(_)
			setState(instance:GetChildren())
		end)
		setState(instance:GetChildren())
		return function()
			childAddedConnection:Disconnect()
			childRemovedConnection:Disconnect()
		end
	end, { instance })
	return state
end