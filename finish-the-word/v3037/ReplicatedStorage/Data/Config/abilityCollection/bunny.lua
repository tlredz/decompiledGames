local import = _G.import("global")
local v = {
	"a",
	"e",
	"i",
	"o",
	"u",
	"r",
	"s",
	"t",
	"n",
	"l"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function randomLetter()
	return v[math.random(1, #v)]
end

local function randomCriteria()
	local v2 = math.random(1, 4)

	if v2 == 1 then
		return {
			Type = "LengthAtLeast",
			Amount = 6,
			Text = "at least 6 letters"
		}
	elseif v2 == 2 then
		return {
			Type = "LengthAtMost",
			Amount = 5,
			Text = "5 letters or fewer"
		}
	elseif v2 == 3 then
		local letter = randomLetter() -- equivalent call inferred; original call site unknown
		return {
			Type = "Contains",
			Letter = letter,
			Text = "contains " .. string.upper(letter)
		}
	end

	local letter2 = randomLetter() -- equivalent call inferred; original call site unknown
	return {
		Type = "EndsWith",
		Letter = letter2,
		Text = "ends with " .. string.upper(letter2)
	}
end

local function fitsCriteria(eggCriteria, value)
	local v2 = string.lower(value or "")

	if eggCriteria.Type == "LengthAtLeast" then
		return #v2 >= eggCriteria.Amount
	end

	if eggCriteria.Type == "LengthAtMost" then
		return #v2 <= eggCriteria.Amount
	end

	if eggCriteria.Type == "Contains" then
		return string.find(v2, eggCriteria.Letter, 1, true) ~= nil
	end

	return eggCriteria.Type == "EndsWith" and v2:sub(-#eggCriteria.Letter) == eggCriteria.Letter
end

return {
	OpenEgg = {
		Info = {
			DisplayName = "Challenge",
			Description = "Complete the challenge!",
			PetDescription = "Every 4 rotations complete a challenge for 5 cash",
			RotationCooldown = 4,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function()
						return true
					end
				}
			}
		end,
		Execute = function(_, object, _, p)
			local eggCriteria = randomCriteria()
			p.EggCriteria = eggCriteria
			p.EggCriteriaRound = object.RoundNumber
			object:note("<font size=\"5\">bonus:</font> " .. eggCriteria.Text)
		end
	},
	EggReward = {
		Info = {
			DisplayName = "Bonus",
			Description = "Gain 5 Cash",
			Cash = 5,
			TurnPlayer = true
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(_, p, _, p2, _, _, _, p3)
						if p2.EggCriteriaRound ~= p.RoundNumber then
							return false
						end

						local eggCriteria = p2.EggCriteria
						return eggCriteria ~= nil and fitsCriteria(eggCriteria, p3)
					end
				}
			}
		end,
		Instance = function(_, _, _, _, _, answer)
			return {
				Answer = answer
			}
		end,
		Execute = function(p, object, p2, p3)
			local eggCriteria = p3.EggCriteria
			p3.EggCriteria = nil
			p3.EggCriteriaRound = nil

			if not (eggCriteria and fitsCriteria(eggCriteria, p2.Answer)) then
				return
			end

			local player = object:getPlayer(p2.CatalystId[1])
			local playerByUserId = player and game.Players:GetPlayerByUserId(player)
			local playerSave = playerByUserId and import.get("playerSave", playerByUserId)

			if not playerSave then
				return
			end

			playerSave.Statistics:plus("Cash", p.Cash or 10)
		end
	}
}