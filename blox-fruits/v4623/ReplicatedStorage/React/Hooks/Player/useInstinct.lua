local Type = require(game.ReplicatedStorage.Packages.Type)
local React = require(game.ReplicatedStorage.Packages.React)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local useCharacter = require(game.ReplicatedStorage.React.Hooks.Player.useCharacter)
local useHasTag = require(game.ReplicatedStorage.React.Hooks.Instance.useHasTag)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local strictInterface = Type.strictInterface({
	ItemId = Type.integer,
	Level = Type.optional(Type.integer),
	MaxLevel = Type.integer,
	Version = Type.optional(Type.integer),
	MaxVersion = Type.integer
})
local unwrapped = ItemId.getId("Instinct", "Ability"):unwrap()
local unwrapped2 = ItemId.getId("Instinct V2", "Ability"):unwrap()
return function()
	local v = useCharacter()
	local v2 = useHasTag("Ken", v)
	local version = useHasTag("KenUpgrade", v) and 2 or v2 and 1 or 0
	local v4 = useAttribute(game.Players.LocalPlayer, "KenMaxDodges")
	local level

	if v4 then
		level = v4 - 1
	else
		level = nil
	end

	return (React.useMemo(function()
		local v6 = {
			Version = version,
			ItemId = 0,
			MaxVersion = 2,
			Level = 0,
			MaxLevel = 7
		}
		local itemId

		if version == 2 then
			itemId = unwrapped2
		else
			itemId = unwrapped
		end

		v6.ItemId = itemId
		v6.Level = level
		table.freeze(v6)
		local v8, v9 = strictInterface(v6)

		if not v8 then
			warn((`bad instinct info: {v9}`))
		end

		return v6
	end, { version, level }))
end