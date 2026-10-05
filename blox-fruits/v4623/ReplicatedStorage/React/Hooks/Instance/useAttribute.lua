local React = require(game.ReplicatedStorage.Packages.React)

local function fn(instance, attributeName: string?)
	if instance and attributeName then
		return instance:GetAttribute(attributeName)
	end

	return nil
end

return function(instance, attributeName: string)
	local state, setState = React.useState(fn(instance, attributeName))
	React.useEffect(function()
		if instance then
			local connection = instance:GetAttributeChangedSignal(attributeName):Connect(function(...)
				setState(fn(instance, attributeName))
			end)
			setState(instance:GetAttribute(attributeName))
			return function()
				connection:Disconnect()
			end
		elseif state then
			setState(nil)
		end
	end, { instance, attributeName })
	return state
end