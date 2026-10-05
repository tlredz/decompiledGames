local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
return function(instance)
	local createElement = React.createElement
	local root = ReactRoblox.createRoot(instance)
	task.spawn(function()
		local createPortal = ReactRoblox.createPortal
		local ReconnectionPrompt = require(script.Parent.ReconnectionPrompt)
		root:render((createPortal(createElement(ReconnectionPrompt.rootComponent, {
			Sx = {},
			event = Instance.new("BindableEvent")
		}), instance)))
	end)
	return function()
		local clone = instance:Clone()
		clone.Parent = workspace
		root:unmount()
	end
end