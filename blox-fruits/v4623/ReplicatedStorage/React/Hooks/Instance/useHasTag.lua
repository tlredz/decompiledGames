local CollectionService = game:GetService("CollectionService")
local React = require(game.ReplicatedStorage.Packages.React)
local Option = require(game.ReplicatedStorage.Packages.Option)
return function(tag: string?, instance)
	local useState = React.useState
	local v

	if not (instance == nil or tag == nil) then
		v = instance:HasTag(tag)
	end

	local state, setState = useState(v)
	React.useEffect(function()
		local none = Option.none()
		local none2 = Option.none()

		if tag == nil or instance == nil then
			setState(nil)
		else
			none = Option.some(CollectionService:GetInstanceAddedSignal(tag):Connect(function(p)
				if instance == p then
					setState(true)
				end
			end))
			none2 = Option.some(CollectionService:GetInstanceRemovedSignal(tag):Connect(function(p)
				if instance == p then
					setState(false)
				end
			end))
			setState(instance:HasTag(tag))
		end

		return function()
			none:inspect(function(connection)
				connection:Disconnect()
			end)
			none2:inspect(function(connection)
				connection:Disconnect()
			end)
		end
	end, { tag, instance })
	return state
end