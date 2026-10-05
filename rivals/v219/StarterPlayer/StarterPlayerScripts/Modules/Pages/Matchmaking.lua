local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local RotatingQueueLibrary = require(ReplicatedStorage.Modules.RotatingQueueLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local LeaderboardController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("LeaderboardController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ArcadeController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ArcadeController"))
local MatchmakingQueueSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BaseMatchmakingQueueSlot"):WaitForChild("MatchmakingQueueSlot"))
local BaseMatchmakingQueueSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BaseMatchmakingQueueSlot"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RankIcon"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("MatchmakingQueueSlot")
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.PageContainer = self.PageFrame:WaitForChild("Container")
	self.CloseButton = self.PageContainer:WaitForChild("Close")
	self.List = self.PageContainer:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.CenterDuelsFrame = self.Container:WaitForChild("CenterDuels")
	self.DuelsFrame = self.Container:WaitForChild("Duels")
	self.DuelsContainer = self.DuelsFrame:WaitForChild("Container")
	self.DuelsContainerCloseButton = self.DuelsContainer:WaitForChild("Close")
	self.QueuesFrame = self.DuelsContainer:WaitForChild("Queues")
	self.RankedFrame = self.DuelsContainer:WaitForChild("Ranked")
	self.RankedButton = self.RankedFrame:WaitForChild("Button")
	self.RankedThumbnail = self.RankedButton:WaitForChild("Thumbnail")
	self.RankedLockedFrame = self.RankedButton:WaitForChild("Locked")
	self.RankedLockedText = self.RankedLockedFrame:WaitForChild("Description")
	self.RankedUnlockedFrame = self.RankedButton:WaitForChild("Unlocked")
	self.RankedIconContainer = self.RankedUnlockedFrame:WaitForChild("IconContainer")
	self.RankedSeasonText = self.RankedUnlockedFrame:WaitForChild("Season")
	self.RankedRankText = self.RankedUnlockedFrame:WaitForChild("Rank")
	self.RankedELOText = self.RankedUnlockedFrame:WaitForChild("ELO")
	self.AprilFoolsFrame = self.Container:WaitForChild("AprilFools")
	self.AprilFoolsContainer = self.AprilFoolsFrame:WaitForChild("Container")
	self.AprilFoolsSlotsFrame = self.AprilFoolsContainer:WaitForChild("Slots")
	self.AprilFoolsSlotsLayout = self.AprilFoolsSlotsFrame:WaitForChild("Layout")
	self.ArcadeServersFrame = self.Container:WaitForChild("ArcadeServers")
	self.ArcadeServersContainer = self.ArcadeServersFrame:WaitForChild("Container")
	self.ArcadeServersHeaderInfoButton = self.ArcadeServersContainer:WaitForChild("Header"):WaitForChild("Info")
	self.ArcadeServersHeaderInfoBubble = self.ArcadeServersHeaderInfoButton:WaitForChild("Bubble")
	self.ArcadeServersHeaderInfoBubbleTitle = self.ArcadeServersHeaderInfoBubble:WaitForChild("Title")
	self.ArcadeServersHeaderInfoBubbleBackground = self.ArcadeServersHeaderInfoBubble:WaitForChild("Background")
	self.RotatingFrame = self.Container:WaitForChild("Rotating")
	self.RotatingContainer = self.RotatingFrame:WaitForChild("Container")
	self.RotatingHeaderFrame = self.RotatingContainer:WaitForChild("Header")
	self.RotatingHeaderTitle = self.RotatingHeaderFrame:WaitForChild("Title")
	self.RotatingHeaderNewReleaseFrame = self.RotatingHeaderFrame:WaitForChild("NewRelease")
	self.RotatingSlotsFrame = self.RotatingContainer:WaitForChild("Slots")
	self.RotatingSlotsLayout = self.RotatingSlotsFrame:WaitForChild("Layout")
	self.EventFrame = self.Container:WaitForChild("Event")
	self.EventContainer = self.EventFrame:WaitForChild("Container")
	self.EventHeaderFrame = self.EventContainer:WaitForChild("Header")
	self.EventHeaderIcon = self.EventHeaderFrame:WaitForChild("Icon")
	self.EventSlotsFrame = self.EventContainer:WaitForChild("Slots")
	self.EventSlotsLayout = self.EventSlotsFrame:WaitForChild("Layout")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self.RankedSlot = BaseMatchmakingQueueSlot.new(self.RankedFrame)
	self._matchmaking_queue_slots = {}
	self._rotating_matchmaking_queue_slots = {}
	self._rotating_batch_containers = {}
	self._rank_icon = nil
	self:_Init()
	return self
end

function object.ScrollTo(data, p, value)
	local arcadeServersFrame

	if p == "Arcade" then
		arcadeServersFrame = data.ArcadeServersFrame
	elseif p == "Rotating" then
		arcadeServersFrame = data.RotatingFrame
	else
		arcadeServersFrame = nil
	end

	if not arcadeServersFrame then
		return
	end

	task.delay(value or 0, function()
		TweenService:Create(data.List, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CanvasPosition = Vector2.new(0, arcadeServersFrame.AbsolutePosition.Y - data.Container.AbsolutePosition.Y)
		}):Play()
	end)
end

function object:Open(...)
	Page.Open(self, ...)
	self.List.CanvasPosition = Vector2.zero
	task.defer(self._GenerateRotatingLoop, self)
end

function object:_UpdateLayouts()
	self.RotatingFrame.Size = UDim2.new(1, 0, 0.1, self.RotatingSlotsLayout.AbsoluteContentSize.Y)
	self.EventFrame.Size = UDim2.new(1, 0, 0.1, self.EventSlotsLayout.AbsoluteContentSize.Y)
	self.AprilFoolsFrame.Size = UDim2.new(1, 0, 0.1, self.AprilFoolsSlotsLayout.AbsoluteContentSize.Y)
	self.ArcadeServersHeaderInfoBubbleBackground.Size = UDim2.new(
		0.04,
		self.ArcadeServersHeaderInfoBubbleTitle.TextBounds.X,
		1,
		0
	)
end

function object:_UpdateArcadeServerHeaderInfo()
	self.ArcadeServersHeaderInfoButton.Visible = true
end

function object:_UpdateLocked()
	local visible = PlayerDataController:Get("Level") < SeasonLibrary.CurrentSeason.LevelRequirement
	self.RankedLockedFrame.Visible = visible
	self.RankedUnlockedFrame.Visible = not visible
end

function object:_UpdateELO()
	if self._rank_icon then
		self._rank_icon:Destroy()
		self._rank_icon = nil
	end

	local _ = SeasonLibrary.CurrentSeason.RankProfile
	local v = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local v2 = v and v.RankedPerformances[SeasonLibrary.UNIVERSAL_ELO_NAME]

	if not v2 then
		return
	end

	local rank = SeasonLibrary:GetRank(v2.CurrentELO, Players.LocalPlayer.UserId)
	self.RankedRankText.Text = rank
	local rankedELOText = self.RankedELOText
	local text

	if v2.CurrentELO then
		text = Utility:PrettyNumber(v2.CurrentELO) .. " ELO"
	else
		text = v2.DuelsPlayed .. " / " .. SeasonLibrary.CurrentSeason.RankProfile.NumPlacementDuels
	end

	rankedELOText.Text = text

	if v2.CurrentELO then
		self._rank_icon = RankIcon.new(v2.CurrentELO, Players.LocalPlayer.UserId)
		self._rank_icon:SetParent(self.RankedIconContainer)
	end
end

function object:_UpdateList()
	self.CloseButton.Position = UDim2.new(0.975, 0, 0.0225, self.PageFrame.AbsoluteSize.Y * 0.125)
	self.List.Position = UDim2.new(0.5, 9, 0, self.PageFrame.AbsoluteSize.Y * 0.125)
	self.List.Size = UDim2.new(0.85, 0, 0, self.PageFrame.AbsoluteSize.Y * 0.75)
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
end

function object:_UpdateOnboarding()
	local statistic = PlayerDataController:GetStatistic("StatisticDuelsPlayed")
	self.RotatingFrame.Visible = statistic >= 3
	self.ArcadeServersFrame.Visible = statistic >= 4
	local aprilFoolsFrame = self.AprilFoolsFrame
	aprilFoolsFrame.Visible = statistic >= 10 and Utility:IsAprilFoolsGamemodesEnabled() and DuelLibrary.APRIL_FOOLS_QUEUES and #DuelLibrary.APRIL_FOOLS_QUEUES > 0
	self.CenterDuelsFrame.Visible = statistic < 3
	self.DuelsContainerCloseButton.Visible = self.CenterDuelsFrame.Visible
	self.CloseButton.Visible = not self.CenterDuelsFrame.Visible
end

function object:_UpdateBeginnerQueue()
	local _matchmaking_queue_slot = self._matchmaking_queue_slots[CONSTANTS.BEGINNER_QUEUE_NAME]

	if not _matchmaking_queue_slot then
		self.RankedFrame.Visible = true
		return
	end

	local visible = PlayerDataController:GetStatistic("StatisticDuelsWon") < CONSTANTS.BEGINNER_QUEUE_WINS
	_matchmaking_queue_slot.Frame.Visible = visible
	self.RankedFrame.Visible = not visible
	self.QueuesFrame.Position = not visible and UDim2.new(0.7, 0, 0.2, 0) or UDim2.new(1, 0, 0.2, 0)
end

function object:_RespondToQueueStatus(value)
	if value == "Success" then
		self.Closed:Fire()
	else
		self.PromptSystem:Open("ErrorMessage", "Whoops!", value or "Server failed to respond, please try again")
	end
end

function object:_GenerateQueues(parent, list, list2, callback)
	if list2 then
		for _, v in pairs(list2) do
			v:Destroy()
		end

		table.clear(list2)
	end

	local v = list2 or {}

	for i = 1, math.ceil(#list / 2) do
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundTransparency = 1
		frame.Parent = parent
		table.insert(v, frame)
		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Padding = UDim.new(0.005, 0)
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		uIListLayout.Parent = frame
		local v2 = list[(i - 1) * 2 + 1 + 1] and 2 or 1

		for i2 = 1, v2 do
			local v3 = list[(i - 1) * 2 + i2]
			local frame2 = Instance.new("Frame")
			frame2.AnchorPoint = Vector2.new(0.5, 0.5)
			frame2.Size = UDim2.new(
				1 / v2 - uIListLayout.Padding.Scale / 2 * (v2 - 1),
				0,
				i > 1 and v2 == 1 and 0.75 or 1,
				0
			)
			frame2.BackgroundTransparency = 1
			frame2.Parent = frame
			local v4 = MatchmakingQueueSlot.new(v3, frame2)
			v4.QueueStatus:Connect(function(p)
				self:_RespondToQueueStatus(p)
			end)
			self._matchmaking_queue_slots[v3] = v4

			if callback then
				callback(v3, frame2, v4)
			end
		end
	end
end

function object:_GenerateRotating()
	for _, _rotating_matchmaking_queue_slot in pairs(self._rotating_matchmaking_queue_slots) do
		_rotating_matchmaking_queue_slot.Container:Destroy()
		_rotating_matchmaking_queue_slot.MatchmakingQueueSlot:Destroy()
	end

	local function callback(p, container, matchmakingQueueSlot)
		self._rotating_matchmaking_queue_slots[p] = {
			Container = container,
			MatchmakingQueueSlot = matchmakingQueueSlot
		}
	end

	self:_GenerateQueues(
		self.RotatingSlotsFrame,
		RotatingQueueLibrary:GetCurrent().QueueNames,
		self._rotating_batch_containers,
		callback
	)
end

function object:_GenerateRotatingLoop()
	local _is_open_hash = self._is_open_hash
	local v = nil

	while self._is_open and _is_open_hash == self._is_open_hash do
		local cycle = RotatingQueueLibrary:GetCycle()

		if cycle ~= v then
			self:_GenerateRotating()
			v = cycle
		end

		self.RotatingHeaderTitle.Text = "New gamemodes in " .. Utility:TimeFormat2((math.ceil((RotatingQueueLibrary:GetTimeUntilNext()))))
		self.RotatingHeaderNewReleaseFrame.Visible = RotatingQueueLibrary:IsNewRelease()
		wait(1)
	end
end

function object:_GenerateQueueSlot(p)
	local v = Utility:WaitForChildRecursive(self.Container, p, 2)

	if not v then
		return
	end

	local v2 = MatchmakingQueueSlot.new(p, v)
	v2.QueueStatus:Connect(function(p2)
		self:_RespondToQueueStatus(p2)
	end)
	self._matchmaking_queue_slots[p] = v2

	if p == CONSTANTS.BEGINNER_QUEUE_NAME then
		self:_UpdateBeginnerQueue()
	end
end

function object:_Setup()
	self.RankedLockedText.Text = "Unlocked at\nLevel " .. SeasonLibrary.CurrentSeason.LevelRequirement
	self.RankedSeasonText.Text = "Season " .. SeasonLibrary.CurrentSeason.Version
	self.RankedThumbnail.Image = SeasonLibrary.CurrentSeason.ThumbnailRankedCoverPhoto
	self.EventHeaderIcon.Image = EventLibrary.EVENT_DETAILS and EventLibrary.EVENT_DETAILS.LTM_HEADER_ICON or self.EventHeaderIcon.Image
	self.ArcadeServersHeaderInfoBubbleTitle.Text = string.format([[
You must be Level %s+ to earn XP from Arcade Servers
This includes Career XP, Weapon XP, & Task progress]], CONSTANTS.LEVEL_REQUIRED_FOR_REWARDS_FROM_ARCADE_SERVERS)

	for _, v in pairs(DuelLibrary.MatchmakingQueueOrder) do
		task.defer(self._GenerateQueueSlot, self, v)
	end

	if DuelLibrary.APRIL_FOOLS_QUEUES and #DuelLibrary.APRIL_FOOLS_QUEUES > 0 then
		self:_GenerateQueues(self.AprilFoolsSlotsFrame, DuelLibrary.APRIL_FOOLS_QUEUES)
	end

	self.EventFrame.Visible = EventLibrary.IS_ACTIVE and EventLibrary.LTM_QUEUENAMES and #EventLibrary.LTM_QUEUENAMES > 0

	if self.EventFrame.Visible then
		self:_GenerateQueues(self.EventSlotsFrame, EventLibrary.LTM_QUEUENAMES)
	end

	for _, childName in pairs(DuelLibrary.ArcadeModeOrder) do
		local arcadeMode = DuelLibrary.ArcadeModes[childName]
		local child = self.ArcadeServersContainer:WaitForChild(childName)
		local title = child:WaitForChild("Button"):WaitForChild("Title")
		title.Text = arcadeMode.DisplayName
		local description = child:WaitForChild("Button"):WaitForChild("Description")
		description.Text = arcadeMode.Description
		local thumbnail = child:WaitForChild("Button"):WaitForChild("Thumbnail")
		thumbnail.Image = arcadeMode.Thumbnail
		local v = childName
		BaseMatchmakingQueueSlot.new(child).Clicked:Connect(function()
			ArcadeController:ToArcadeServer(v)
		end)
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.DuelsContainerCloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.ArcadeServersHeaderInfoButton.MouseButton1Click:Connect(function()
		self.ArcadeServersHeaderInfoBubble.Visible = not self.ArcadeServersHeaderInfoBubble.Visible
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateList()
	end)
	self.PageFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateList()
	end)
	self.RankedSlot.Clicked:Connect(function()
		if PlayerDataController:Get("Level") >= SeasonLibrary.CurrentSeason.LevelRequirement then
			self.OpenPage:Fire("Ranked")
		else
			Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
		end
	end)
	self.RotatingSlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.EventSlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.AprilFoolsSlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.ArcadeServersHeaderInfoBubbleTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayouts()
	end)
	PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_UpdateOnboarding()
	end)
	PlayerDataController:GetDataChangedSignal("StatisticDuelsWon"):Connect(function()
		self:_UpdateBeginnerQueue()
	end)
	PlayerDataController:GetDataChangedSignal("Level"):Connect(function()
		self:_UpdateLocked()
		self:_UpdateArcadeServerHeaderInfo()
	end)
	PlayerDataController:GetDataChangedSignal("Seasons"):Connect(function()
		self:_UpdateELO()
	end)
	LeaderboardController:GetLeaderboardRefreshedSignal("Highest ELO"):Connect(function()
		self:_UpdateELO()
	end)
	self:_Setup()
	self:_UpdateList()
	self:_UpdateOnboarding()
	self:_UpdateELO()
	self:_UpdateLocked()
	self:_UpdateLayouts()
	self:_UpdateArcadeServerHeaderInfo()
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.DuelsContainerCloseButton)
	ButtonEffect:Add(self.ArcadeServersHeaderInfoButton)
end

return object._new()