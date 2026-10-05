local import = _G.import("iterator")
local v = nil
local v2 = nil

local function getLanguageId(object, p)
	local v3 = tonumber(object:getPlayer(p))

	if v3 then
		return object:getPlayerLanguageId(game.Players:GetPlayerByUserId(v3))
	end

	return 1
end

local function getNextPlayer(data)
	local turnPlayer = data.TurnPlayer

	for _ = 1, data.Capacity do
		turnPlayer = data.Capacity <= turnPlayer and 1 or turnPlayer + 1

		if data.Players[turnPlayer] ~= "null" then
			return turnPlayer
		end
	end
end

local function getThreeLetterPrefix(p, p2, p3)
	v = v or _G.import("validator")
	v2 = v2 or _G.import("bank")
	local word = v2:normalizeWord(p2)

	if #word < 3 then
		return
	end

	local v3 = word:sub(#word - 2)
	local _, v4 = v:getPrefixSelectionChance(v3, p.UsedPrefixCounts or {}, getLanguageId(p, p3))

	if v4 and not (v4 <= 3) then
		return v3
	end
end

return {
	FireworksSpark = {
		Info = {
			DisplayName = "Spark",
			Description = "Gain a spark",
			PetDescription = string.format("Words with 10+ letters gain a spark. After %s sparks, start", 3)
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(_, object, p, _, _, p2, _, list)
						local effectValue = object:getEffectValue(p2, "Celebration")

						if p == object.TurnPlayer or effectValue then
							return #list >= 10
						end

						return false
					end
				}
			}
		end,
		Execute = function(_, object, p, p2)
			if object:getEffectValue(p.CatalystId, "Celebration") then
				p2.PlayerStacks[object.TurnPlayer] = (p2.PlayerStacks[object.TurnPlayer] or 0) + 1
				return
			end

			if object.RoundNumber - (p2.LastCelebration or -1e999) < 10 then
				return
			end

			object:incStack(p2, 1)

			if object:getStack(p2) < 3 then
				return
			end

			object:executeAbility(p2, "FireworksCelebration")
		end
	},
	FireworksCelebration = {
		Info = {
			DisplayName = "Jubilee",
			Description = "Start the celebration!",
			PetDescription = string.format("After %s rotations, the player with the most 10+ letter words enters", 10)
		},
		Execute = function(_, object, p, p2)
			object:setStack(p2, 0)
			p2.PlayerStacks = import.gen(object.Capacity, function(p3)
				return p3, 0
			end)
			p2.Celebrating = true
			object:addEffect(p.CatalystId, "Celebration", {
				Rotation = 20
			})
		end
	},
	FireworksCelebrationEnd = {
		Info = {
			DisplayName = "Revelry",
			Description = "Gain pressure",
			PetDescription = "Give 3 letter prefixes, up to 10 times"
		},
		Triggers = function(_)
			return {
				{
					Event = "RoundBegan",
					Condition = function(_, object, _, p)
						return p.Celebrating and not object:getEffectValue(p.CatalystId, "Celebration")
					end
				}
			}
		end,
		Execute = function(_, p, _, p2)
			p2.Celebrating = nil
			p2.LastCelebration = p.RoundNumber
			local v3 = -1
			local forcedPrefixPlayer = nil

			for i = 1, p.Capacity do
				local v5 = p2.PlayerStacks[i] or 0

				if not (v3 < v5) then
					continue
				end

				forcedPrefixPlayer = i
				v3 = v5
			end

			if not forcedPrefixPlayer or v3 <= 0 then
				return
			end

			p2.ForcedPrefixPlayer = forcedPrefixPlayer
			p2.ForcedPrefixRoundsLeft = 10
		end
	},
	FireworksForcePrefix = {
		Info = {
			DisplayName = "Pressure",
			Description = "Use a 3-letter prefix."
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(_, p, _, p2, _, _, _, p3)
						return (p2.ForcedPrefixRoundsLeft or 0) > 0 and p.TurnPlayer == p2.ForcedPrefixPlayer and getThreeLetterPrefix(
							p,
							p3,
							getNextPlayer(p)
						) ~= nil
					end
				}
			}
		end,
		Instance = function(_, p, _, _, _, p2)
			return {
				Prefix = getThreeLetterPrefix(p, p2, getNextPlayer(p))
			}
		end,
		Execute = function(_, object, p, p2)
			p2.ForcedPrefixRoundsLeft -= 1

			if p2.ForcedPrefixRoundsLeft == 0 then
				p2.ForcedPrefixPlayer = nil
			end

			object:addActivation("Round", function()
				object.CurrentPrefix = p.Prefix
				object.LockedPrefix = p.Prefix
				object.Answer = p.Prefix
				object.MatchDisplay.AnswerInput:reset(p.Prefix)
				object:_updateUi()
			end)
		end
	}
}