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
		root:render((createPortal(createElement(Interface.buffList, {
			buffs = {
				Sword = 3000,
				FruitCooldown = 2,
				FruitXCooldown = 2,
				Gun = 1
			}
		}), p)))
	end)
	return function()
		v:Destroy()
		root:unmount()
	end
end