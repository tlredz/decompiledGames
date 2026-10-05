local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(game.ReplicatedStorage.Modules.FruitSkillUtil)
local ItemReplication = require(game.ReplicatedStorage.React.Factories.Hooks.ItemReplication)
local v = {
	Lvl = {},
	Cost = {},
	Cooldown = {},
	Fragments = nil,
	Cap = 100,
	Awakening = {
		Cost = {},
		Cooldown = {},
		Fragments = nil
	}
}
TableUtil.deepFreeze(v)
return (ItemReplication.use(ItemReplication.KEYS.COMBAT_DATA, nil, {
	Type = "All",
	Value = v
}))