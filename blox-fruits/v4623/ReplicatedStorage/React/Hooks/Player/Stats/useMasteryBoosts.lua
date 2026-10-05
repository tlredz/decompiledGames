local React = require(game.ReplicatedStorage.Packages.React)
local useMasteryBoost = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Fruit.useMasteryBoost)
local useMasteryBoost2 = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Gun.useMasteryBoost)
local useMasteryBoost3 = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Melee.useMasteryBoost)
local useMasteryBoost4 = require(game.ReplicatedStorage.React.Hooks.Player.Stats.Sword.useMasteryBoost)
require(script.Parent.useLevels)
return function()
	local demonFruit = useMasteryBoost()
	local gun = useMasteryBoost2()
	local melee = useMasteryBoost3()
	local sword = useMasteryBoost4()
	return React.useMemo(function()
		return table.freeze({
			Gun = gun,
			Melee = melee,
			Sword = sword,
			["Demon Fruit"] = demonFruit
		})
	end, {
		demonFruit,
		gun,
		melee,
		sword
	})
end