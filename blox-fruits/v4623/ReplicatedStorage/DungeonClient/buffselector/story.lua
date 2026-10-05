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
		local Interface = require(script.Parent.Interface)
		root:render((createPortal(createElement(Interface.buffSelector, {
			onClose = function()
				v:Destroy()
			end,
			teleporterPad = workspace:FindFirstChild("DUNGEON_TELEPORTER", true)
		}), p)))
	end)
	return function()
		v:Destroy()
		root:unmount()
	end
end