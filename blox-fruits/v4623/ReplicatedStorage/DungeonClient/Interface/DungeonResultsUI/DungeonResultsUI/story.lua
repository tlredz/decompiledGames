game:GetService("ReplicatedStorage")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local parentModule = require(script.Parent)
return function(p)
	local createElement = React.createElement
	local root = ReactRoblox.createRoot(p, {})
	local Maid = require(game.ReplicatedStorage.Util.Maid)
	local v = Maid.new()
	task.delay(1, function() end)
	task.spawn(function()
		root:render((ReactRoblox.createPortal(createElement(parentModule, {
			allPlayers = {
				{
					portraitUserId = 123456,
					statusGradientColor = Color3.fromRGB(0, 255, 0),
					isMVP = true,
					displayName = "PlayerOne",
					subText = "12345 Damage",
					isMainPlayer = true,
					Tier = "Gold"
				},
				{
					portraitUserId = 234567,
					statusGradientColor = Color3.fromRGB(255, 0, 0),
					isMVP = false,
					displayName = "PlayerTwo",
					subText = "12345 Damage",
					isMainPlayer = false
				},
				{
					portraitUserId = 345678,
					statusGradientColor = Color3.fromRGB(0, 0, 255),
					isMVP = false,
					displayName = "PlayerThree",
					subText = "12345 Damage",
					isMainPlayer = false
				}
			},
			matchTime = 325
		}), p)))
	end)
	return function()
		v:Destroy()
		root:unmount()
	end
end