local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SimulatedTime = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("SimulatedTime"))
local TimedBonusEffectsConfig = {
	Boosts = {
		Ichor15 = {
			duration = 10800,
			multiplier = 0.15,
			requiresPCCafe = true,
			display = {
				multiplierText = "+15%",
				labelText = "MATCH BONUS"
			}
		}
	},
	Now = function()
		return SimulatedTime.now().UnixTimestamp
	end,
	GetDayGMT9 = function(p)
		return (math.floor((p + 32400) / 86400))
	end,
	IsTicking = function(p)
		return typeof(p) == "table" and p.TickingSince ~= nil
	end
}

function TimedBonusEffectsConfig.GetEffectiveRemaining(p)
	if typeof(p) ~= "table" then
		return 0
	end

	local remainingSeconds = p.RemainingSeconds or 0

	if p.TickingSince then
		remainingSeconds -= TimedBonusEffectsConfig.Now() - p.TickingSince
	end

	return (math.max(0, remainingSeconds))
end

function TimedBonusEffectsConfig.IsActive(p)
	return TimedBonusEffectsConfig.GetEffectiveRemaining(p) > 0
end

function TimedBonusEffectsConfig.InitPool(p)
	local boost = TimedBonusEffectsConfig.Boosts[p]

	if boost then
		return {
			RemainingSeconds = boost.duration,
			TickingSince = nil,
			ResetDay = TimedBonusEffectsConfig.GetDayGMT9(TimedBonusEffectsConfig.Now())
		}
	end

	return nil
end

function TimedBonusEffectsConfig.RefillIfNewDay(p, p2)
	local boost = TimedBonusEffectsConfig.Boosts[p2]

	if not boost then
		return p
	end

	local dayGMT9 = TimedBonusEffectsConfig.GetDayGMT9(TimedBonusEffectsConfig.Now())

	if typeof(p) == "table" and p.ResetDay == dayGMT9 then
		return p
	end

	return {
		RemainingSeconds = boost.duration,
		TickingSince = p and p.TickingSince or nil,
		ResetDay = dayGMT9
	}
end

function TimedBonusEffectsConfig.StartTicking(data)
	if typeof(data) ~= "table" then
		return nil
	end

	if data.TickingSince then
		return data
	end

	if (data.RemainingSeconds or 0) <= 0 then
		return nil
	end

	return {
		RemainingSeconds = data.RemainingSeconds,
		TickingSince = TimedBonusEffectsConfig.Now(),
		ResetDay = data.ResetDay
	}
end

function TimedBonusEffectsConfig.PauseTicking(p)
	if TimedBonusEffectsConfig.IsTicking(p) then
		return {
			RemainingSeconds = TimedBonusEffectsConfig.GetEffectiveRemaining(p),
			TickingSince = nil,
			ResetDay = p.ResetDay
		}
	end

	return p
end

function TimedBonusEffectsConfig.ClearStaleTicking(p)
	if TimedBonusEffectsConfig.IsTicking(p) then
		return {
			RemainingSeconds = p.RemainingSeconds,
			TickingSince = nil,
			ResetDay = p.ResetDay
		}
	end

	return p
end

return TimedBonusEffectsConfig