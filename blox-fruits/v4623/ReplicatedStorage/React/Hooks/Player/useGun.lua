local Type = require(game.ReplicatedStorage.Packages.Type)
local React = require(game.ReplicatedStorage.Packages.React)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useBackpack = require(game.ReplicatedStorage.React.Hooks.Player.useBackpack)
local useCombatData = require(game.ReplicatedStorage.React.Hooks.Item.useCombatData)
local strictInterface = Type.strictInterface({
	ItemId = Type.integer,
	Data = Type.table
})
return function()
	local v = useBackpack()
	local itemId2 = React.useMemo(function()
		if not v then
			return nil
		end

		for _, v3 in v do
			local itemId = v3:GetAttribute("ItemId")

			if type(itemId) ~= "number" then
				continue
			end

			local nullable = ItemConfig.match(itemId):asNullable()

			if nullable and nullable.Moveset and nullable.Moveset.Type == "Gun" then
				return nullable.Index.ItemId
			end
		end

		return nil
	end, { v })
	local v3 = useMockState("PlayerGunItemId", ItemId.getId("Dual Flintlock", "Moveset"):unwrap())

	if v3 then
		itemId2 = v3:get()
	end

	local v4 = useCombatData(itemId2)
	return (React.useMemo(function()
		if not (itemId2 and v4) then
			return nil
		end

		local v5 = {
			ItemId = itemId2,
			Data = v4
		}
		table.freeze(v5)
		local v6, v7 = strictInterface(v5)

		if v6 then
			return v5
		end

		warn((`bad gun info: {v7}`))
		return nil
	end, { itemId2, v4 }))
end