local GuiService = game:GetService("GuiService")
local React = require(game.ReplicatedStorage.Packages.React)
local useOnScreenEffect = require(game.ReplicatedStorage.React.Hooks.useOnScreenEffect)

function getSize()
	local guiInset, v = GuiService:GetGuiInset()
	return workspace.CurrentCamera.ViewportSize + guiInset + v
end

return function()
	local state, setState = React.useState(getSize())
	useOnScreenEffect(function()
		local viewportSizeChangedConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			setState(getSize())
		end)
		return function()
			viewportSizeChangedConnection:Disconnect()
		end
	end, {})
	return state
end