local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(game.ReplicatedStorage.Economy.LegacyData.RobuxItem)
require(game.ReplicatedStorage.Economy.EconomyItem)
local PERMANENT_FRUIT = require(script.PERMANENT_FRUIT)
local MONEY = require(script.MONEY)
local FRAGMENT = require(script.FRAGMENT)
local EXP = require(script.EXP)
local MASTERY = require(script.MASTERY)
local SCROLL = require(script.SCROLL)
local GAMEPASS = require(script.GAMEPASS)
local MISC = require(script.MISC)
local DUNGEON = require(script.DUNGEON)
local VOUCHER = require(script.VOUCHER)
local BUNDLE = require(script.BUNDLE)
local MODIFICATION = require(script.MODIFICATION)
local ALL = {}
TableUtil.append(ALL, PERMANENT_FRUIT)
TableUtil.append(ALL, MONEY)
TableUtil.append(ALL, FRAGMENT)
TableUtil.append(ALL, EXP)
TableUtil.append(ALL, MASTERY)
TableUtil.append(ALL, SCROLL)
TableUtil.append(ALL, GAMEPASS)
TableUtil.append(ALL, MISC)
TableUtil.append(ALL, DUNGEON)
TableUtil.append(ALL, VOUCHER)
TableUtil.append(ALL, BUNDLE.ALL)
TableUtil.append(ALL, MODIFICATION.ALL)
table.freeze(ALL)
local PRODUCTS = {
	ALL = ALL,
	MODIFICATION = MODIFICATION,
	DUNGEON = DUNGEON,
	EXP = EXP,
	MASTERY = MASTERY,
	FRAGMENT = FRAGMENT,
	PERMANENT_FRUIT = PERMANENT_FRUIT,
	MISC = MISC,
	GAMEPASS = GAMEPASS,
	MONEY = MONEY,
	SCROLL = SCROLL,
	VOUCHER = VOUCHER,
	BUNDLE = BUNDLE
}
table.freeze(PRODUCTS)
return PRODUCTS