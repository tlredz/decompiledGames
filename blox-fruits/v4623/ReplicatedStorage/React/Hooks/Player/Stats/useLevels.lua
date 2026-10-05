local React = require(game.ReplicatedStorage.Packages.React)
local useLevel = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Defense.useLevel)
local useLevel2 = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Fruit.useLevel)
local useLevel3 = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Gun.useLevel)
local useLevel4 = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Melee.useLevel)
local useLevel5 = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Sword.useLevel)
require(game.ReplicatedStorage.Types.StatTypes)
return function()
	local defense = useLevel()
	local demonFruit = useLevel2()
	local gun = useLevel3()
	local melee = useLevel4()
	local sword = useLevel5()
	return React.useMemo(function()
		return table.freeze({
			Gun = gun,
			Defense = defense,
			Melee = melee,
			Sword = sword,
			["Demon Fruit"] = demonFruit
		})
	end, {
		defense,
		demonFruit,
		gun,
		melee,
		sword
	})
end