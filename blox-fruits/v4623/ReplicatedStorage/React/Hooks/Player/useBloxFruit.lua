local Type = require(game.ReplicatedStorage.Packages.Type)
local React = require(game.ReplicatedStorage.Packages.React)
local useReplicatedData = require(game.ReplicatedStorage.React.Hooks.Player.useReplicatedData)
local useFuture = require(game.ReplicatedStorage.React.Hooks.useFuture)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useIdSearch = require(game.ReplicatedStorage.React.Hooks.Item.useIdSearch)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useCombatData = require(game.ReplicatedStorage.React.Hooks.Item.useCombatData)
local useProperty = require(game.ReplicatedStorage.React.Hooks.Instance.useProperty)
local strictInterface = Type.strictInterface({
	ItemId = Type.integer,
	Data = Type.table
})
return function()
	local v = useReplicatedData()
	local v3

	if v then
		v3 = v.DevilFruit
	end

	local v4 = useFuture(v3)
	local v5 = useMockState("PlayerBloxFruit", "Bomb-Bomb")
	local v6 = useProperty(v4, function(p)
		return p and p.Value and p.Value:len() > 0 and p.Value or nil
	end)

	if v5 then
		v6 = v5:get()
	end

	local v8 = useMatch((useIdSearch(v6, { "Moveset" })))
	local v10

	if v8 then
		v10 = v8.Index.ItemId
	end

	local v11 = useCombatData(v10)
	return (React.useMemo(function()
		if not (v8 and v11) then
			return nil
		end

		local v12 = {
			ItemId = v8.Index.ItemId,
			Data = v11
		}
		table.freeze(v12)
		local v13, v14 = strictInterface(v12)

		if v13 then
			return v12
		end

		warn((`bad bloxFruit info: {v14}`))
		return nil
	end, { v8, v11 }))
end