local v = nil

local function getLanguageId(object)
	local v2 = tonumber(object:getPlayer(object.TurnPlayer))

	if v2 then
		return object:getPlayerLanguageId(game.Players:GetPlayerByUserId(v2))
	end

	return 1
end

local function tryShufflePrefix(object)
	v = v or _G.import("validator")
	local currentPrefix = object.CurrentPrefix

	if not currentPrefix or #currentPrefix <= 1 then
		return
	end

	local v2 = {}

	for i = 1, #currentPrefix do
		v2[i] = currentPrefix:sub(i, i)
	end

	local v3 = tonumber(object:getPlayer(object.TurnPlayer))
	local v4 = not v3 and 1 or object:getPlayerLanguageId(game.Players:GetPlayerByUserId(v3))

	for _ = 1, 20 do
		for i = #v2, 2, -1 do
			local v5 = math.random(1, i)
			local v6 = v2[v5]
			local v7 = v2[i]
			v2[i] = v6
			v2[v5] = v7
		end

		local joined = table.concat(v2)

		if joined ~= currentPrefix and v:getPrefixSelectionChance(joined, object.UsedPrefixCounts or {}, v4) > 0 then
			return joined
		end
	end
end

return {
	Glitch = {
		Info = {
			DisplayName = "Glitch",
			Description = "Scramble the prefix",
			PetDescription = "Every 5 turns, scramble your opponent's prefix.",
			TurnPlayer = false,
			RotationCooldown = 5
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function(_, p, _, p2)
						p2.PendingShuffled = tryShufflePrefix(p)
						return p2.PendingShuffled ~= nil
					end
				}
			}
		end,
		Execute = function(_, object, _, p)
			local pendingShuffled = p.PendingShuffled
			p.PendingShuffled = nil

			if not pendingShuffled then
				return
			end

			object.CurrentPrefix = pendingShuffled
			object.LockedPrefix = pendingShuffled
			object.Answer = pendingShuffled
			object.MatchDisplay.AnswerInput:reset(pendingShuffled)
			object:_updateUi()
		end
	}
}