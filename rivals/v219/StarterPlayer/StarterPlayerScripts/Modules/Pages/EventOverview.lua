local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local EventController = require(Players.LocalPlayer.PlayerScripts.Controllers.EventController)
local ShopController = require(Players.LocalPlayer.PlayerScripts.Controllers.ShopController)
local MatchmakingQueueSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BaseMatchmakingQueueSlot"):WaitForChild("MatchmakingQueueSlot"))
local ShopSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BaseShopSlot"):WaitForChild("ShopSlot"))
local AdventCalendarSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("AdventCalendarSlot"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local TaskSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("TaskSlot"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.LockedFrame = self.PageFrame:WaitForChild("Locked")
	self.LockedDescriptionText = self.LockedFrame:WaitForChild("Description")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.HeaderFrame = self.Container:WaitForChild("Header")
	self.HeaderPicture = self.HeaderFrame:WaitForChild("Picture")
	self.HeaderTitleText = self.HeaderFrame:WaitForChild("Title")
	self.HeaderCountdownText = self.HeaderFrame:WaitForChild("Countdown")
	self.EventTasksFrame = self.Container:WaitForChild("EventTasks")
	self.EventTasksLockedFrame = self.EventTasksFrame:WaitForChild("Locked")
	self.EventTasksLockedDescription = self.EventTasksLockedFrame:WaitForChild("Description")
	self.EventTasksUnlockedFrame = self.EventTasksFrame:WaitForChild("Unlocked")
	self.EventTasksContainer = self.EventTasksUnlockedFrame:WaitForChild("Container")
	self.EventTasksTitleText = self.EventTasksContainer:WaitForChild("Title")
	self.EventTasksSlotsFrame = self.EventTasksContainer:WaitForChild("Slots")
	self.EventTasksSlotsLayout = self.EventTasksSlotsFrame:WaitForChild("Layout")
	self.RushFrame = self.EventTasksUnlockedFrame:WaitForChild("Rush")
	self.RushTitleText = self.RushFrame:WaitForChild("Title")
	self.RushProgressFrame = self.RushFrame:WaitForChild("Progress")
	self.RushProgressBar = self.RushProgressFrame:WaitForChild("Bar")
	self.RushProgressCompleted = self.RushProgressFrame:WaitForChild("Completed")
	self.RushProgressText = self.RushProgressFrame:WaitForChild("Title")
	self.ShopEntriesFrame = self.Container:WaitForChild("ShopEntries")
	self.ShopEntriesContainer = self.ShopEntriesFrame:WaitForChild("Container")
	self.ShopEntriesTitleText = self.ShopEntriesContainer:WaitForChild("Title")
	self.ShopEntriesSlotsFrame = self.ShopEntriesContainer:WaitForChild("Slots")
	self.ShopEntriesSlotsLayout = self.ShopEntriesSlotsFrame:WaitForChild("Layout")
	self.AdventCalendarFrame = self.Container:WaitForChild("AdventCalendar")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self.AdventCalendarSlot = AdventCalendarSlot.new(self.AdventCalendarFrame)
	self._open_connections = {}
	self._task_slots = {}
	self._shop_slots = {}
	self:_Init()
	return self
end

function object:Open(...)
	Page.Open(self, ...)
	self.AdventCalendarSlot:SetEnabled(true)
	table.insert(self._open_connections, PlayerDataController:GetDataChangedSignal("Tasks"):Connect(function()
		self:_GenerateTasks()
	end))
	table.insert(self._open_connections, PlayerDataController:GetDataChangedSignal("EventTasks"):Connect(function()
		self:_GenerateTasks()
	end))
	table.insert(
		self._open_connections,
		PlayerDataController:GetDataChangedSignal("CosmeticInventory"):Connect(function()
			self:_GenerateShopEntries()
		end)
	)
	table.insert(self._open_connections, PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_GenerateShopEntries()
	end))
	table.insert(
		self._open_connections,
		PlayerDataController:GetDataChangedSignal("EventCurrencyRushProgress"):Connect(function()
			self:_UpdateRush()
		end)
	)
	table.insert(
		self._open_connections,
		PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
			self:_UpdateLocked()
		end)
	)
	task.spawn(function()
		local _is_open_hash = self._is_open_hash

		while _is_open_hash == self._is_open_hash do
			self:_UpdateCountdown()
			wait(1)
		end
	end)
	self:_UpdateRush()
	self:_UpdateCountdown()
	self:_UpdateLocked()
	self:_GenerateTasks()
	self:_GenerateShopEntries()
end

function object.Close(p, ...)
	p.AdventCalendarSlot:SetEnabled(false)
	Page.Close(p, ...)
end

function object:_UpdateLocked()
	local v = EventLibrary.NUM_GAMES_NEEDED_TO_PARTICIPATE - PlayerDataController:GetStatistic("StatisticDuelsPlayed")
	self.List.Visible = v <= 0
	self.LockedFrame.Visible = v > 0
	self.LockedDescriptionText.Text = "Play " .. v .. " more duels to gain access!"
end

function object:_UpdateCountdown()
	local timeRemaining = EventController:GetTimeRemaining()
	self.HeaderCountdownText.Text = timeRemaining and timeRemaining == 0 and "Ending any minute now!" or timeRemaining and timeRemaining > 0 and "Ending in " .. Utility:TimeFormat2(timeRemaining) or "Here for a limited time only!"
end

function object:_UpdateRush()
	local eventCurrencyRushProgress = PlayerDataController:Get("EventCurrencyRushProgress")
	local v = math.clamp(eventCurrencyRushProgress / EventLibrary.CURRENCY_RUSH_DAILY_LIMIT, 0, 1)
	self.RushProgressText.Text = v < 1 and eventCurrencyRushProgress .. " / " .. EventLibrary.CURRENCY_RUSH_DAILY_LIMIT or ""
	self.RushProgressCompleted.Visible = v >= 1
	self.RushProgressBar.Size = UDim2.new(v, 0, 1, 2)
	self.RushProgressBar.BackgroundColor3 = v < 1 and EventLibrary.EVENT_DETAILS.CURRENCY_COLOR or Color3.fromRGB(
		100,
		255,
		50
	)
end

function object:_GenerateTasks(_)
	for _, _task_slot in pairs(self._task_slots) do
		_task_slot:Destroy()
	end

	self._task_slots = {}
	self.EventTasksLockedFrame.Visible = not PlayerDataController:AreTasksCompleted()
	self.EventTasksUnlockedFrame.Visible = not self.EventTasksLockedFrame.Visible
	local eventTasks = PlayerDataController:Get("EventTasks")

	for _, v in pairs(eventTasks or {}) do
		local v2 = TaskSlot.new(v)
		v2:SetParent(self.EventTasksSlotsFrame)
		table.insert(self._task_slots, v2)
	end
end

function object:_GenerateShopEntries()
	for _, _shop_slot in pairs(self._shop_slots) do
		_shop_slot:Destroy()
	end

	self._shop_slots = {}

	for _, v in pairs(EventLibrary.IS_ACTIVE and EventLibrary.SHOP_ENTRIES_OVERVIEW or {}) do
		local v2 = ShopSlot.new(ShopController:GetShopEntry(v))
		v2.Frame.Parent = self.ShopEntriesSlotsFrame
		table.insert(self._shop_slots, v2)
		v2.RewardSlot:OnClick(function()
			if v2.IsLocked or v2.IsOwned then
				return
			end

			self.PromptSystem:Open("InspectShopEntry", v2.ShopEntry.EntryName)
		end)
	end
end

function object:_Setup()
	self.HeaderPicture.Image = EventLibrary.EVENT_DETAILS.OVERVIEW_BANNER_IMAGE
	self.HeaderTitleText.Text = string.upper(EventLibrary.EVENT_NAME or "???") .. " EVENT"
	self.EventTasksTitleText.Text = "Earn " .. EventLibrary.EVENT_DETAILS.CURRENCY_NAME_PLURAL .. "!"
	self.ShopEntriesTitleText.Text = "Spend " .. EventLibrary.EVENT_DETAILS.CURRENCY_NAME_PLURAL .. "!"
	self.RushTitleText.Text = string.upper(EventLibrary.EVENT_DETAILS.CURRENCY_NAME) .. " RUSH — Earn ×" .. EventLibrary.CURRENCY_RUSH_MULTIPLIER .. " " .. EventLibrary.EVENT_DETAILS.CURRENCY_NAME_PLURAL .. " every day!"
	self.EventTasksLockedDescription.Text = "Complete your Daily Tasks to start earning " .. EventLibrary.EVENT_DETAILS.CURRENCY_NAME_PLURAL .. "!"

	for k, name in pairs(EventLibrary.LTM_QUEUENAMES or {}) do
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Size = UDim2.new(0.995, 0, 0.2, 0)
		frame.BackgroundTransparency = 1
		frame.LayoutOrder = 10 + k
		frame.Parent = self.Container
		MatchmakingQueueSlot.new(name, frame).QueueStatus:Connect(function(value)
			if value == "Success" then
				self:CloseRequest()
			else
				self.PromptSystem:Open("ErrorMessage", "Whoops!", value or "Server failed to respond, please try again")
			end
		end)
	end

	ShopController:GetDailyShop()
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	self.EventTasksSlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.EventTasksFrame.Size = UDim2.new(
			1,
			0,
			0,
			self.EventTasksContainer.AbsoluteSize.Y * 0.2 + self.EventTasksSlotsLayout.AbsoluteContentSize.Y + self.RushFrame.AbsoluteSize.Y
		)
	end)
	self.ShopEntriesSlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.ShopEntriesFrame.Size = UDim2.new(
			1,
			0,
			0,
			self.ShopEntriesContainer.AbsoluteSize.Y * 0.3 + self.ShopEntriesSlotsLayout.AbsoluteContentSize.Y
		)
	end)
	self.PromptSystem.PromptAdded:Connect(function(p)
		self.List.CanvasPosition = Vector2.new(0, 0)

		if p.InspectCurrencyPage then
			p.InspectCurrencyPage:Connect(function()
				Pages.PageSystem:OpenPage("Shop")
				Pages.PageSystem:WaitForPage("Shop"):SetPage("Currency")
			end)
		end
	end)
	self:_Setup()
	self:_UpdateRush()
	self:_UpdateCountdown()
	self:_UpdateLocked()
	self:_GenerateTasks()
	self:_GenerateShopEntries()
	ButtonEffect:Add(self.CloseButton)
end

return object._new()