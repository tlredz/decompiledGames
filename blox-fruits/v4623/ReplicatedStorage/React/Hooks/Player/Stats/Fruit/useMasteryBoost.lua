local useBloxFruit = require(game.ReplicatedStorage.React.Hooks.Player.useBloxFruit)
local useMastery = require(game.ReplicatedStorage.React.Hooks.Item.useMastery)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useIsDungeon = require(game.ReplicatedStorage.React.Hooks.useIsDungeon)
local useLevel = require(game.ReplicatedStorage.React.Hooks.Player.useLevel)
local useHolding = require(game.ReplicatedStorage.React.Hooks.Player.useHolding)
return function()
	local v = useBloxFruit()
	local _, v2 = useHolding()

	if not v or not v2 or v.ItemId ~= v2 or not v2 then
		v2 = nil
	end

	local v4 = useMastery(v2)
	local v5 = useMockState("FruitMasteryBoost", nil)

	if v5 then
		return v5:get()
	end

	local v6 = useIsDungeon()
	local v7 = useLevel()
	return not v6 and v4 and v7 and math.floor(v4 / 4 + v7 * (v4 / 600) * 0.1) or nil
end