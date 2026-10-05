local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
return function(p)
	local createElement = React.createElement
	local root = ReactRoblox.createRoot(p)
	task.spawn(function()
		local createPortal = ReactRoblox.createPortal
		local Interface = require(script.Parent.Interface)
		local rootWaitingComponent = Interface.rootWaitingComponent
		local folder = Instance.new("Folder")
		local folder_2 = Instance.new("Folder", folder)
		folder_2.Name = "9829205164"
		local folder_3 = Instance.new("Folder", folder)
		folder_3.Name = "1234567"
		root:render((createPortal(createElement(rootWaitingComponent, {
			dungeonWaitingFolder = folder
		}), p)))
	end)
	return function()
		root:unmount()
	end
end