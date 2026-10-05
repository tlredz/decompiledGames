local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local game2 = chickenOrHero:WaitForChild("Game")
local mapVoteState = game2:WaitForChild("MapVoteState")
local mapVoteEvent = game2:WaitForChild("MapVoteEvent")
local session = game2:WaitForChild("Session")
local MapVoteConfig = require(game2:WaitForChild("MapVoteConfig"))
local MapVoteTiming = require(chickenOrHero.Presentation:WaitForChild("MapVoteTiming"))
local HudNavigation = require(chickenOrHero.Presentation:WaitForChild("HudNavigation"))
local MapVoteView = require(chickenOrHero.Presentation:WaitForChild("MapVoteView"))
local v = MapVoteView.new(localPlayer:WaitForChild("PlayerGui"))
local v2 = {
	phase = "Closed"
}
local connections = {}
local total = 0
local v3 = nil
local v4 = 0
local v5 = false
local selectedObject = nil
local v6 = false
local v7 = false
local v8 = false
local v9 = {
	"StarterPackOpen",
	"LikeRewardOpen",
	"CreatorPanelOpen",
	"CreatorCameraActive",
	"CreatorUIHidden",
	"ScreenPresentationActive",
	"GlobalWheelOpen",
	"MatchSummaryVisible",
	"TutorialModalActive",
	"CursorHintOpen",
	"CursorHintPending",
	"BalloonOfferOpen",
	"ArmoryOpen",
	"JourneyOpen",
	"SettingsOpen",
	"UpdateLogOpen",
	"ServerBrowserOpen",
	"AdminConsoleActive",
	"AnnouncementComposerOpen",
	"EmoteWheelOpen",
	"FairPlayNoticeOpen",
	"ConnectionQualityOpen"
}

local function eligible()
	return localPlayer:GetAttribute("ClientReady") == true and localPlayer:GetAttribute("InitialLoadingComplete") == true and not (localPlayer:GetAttribute("AFK") or localPlayer:GetAttribute("InMatch") or localPlayer:GetAttribute("TutorialSession") or localPlayer:GetAttribute("TutorialRouting") or localPlayer:GetAttribute("AdminTransferring") or localPlayer:GetAttribute("ServerBrowserTransferring"))
end

local function modal(mapVoteOpen)
	if mapVoteOpen == v8 then
		return
	end

	v8 = mapVoteOpen
	localPlayer:SetAttribute("MapVoteOpen", mapVoteOpen)

	if mapVoteOpen then
		HudNavigation.opening("MapVote")
		selectedObject = GuiService.SelectedObject

		if UserInputService.GamepadEnabled then
			GuiService.SelectedObject = v.close
		end
	elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(v.gui) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end
end

local function render()
	local now = os.clock()

	if not v3 and localPlayer:GetAttribute("ClientReady") == true and localPlayer:GetAttribute("InitialLoadingComplete") == true and not localPlayer:GetAttribute("ScreenPresentationActive") then
		v3 = now
	end

	local matchSummaryVisible = localPlayer:GetAttribute("MatchSummaryVisible") == true

	if v5 and not matchSummaryVisible then
		v4 = now + (MapVoteConfig.AfterSummarySeconds or 0.5)
	end

	v5 = matchSummaryVisible
	local v10

	if v2.phase == "Voting" or v2.phase == "Result" then
		v10 = eligible()
	else
		v10 = false
	end

	local valleyHUD = localPlayer.PlayerGui:FindFirstChild("ValleyHUD")
	local v11 = session:GetAttribute("MapChanging") == true or valleyHUD and valleyHUD:GetAttribute("DrawerOpen") == true

	for _, attributeName in v9 do
		if localPlayer:GetAttribute(attributeName) ~= true then
			continue
		end

		v11 = true
		break
	end

	local canPresent = MapVoteTiming.canPresent(
		now,
		v3,
		localPlayer:GetAttribute("MapVoteJoinedAt"),
		v2.openedAt,
		v4,
		MapVoteConfig
	)
	local v13 = v10 and not v11 and canPresent
	local v14 = math.max(0, (math.ceil((v2.endsAt or 0) - workspace:GetServerTimeNow())))

	if v13 and not v6 then
		v6 = true
		v7 = MapVoteTiming.shouldExpand(v2.phase, v14)
	end

	modal(v13 and v7 or false)
	localPlayer:SetAttribute("MapVoteVisible", v13 == true)
	v:setExpanded(v13 and v7)
	v:setVisible(v13)

	if v10 then
		v:render(v2, localPlayer.UserId)
		v:clock(v14, session:GetAttribute("GlobalPaused") == true)
	end

	v:layout()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function read()
	local success, result = pcall(HttpService.JSONDecode, HttpService, mapVoteState.Value)

	if success and type(result) == "table" then
		if result.token ~= v2.token then
			v6 = false
			v7 = false
		end

		v2 = result
		render()
	end
end

function v.onVote(p)
	if eligible() and v2.phase == "Voting" and not session:GetAttribute("GlobalPaused") then
		mapVoteEvent:FireServer("Vote", p, v2.token)
	end
end

table.insert(connections, v.close.Activated:Connect(function()
	v7 = not v7
	v6 = true
	render()
end))
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and v8 and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
		v7 = false
		render()
	end
end))
table.insert(connections, mapVoteState.Changed:Connect(read))
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
	total += dt

	if total >= 0.1 then
		total = 0
		render()
	end
end))
script.Destroying:Connect(function()
	for _, connection in connections do
		connection:Disconnect()
	end

	if v8 ~= false then
		v8 = false
		localPlayer:SetAttribute("MapVoteOpen", false)

		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(v.gui) then
			GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
		end
	end

	localPlayer:SetAttribute("MapVoteOpen", false)
	localPlayer:SetAttribute("MapVoteVisible", false)
	v:destroy()
end)
read() -- equivalent call inferred; original call site unknown