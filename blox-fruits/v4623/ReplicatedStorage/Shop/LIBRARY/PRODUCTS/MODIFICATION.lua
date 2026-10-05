local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(game.ReplicatedStorage.Economy.EconomyItem)
local SKIN = require(script.SKIN)
local MUTATION = require(script.MUTATION)
local ALL = {}
TableUtil.append(ALL, SKIN.ALL)
TableUtil.append(ALL, MUTATION)
table.freeze(ALL)
local MODIFICATION = {
	ALL = ALL,
	SKIN = SKIN,
	MUTATION = MUTATION
}
table.freeze(MODIFICATION)
return MODIFICATION