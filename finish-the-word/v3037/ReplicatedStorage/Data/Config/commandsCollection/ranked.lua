local import = _G.import("global")
local import2 = _G.import("rankedState")
local import3 = _G.import("rankUtil")
local import4 = _G.import("glicko2Util")
local import5 = _G.import("rankedConstants")
local PLACEMENT_MATCHES = import5.PLACEMENT_MATCHES
local GLICKO = import5.GLICKO
local PLAYER_COUNTS = import5.PLAYER_COUNTS
return {
	setRating = {
		Name = "setRating",
		Description = "Set a player's public rating.",
		Category = "Ranked",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "modeKey",
				Type = "string",
				Provider = "modeKey"
			},
			{
				Name = "rating",
				Type = "int"
			},
			{
				Name = "forcePlaced",
				Type = "bool",
				Provider = "boolString",
				Optional = true,
				Default = false
			},
			{
				Name = "rd",
				Type = "int",
				Optional = true,
				Default = 50
			}
		},
		Run = function(_, data)
			local playerSave = import.get("playerSave", data.player)
			playerSave.RankedData:auto_repl(true)
			local mode = playerSave:ensureMode(data.modeKey)
			mode.Mu = import4.ratingToMu((math.max(0, data.rating)))
			mode.Phi = math.clamp(data.rd, 10, 350) / GLICKO.SCALE
			mode.Sigma = GLICKO.SIGMA0

			if data.forcePlaced then
				mode.MatchesPlayed = math.max(mode.MatchesPlayed or 0, PLACEMENT_MATCHES)
			end

			playerSave.RankedData:auto_repl(false)
			local v = math.floor(import4.muToRating(mode.Mu) + 0.5)
			local rankFromRating = import2.getRankFromRating(v)
			return string.format("[%s] %s → %d (%s)", data.modeKey, data.player.Name, v, rankFromRating)
		end
	},
	addRating = {
		Name = "addRating",
		Description = "Add or remove public rating points.",
		Category = "Ranked",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "modeKey",
				Type = "string",
				Provider = "modeKey"
			},
			{
				Name = "deltaRating",
				Type = "int"
			}
		},
		Run = function(_, data)
			local playerSave = import.get("playerSave", data.player)
			playerSave.RankedData:auto_repl(true)
			local mode = playerSave:ensureMode(data.modeKey)
			local v = math.max(0, math.floor(import4.muToRating(mode.Mu or GLICKO.MU0) + 0.5) + data.deltaRating)
			mode.Mu = import4.ratingToMu(v)
			mode.Phi = math.min(mode.Phi or GLICKO.PHI0, 80 / GLICKO.SCALE)
			mode.MatchesPlayed = math.max(mode.MatchesPlayed or 0, PLACEMENT_MATCHES)
			playerSave.RankedData:auto_repl(false)
			local rankFromRating = import2.getRankFromRating(v)
			local v2 = data.deltaRating >= 0 and "+" or ""
			return string.format(
				"[%s] %s %s%d → %d (%s)",
				data.modeKey,
				data.player.Name,
				v2,
				data.deltaRating,
				v,
				rankFromRating
			)
		end
	},
	setRank = {
		Name = "setRank",
		Description = "Set a player's rank.",
		Category = "Ranked",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			},
			{
				Name = "modeKey",
				Type = "string",
				Provider = "modeKey"
			},
			{
				Name = "rank",
				Type = "string",
				Provider = "rankId"
			}
		},
		Run = function(_, data)
			local playerSave = import.get("playerSave", data.player)
			playerSave.RankedData:auto_repl(true)

			if data.rank == "Unranked" then
				playerSave.RankedData.Modes[data.modeKey] = nil
			else
				local ratingFromRank = import3.getRatingFromRank(data.rank)
				local mode = playerSave:ensureMode(data.modeKey)
				mode.Mu = import4.ratingToMu(ratingFromRank)
				mode.Phi = 10 / GLICKO.SCALE
				mode.Sigma = GLICKO.SIGMA0
				mode.MatchesPlayed = math.max(mode.MatchesPlayed or 0, PLACEMENT_MATCHES)
			end

			playerSave.RankedData:auto_repl(false)
			return string.format("[%s] %s → %s", data.modeKey, data.player.Name, data.rank)
		end
	},
	rankedStatus = {
		Name = "rankedStatus",
		Description = "Show a player's ranked status across all modes.",
		Category = "Ranked",
		Groups = { "Admin" },
		Args = {
			{
				Name = "player",
				Type = "player"
			}
		},
		Run = function(_, p)
			local playerSave = import.get("playerSave", p.player)
			local rankedData = playerSave.RankedData
			local v = { string.format("=== %s Ranked Status ===", p.player.Name) }

			for _, v2 in ipairs(PLAYER_COUNTS) do
				local v3 = ""

				for i = 1, v2 do
					v3 ..= "1" .. (i == v2 and "" or "v")
				end

				local mode = rankedData.Modes[v3]

				if mode then
					playerSave:isModePlaced(v2)
					local publicRating = playerSave:getPublicRating(v2)
					local modeConservativeRating = playerSave:getModeConservativeRating(v2)
					local rankFromRating = import2.getRankFromRating(publicRating)
					local placementMatchesLeft = playerSave:getPlacementMatchesLeft(v2)
					table.insert(
						v,
						(string.format(
							"%s | Mu: %.2f | Phi: %.4f | Public: %s | Cons: %d | Rank: %s | Matches: %d | W/L: %d/%d | Placements: %d",
							v3,
							mode.Mu or 0,
							mode.Phi or 0,
							publicRating and tostring(publicRating) or "N/A",
							modeConservativeRating or 0,
							rankFromRating,
							mode.MatchesPlayed or 0,
							mode.Wins or 0,
							mode.Losses or 0,
							placementMatchesLeft
						))
					)
				else
					table.insert(v, string.format("%s | Not played", v3))
				end
			end

			local joined = table.concat(v, "\n")
			print(joined)
			return "Printed the status to console"
		end
	}
}