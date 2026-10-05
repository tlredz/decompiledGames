local React = require(game.ReplicatedStorage.Packages.React)
local useKeyInfo = require(game.ReplicatedStorage.React.Hooks.Fruit.useKeyInfo)
local useDataInstance = require(game.ReplicatedStorage.React.Hooks.Player.useDataInstance)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
return function()
	local v2 = useMatchingChild(useDataInstance(), function(stringValue)
		if stringValue:IsA("StringValue") and stringValue.Name == "DevilFruit" then
			return stringValue
		end

		return nil
	end)
	local v3 = React.useCallback(function()
		if v2 then
			return v2.Value
		end

		return ""
	end, { v2 })
	local state, setState = React.useState(v3())
	React.useEffect(function()
		if not v2 then
			return
		end

		local valueChangedConnection = v2:GetPropertyChangedSignal("Value"):Connect(function(...)
			setState(v3())
		end)
		return function()
			valueChangedConnection:Disconnect()
		end
	end, { v3, v2 })
	return useKeyInfo(state)
end