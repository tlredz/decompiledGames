local SocialService = game:GetService("SocialService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local String = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("String"))
local GameSettings = require(ReplicatedStorage:WaitForChild("GameSettings"))
local General = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("General"))
local RunService = game:GetService("RunService")
local cashBoostDuration = tonumber(General.CashBoostDuration) or 3
local text = string.format("%s, x2 Cash", cashBoostDuration == 1 and "1 Hour" or cashBoostDuration .. " Hours")
local color = Color3.fromRGB(170, 255, 0)
local handle = workspace:WaitForChild("Functionals"):WaitForChild("EventBoost"):WaitForChild("Handle")
local join = handle:WaitForChild("Join")
local claim = handle:WaitForChild("Claim")
local label = handle:WaitForChild("Instruction"):WaitForChild("Billboard"):WaitForChild("Label")
local label2 = handle:WaitForChild("Attachment"):WaitForChild("Billboard"):WaitForChild("Label")
local label3 = handle:WaitForChild("Timer"):WaitForChild("Label")
local textColor3 = label3.TextColor3
local parent = label3.Parent
local distantCashIcon = handle:WaitForChild("DistantCashIcon")
parent.MaxDistance = 1e999
parent.AlwaysOnTop = true
parent.Enabled = false
distantCashIcon.MaxDistance = 1e999
distantCashIcon.Size = UDim2.fromOffset(20, 20)
distantCashIcon.Enabled = false

local function UpdateMoneybagDistance()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
	local v2

	if humanoidRootPart == nil then
		v2 = false
	else
		v2 = handle:IsDescendantOf(workspace)
	end

	local v3 = label3.Visible and label3.Text ~= ""
	local v4 = v2 and (humanoidRootPart.Position - handle.Position).Magnitude > 100
	local enabled = v2 and v3 and not v4
	local enabled2 = v2 and v4

	if parent.Enabled ~= enabled then
		parent.Enabled = enabled
	end

	if distantCashIcon.Enabled ~= enabled2 then
		distantCashIcon.Enabled = enabled2
	end
end

local total = 0
RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total < 0.1 then
		return
	end

	total = 0
	UpdateMoneybagDistance()
end)
local claimEventReward = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("ClaimEventReward")
local eggPickup = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("EggPickup", 30)
local eventRsvpResult = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild(
	"EventRsvpResult",
	30
)
local x2Cash = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("ActiveBuffs"):WaitForChild("x2Cash")
local timer = x2Cash and x2Cash:FindFirstChild("Timer")

if x2Cash then
	x2Cash.Visible = false
end

label2.Text = text
join.Enabled = false
claim.Enabled = false
local v2 = false

local function UnixOf(value)
	if typeof(value) == "DateTime" then
		return value.UnixTimestamp
	end

	if typeof(value) == "number" then
		if value > 1000000000000 then
			value = math.floor(value / 1000) or value
		end

		return value
	else
		if typeof(value) == "string" then
			local success, result = pcall(DateTime.fromIsoDate, value)
			return success and result and result.UnixTimestamp or nil
		end

		if typeof(value) ~= "table" then
			return nil
		end

		if typeof(value.UnixTimestamp) == "number" then
			return value.UnixTimestamp
		end

		if typeof(value.UnixTimestampMillis) == "number" then
			return (math.floor(value.UnixTimestampMillis / 1000))
		end

		if value.year or value.Year then
			local success, result = pcall(os.time, {
				year = value.year or value.Year,
				month = value.month or value.Month,
				day = value.day or value.Day,
				hour = value.hour or value.Hour or 0,
				min = value.min or value.minute or value.Minute or 0,
				sec = value.sec or value.second or value.Second or 0
			})
			return success and result or nil
		end

		if v2 then
			return nil
		end

		v2 = true
		local v3 = {}

		for k, item in pairs(value) do
			table.insert(v3, tostring(k) .. "=" .. tostring(item))
		end

		warn("[EventReward] unrecognised time table: {" .. table.concat(v3, ", ") .. "}")
		return nil
	end
end

local function FieldUnix(p, ...)
	for _, v3 in { ... } do
		local unix = UnixOf(p[v3])

		if unix then
			return unix
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartOf(p)
	return FieldUnix(p, "StartTime", "StartUtc", "StartTimeUtc", "StartsAt", "Start")
end

local function EndOf(p)
	return FieldUnix(p, "EndTime", "EndUtc", "EndTimeUtc", "EndsAt", "End")
end

local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function ClaimableUntil(p)
	if not p.HasStarted then
		return nil
	end

	local start = StartOf(p) -- equivalent call inferred; original call site unknown

	if not start then
		v3[p.Id] = v3[p.Id] or os.time()
		start = v3[p.Id]
	end

	return start + 43200
end

local v4 = nil
local v5 = nil
local v6 = nil
local v7 = 0
local v8 = false

local function ParseSimulatedStart(SIMULATEEVENTONSTUDIO)
	local v9, v10, v11, v12 = string.match(
		SIMULATEEVENTONSTUDIO,
		"^%s*(%d+):(%d+)%s*([AaPp][Mm])%s*,%s*GMT%s*([+-]?%d+)%s*$"
	)

	if not v9 then
		warn(string.format(
			"[EventReward] SIMULATEEVENTONSTUDIO %q isn't in the form \"7:42PM, GMT+8\" - ignored",
			(tostring(SIMULATEEVENTONSTUDIO))
		))
		return nil
	end

	local v13 = tonumber(v9)
	local min = tonumber(v10)
	local v15 = tonumber(v12)
	local hour

	if string.lower(v11) == "pm" and v13 < 12 then
		hour = v13 + 12
	else
		hour = string.lower(v11) == "am" and v13 == 12 and 0 or v13
	end

	local v17 = v15 * 3600
	local v18 = os.date("!*t", os.time() + v17)
	return os.time({
		year = v18.year,
		month = v18.month,
		day = v18.day,
		hour = hour,
		min = min,
		sec = 0
	}) - v17
end

local SIMULATEEVENTONSTUDIO = GameSettings.IsTestEnvironment() and GameSettings.SIMULATEEVENTONSTUDIO
local v9

if typeof(SIMULATEEVENTONSTUDIO) == "string" and SIMULATEEVENTONSTUDIO ~= "" then
	v9 = ParseSimulatedStart(SIMULATEEVENTONSTUDIO)

	if v9 then
		print(string.format(
			"[EventReward] simulating an event that starts at %s (in %.1f min)",
			os.date("!%H:%M UTC", v9),
			(v9 - os.time()) / 60
		))
	end
else
	v9 = nil
end

local function SimulatedEvents()
	local now = os.time()
	local startTime = v9

	if startTime + 43200 <= now then
		startTime += 86400
	end

	return {
		{
			Id = "9" .. tostring(v9),
			Title = "Studio Event",
			StartTime = startTime,
			HasStarted = startTime <= now,
			HasEnded = false
		}
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function BoostActive()
	return (tonumber(localPlayer:GetAttribute("EventBoostUntil")) or 0) > os.time()
end

local function Refresh()
	local result, success

	if v9 then
		result = SimulatedEvents()
		success = true
	else
		success, result = pcall(function()
			return SocialService:GetUpcomingExperienceEventsAsync()
		end)
	end

	if not success or typeof(result) ~= "table" then
		warn("[EventReward] could not load events:", result)
		return
	end

	if not v8 and result[1] then
		v8 = true
		local v10 = {}

		for k, v11 in pairs(result[1]) do
			table.insert(v10, tostring(k) .. "=" .. typeof(v11))
		end

		print("[EventReward] event record fields: " .. table.concat(v10, ", "))
	end

	local now = os.time()
	v4 = nil
	v5 = nil
	v6 = nil
	local v10 = 0

	for _, v11 in ipairs(result) do
		if not (typeof(v11) == "table" and v11.Id) then
			continue
		end

		local claimableUntil = ClaimableUntil(v11) -- equivalent call inferred; original call site unknown

		if v11.HasStarted then
			local v13 = FieldUnix(v11, "StartTime", "StartUtc", "StartTimeUtc", "StartsAt", "Start") or v3[v11.Id] or 0

			if v10 < v13 then
				v10 = v13
			end
		end

		if v11.HasStarted and claimableUntil and now < claimableUntil then
			if not v4 or (FieldUnix(v11, "StartTime", "StartUtc", "StartTimeUtc", "StartsAt", "Start") or 0) > (FieldUnix(
				v4,
				"StartTime",
				"StartUtc",
				"StartTimeUtc",
				"StartsAt",
				"Start"
			) or 0) then
				v4 = v11
			end
		elseif not v11.HasStarted then
			v5 = v5 or v11

			if not v11.HasEnded and (not v6 or (FieldUnix(
				v11,
				"StartTime",
				"StartUtc",
				"StartTimeUtc",
				"StartsAt",
				"Start"
			) or 1e999) < (FieldUnix(v6, "StartTime", "StartUtc", "StartTimeUtc", "StartsAt", "Start") or 1e999)) then
				v6 = v11
			end
		end
	end

	v7 = v10
end

local function Apply()
	local boostActive = BoostActive() -- equivalent call inferred; original call site unknown
	local enabled

	if v4 == nil then
		enabled = false
	else
		enabled = not boostActive
	end

	local enabled2 = not enabled and v5 ~= nil

	if claim.Enabled ~= enabled then
		claim.Enabled = enabled
	end

	if join.Enabled ~= enabled2 then
		join.Enabled = enabled2
	end

	if enabled2 and v5.Title then
		join.ObjectText = v5.Title
	end

	local text2 = boostActive and "Boost Is Active" or v4 and "Claim, Event Is Happening :>" or "Play on the event for boost"

	if label.Text ~= text2 then
		label.Text = text2
	end
end

local function Tick()
	local now = os.time()
	local eventBoostUntil = tonumber(localPlayer:GetAttribute("EventBoostUntil")) or 0
	local text2 = ""
	local textColor = textColor3

	if now < eventBoostUntil then
		text2 = "Boost: " .. String:ConvertToDHMS(eventBoostUntil - now)
		textColor = color
	elseif v4 then
		local claimableUntil = ClaimableUntil(v4) -- equivalent call inferred; original call site unknown

		if claimableUntil then
			text2 = "Claim within " .. String:ConvertToDHMS((math.max(claimableUntil - now, 0)))
			textColor = color
		end
	elseif v5 then
		local start = StartOf(v5) -- equivalent call inferred; original call site unknown

		if start and now < start then
			text2 = "Starts in " .. String:ConvertToDHMS(start - now)
		end
	end

	if label3.Text ~= text2 then
		label3.Text = text2
	end

	if label3.TextColor3 ~= textColor then
		label3.TextColor3 = textColor
	end

	label3.Visible = text2 ~= ""
	UpdateMoneybagDistance()

	if x2Cash then
		local visible = now < eventBoostUntil

		if x2Cash.Visible ~= visible then
			x2Cash.Visible = visible
		end

		if visible and timer then
			local convertToHMS = String:ConvertToHMS(eventBoostUntil - now)

			if timer.Text ~= convertToHMS then
				timer.Text = convertToHMS
			end
		end
	end
end

local v10 = {
	Going = true,
	NotGoing = true,
	MaybeGoing = true
}

-- equivalent calls inferred from this helper; original call sites unknown
local function ReportRsvp(p, result)
	local name = typeof(result) == "EnumItem" and result.Name or typeof(result) == "string" and result or nil

	if name and v10[name] and eventRsvpResult then
		eventRsvpResult:FireServer(tostring(p), name)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RsvpAnswerFor(id)
	local eventRsvps = localPlayer:GetAttribute("EventRsvps")

	if typeof(eventRsvps) ~= "string" or eventRsvps == "" then
		return nil
	end

	local success, result = pcall(HttpService.JSONDecode, HttpService, eventRsvps)

	if success and typeof(result) == "table" then
		return result[tostring(id)]
	end

	return nil
end

join.Triggered:Connect(function()
	local v11 = v5

	if not v11 then
		return
	end

	if v9 then
		print("[EventReward] (simulated) would open the RSVP dialog for " .. tostring(v11.Title))
		return
	end

	local success, result = pcall(function()
		return SocialService:PromptRsvpToEventAsync(v11.Id)
	end)

	if not success then
		warn("[EventReward] RSVP prompt failed:", result)
		return
	end

	ReportRsvp(v11.Id, result) -- equivalent call inferred; original call site unknown
end)
local v11 = false
claim.Triggered:Connect(function()
	local v12 = v4

	if not v12 or v11 then
		return
	end

	v11 = true
	local success, result = pcall(function()
		return claimEventReward:InvokeServer((tostring(v12.Id)))
	end)
	v11 = false

	if success then
	end
end)
local v12 = false
local v13 = {}

if eggPickup then
	eggPickup.OnClientEvent:Connect(function(p, _, p2)
		if not (GameSettings.PROMPTEVENTONRETURNEGG == true and p == "Deposited") then
			return
		end

		local v14 = v6

		if not v14 or v12 or v7 > 0 and os.time() < v7 + 3600 or p2 ~= true then
			return
		end

		local id = tostring(v14.Id)

		if v13[id] then
			return
		end

		local rsvpAnswerFor = RsvpAnswerFor(id) -- equivalent call inferred; original call site unknown

		if rsvpAnswerFor ~= nil then
			return
		end

		v12 = true
		task.delay(1, function()
			if GameSettings.PROMPTEVENTONRETURNEGG ~= true then
				v12 = false
				return
			end

			v13[id] = true

			if v9 then
				print("[EventReward] (simulated) would ask the player to follow " .. tostring(v14.Title))
				v12 = false
			else
				local success, result = pcall(function()
					return SocialService:PromptRsvpToEventAsync(v14.Id)
				end)
				v12 = false

				if success then
					ReportRsvp(id, result) -- equivalent call inferred; original call site unknown
				else
					warn("[EventReward] follow nudge failed:", result)
				end
			end
		end)
	end)
end

localPlayer:GetAttributeChangedSignal("EventBoostUntil"):Connect(function()
	Apply()
	Tick()
end)
task.spawn(function()
	while true do
		Refresh()
		Apply()
		Tick()
		task.wait(60)
	end
end)
task.spawn(function()
	while true do
		task.wait(1)
		local now = os.time()

		if v4 then
			local claimableUntil = ClaimableUntil(v4) -- equivalent call inferred; original call site unknown

			if claimableUntil and claimableUntil <= now then
				v4 = nil
				Refresh()
			end
		end

		if v5 then
			local start = StartOf(v5) -- equivalent call inferred; original call site unknown

			if start and start <= now then
				Refresh()
			end
		end

		Apply()
		Tick()
	end
end)