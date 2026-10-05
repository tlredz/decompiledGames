local Workspace = game:GetService("Workspace")
local ashfallCountdownTimeChangedConnection = nil

local function approximateTimeFormat(p: number)
	local v = math.round(p % 60)
	local v2 = math.round(p // 60 % 60)
	local v3 = math.round(p // 3600 % 24)
	local v4 = math.round(p // 86400)

	if v4 > 1 or v3 > 24 then
		local v5 = tostring(v4)
		return string.format("%s %s", v5, v4 > 1 and "days" or "day")
	end

	if v3 > 1 or v2 > 60 then
		local v5 = tostring(v3)
		return string.format("%s %s", v5, v3 > 1 and "hours" or "hour")
	end

	if v2 > 1 or v > 60 then
		local v5 = tostring(v2)
		return string.format("%s %s", v5, v2 > 1 and "minutes" or "minute")
	end

	if v >= 1 then
		local v5 = tostring(v)
		return string.format("%s %s", v5, v > 1 and "seconds" or "second")
	else
		return "ERUPTING!"
	end
end

local function setTime(p: number, p2: string, parent)
	if p <= -1800 or p > 600 then
		return
	end

	local formatted = `{p <= -1800 and "CURRENTLY LIVE!" or p <= 0 and "ERUPTING!" or `In {p2}!`}`

	if not script.Parent.Visible then
		script.Parent.Visible = true
	end

	parent.Text = formatted
	task.defer(function()
		if p <= 0 then
			task.wait(15)
			script.Parent.Visible = false

			if ashfallCountdownTimeChangedConnection then
				ashfallCountdownTimeChangedConnection:Disconnect()
				ashfallCountdownTimeChangedConnection = nil
			end

			script.Enabled = false
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function update(ashfallCountdownTime: number)
	local v

	if ashfallCountdownTime > 0 then
		v = approximateTimeFormat(ashfallCountdownTime)
	end

	setTime(ashfallCountdownTime, v, script.Parent)
end

if Workspace:GetAttribute("ashfallCountdownTime") and Workspace:GetAttribute("ashfallCountdownTime") < 600 then
	update(Workspace:GetAttribute("ashfallCountdownTime")) -- equivalent call inferred; original call site unknown
end

ashfallCountdownTimeChangedConnection = Workspace:GetAttributeChangedSignal("ashfallCountdownTime"):Connect(function()
	if Workspace:GetAttribute("ashfallCountdownTime") < 600 then
		update(Workspace:GetAttribute("ashfallCountdownTime")) -- equivalent call inferred; original call site unknown
	end
end)