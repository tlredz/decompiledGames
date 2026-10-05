local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local RunService = game:GetService("RunService")
local v = Component.new({
	Tag = "DayHourMinuteClockLabel"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._finishedText = self.Instance:GetAttribute("FinshedText") or "ANY MOMENT NOW!"
end

function v:Start()
	self.useUppercase = self.Instance:GetAttribute("UseUppercase")
	self.format = self.Instance:GetAttribute("Format")

	if self.useUppercase == nil then
		self.useUppercase = false
	end

	local function readEndUnix()
		local dayHourMinuteClockTargetTime = self.Instance:GetAttribute("DayHourMinuteClockTargetTime")

		if typeof(dayHourMinuteClockTargetTime) == "number" then
			return dayHourMinuteClockTargetTime
		end

		return nil
	end

	local dayHourMinuteClockTargetTime = self.Instance:GetAttribute("DayHourMinuteClockTargetTime")

	if typeof(dayHourMinuteClockTargetTime) ~= "number" then
		dayHourMinuteClockTargetTime = nil
	end

	local function readClockMode()
		local clockMode = self.Instance:GetAttribute("ClockMode")

		if typeof(clockMode) ~= "string" then
			return nil
		end

		local v2 = {}
		local result = {}

		for k in string.gmatch(clockMode, "[^,]+") do
			local v3 = string.sub(string.lower(string.match(k, "^%s*(.-)%s*$") or ""), 1, 1)

			if not (v3 == "d" or v3 == "h" or v3 == "m" or v3 == "s") or v2[v3] then
				continue
			end

			table.insert(result, v3)
			v2[v3] = true
		end

		if #result == 0 then
			return nil
		end

		return result
	end

	local function readReduce()
		local reduceClockLabeling = self.Instance:GetAttribute("ReduceClockLabeling")
		return typeof(reduceClockLabeling) == "boolean" and reduceClockLabeling
	end

	local function readSemiReduce()
		local semiReduceClockLabeling = self.Instance:GetAttribute("SemiReduceClockLabeling")
		return typeof(semiReduceClockLabeling) == "boolean" and semiReduceClockLabeling
	end

	local function readHoursMinutesSeconds()
		local hoursMinutesSeconds = self.Instance:GetAttribute("HoursMinutesSeconds")
		return typeof(hoursMinutesSeconds) == "boolean" and hoursMinutesSeconds
	end

	local v2 = readClockMode()
	local reduceClockLabeling = self.Instance:GetAttribute("ReduceClockLabeling")

	if typeof(reduceClockLabeling) ~= "boolean" then
		reduceClockLabeling = false
	end

	local semiReduceClockLabeling = self.Instance:GetAttribute("SemiReduceClockLabeling")

	if typeof(semiReduceClockLabeling) ~= "boolean" then
		semiReduceClockLabeling = false
	end

	local hoursMinutesSeconds = self.Instance:GetAttribute("HoursMinutesSeconds")

	if typeof(hoursMinutesSeconds) ~= "boolean" then
		hoursMinutesSeconds = false
	end

	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("DayHourMinuteClockTargetTime"):Connect(function()
		local dayHourMinuteClockTargetTime2 = self.Instance:GetAttribute("DayHourMinuteClockTargetTime")

		if typeof(dayHourMinuteClockTargetTime2) ~= "number" then
			dayHourMinuteClockTargetTime2 = nil
		end

		dayHourMinuteClockTargetTime = dayHourMinuteClockTargetTime2
	end))
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("ClockMode"):Connect(function()
		v2 = readClockMode()
	end))
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("ReduceClockLabeling"):Connect(function()
		local reduceClockLabeling2 = self.Instance:GetAttribute("ReduceClockLabeling")

		if typeof(reduceClockLabeling2) ~= "boolean" then
			reduceClockLabeling2 = false
		end

		reduceClockLabeling = reduceClockLabeling2
	end))
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("SemiReduceClockLabeling"):Connect(function()
		local semiReduceClockLabeling2 = self.Instance:GetAttribute("SemiReduceClockLabeling")

		if typeof(semiReduceClockLabeling2) ~= "boolean" then
			semiReduceClockLabeling2 = false
		end

		semiReduceClockLabeling = semiReduceClockLabeling2
	end))
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("HoursMinutesSeconds"):Connect(function()
		local hoursMinutesSeconds2 = self.Instance:GetAttribute("HoursMinutesSeconds")

		if typeof(hoursMinutesSeconds2) ~= "boolean" then
			hoursMinutesSeconds2 = false
		end

		hoursMinutesSeconds = hoursMinutesSeconds2
	end))

	local function formatCountdown(p: number)
		if p <= 0 then
			return self._finishedText
		end

		local v3 = math.max(0, (math.floor(p + 0.5)))
		local v4 = math.floor(v3 / 86400)
		local v5 = v3 - v4 * 86400
		local v6 = math.floor(v5 / 3600)
		local v7 = v5 - v6 * 3600
		local v8 = math.floor(v7 / 60)
		local v9 = v7 - v8 * 60
		local v10 = v4 == 0 and v6 == 0 and v8 == 0 and v9 == 0 and 1 or v9

		if v2 ~= nil then
			local v11 = {
				d = "D",
				h = "H",
				m = "M",
				s = "S"
			}
			local v12 = {
				d = v4,
				h = v6,
				m = v8,
				s = v10
			}

			if reduceClockLabeling or semiReduceClockLabeling then
				for _, v13 in ipairs(v2) do
					local v14 = v12[v13]

					if v14 > 0 then
						return string.format("%d %s", v14, v11[v13])
					end
				end

				for i = #v2, 1, -1 do
					local v13 = v2[i]

					if v13 == "s" then
						return "1 S"
					end

					return string.format("%d %s", v12[v13], v11[v13])
				end
			else
				local v13 = {}

				for _, v14 in ipairs(v2) do
					local v15 = v12[v14]

					if v15 > 0 then
						table.insert(v13, string.format("%d %s", v15, v11[v14]))
					end
				end

				if #v13 ~= 0 then
					return table.concat(v13, " ")
				end

				local flag = false

				for _, v15 in ipairs(v2) do
					if v15 ~= "s" then
						continue
					end

					flag = true
					break
				end

				if flag then
					return "1 S"
				end

				local v15 = v2[#v2]
				local v16 = v11[v15]
				return string.format("%d %s", v12[v15], v16)
			end
		end

		if hoursMinutesSeconds then
			if v4 > 0 then
				return string.format(`%d {v4 == 1 and "Day" or "Days"}`, v4) or ""
			end

			return string.format("%d:%02d:%02d", v6, v8, v10)
		elseif reduceClockLabeling then
			if v4 > 0 then
				return string.format("%d Days", v4)
			end

			if v6 > 0 then
				return string.format("%d Hours", v6)
			end

			if v8 > 0 then
				return string.format("%d Minutes", v8)
			end

			local v11 = math.max(1, v10)
			local v12 = v11 == 1 and "Second" or "Seconds"
			return string.format("%d %s", v11, v12)
		else
			if semiReduceClockLabeling then
				if v4 > 0 then
					return string.format("%d Days %d Hours", v4, v6)
				end
			elseif v4 > 0 then
				return string.format("%d Days %d Hours %d Minutes", v4, v6, v8)
			end

			if v6 > 0 then
				return string.format("%d Hours %d Minutes", v6, v8)
			end

			if v8 == 1 then
				local v11 = math.max(1, v10)
				local v12 = v11 == 1 and "Second" or "Seconds"
				return string.format("1 Minute %d %s", v11, v12)
			elseif v8 > 1 then
				local v11 = math.max(1, v10)
				local v12 = v11 == 1 and "Second" or "Seconds"
				return string.format("%d Minutes %d %s", v8, v11, v12)
			else
				local v11 = math.max(1, v10)
				local v12 = v11 == 1 and "Second" or "Seconds"
				return string.format("%d %s", v11, v12)
			end
		end
	end

	local v3 = 0
	local v4 = nil
	self._Janitor:Add(RunService.Heartbeat:Connect(function(dt)
		local serverTimeNow = workspace:GetServerTimeNow()

		if not (typeof(serverTimeNow) == "number" and dayHourMinuteClockTargetTime ~= nil) then
			return
		end

		if v3 < 1 then
			v3 += dt
		else
			v3 = dt % 1
		end

		local text = formatCountdown(math.max(0, dayHourMinuteClockTargetTime - serverTimeNow))

		if self.format then
			text = string.format(self.format, text)
		end

		if self.useUppercase then
			text = text:upper()
		end

		if text ~= v4 then
			v4 = text
			self.Instance.Text = text
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v