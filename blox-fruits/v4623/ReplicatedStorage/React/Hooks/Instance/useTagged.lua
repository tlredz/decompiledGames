local CollectionService = game:GetService("CollectionService")
local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.Option)
return function(tag: string?)
	local state, setState = React.useState({})
	React.useEffect(function()
		if tag == nil then
			return function() end
		end

		local connection = CollectionService:GetInstanceAddedSignal(tag):Connect(function(_)
			setState(CollectionService:GetTagged(tag))
		end)
		local connection2 = CollectionService:GetInstanceRemovedSignal(tag):Connect(function(_)
			setState(CollectionService:GetTagged(tag))
		end)
		setState(CollectionService:GetTagged(tag))
		return function()
			connection:Disconnect()
			connection2:Disconnect()
		end
	end, { tag })
	return state
end