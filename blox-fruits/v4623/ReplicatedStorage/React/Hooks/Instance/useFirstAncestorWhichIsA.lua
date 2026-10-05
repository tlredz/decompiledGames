local React = require(game.ReplicatedStorage.Packages.React)
return function(instance, className: string)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if instance then
			local ancestryChangedConnection = instance.AncestryChanged:Connect(function()
				local firstAncestorWhichIsA = instance:FindFirstAncestorWhichIsA(className)

				if firstAncestorWhichIsA ~= state then
					setState(firstAncestorWhichIsA)
				end
			end)
			local firstAncestorWhichIsA = instance:FindFirstAncestorWhichIsA(className)

			if firstAncestorWhichIsA ~= state then
				setState(firstAncestorWhichIsA)
			end

			return function()
				ancestryChangedConnection:Disconnect()
			end
		else
			if state then
				setState(nil)
			end

			return function() end
		end
	end, { instance, className, state })
	return state
end