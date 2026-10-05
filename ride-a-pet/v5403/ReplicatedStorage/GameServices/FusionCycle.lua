local Fusion = require(game.ReplicatedStorage.GameData.Fusion)
local RunService = game:GetService("RunService")
local FusionCycle = {
	Status = function(p, p2)
		if p2 == nil then
			p2 = RunService:IsStudio()
		end

		if p2 or game.GameId == Fusion.DevelopmentUniverseId then
			return true, nil
		end

		local v = p or workspace:GetServerTimeNow()
		local startTime = Fusion.StartTime
		local v2 = DateTime.fromUniversalTime(
			startTime.Year,
			startTime.Month,
			startTime.Day,
			startTime.Hour or 0,
			startTime.Minute or 0,
			startTime.Second or 0
		).UnixTimestamp - (startTime.TimezoneOffsetHours or 0) * 3600

		if v < v2 then
			return false, v2 - v
		end

		local v3 = Fusion.ActiveWeeks * 604800

		if Fusion.AutomaticLifeCycle == false then
			local v4 = v2 + v3 - v

			if v4 > 0 then
				return true, v4
			end

			return false, nil
		else
			local v4 = v3 + Fusion.InactiveWeeks * 604800
			local v5 = (v - v2) % v4

			if v5 < v3 then
				return true, v3 - v5
			end

			return false, v4 - v5
		end
	end,
	Format = function(p)
		local v = math.max(0, (math.ceil(p)))
		local v2 = math.floor(v / 86400)
		local v3 = math.floor(v % 86400 / 3600)
		local v4 = math.floor(v % 3600 / 60)
		local v5 = v % 60

		if v2 > 0 then
			return string.format("%dd, %dh, %dm, %ds", v2, v3, v4, v5)
		end

		if v3 > 0 then
			return string.format("%dh, %dm, %ds", v3, v4, v5)
		end

		if v4 > 0 then
			return string.format("%dm, %ds", v4, v5)
		end

		return string.format("%ds", v5)
	end
}

function FusionCycle.Label(p)
	if p and p <= Fusion.CountdownWeeks * 604800 then
		return FusionCycle.Format(p)
	end

	return "⏳LIMITED TIME"
end

return FusionCycle