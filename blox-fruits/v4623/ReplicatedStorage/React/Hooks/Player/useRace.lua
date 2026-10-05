local Type = require(game.ReplicatedStorage.Packages.Type)
local React = require(game.ReplicatedStorage.Packages.React)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local useDataInstance = require(game.ReplicatedStorage.React.Hooks.Player.useDataInstance)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useEvolution = require(game.ReplicatedStorage.React.Hooks.Item.useEvolution)
local useProperty = require(game.ReplicatedStorage.React.Hooks.Instance.useProperty)
local betterLiteral = TypeUtil.Types.BetterLiteral("Human", "Rabbit", "Shark", "Angel", "Ghoul", "Cyborg", "Draco")
local strictInterface = Type.strictInterface({
	Type = betterLiteral,
	Level = Type.integer,
	Icon = TypeUtil.Types.ImageData,
	ItemId = Type.integer,
	Symbol = TypeUtil.Types.ImageData,
	SymbolEdges = TypeUtil.Types.ImageData
})
local v = {
	[IdMap.Race.Human] = SpriteMap.RaceSymbols["Human Symbol"],
	[IdMap.Race.Angel] = SpriteMap.RaceSymbols["Angel Symbol"],
	[IdMap.Race.Cyborg] = SpriteMap.RaceSymbols["Cyborg Symbol"],
	[IdMap.Race.Draco] = SpriteMap.RaceSymbols["Draco Symbol"],
	[IdMap.Race.Ghoul] = SpriteMap.RaceSymbols["Ghoul Symbol"],
	[IdMap.Race.Shark] = SpriteMap.RaceSymbols["Shark Symbol"],
	[IdMap.Race.Rabbit] = SpriteMap.RaceSymbols["Rabbit Symbol"]
}
local v2 = {
	[IdMap.Race.Human] = SpriteMap.RaceSymbols["Human Symbol Edges"],
	[IdMap.Race.Angel] = SpriteMap.RaceSymbols["Angel Symbol Edges"],
	[IdMap.Race.Cyborg] = SpriteMap.RaceSymbols["Cyborg Symbol Edges"],
	[IdMap.Race.Draco] = SpriteMap.RaceSymbols["Draco Symbol Edges"],
	[IdMap.Race.Ghoul] = SpriteMap.RaceSymbols["Ghoul Symbol Edges"],
	[IdMap.Race.Shark] = SpriteMap.RaceSymbols["Shark Symbol Edges"],
	[IdMap.Race.Rabbit] = SpriteMap.RaceSymbols["Rabbit Symbol Edges"]
}

function fixStorageKey(p: string)
	if p == "Fishman" then
		return "Shark"
	elseif p == "Skypiea" then
		return "Angel"
	end

	return p == "Mink" and "Rabbit" or p
end

return function()
	local v5 = useProperty(useMatchingChild(useDataInstance(), function(stringValue)
		if stringValue:IsA("StringValue") and stringValue.Name == "Race" then
			return stringValue
		end

		return nil
	end), function(p)
		return p and p.Value and p.Value:len() > 0 and p.Value or nil
	end)
	local v6 = useMatch(v5 and fixStorageKey(v5) or nil, "Race")
	local v7 = useMockState("PlayerRaceId", IdMap.Race.Human)

	if v7 then
		v6 = ItemConfig.match(v7:get()):unwrap()
	end

	local v9

	if v6 then
		v9 = v6.Index.ItemId or nil
	end

	local level = useEvolution(v9) or 1
	local v11 = useMockState("PlayerRaceLevel", 1)

	if v11 then
		level = v11:get()
	end

	return (React.useMemo(function()
		if not (level and v6) then
			return nil
		end

		local v12 = {
			Type = v6.Index.StorageKey,
			Level = level,
			Icon = v6.Display.Sprite or Spritesheets.MAP[v6.Index.StorageKey],
			ItemId = v6.Index.ItemId,
			Symbol = v[v6.Index.ItemId],
			SymbolEdges = v2[v6.Index.ItemId]
		}
		table.freeze(v12)
		local v13, v14 = strictInterface(v12)

		if v13 then
			return v12
		end

		warn((`bad race info: {v14}`))
		return nil
	end, { level, v6 }))
end