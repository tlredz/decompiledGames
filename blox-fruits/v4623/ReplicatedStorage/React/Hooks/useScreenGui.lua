local React = require(game.ReplicatedStorage.Packages.React)
return function(instance, flag: boolean?)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if instance then
			local tryUpdateScreenGui

			tryUpdateScreenGui = function(p)
				local v = p or instance

				if not v then
					return false
				end

				assert(v, "ScreenGui: root must be a valid Instance")
				local screenGui = v:FindFirstAncestorWhichIsA("ScreenGui")

				if not screenGui then
					return false
				end

				if flag then
					if not tryUpdateScreenGui(screenGui) then
						setState(screenGui)
					end
				else
					setState(screenGui)
				end

				return true
			end

			local destroyingConnection = instance.Destroying:Connect(function()
				setState(nil)
			end)
			local ancestryChangedConnection = instance.AncestryChanged:Connect(function()
				tryUpdateScreenGui()
			end)
			tryUpdateScreenGui()
			return function()
				destroyingConnection:Disconnect()
				ancestryChangedConnection:Disconnect()
			end
		else
			if state then
				setState(nil)
			end

			return function() end
		end
	end, { instance, flag })
	return state
end