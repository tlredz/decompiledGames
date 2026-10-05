local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ContractsLibrary = require(ReplicatedStorage.Modules.ContractsLibrary)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local MatchmakingController = require(Players.LocalPlayer.PlayerScripts.Controllers.MatchmakingController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ArcadeController = require(Players.LocalPlayer.PlayerScripts.Controllers.ArcadeController)
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local ContractSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BaseContractSlot"):WaitForChild("ContractSlot"))
local StatisticsList = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("StatisticsList"))
local LockedMapSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("LockedMapSlot"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local MapSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("MapSlot"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local contractDivider = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ContractDivider")
Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("LockedMapSlot")
local playSourceLabel = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PlaySourceLabel")
local emptySlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("EmptySlot")
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.PageContainer = self.PageFrame:WaitForChild("Container")
	self.CloseButton = self.PageContainer:WaitForChild("Close")
	self.CloseButtonIcon = self.CloseButton:WaitForChild("Icon")
	self.List = self.PageContainer:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.SlotsFrame = self.Container:WaitForChild("Slots")
	self.SlotsContainer = self.SlotsFrame:WaitForChild("Container")
	self.SlotsLayout = self.SlotsContainer:WaitForChild("Layout")
	self.InspectList = self.PageContainer:WaitForChild("Inspect")
	self.InspectContainer = self.InspectList:WaitForChild("Container")
	self.InspectLayout = self.InspectContainer:WaitForChild("Layout")
	self.InspectDetailsFrame = self.InspectContainer:WaitForChild("Details")
	self.InspectDetailsFrameUIScale = self.InspectDetailsFrame:WaitForChild("UIScale")
	self.InspectDetailsContainer = self.InspectDetailsFrame:WaitForChild("Container")
	self.InspectDetailsLayout = self.InspectDetailsContainer:WaitForChild("Layout")
	self.InspectDetailsThumbnail = self.InspectDetailsContainer:WaitForChild("Thumbnail")
	self.InspectDetailsTextLabelsFrame = self.InspectDetailsContainer:WaitForChild("TextLabels")
	self.InspectDetailsTextLabelsContainer = self.InspectDetailsTextLabelsFrame:WaitForChild("Container")
	self.InspectDetailsTextLabelsLayout = self.InspectDetailsTextLabelsContainer:WaitForChild("Layout")
	self.InspectDetailsTitle = self.InspectDetailsTextLabelsContainer:WaitForChild("Title")
	self.InspectDetailsDescription = self.InspectDetailsTextLabelsContainer:WaitForChild("Description")
	self.InspectDetailsCreator = self.InspectDetailsTextLabelsContainer:WaitForChild("Creator")
	self.InspectQueuesFrame = self.InspectContainer:WaitForChild("Queues")
	self.InspectQueuesFrameUIScale = self.InspectQueuesFrame:WaitForChild("UIScale")
	self.InspectQueuesContainer = self.InspectQueuesFrame:WaitForChild("Container")
	self.InspectQueuesLabelsFrame = self.InspectQueuesContainer:WaitForChild("Labels")
	self.InspectQueuesLabelsLayout = self.InspectQueuesLabelsFrame:WaitForChild("Layout")
	self.InspectStatisticsFrame = self.InspectContainer:WaitForChild("Statistics")
	self.InspectStatisticsFrameUIScale = self.InspectStatisticsFrame:WaitForChild("UIScale")
	self.InspectStatisticsContainer = self.InspectStatisticsFrame:WaitForChild("Container")
	self.InspectStatisticsLayout = self.InspectStatisticsContainer:WaitForChild("Layout")
	self.InspectStatisticsTextLabelsFrame = self.InspectStatisticsContainer:WaitForChild("TextLabels")
	self.InspectStatisticsTextLabelsContainer = self.InspectStatisticsTextLabelsFrame:WaitForChild("Container")
	self.InspectStatisticsTextLabelsLayout = self.InspectStatisticsTextLabelsContainer:WaitForChild("Layout")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self.StatisticsList = StatisticsList.new(self.InspectStatisticsTextLabelsContainer, 1, true)
	self._map_slots = {}
	self._locked_map_slots = {}
	self._empty_map_slots = {}
	self._map_slot_ui_scales = {}
	self._map_slot_tweens = {}
	self._inspected_map_name = nil
	self._inspected_map_info = nil
	self._inspected_map_locked_slot = nil
	self._inspected_queue_labels = {}
	self._inspected_map_contract_slots = {}
	self._inspect_tweens = {}
	self:_Init()
	return self
end

function object:CloseRequest()
	if self._inspected_map_name then
		self:Inspect(nil)
	else
		Page.CloseRequest(self)
	end
end

function object:Inspect(inspected_map_name)
	for _, _inspect_tween in pairs(self._inspect_tweens) do
		_inspect_tween:Cancel()
	end

	for _, _inspected_queue_label in pairs(self._inspected_queue_labels) do
		_inspected_queue_label:Destroy()
	end

	for _, _inspected_map_contract_slot in pairs(self._inspected_map_contract_slots) do
		_inspected_map_contract_slot:Destroy()
	end

	self._inspected_map_contract_slots = {}
	self._inspect_tweens = {}
	self._inspected_queue_labels = {}

	if self._inspected_map_locked_slot then
		self._inspected_map_locked_slot:Destroy()
		self._inspected_map_locked_slot = nil
	end

	self._inspected_map_name = inspected_map_name
	self._inspected_map_info = DuelLibrary.Maps[self._inspected_map_name]
	self.List.Visible = not self._inspected_map_name
	self.InspectList.Visible = self._inspected_map_name
	self.CloseButtonIcon.Image = self._inspected_map_name and "rbxassetid://17562685319" or "rbxassetid://17838290166"

	if not self._inspected_map_name then
		self:_PlayMapSlotsTween()
		return
	end

	local _IsMapUnlocked = self:_IsMapUnlocked(self._inspected_map_name)
	self.InspectDetailsTitle.Text = not _IsMapUnlocked and "Discover this map in a duel to learn more!" or self._inspected_map_name or "Discover this map in a duel to learn more!"
	self.InspectDetailsTitle.TextTransparency = _IsMapUnlocked and 0 or 0.5
	self.InspectDetailsTitle.FontFace = _IsMapUnlocked and Font.fromId(
		12187365977,
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	) or Font.fromId(12187365977, Enum.FontWeight.Medium, Enum.FontStyle.Italic)
	self.InspectDetailsTitle.Size = _IsMapUnlocked and UDim2.new(0.95, 0, 0.066, 0) or UDim2.new(0.95, 0, 0.035, 0)
	self.InspectDetailsThumbnail.Image = not _IsMapUnlocked and "" or self._inspected_map_info.Image or ""
	self.InspectDetailsDescription.Text = not _IsMapUnlocked and "" or not self._inspected_map_info.Description and "" or "• " .. self._inspected_map_info.Description
	local inspectDetailsCreator = self.InspectDetailsCreator
	local text

	if _IsMapUnlocked then
		if #self._inspected_map_info.Contributors > 0 then
			text = string.format(
				"• Created by %s with contributions from %s",
				self:_GetUsernamesString(self._inspected_map_info.Creators),
				self:_GetUsernamesString(self._inspected_map_info.Contributors)
			)
		else
			text = not (#self._inspected_map_info.Creators > 0) and "" or string.format(
				"• Created by %s",
				self:_GetUsernamesString(self._inspected_map_info.Creators)
			)
		end
	else
		text = ""
	end

	inspectDetailsCreator.Text = text
	self.InspectDetailsDescription.Visible = self.InspectDetailsDescription.Text ~= ""
	self.InspectDetailsCreator.Visible = self.InspectDetailsCreator.Text ~= ""

	if not _IsMapUnlocked then
		self._inspected_map_locked_slot = LockedMapSlot.new(self._inspected_map_name, true)
		self._inspected_map_locked_slot.Frame.Size = UDim2.new(1, 0, 1, 0)
		self._inspected_map_locked_slot.Frame.SizeConstraint = Enum.SizeConstraint.RelativeXY
		self._inspected_map_locked_slot.Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		self._inspected_map_locked_slot.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		self._inspected_map_locked_slot.Frame.Button.Difficulty.UIStroke.Enabled = false
		self._inspected_map_locked_slot:SetParent(self.InspectDetailsThumbnail)
	end

	local function create_playsource_label(layoutOrder, p, p2, p3)
		local playSource = DuelLibrary.PlaySources[p]

		if playSource and playSource.DatabaseInfo and typeof(playSource.DatabaseInfo.CanBeStartedFromClient) == "function" and not playSource.DatabaseInfo.CanBeStartedFromClient() then
			return
		end

		local v2 = p2 or playSource and playSource.AssignedColor or Color3.fromRGB(0, 0, 0)
		local v3 = p3 or v2:Lerp(Color3.fromRGB(0, 0, 0), 0.5)
		local clone = playSourceLabel:Clone()
		clone.LayoutOrder = layoutOrder
		local title = clone.Container.Title
		local text2

		if playSource then
			text2 = playSource.DisplayName or p
		else
			text2 = p
		end

		title.Text = text2
		clone.Play.ImageColor3 = v2
		clone.Parent = self.InspectQueuesLabelsFrame
		table.insert(self._inspected_queue_labels, clone)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			clone.Size = UDim2.new(0.05, clone.Container.Title.TextBounds.X, 0.05, 0)
		end

		clone.Container.Title:GetPropertyChangedSignal("TextBounds"):Connect(update)
		update() -- equivalent call inferred; original call site unknown

		local function hover()
			clone.Play.Visible = true
			clone.Container.Title.Visible = false
			clone.Container.Title.TextColor3 = v2
			clone.Background.ImageColor3 = v3
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function unhover()
			clone.Play.Visible = false
			clone.Container.Title.Visible = true
			clone.Container.Title.TextColor3 = v3
			clone.Background.ImageColor3 = v2
		end

		unhover() -- equivalent call inferred; original call site unknown

		if playSource then
			clone.MouseButton1Click:Connect(function()
				local v5

				if playSource.Type == "MatchmakingQueue" then
					v5 = MatchmakingController:QueueInto(p)
				elseif playSource.Type == "ArcadeMode" then
					v5 = ArcadeController:ToArcadeServer(p)
				else
					v5 = assert(false, "???")
				end

				if v5 ~= "Success" then
					self.PromptSystem:Open(
						"ErrorMessage",
						"Whoops!",
						v5 or "Server failed to respond, please try again"
					)
					return
				end

				self.Closed:Fire()
				Equipment:Close()
			end)
			clone.MouseEnter:Connect(hover)
			clone.SelectionGained:Connect(hover)
			clone.MouseLeave:Connect(unhover)
			clone.SelectionLost:Connect(unhover)
		end
	end

	if self._inspected_map_info.IsHidden then
		create_playsource_label(1, "N/A", Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255))
	elseif #self._inspected_map_info.PlaySources == 0 then
		create_playsource_label(1, "Private Servers", Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255))
	else
		for k, playSource in pairs(self._inspected_map_info.PlaySources) do
			create_playsource_label(k, playSource)
		end
	end

	self.InspectStatisticsFrame.Visible = PlayerDataController:GetMapStatistic(inspected_map_name, "StatisticPlaytime") > 0
	self.StatisticsList:Generate(false, "MapStatistics", inspected_map_name)

	if _IsMapUnlocked then
		local layoutOrder = 50

		for k, v3 in pairs(ContractsLibrary:GetMapContracts(self._inspected_map_name)) do
			if k > 1 then
				local clone = contractDivider:Clone()
				clone.LayoutOrder = layoutOrder
				clone.Parent = self.InspectContainer
				table.insert(self._inspected_map_contract_slots, clone)
				layoutOrder += 1
			end

			local mapStatistics = ContractSlot.new("MapStatistics", v3)
			mapStatistics.Frame.LayoutOrder = layoutOrder
			mapStatistics.Frame.Parent = self.InspectContainer
			table.insert(self._inspected_map_contract_slots, mapStatistics)
			layoutOrder += 1
		end
	end

	self.InspectDetailsFrameUIScale.Scale = 0.5
	self.InspectQueuesFrameUIScale.Scale = 0.5
	self.InspectStatisticsFrameUIScale.Scale = 0.5
	local tween = TweenService:Create(
		self.InspectDetailsFrameUIScale,
		TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Scale = 1
		}
	)
	tween:Play()
	table.insert(self._inspect_tweens, tween)
	local tween2 = TweenService:Create(
		self.InspectQueuesFrameUIScale,
		TweenInfo.new(0.375, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Scale = 1
		}
	)
	tween2:Play()
	table.insert(self._inspect_tweens, tween2)
	local tween3 = TweenService:Create(
		self.InspectStatisticsFrameUIScale,
		TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Scale = 1
		}
	)
	tween3:Play()
	table.insert(self._inspect_tweens, tween3)
end

function object:Open(...)
	Page.Open(self, ...)
	self:Inspect(nil)
	self:_UpdateMapSlots()
	self:_PlayMapSlotsTween()
end

function object:_IsMapUnlocked(p)
	return DuelLibrary.Maps[p] and #DuelLibrary.Maps[p].PlaySources == 0 and true or PlayerDataController:GetMapStatistic(
		p,
		"StatisticPlaytime"
	) > 0
end

function object:_PlayMapSlotsTween()
	for _, _map_slot_tween in pairs(self._map_slot_tweens) do
		_map_slot_tween:Cancel()
	end

	self._map_slot_tweens = {}

	local function play(p, uIScale)
		uIScale.Scale = 0.25
		local tween = TweenService:Create(
			uIScale,
			TweenInfo.new(math.sqrt(p) * 0.1 + 0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Scale = 1
			}
		)
		tween:Play()
		table.insert(self._map_slot_tweens, tween)
	end

	for k, _map_slot in pairs(self._map_slots) do
		play(k, _map_slot[2].Frame.UIScale)
	end

	for k, _locked_map_slot in pairs(self._locked_map_slots) do
		play(k, _locked_map_slot[2].Frame.UIScale)
	end

	for k, _empty_map_slot in pairs(self._empty_map_slots) do
		play(#self._map_slots + k, _empty_map_slot.UIScale)
	end
end

function object:_GetUsernamesString(list)
	local v = ""

	for k, v2 in pairs(list) do
		v = (v .. (k == 1 and "" or k == #list and ", & " or ", ")) .. "@" .. v2
	end

	return v
end

function object:_UpdateMapSlots()
	if not self:IsOpen() then
		return
	end

	for _, _map_slot in pairs(self._map_slots) do
		_map_slot[2].Frame.Visible = self:_IsMapUnlocked(_map_slot[1])
	end

	for _, _locked_map_slot in pairs(self._locked_map_slots) do
		_locked_map_slot[2].Frame.Visible = not self:_IsMapUnlocked(_locked_map_slot[1])
	end
end

function object:_UpdateList()
	self.CloseButton.Position = UDim2.new(0.975, 0, 0.0225, self.PageFrame.AbsoluteSize.Y * 0.125)
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	self.List.Active = self.Layout.AbsoluteContentSize.Y >= self.List.AbsoluteSize.Y
	self.List.Position = UDim2.new(0.5, 9, 0, self.PageFrame.AbsoluteSize.Y * 0.125)
	self.List.Size = UDim2.new(0.85, 0, 0, self.PageFrame.AbsoluteSize.Y * 0.75)
	self.InspectList.Position = self.List.Position
	self.InspectList.Size = self.List.Size
end

function object:_Setup()
	local table2 = Utility:CloneTable(DuelLibrary.MapOrder)
	table.sort(table2, function(a, b)
		return DuelLibrary:SortMaps(a, b)
	end)

	local function create_map_slot(layoutOrder, p)
		local v = MapSlot.new(p)
		v.Frame.LayoutOrder = layoutOrder
		v:SetParent(self.SlotsContainer)
		table.insert(self._map_slots, { p, v })
		v.Frame.Button.MouseButton1Click:Connect(function()
			self:Inspect(p)
		end)
		local uIScale = Instance.new("UIScale")
		uIScale.Parent = v.Frame
	end

	local function create_locked_map_slot(layoutOrder, p)
		local _ = DuelLibrary.Maps[p]
		local v = LockedMapSlot.new(p)
		v.Frame.LayoutOrder = layoutOrder
		v:SetParent(self.SlotsContainer)
		table.insert(self._locked_map_slots, { p, v })
		v.Frame.Button.MouseButton1Click:Connect(function()
			self:Inspect(p)
		end)
		local uIScale = Instance.new("UIScale")
		uIScale.Parent = v.Frame
	end

	for k, v in pairs(table2) do
		create_map_slot(k, v)
		create_locked_map_slot(k, v)
	end

	for _ = 1, math.max(0, 9 - #table2) + (3 - (not (#table2 > 9) and 0 or (#table2 - 1) % 3 + 1)) do
		local clone = emptySlot:Clone()
		clone.LayoutOrder = 9999999
		clone.Parent = self.SlotsContainer
		table.insert(self._empty_map_slots, clone)
		local uIScale = Instance.new("UIScale")
		uIScale.Parent = clone
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateList()
	end)
	self.SlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.SlotsFrame.Size = UDim2.new(1, 0, 0, self.SlotsLayout.AbsoluteContentSize.Y)
	end)
	self.InspectLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.InspectList.CanvasSize = UDim2.new(0, 0, 0, self.InspectLayout.AbsoluteContentSize.Y)
		self.InspectList.Active = self.InspectLayout.AbsoluteContentSize.Y >= self.InspectList.AbsoluteSize.Y
	end)
	self.InspectDetailsTextLabelsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.InspectDetailsTextLabelsFrame.Size = UDim2.new(
			1,
			0,
			0,
			self.InspectDetailsTextLabelsLayout.AbsoluteContentSize.Y
		)
	end)
	self.InspectDetailsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.InspectDetailsFrame.Size = UDim2.new(1, 0, 0, self.InspectDetailsLayout.AbsoluteContentSize.Y)
	end)
	self.InspectQueuesLabelsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.InspectQueuesFrame.Size = UDim2.new(1, 0, 0.088, self.InspectQueuesLabelsLayout.AbsoluteContentSize.Y)
	end)
	self.InspectStatisticsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.InspectStatisticsFrame.Size = UDim2.new(1, 0, 0, self.InspectStatisticsLayout.AbsoluteContentSize.Y)
	end)
	self.InspectStatisticsTextLabelsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.InspectStatisticsTextLabelsFrame.Size = UDim2.new(
			1,
			0,
			0,
			self.InspectStatisticsTextLabelsLayout.AbsoluteContentSize.Y
		)
	end)
	self.PageFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateList()
	end)
	PlayerDataController.StatisticsUpdated:Connect(function()
		self:_UpdateMapSlots()
	end)
	self:_Setup()
	self:_UpdateList()
	self:_UpdateMapSlots()
	self:Inspect(nil)
	ButtonEffect:Add(self.CloseButton)
end

return object._new()