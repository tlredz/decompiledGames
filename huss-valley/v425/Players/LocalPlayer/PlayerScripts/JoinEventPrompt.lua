local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local eventHostRemote = chickenOrHero:WaitForChild("Admin"):WaitForChild("EventHostRemote")
local armoryEvent = chickenOrHero:WaitForChild("Weapons"):WaitForChild("ArmoryEvent")
local StarterPackConfig = require(chickenOrHero:WaitForChild("Gear"):WaitForChild("StarterPackConfig"))
local v = true
local connections = {}

local function connect(object, p)
	table.insert(connections, object:Connect(p))
end

local eventModel = script:WaitForChild("EventModel")
local prompt = eventModel:WaitForChild("Prompt")
local proximityPrompt = prompt:WaitForChild("ProximityPrompt")
local decal = prompt:WaitForChild("Decal")
local textLabel = eventModel:WaitForChild("Main"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel")
local textLabel2 = eventModel:WaitForChild("Timer"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel")
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = false
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = nil
local v10 = false
local issuedAt = -1e999
local lastTime = os.clock()
local v11 = {
	"ArmoryOpen",
	"JourneyOpen",
	"EmoteWheelOpen",
	"SettingsOpen",
	"UpdateLogOpen",
	"ServerBrowserOpen",
	"LikeRewardOpen",
	"MapVoteOpen",
	"MatchSummaryVisible",
	"AdminConsoleActive",
	"EventHostPanelOpen",
	"ScreenPresentationActive",
	"TutorialRouting",
	"TutorialSession",
	"StarterPackOpen",
	"QuestsOpen",
	"CrateOpen",
	"SpinWheelOpen"
}

local function starterHasPriority()
	local enabled

	if localPlayer:GetAttribute("StarterPackOpen") == true then
		enabled = true
	else
		enabled = StarterPackConfig.Enabled

		if enabled then
			if game.GameId == StarterPackConfig.UniverseId and v8.starterFirstMatch == true then
				enabled = not (v8.starterPurchased or v8.starterPresented) and (v8.starterOfferEndsAt or 0) > workspace:GetServerTimeNow()
			else
				enabled = false
			end
		end
	end

	return enabled
end

local function canInvite(p)
	if not v or v9 ~= p or v5 or os.clock() >= p.expiresAt or localPlayer:GetAttribute("ClientReady") ~= true or localPlayer:GetAttribute("InMatch") == true or os.clock() - lastTime < 2 or v8.loaded ~= true or v8.starterProgressPending == true or starterHasPriority() then
		return false
	end

	for _, attributeName in v11 do
		if localPlayer:GetAttribute(attributeName) then
			return false
		end
	end

	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideModel()
	proximityPrompt.Enabled = false
	eventModel.Parent = script
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startTimestamp(p)
	local startTime = p.StartTime

	if type(startTime) ~= "table" then
		return nil
	end

	local success, result = pcall(function()
		return DateTime.fromUniversalTime(
			startTime.Year,
			startTime.Month,
			startTime.Day,
			startTime.Hour,
			startTime.Minute,
			startTime.Second,
			startTime.Millisecond or 0
		)
	end)
	return success and result.UnixTimestamp or nil
end

local function formatRemaining(p)
	local v12 = math.max(0, p)
	local v13 = math.floor(v12 / 86400)
	local v14 = math.floor(v12 % 86400 / 3600)
	local v15 = math.floor(v12 % 3600 / 60)

	if v13 > 0 then
		return string.format("%dd %dh %dm", v13, v14, v15)
	end

	if v14 > 0 then
		return string.format("%dh %dm", v14, v15)
	end

	return string.format("%d:%02d", v15, v12 % 60)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateTimer()
	if not v4 then
		return false
	end

	local v12 = math.max(0, v4 - DateTime.now().UnixTimestamp)
	textLabel2.Text = formatRemaining(v12)
	return v12 == 0
end

local function getNextEvent()
	local success, result = pcall(function()
		return SocialService:GetUpcomingExperienceEventsAsync()
	end)

	if not success or type(result) ~= "table" then
		warn("JoinEventPrompt: failed to get upcoming events:", result)
		return nil
	end

	local unixTimestamp = DateTime.now().UnixTimestamp
	local v12 = nil
	local v13 = nil

	for _, v14 in ipairs(result) do
		local v15 = startTimestamp(v14) -- equivalent call inferred; original call site unknown

		if not (v14.Id and v15 and unixTimestamp < v15) then
			continue
		end

		if v14.HasStarted or v14.HasEnded or not (not v12 or v15 < v12) then
			continue
		end

		v13 = v14
		v12 = v15
	end

	return v13, v12
end

local function refreshEvent()
	local nextEvent, v12 = getNextEvent()

	if not v then
		return
	end

	if nextEvent then
		local id = tostring(nextEvent.Id)
		local success, result = pcall(function()
			return SocialService:GetEventRsvpStatusAsync(id)
		end)

		if not v then
			return
		end

		if not success then
			warn("JoinEventPrompt: failed to get RSVP status:", result)
		end

		v2 = id
		v4 = v12
		local title = nextEvent.Title or nextEvent.DisplayTitle
		local v13 = (type(title) ~= "string" or title == "") and "Next Event" or title
		v3 = v13
		local v14 = v6[id] or result == Enum.RsvpStatus.Going or nextEvent.UserRsvpStatus == Enum.RsvpStatus.Going

		if v14 then
			v6[id] = true
		end

		textLabel.Text = (v14 and "Already Signed Up: " or "Sign Up: ") .. v13
		local thumbnailIds = nextEvent.ThumbnailIds
		local v15

		if type(thumbnailIds) == "table" then
			v15 = thumbnailIds[1]
		else
			v15 = false
		end

		decal.Texture = v15 and "rbxassetid://" .. tostring(v15) or ""
		eventModel.Parent = workspace
		proximityPrompt.Enabled = not (v14 or v5)

		if not v4 then
			return
		end

		local v16 = math.max(0, v4 - DateTime.now().UnixTimestamp)
		textLabel2.Text = formatRemaining(v16)
	else
		v2 = nil
		v4 = nil
		hideModel() -- equivalent call inferred; original call site unknown
	end
end

local function promptEvent(p)
	if not v or v5 or v6[p] then
		return
	end

	v5 = true
	v7[p] = true
	localPlayer:SetAttribute("EventRsvpOpen", true)
	proximityPrompt.Enabled = false
	local success, result = pcall(function()
		return SocialService:PromptRsvpToEventAsync(p)
	end)
	v5 = false
	localPlayer:SetAttribute("EventRsvpOpen", nil)

	if not v then
		return
	end

	if success and result == Enum.RsvpStatus.Going then
		v6[p] = true

		if v2 == p then
			textLabel.Text = "Already Signed Up: " .. v3
		end
	elseif not success then
		warn("JoinEventPrompt: failed to open RSVP prompt:", result)
	end

	if eventModel.Parent == workspace then
		proximityPrompt.Enabled = v2 ~= nil and not v6[v2]
	end
end

table.insert(connections, proximityPrompt.Triggered:Connect(function()
	if v5 or not proximityPrompt.Enabled or not v2 or eventModel.Parent ~= workspace then
		return
	end

	promptEvent(v2)
end))

local function tryInvite(p)
	if not canInvite(p) then
		return
	end

	local nextEvent, v12 = getNextEvent()

	if not canInvite(p) then
		return
	end

	if not nextEvent then
		v9 = nil
		return
	end

	local id = tostring(nextEvent.Id)

	if v6[id] or v7[id] or nextEvent.UserRsvpStatus == Enum.RsvpStatus.Going then
		v9 = nil
		return
	end

	local success, result = pcall(function()
		return SocialService:GetEventRsvpStatusAsync(id)
	end)

	if not canInvite(p) then
		return
	end

	if success then
		if result == Enum.RsvpStatus.Going then
			v6[id] = true
			v9 = nil
		else
			if v12 <= DateTime.now().UnixTimestamp then
				p.retryAt = os.clock() + 5
				return
			end

			v9 = nil
			promptEvent(id)
		end
	else
		p.attempts += 1
		p.retryAt = os.clock() + 30

		if p.attempts >= 3 then
			v9 = nil
		end
	end
end

table.insert(connections, armoryEvent.OnClientEvent:Connect(function(p, p2)
	if p == "State" and type(p2) == "table" then
		v8 = p2

		if v9 and starterHasPriority() then
			v9 = nil
		end
	end
end))
table.insert(connections, localPlayer:GetAttributeChangedSignal("StarterPackOpen"):Connect(function()
	if localPlayer:GetAttribute("StarterPackOpen") then
		v9 = nil
	end
end))
table.insert(connections, localPlayer:GetAttributeChangedSignal("InMatch"):Connect(function()
	lastTime = os.clock()
end))
table.insert(connections, eventHostRemote.OnClientEvent:Connect(function(p, p2)
	if p ~= "PromptEvent" or type(p2) ~= "table" or type(p2.issuedAt) ~= "number" or p2.issuedAt ~= p2.issuedAt or p2.issuedAt <= issuedAt or workspace:GetServerTimeNow() - p2.issuedAt > 60 or p2.issuedAt > workspace:GetServerTimeNow() + 30 then
		return
	end

	issuedAt = p2.issuedAt

	if starterHasPriority() or v5 then
		return
	end

	v9 = v9 or {
		expiresAt = os.clock() + 1200,
		retryAt = 0,
		attempts = 0
	}
	armoryEvent:FireServer("Get")
end))
script.Destroying:Connect(function()
	v = false
	v9 = nil
	localPlayer:SetAttribute("EventRsvpOpen", nil)

	for _, connection in connections do
		connection:Disconnect()
	end

	eventModel:Destroy()
end)
hideModel() -- equivalent call inferred; original call site unknown
armoryEvent:FireServer("Get")
local v12 = 0

while v and script.Parent do
	if v12 <= os.clock() then
		refreshEvent()
		v12 = os.clock() + 60
	else
		-- equivalent call inferred; original call site unknown
		if updateTimer() then
			refreshEvent()
			v12 = os.clock() + 60
		end
	end

	if v9 then
		if os.clock() >= v9.expiresAt or starterHasPriority() then
			v9 = nil
		elseif not v10 and os.clock() >= v9.retryAt and canInvite(v9) then
			v10 = true
			local v14 = v9
			task.spawn(function()
				local v15, v16 = xpcall(function()
					tryInvite(v14)
				end, debug.traceback)
				v10 = false

				if not v15 then
					if v9 == v14 then
						v9 = nil
					end

					warn("JoinEventPrompt: invitation failed:", v16)
				end
			end)
		end
	end

	task.wait(1)
end