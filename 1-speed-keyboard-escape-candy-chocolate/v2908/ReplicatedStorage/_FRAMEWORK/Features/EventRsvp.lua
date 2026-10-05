local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local SocialService = game:GetService("SocialService")
local FeatureManager = require(ReplicatedStorage._FRAMEWORK.Libraries.FeatureManager)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local remo = require(ReplicatedStorage.Packages.remo)
local t = require(ReplicatedStorage.Packages.t)
local v = { "EventRSVPzone", "EventRSVPConcertzone" }
local v2 = { "EventRSVPbutton", "EventRSVPConcertbutton" }
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local EventRsvp = {
	remotes = remo.createRemotes({
		syncStatus = remo.remote(t.literal("Going", "None", "NotGoing"))
	})
}
local eventId2 = ""
local v4 = nil
local v5 = nil
local flag = false
local now = 0

local function applyBoost(p, p2)
	v5:StopBonus("player", "XP", p, "EventRsvp")
	local v6 = p2.ValidatedAt + 1800 - os.time()

	if p2.EventId == eventId2 and v6 >= 1 then
		v5:ActivateBonus("player", "XP", 2, v6, p, "EventRsvp")
	end
end

local function checkSyncReady(p)
	if eventId2 == "" then
		return false, nil
	end

	local activeData = v4:GetActiveData(p)

	if activeData then
		return true, activeData.RSVPBoost
	end

	return false, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function recordValidation(state)
	state.Status = "Going"

	if state.EventId ~= eventId2 or state.ValidatedAt == 0 then
		state.EventId = eventId2
		state.ValidatedAt = os.time()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applySync(p, rSVPBoost, status: string)
	if status == "Going" then
		recordValidation(rSVPBoost) -- equivalent call inferred; original call site unknown
	else
		rSVPBoost.Status = status
	end

	v4:GetStore(p, "RSVPBoost"):Set(rSVPBoost)
	applyBoost(p, rSVPBoost)
end

local function onSyncStatus(p, status: string)
	local v6, rSVPBoost

	if eventId2 == "" then
		v6 = false
	else
		local activeData = v4:GetActiveData(p)

		if activeData then
			rSVPBoost = activeData.RSVPBoost
			v6 = true
		else
			v6 = false
		end
	end

	if v6 and rSVPBoost then
		applySync(p, rSVPBoost, status) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function publishEventId(eventId: string)
	eventId2 = eventId
	local v6 = ReplicatedStorage:FindFirstChild("EventRsvpId")

	if not v6 then
		v6 = Instance.new("StringValue")
		v6.Name = "EventRsvpId"
	end

	v6.Value = eventId
	v6.Parent = ReplicatedStorage
end

local function resolveEventId()
	local success, result = pcall(function()
		local ConfigService = game:GetService("ConfigService")
		return ConfigService:GetConfigAsync()
	end)

	if success and result then
		local success2, result2 = pcall(function()
			return result:GetValue("event_id")
		end)

		if success2 and type(result2) == "string" then
			return result2
		end
	end

	return ""
end

local function getRsvpStatus(p: string)
	local success, result = pcall(function()
		return SocialService:GetExperienceEventAsync(p)
	end)

	if success and result and result.UserRsvpStatus ~= nil then
		return true, result.UserRsvpStatus
	end

	local success2, result2 = pcall(function()
		return SocialService:GetEventRsvpStatusAsync(p)
	end)

	if success2 then
		return true, result2
	end

	return false, result2
end

local function fireStatus(p)
	if p == Enum.RsvpStatus.Going then
		EventRsvp.remotes.syncStatus:fire("Going")
	elseif p == Enum.RsvpStatus.NotGoing then
		EventRsvp.remotes.syncStatus:fire("NotGoing")
	elseif p == Enum.RsvpStatus.None then
		EventRsvp.remotes.syncStatus:fire("None")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showJoinWindow(p: string)
	local success, result = pcall(function()
		return SocialService:PromptRsvpToEventAsync(p)
	end)

	if success and result then
		fireStatus(result)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function promptRsvp(p: string)
	if flag then
		return
	end

	flag = true
	local rsvpStatus, v6 = getRsvpStatus(p)

	if rsvpStatus and v6 == Enum.RsvpStatus.Going then
		fireStatus(v6)
	else
		showJoinWindow(p) -- equivalent call inferred; original call site unknown
	end

	flag = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasButtonTag(player)
	for _, tag in v2 do
		if CollectionService:HasTag(player, tag) then
			return true
		end
	end

	return false
end

local function startClient(value: string)
	local localPlayer = Players.LocalPlayer
	task.spawn(function()
		task.wait(3)
		promptRsvp(value) -- equivalent call inferred; original call site unknown
	end)

	local function onZoneTouched(instance)
		local character = localPlayer.Character

		if character and instance:IsDescendantOf(character) and os.clock() - now >= 1 then
			now = os.clock()
			showJoinWindow(value) -- equivalent call inferred; original call site unknown
		end
	end

	for _, tag in v do
		for _, v6 in CollectionService:GetTagged(tag) do
			v6.Touched:Connect(onZoneTouched)
		end

		CollectionService:GetInstanceAddedSignal(tag):Connect(function(p)
			p.Touched:Connect(onZoneTouched)
		end)
	end

	ProximityPromptService.PromptTriggered:Connect(function(player)
		-- equivalent call inferred; original call site unknown
		if hasButtonTag(player) then
			showJoinWindow(value) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function startServer()
	publishEventId(resolveEventId()) -- equivalent call inferred; original call site unknown

	if eventId2 == "" then
		logger:warn("No event_id in ConfigService")
	end

	for _, v6 in Players:GetPlayers() do
		local v7, rSVPBoost

		if eventId2 == "" then
			v7 = false
		else
			local activeData = v4:GetActiveData(v6)

			if activeData then
				rSVPBoost = activeData.RSVPBoost
				v7 = true
			else
				v7 = false
			end
		end

		if v7 and rSVPBoost then
			applyBoost(v6, rSVPBoost)
		end
	end
end

FeatureManager.RegisterFeature(script.Name, {
	OnInit = function()
		if RunService:IsServer() then
			local DataManager = require(ServerScriptService.DataManager)
			v4 = DataManager
			local BonusManager = require(ReplicatedStorage.BonusManager)
			v5 = BonusManager
			EventRsvp.remotes.syncStatus:connect(onSyncStatus)
			v4.profileLoaded:Connect(function(p)
				local v6, rSVPBoost

				if eventId2 == "" then
					v6 = false
				else
					local activeData = v4:GetActiveData(p)

					if activeData then
						rSVPBoost = activeData.RSVPBoost
						v6 = true
					else
						v6 = false
					end
				end

				if v6 and rSVPBoost then
					applyBoost(p, rSVPBoost)
				end
			end)
		end
	end,
	OnStart = function()
		if RunService:IsServer() then
			startServer()
			return
		end

		local eventRsvpId = ReplicatedStorage:WaitForChild("EventRsvpId", 60)

		if eventRsvpId and eventRsvpId.Value ~= "" then
			startClient(eventRsvpId.Value)
		end
	end
})
return EventRsvp