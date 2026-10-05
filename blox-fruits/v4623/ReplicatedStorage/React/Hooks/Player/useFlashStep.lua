local Type = require(game.ReplicatedStorage.Packages.Type)
local React = require(game.ReplicatedStorage.Packages.React)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local useCharacter = require(game.ReplicatedStorage.React.Hooks.Player.useCharacter)
local useHasTag = require(game.ReplicatedStorage.React.Hooks.Instance.useHasTag)
local strictInterface = Type.strictInterface({
	ItemId = Type.integer,
	IsUnlocked = Type.optional(Type.boolean)
})
local unwrapped = ItemId.getId("Flash Step", "Ability"):unwrap()
return function()
	local isUnlocked = useHasTag("Soru", (useCharacter()))
	return (React.useMemo(function()
		local v3 = {
			ItemId = unwrapped,
			IsUnlocked = isUnlocked
		}
		table.freeze(v3)
		local v4, v5 = strictInterface(v3)

		if not v4 then
			warn((`bad flashStep info: {v5}`))
		end

		return v3
	end, { isUnlocked }))
end