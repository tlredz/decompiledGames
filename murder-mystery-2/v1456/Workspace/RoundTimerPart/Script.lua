local parent = script.Parent
local surfaceGui = parent:WaitForChild("SurfaceGui")
local timer = surfaceGui:WaitForChild("Timer")

-- equivalent calls inferred from this helper; original call sites unknown
local function GetTimeText(time: number)
	local v = math.floor(time / 60)
	local v2 = time - v * 60
	return (v > 0 and v .. "m " or "") .. v2 .. "s"
end

local function updateTimer()
	local time = parent:GetAttribute("Time") or -1
	local _ = parent:GetAttribute("RoundLength") or 180

	if not (time > 0) then
		surfaceGui.Enabled = false
		return
	end

	surfaceGui.Enabled = true
	timer.Text = GetTimeText(time)
end

local time = parent:GetAttribute("Time") or -1
local _ = parent:GetAttribute("RoundLength") or 180

if time > 0 then
	surfaceGui.Enabled = true
	timer.Text = GetTimeText(time)
else
	surfaceGui.Enabled = false
end

parent:GetAttributeChangedSignal("Time"):Connect(updateTimer)