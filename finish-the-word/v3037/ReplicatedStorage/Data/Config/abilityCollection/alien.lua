local v = nil
local v2 = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z"
}

local function getLanguageId(object)
	local v3 = tonumber(object:getPlayer(object.TurnPlayer))

	if v3 then
		return object:getPlayerLanguageId(game.Players:GetPlayerByUserId(v3))
	end

	return 1
end

local function getExtensionOptions(object)
	v = v or _G.import("validator")
	local currentPrefix = object.CurrentPrefix or ""

	if currentPrefix == "" then
		return {}
	end

	local v3 = tonumber(object:getPlayer(object.TurnPlayer))
	local v4 = not v3 and 1 or object:getPlayerLanguageId(game.Players:GetPlayerByUserId(v3))
	local usedPrefixCounts = object.UsedPrefixCounts or {}
	local result = {}

	for _, v5 in ipairs(v2) do
		local prefix = currentPrefix .. v5
		local prefixSelectionChance = v:getPrefixSelectionChance(prefix, usedPrefixCounts, v4)

		if prefixSelectionChance > 0 then
			table.insert(result, {
				Prefix = prefix,
				Weight = prefixSelectionChance * (1 + (1 - prefixSelectionChance) * 0.35)
			})
		end
	end

	return result
end

local function pickExtendedPrefix(object)
	local extensionOptions = getExtensionOptions(object)
	local total = 0

	for _, extensionOption in ipairs(extensionOptions) do
		total += extensionOption.Weight
	end

	if total <= 0 then
		return
	end

	local v3 = math.random() * total
	local total2 = 0

	for _, extensionOption in ipairs(extensionOptions) do
		total2 += extensionOption.Weight

		if v3 <= total2 then
			return extensionOption.Prefix
		end
	end

	return extensionOptions[#extensionOptions].Prefix
end

return {
	Extend = {
		Info = {
			DisplayName = "Extend",
			Description = "Add 1 letter to the prefix",
			PetDescription = "Every 3 rounds, add 1 letter to the prefix",
			RotationCooldown = 3,
			TurnPlayer = false
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(_, p)
						return #getExtensionOptions(p) > 0
					end
				}
			}
		end,
		Execute = function(_, object)
			local v3 = pickExtendedPrefix(object)

			if not v3 then
				return
			end

			object.CurrentPrefix = v3
			object.LockedPrefix = v3
			object.Answer = v3
			object.MatchDisplay.AnswerInput:reset(v3)
			object:_updateUi()
		end
	}
}