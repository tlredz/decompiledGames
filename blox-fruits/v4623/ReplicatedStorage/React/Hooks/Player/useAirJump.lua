local Type = require(game.ReplicatedStorage.Packages.Type)
local React = require(game.ReplicatedStorage.Packages.React)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local useCharacter = require(game.ReplicatedStorage.React.Hooks.Player.useCharacter)
local useHasTag = require(game.ReplicatedStorage.React.Hooks.Instance.useHasTag)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useProperty = require(game.ReplicatedStorage.React.Hooks.Instance.useProperty)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local strictInterface = Type.strictInterface({
	ItemId = Type.integer,
	JumpCount = Type.optional(Type.number)
})
local unwrapped = ItemId.getId("Air Jump", "Ability"):unwrap()
return function()
	local v = useCharacter()
	local v2 = useHasTag("Geppo", v)
	local v3 = useMatchingChild(v, function(intValue)
		if intValue.Name == "GeppoCount" and intValue:IsA("IntValue") then
			return intValue
		end

		return nil
	end)

	if not v2 then
		v3 = nil
	end

	local v5 = useProperty(v3, function(p)
		return p.Value
	end)
	local v6 = useAttribute(v, "SkyjumpBoost")

	if v5 == nil and type(v6) == "number" then
		v5 = v6
	end

	if v5 <= 0 then
		v5 = nil
	end

	return (React.useMemo(function()
		local v7 = {
			ItemId = unwrapped,
			JumpCount = v2 and 1 or v5
		}
		table.freeze(v7)
		local v8, v9 = strictInterface(v7)

		if not v8 then
			warn((`bad airJump info: {v9}`))
		end

		return v7
	end, { v2, v5 }))
end