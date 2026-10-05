local CollectionService = game:GetService("CollectionService")
local React = require(game.ReplicatedStorage.Packages.React)
local Option = require(game.ReplicatedStorage.Packages.Option)
return function(tag: string?)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if tag == nil then
			return function() end
		end

		local connection = CollectionService:GetInstanceAddedSignal(tag):Connect(function(p)
			if state ~= p then
				setState(p)
			end
		end)
		local none = Option.none()
		local none2 = Option.none()
		local none3 = Option.none()

		if state then
			none3 = Option.some(state.AncestryChanged:Connect(function(instance)
				if not instance:IsDescendantOf(game) then
					setState(nil)
				end
			end))
			none = Option.some(CollectionService:GetInstanceRemovedSignal(tag):Connect(function(p)
				if state == p then
					setState(nil)
				end
			end))
			none2 = Option.some(state.Destroying:Connect(function()
				setState(nil)
			end))
		end

		local v = CollectionService:GetTagged(tag)[1]

		if v and state ~= v then
			setState(v)
		end

		return function()
			connection:Disconnect()
			none3:inspect(function(connection2)
				connection2:Disconnect()
			end)
			none2:inspect(function(connection2)
				connection2:Disconnect()
			end)
			none:inspect(function(connection2)
				connection2:Disconnect()
			end)
		end
	end, { tag, state })
	return state
end