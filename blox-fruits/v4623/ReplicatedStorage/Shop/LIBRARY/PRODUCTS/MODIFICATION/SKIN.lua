local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(game.ReplicatedStorage.Economy.EconomyItem)
local FRUIT = require(script.FRUIT)
local AURA = require(script.AURA)
local ALL = {}
TableUtil.append(ALL, FRUIT)
TableUtil.append(ALL, AURA)
table.freeze(ALL)
local SKIN = {
	ALL = ALL,
	FRUIT = FRUIT,
	AURA = AURA
}
table.freeze(SKIN)
return SKIN