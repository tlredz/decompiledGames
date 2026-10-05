local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local EVENT = require(script.EVENT)
local DRAGON_SKIN = require(script.DRAGON_SKIN)
local ALL = {}
TableUtil.append(ALL, EVENT)
TableUtil.append(ALL, DRAGON_SKIN)
table.freeze(ALL)
local BUNDLE = {
	ALL = ALL,
	EVENT = EVENT,
	DRAGON_SKIN = DRAGON_SKIN
}
table.freeze(BUNDLE)
return BUNDLE