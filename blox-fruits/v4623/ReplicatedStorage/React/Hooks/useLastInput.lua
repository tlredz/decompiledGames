local React = require(game.ReplicatedStorage.Packages.React)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)

function getLastInput()
	local v, _ = LastInput:Get()
	return v
end

return function()
	local state, setState = React.useState(getLastInput())
	React.useEffect(function()
		local changedConnection = LastInput.Changed:Connect(function()
			local v, _ = LastInput:Get()
			setState(v)
		end)
		return function()
			changedConnection:Disconnect()
		end
	end, {})
	local v = useMockState("LastInput", "MouseKeyboard")

	if v then
		state = v:get()
	end

	return state
end