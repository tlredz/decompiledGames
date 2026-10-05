local React = require(game.ReplicatedStorage.Packages.React)
local useOnScreenEffect = require(game.ReplicatedStorage.React.Hooks.useOnScreenEffect)
return function()
	local state, setState = React.useState(workspace.CurrentCamera.ViewportSize)
	useOnScreenEffect(function()
		local viewportSizeChangedConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			setState(workspace.CurrentCamera.ViewportSize)
		end)
		return function()
			viewportSizeChangedConnection:Disconnect()
		end
	end, {})
	return state
end