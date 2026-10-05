game:GetService("ReplicatedStorage")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
return function(p)
	local createElement = React.createElement
	local root = ReactRoblox.createRoot(p)
	local Maid = require(game.ReplicatedStorage.Util.Maid)
	local v = Maid.new()
	task.spawn(function()
		local createPortal = ReactRoblox.createPortal
		local ReturningToHubShortly = require(script.Parent.Interface.ReturningToHubShortly)
		root:render((createPortal(createElement(ReturningToHubShortly, {
			onClose = function()
				v:Destroy()
			end
		}), p)))
	end)
	return function()
		v:Destroy()
		root:unmount()
	end
end