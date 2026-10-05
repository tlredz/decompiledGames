local React = require(game.ReplicatedStorage.Packages.React)
local useLock = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Fruit.useLock)
local useLock2 = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Gun.useLock)
local useLock3 = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Sword.useLock)
require(script.Parent.useLevels)
return function()
	local demonFruit = useLock()
	local gun = useLock2()
	local sword = useLock3()
	return React.useMemo(function()
		return table.freeze({
			Gun = gun,
			Melee = false,
			Sword = sword,
			["Demon Fruit"] = demonFruit,
			Defense = false
		})
	end, { demonFruit, gun, sword })
end