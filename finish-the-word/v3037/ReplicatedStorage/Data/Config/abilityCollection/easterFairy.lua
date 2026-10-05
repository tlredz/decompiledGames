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
			Amount = 7,
			Text = "at least 7 letters"
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

local function fitsCriteria(criteria, value)
	local v2 = string.lower(value or "")

	if criteria.Type == "LengthAtLeast" then
		return #v2 >= criteria.Amount
	end

	if criteria.Type == "LengthAtMost" then
		return #v2 <= criteria.Amount
	end

	if criteria.Type == "Contains" then
		return string.find(v2, criteria.Letter, 1, true) ~= nil
	end

	return criteria.Type == "EndsWith" and v2:sub(-#criteria.Letter) == criteria.Letter
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearObjective(p, p2)
	p2.EasterFairy = nil
	p2.Abilities.EasterHunt.LastRotationTriggered = p.RotationNumber
end

local function activeObjectives(p)
	local result = {}

	for k, catalyst in pairs(p.Catalysts) do
		for k2, catalystInstance in pairs(catalyst) do
			local easterFairy = catalystInstance.EasterFairy

			if not easterFairy then
				continue
			end

			if p.RotationNumber - easterFairy.StartRotation >= easterFairy.ExpireRotations then
				clearObjective(p, catalystInstance) -- equivalent call inferred; original call site unknown
			else
				table.insert(result, {
					CatalystInstance = catalystInstance,
					Objective = easterFairy,
					CatalystId = { k, k2 }
				})
			end
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function activeObjectiveFor(p, p2)
	for _, v2 in ipairs((activeObjectives(p2))) do
		if v2.CatalystInstance == p then
			return v2.Objective
		end
	end
end

return {
	EasterHunt = {
		Info = {
			DisplayName = "Hunt",
			Description = "Create a global challenge",
			PetDescription = "Create a global challenge.",
			RotationCooldown = 4,
			TurnPlayer = true,
			ExpireRotations = 10,
			MaxActive = 2
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(p, object, _, p2)
						local v2 = activeObjectives(object)

						for _, v3 in ipairs(v2) do
							if v3.CatalystInstance ~= p2 then
								continue
							end

							object:note("<font size=\"5\">global bonus:</font> " .. v3.Objective.Criteria.Text)
							return false
						end

						return not (#v2 >= (p.MaxActive or 2))
					end
				}
			}
		end,
		Instance = function(p)
			return {
				ExpireRotations = p.ExpireRotations or 10
			}
		end,
		Execute = function(_, object, p, p2)
			p2.EasterFairy = {
				Criteria = randomCriteria(),
				StartRotation = object.RotationNumber,
				ExpireRotations = p.ExpireRotations
			}
			object:note("<font size=\"5\">global bonus:</font> " .. p2.EasterFairy.Criteria.Text)
		end
	},
	EasterReward = {
		Info = {
			DisplayName = "Prize",
			Description = "Gain cash",
			PetDescription = "First player to complete it gains cash.",
			Cash = 5
		},
		Triggers = function(_)
			return {
				{
					Event = "Correct",
					Condition = function(_, p, _, p2, _, _, _, p3)
						local v2 = activeObjectiveFor(p2, p) -- equivalent call inferred; original call site unknown

						if v2 then
							return (fitsCriteria(v2.Criteria, p3))
						end

						return false
					end
				}
			}
		end,
		Instance = function(_, object, _, _, _, answer)
			return {
				Answer = answer,
				WinnerPlayerId = object.TurnPlayer,
				WinnerUserId = object:getPlayer(object.TurnPlayer)
			}
		end,
		Execute = function(p, object, data, p2)
			local easterFairy = p2.EasterFairy

			if not (easterFairy and fitsCriteria(easterFairy.Criteria, data.Answer)) then
				return
			end

			clearObjective(object, p2) -- equivalent call inferred; original call site unknown

			if object:getPlayer(data.WinnerPlayerId) ~= data.WinnerUserId then
				return
			end

			local playerByUserId = game.Players:GetPlayerByUserId(data.WinnerUserId)
			local playerSave = playerByUserId and import.get("playerSave", playerByUserId)

			if not playerSave then
				return
			end

			playerSave.Statistics:plus("Cash", p.Cash or 10)
		end
	}
}