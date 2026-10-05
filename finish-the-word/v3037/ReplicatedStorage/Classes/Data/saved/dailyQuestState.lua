local import = _G.import("class")
local import2 = _G.import("questCollection")
local import3 = _G.import("timeUtil")
local v = import.new()

function v:assignDailyQuests()
	local dailyQuestDay = math.floor(os.time() / 86400)
	local random = Random.new(self.UserId + dailyQuestDay)
	local v3 = {}
	import2:run(function(p)
		table.insert(v3, p)
	end)
	table.sort(v3)

	for i = #v3, 2, -1 do
		local integer = random:NextInteger(1, i)
		local v4 = v3[integer]
		local v5 = v3[i]
		v3[i] = v4
		v3[integer] = v5
	end

	local v4 = {}

	for k in self.DailyQuests:pairs() do
		table.insert(v4, k)
	end

	for _, v5 in ipairs(v4) do
		self.DailyQuests[v5] = nil
	end

	local count = 0
	local v5 = {}

	for _, v6 in ipairs(v3) do
		if count >= 2 then
			break
		end

		local v7 = import2:get(v6)

		if v5[v7.Type] then
			continue
		end

		v5[v7.Type] = true
		self.DailyQuests[v6] = {
			Progress = 0,
			Claimed = false
		}
		count += 1
	end

	self.DailyQuestDay = dailyQuestDay
end

function v:refreshDailyQuests()
	local v2 = math.floor(os.time() / 86400)

	if self.DailyQuestDay == v2 then
		local v3 = {}
		local count = 0

		for k in self.DailyQuests:pairs() do
			local v4 = import2:get(k)

			if v4 and not v3[v4.Type] then
				v3[v4.Type] = true
				count += 1
			else
				self:assignDailyQuests()
				return
			end
		end

		if count == 2 then
			return
		end

		self:assignDailyQuests()
	else
		self.DailyPlaytime = 0
		self:assignDailyQuests()
	end
end

function v:scheduleQuestReset()
	if self:hasTimedProcess("DailyQuestReset") then
		return
	end

	self:timeProcess("DailyQuestReset", import3.secondsUntilMidnight(), true)
end

function v:new()
	self.DailyQuests = {
		_Insertable = true
	}
	self.DailyQuestDay = 0
	self.DailyPlaytime = 0
end

function v:postShell()
	local now = os.time()
	local v2 = math.floor(now / 86400) * 86400
	local joinTime = self._Meta and self._Meta.JoinTime or now - self.SessionTime
	local v3 = math.max(0, self.SessionTime - math.max(0, v2 - joinTime))
	self:refreshDailyQuests()
	self.DailyPlaytime += v3
	self:scheduleQuestReset()
end

return v