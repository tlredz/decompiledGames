local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemConfig = require(ReplicatedStorage.ItemConfig)
local useMastery = require(ReplicatedStorage.React.Hooks.Item.useMastery)
local useMoveList = require(ReplicatedStorage.React.Hooks.Item.useMoveList)
local useBloxFruit = require(script.Parent.useBloxFruit)
local useFightingStyle = require(script.Parent.useFightingStyle)
local useGun = require(script.Parent.useGun)
local useSword = require(script.Parent.useSword)

local function getMovesetId(p: number)
	local nullable = ItemConfig.match(p):asNullable()
	local v = nullable and ItemConfig.match(nullable.Index.StorageKey, "Moveset"):asNullable()

	if v then
		return v.Index.ItemId
	end

	return nil
end

return function()
	local v = useFightingStyle()
	local itemId

	if v then
		local itemId2 = v.ItemId
		local nullable = ItemConfig.match(itemId2):asNullable()
		local v3 = nullable and ItemConfig.match(nullable.Index.StorageKey, "Moveset"):asNullable()

		if v3 then
			itemId = v3.Index.ItemId
		end
	else
		itemId = v
	end

	local mastery2 = useMastery(itemId)
	local itemId2

	if v then
		local itemId3 = v.ItemId
		local nullable = ItemConfig.match(itemId3):asNullable()
		local v5 = nullable and ItemConfig.match(nullable.Index.StorageKey, "Moveset"):asNullable()

		if v5 then
			itemId2 = v5.Index.ItemId
		end
	else
		itemId2 = v
	end

	local moveset2 = useMoveList(itemId2)
	local v6 = useBloxFruit()
	local itemId3

	if v6 then
		local itemId4 = v6.ItemId
		local nullable = ItemConfig.match(itemId4):asNullable()
		local v8 = nullable and ItemConfig.match(nullable.Index.StorageKey, "Moveset"):asNullable()

		if v8 then
			itemId3 = v8.Index.ItemId
		end
	else
		itemId3 = v6
	end

	local mastery3 = useMastery(itemId3)
	local itemId4

	if v6 then
		local itemId5 = v6.ItemId
		local nullable = ItemConfig.match(itemId5):asNullable()
		local v10 = nullable and ItemConfig.match(nullable.Index.StorageKey, "Moveset"):asNullable()

		if v10 then
			itemId4 = v10.Index.ItemId
		end
	else
		itemId4 = v6
	end

	local moveset3 = useMoveList(itemId4)
	local v11 = useSword()
	local itemId5

	if v11 then
		local itemId6 = v11.ItemId
		local nullable = ItemConfig.match(itemId6):asNullable()
		local v13 = nullable and ItemConfig.match(nullable.Index.StorageKey, "Moveset"):asNullable()

		if v13 then
			itemId5 = v13.Index.ItemId
		end
	else
		itemId5 = v11
	end

	local mastery4 = useMastery(itemId5)
	local itemId6

	if v11 then
		local itemId7 = v11.ItemId
		local nullable = ItemConfig.match(itemId7):asNullable()
		local v15 = nullable and ItemConfig.match(nullable.Index.StorageKey, "Moveset"):asNullable()

		if v15 then
			itemId6 = v15.Index.ItemId
		end
	else
		itemId6 = v11
	end

	local moveset4 = useMoveList(itemId6)
	local v16 = useGun()
	local itemId7

	if v16 then
		local itemId8 = v16.ItemId
		local nullable = ItemConfig.match(itemId8):asNullable()
		local v18 = nullable and ItemConfig.match(nullable.Index.StorageKey, "Moveset"):asNullable()

		if v18 then
			itemId7 = v18.Index.ItemId
		end
	else
		itemId7 = v16
	end

	local mastery5 = useMastery(itemId7)
	local itemId8

	if v16 then
		local itemId9 = v16.ItemId
		local nullable = ItemConfig.match(itemId9):asNullable()
		local v20 = nullable and ItemConfig.match(nullable.Index.StorageKey, "Moveset"):asNullable()

		if v20 then
			itemId8 = v20.Index.ItemId
		end
	else
		itemId8 = v16
	end

	local result = {}

	for _, v20 in {
		{
			Item = v,
			Mastery = mastery2,
			Moveset = moveset2,
			MovesetName = "FightingStyle"
		},
		{
			Item = v6,
			Mastery = mastery3,
			Moveset = moveset3,
			MovesetName = "Fruit"
		},
		{
			Item = v11,
			Mastery = mastery4,
			Moveset = moveset4,
			MovesetName = "Sword"
		},
		{
			Item = v16,
			Mastery = mastery5,
			Moveset = useMoveList(itemId8),
			MovesetName = "Gun"
		}
	} do
		local item = v20.Item
		local mastery = v20.Mastery or 0
		local moveset = v20.Moveset

		if not (item and moveset and moveset) then
			continue
		end

		local v21 = 0

		for _, v22 in moveset do
			v21 = math.max(v22.Mastery, v21)
		end

		if mastery < v21 then
			table.insert(result, {
				ItemId = item.ItemId,
				LevelsToMaxSkills = v21 - mastery,
				Moveset = v20.MovesetName
			})
		end
	end

	return result
end