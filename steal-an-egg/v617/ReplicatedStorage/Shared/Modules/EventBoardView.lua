local v = {
	RefreshSeconds = 60,
	RetryBackoffSeconds = 30,
	TimerUpdateSeconds = 1,
	PromptDistance = 12,
	ToUnix = function(data)
		if type(data) ~= "table" then
			return nil
		end

		local success, result = pcall(function()
			return DateTime.fromUniversalTime(
				data.Year,
				data.Month,
				data.Day,
				data.Hour,
				data.Minute,
				data.Second,
				data.Millisecond or 0
			)
		end)

		if success and result then
			return result.UnixTimestamp
		end

		return nil
	end
}

function v.IsEligible(data, p: number)
	if type(data) ~= "table" or type(data.Id) ~= "string" or data.Id == "" or data.Status ~= Enum.ExperienceEventStatus.Active then
		return false
	end

	if data.HasStarted == true or data.HasEnded == true then
		return false
	end

	local unix = v.ToUnix(data.StartTime)
	return unix ~= nil and p < unix
end

function v.Pick(items, p: number)
	if type(items) ~= "table" then
		return nil
	end

	local v2 = nil

	for _, item in items do
		if not v.IsEligible(item, p) then
			continue
		end

		local unix = v.ToUnix(item.StartTime)

		if v2 == nil or unix < v2.StartsAt then
			v2 = {
				Id = item.Id,
				Title = type(item.Title) ~= "string" and "" or item.Title,
				StartsAt = unix,
				Going = item.UserRsvpStatus == Enum.RsvpStatus.Going
			}
		end
	end

	return v2
end

function v.ShouldShow(p)
	return p ~= nil and not p.Going
end

function v.Countdown(p: number)
	local v2 = math.max(0, (math.floor(p)))
	local v3 = v2 // 86400
	local v4 = v2 % 86400 // 3600
	local v5 = v2 % 3600 // 60
	local v6 = v2 % 60

	if v3 > 0 then
		return string.format("%dd %dh %dm", v3, v4, v5)
	end

	if v4 > 0 then
		return string.format("%dh %dm %ds", v4, v5, v6)
	end

	return string.format("%dm %ds", v5, v6)
end

return table.freeze(v)