local v = nil
local v2 = nil

local function getLanguageId(object)
	local v4 = tonumber(object:getPlayer(object.TurnPlayer))

	if v4 then
		return object:getPlayerLanguageId(game.Players:GetPlayerByUserId(v4))
	end

	return 1
end

local function getFullSuffix(object)
	v = v or _G.import("validator")
	v2 = v2 or _G.import("bank")
	local lastAnswer = object.LastAnswer

	if not lastAnswer or lastAnswer == "" then
		return
	end

	local word = v2:normalizeWord(lastAnswer)

	if word == "" then
		return
	end

	local v4 = tonumber(object:getPlayer(object.TurnPlayer))
	local v5 = not v4 and 1 or object:getPlayerLanguageId(game.Players:GetPlayerByUserId(v4))
	local _, v6 = v:getPrefixSelectionChance(word, object.UsedPrefixCounts or {}, v5)

	if v6 and not (v6 <= 3) then
		return word
	end
end

return {
	Suffix = {
		Info = {
			DisplayName = "Duplicate",
			Description = "Use the full word",
			PetDescription = "Every 5 turns, use the full word.",
			RotationCooldown = 5,
			TurnPlayer = false
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(_, p)
						return getFullSuffix(p) ~= nil
					end
				}
			}
		end,
		Execute = function(_, object, _, _)
			local fullSuffix = getFullSuffix(object)

			if not fullSuffix then
				return
			end

			object.CurrentPrefix = fullSuffix
			object.LockedPrefix = fullSuffix
			object.Answer = fullSuffix
			object.MatchDisplay.AnswerInput:reset(fullSuffix)
			object:_updateUi()
		end
	}
}