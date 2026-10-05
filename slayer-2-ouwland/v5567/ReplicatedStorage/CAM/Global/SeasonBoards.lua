local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Ranked = require(ReplicatedStorage.CAM.Global.Ranked)
local kinds = nil
kinds = {
	PvP = {
		Owns = Ranked.IsKey,
		Season = Ranked.Season,
		Previous = Ranked.Previous,
		Number = function(value)
			local v2, v3 = string.match(value, "^(%d+)%-(%d+)$")
			local seasonOrigin = MinigameSettings.Settings.Ouwigahara.SeasonOrigin
			return (tonumber(v2) - seasonOrigin.Year) * 12 + tonumber(v3) - seasonOrigin.Month + 1
		end,
		Label = Ranked.SeasonLabel,
		Board = function(p: string, p2)
			return DataStoreService:GetOrderedDataStore(`RankedPoints_{p}`, p2)
		end,
		Histogram = function(value: string, p)
			return (`RankedHist_{p}_{string.gsub(value, ":", "_")}`)
		end,
		Knobs = function()
			return MinigameSettings.Settings.PvP.Ranked
		end,
		Title = function(p: string)
			local bucketOfKey = Ranked.BucketOfKey(p)

			if bucketOfKey ~= nil then
				return (`{bucketOfKey} Zenith`)
			end

			if p == Ranked.TOURNEY then
				return "Zenith"
			end

			return (`Ranked {p}`)
		end,
		Tiers = true,
		Mine = function(instance, childName: string)
			local modes = instance:FindFirstChild("Modes")
			local child

			if modes ~= nil then
				child = modes:FindFirstChild(childName)
			end

			local points

			if child ~= nil then
				points = child:FindFirstChild("Points")
			end

			local placements

			if child ~= nil then
				placements = child:FindFirstChild("Placements")
			end

			if points == nil or placements == nil or placements.Value < MinigameSettings.Settings.PvP.Ranked.PlacementCount then
				return nil
			end

			return points.Value
		end,
		Saved = function(instance, childName: string)
			local modes = instance:FindFirstChild("Modes")
			local child

			if modes ~= nil then
				child = modes:FindFirstChild(childName)
			end

			local rank

			if child ~= nil then
				rank = child:FindFirstChild("Rank")
			end

			local share

			if child ~= nil then
				share = child:FindFirstChild("Share")
			end

			local selected = rank == nil and 0 or rank.Value

			if share == nil then
				return selected, 0
			end

			return selected, share.Value
		end
	},
	Ouwigahara = {
		Owns = function(p: string)
			return MinigameSettings.Settings.Ouwigahara.Modes[p] ~= nil
		end,
		Season = function(p: number?)
			local v2 = os.date("!*t", p or os.time())
			local seasonOrigin = MinigameSettings.Settings.Ouwigahara.SeasonOrigin
			return (v2.year - seasonOrigin.Year) * 12 + (v2.month - seasonOrigin.Month)
		end,
		Previous = function(p)
			return p - 1
		end,
		Number = function(p)
			return p + 1
		end,
		Label = function(p)
			return (`Season {p + 1}`)
		end,
		Board = function(p: string, p2)
			return DataStoreService:GetOrderedDataStore(`OuwigaharaScore_{p}`, (tostring(p2)))
		end,
		Histogram = function(p: string, p2)
			return (`OuwigaharaHist_{p2}_{p}`)
		end,
		Knobs = function()
			return MinigameSettings.Settings.Ouwigahara
		end,
		Title = function(p: string)
			return (`Ranked {MinigameSettings.Settings.Ouwigahara.Modes[p].Title}`)
		end,
		Tiers = false,
		Mine = function(instance, childName: string)
			local tower = instance:FindFirstChild("Tower")
			local child

			if tower ~= nil then
				child = tower:FindFirstChild(childName)
			end

			local season

			if child ~= nil then
				season = child:FindFirstChild("Season")
			end

			local best

			if child ~= nil then
				best = child:FindFirstChild("Best")
			end

			if season == nil or best == nil or season.Value ~= kinds.Ouwigahara.Season() then
				return nil
			end

			return best.Value
		end,
		Saved = function(instance, childName: string)
			local tower = instance:FindFirstChild("Tower")
			local child

			if tower ~= nil then
				child = tower:FindFirstChild(childName)
			end

			local rank

			if child ~= nil then
				rank = child:FindFirstChild("Rank")
			end

			local share

			if child ~= nil then
				share = child:FindFirstChild("Share")
			end

			local selected = rank == nil and 0 or rank.Value

			if share == nil then
				return selected, 0
			end

			return selected, share.Value
		end
	}
}
return {
	Kinds = kinds,
	KindOf = function(p: string)
		for _, v2 in kinds do
			if v2.Owns(p) then
				return v2
			end
		end

		return nil
	end
}