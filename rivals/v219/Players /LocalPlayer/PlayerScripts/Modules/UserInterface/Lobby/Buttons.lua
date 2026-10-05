local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local EventLibrary = require(ReplicatedStorage.Modules.EventLibrary)
local TaskLibrary = require(ReplicatedStorage.Modules.TaskLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ShopController"))
local CosmeticViewportFrame = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("CosmeticViewportFrame"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local EmoteViewportFrame = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("EmoteViewportFrame"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local lobbyButtonSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("LobbyButtonSlot")
local v = {
	{
		"Backpack",
		"Backpack",
		"See your extra loot",
		"rbxassetid://18185474596"
	},
	{
		"Career",
		"Career",
		"Check out your collection & statistics",
		nil
	},
	{
		"Equipment",
		"Weapons",
		"View your weapons, career, emotes, & more",
		nil,
		"UIOpenPage1"
	},
	{
		"Tasks",
		"Tasks",
		"Complete tasks to earn keys",
		"rbxassetid://17653923757",
		"UIOpenPage2"
	},
	{
		"Shop",
		"Shop",
		"Unlock weapons, redeem codes, & more",
		"rbxassetid://17619445340",
		"UIOpenPage3"
	},
	{
		"BattlePass",
		"Pass",
		"Free weapons, skins, keys, & more",
		"rbxassetid://81577092220450",
		"UIOpenPage4"
	},
	{
		"Settings",
		"Settings",
		"Change crosshair & hotkeys",
		"rbxassetid://17619445191"
	},
	{
		"Rewards",
		"Codes",
		"Earn free rewards & redeem codes",
		"rbxassetid://84811629597038"
	},
	{
		"Recover",
		"Recover",
		"Recover your win streak",
		"rbxassetid://112615701583145"
	},
	{
		"EventOverview",
		"Event",
		"Here for a limited time only!",
		nil
	},
	{
		"EquipmentExit",
		"Leave",
		nil,
		"rbxassetid://17619444538",
		"UICancelAction"
	},
	{
		"Emotes",
		"Emotes",
		"Preview & equip your emotes",
		"rbxassetid://111957823189761",
		"UIOpenPage1"
	},
	{
		"Maps",
		"Maps",
		"View map details & map contracts",
		"rbxassetid://112880011932436",
		"UIOpenPage2"
	},
	{
		"DuelHistory",
		"History",
		"Check out your most recent duels",
		"rbxassetid://18678814606",
		"UIOpenPage3"
	},
	{
		"Collection",
		"Collection",
		"Quickly view your game progress",
		"rbxassetid://18186174849",
		"UIOpenPage4"
	},
	{
		"Contracts",
		"Contracts",
		"Earn free keys & cosmetics",
		"rbxassetid://17619445009"
	},
	{
		"Skins",
		"Skin",
		"Change how this weapon looks",
		nil,
		"UIOpenPage1"
	},
	{
		"Wraps",
		"Wrap",
		"Apply a wrap to this weapon",
		nil,
		"UIOpenPage2"
	},
	{
		"Charms",
		"Charm",
		"Equip a gun buddy",
		nil,
		"UIOpenPage3"
	},
	{
		"Finishers",
		"Finisher",
		"Play an effect on elimination",
		nil,
		"UIOpenPage4"
	}
}
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.IsOpen = false
	self.Frame = UILibrary:GetTo("MainFrame", "Lobby", "Buttons")
	self._visibility_effect_hash = 0
	self._hover_effect_hash = 0
	self._buttons = {}
	self._button_callbacks = {}
	self._unhover_functions = {}
	self._wraps_cosmetic_viewport_frame = nil
	self._charms_cosmetic_viewport_frame = nil
	self._emotes_emote_viewport_frame = nil
	self:_Init()
	return self
end

function class:_Unhover()
	for _, _unhover_function in pairs(self._unhover_functions) do
		_unhover_function()
	end
end

function class:_UpdateVisibility()
	self.IsOpen = not (Pages.PageSystem.CurrentPage or Equipment:IsUnlocking() or Queue:IsVisible() or Teleporting.Enabled or MobileInputs.EditorEnabled or GuiService.MenuIsOpen)
	self.Frame.Container:TweenPosition(
		self.IsOpen and UDim2.new(0.5, 0, 0.9625, -20) or UDim2.new(0.5, 0, 1.3, 20),
		"Out",
		"Quint",
		0.25,
		true
	)
	self:_Unhover()
end

function class:_PlayButtonVisibilityEffect()
	self._visibility_effect_hash += 1
	local _visibility_effect_hash = self._visibility_effect_hash
	local _buttons = {}

	for _, _button in pairs(self._buttons) do
		if _button.Visible then
			table.insert(_buttons, _button)
		end
	end

	table.sort(_buttons, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	for k, v2 in pairs(_buttons) do
		if GuiService.ReducedMotionEnabled then
			v2.Size = UDim2.new(1, 0, 1, 0)
			v2:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 0, true)
		else
			v2.Size = UDim2.new(0, 0, 0, 0)
			v2:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0, true)
			local v3 = v2
			task.delay(0.1 * (k - 1), function()
				if _visibility_effect_hash ~= self._visibility_effect_hash then
					return
				end

				v3:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Back", 0.25, true)
			end)
		end
	end
end

function class:_UpdateButtonInformation()
	if self._wraps_cosmetic_viewport_frame then
		self._wraps_cosmetic_viewport_frame:Destroy()
		self._wraps_cosmetic_viewport_frame = nil
	end

	if self._charms_cosmetic_viewport_frame then
		self._charms_cosmetic_viewport_frame:Destroy()
		self._charms_cosmetic_viewport_frame = nil
	end

	if self._emotes_emote_viewport_frame then
		self._emotes_emote_viewport_frame:Destroy()
		self._emotes_emote_viewport_frame = nil
	end

	local v2 = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local battlePass = v2 and v2.BattlePass
	local maxPassTrackNum = battlePass and battlePass.MaxPassTrackNum or 0
	self._buttons.BattlePass.Button.Container.Icon.Image = SeasonLibrary.PASS_TRACK_IMAGES[math.clamp(
		maxPassTrackNum,
		1,
		#SeasonLibrary.PASS_TRACK_IMAGES
	)]
	local weaponData = PlayerDataController:GetWeaponData(Equipment:GetSelectedWeapon())
	local v3 = not (weaponData and weaponData.Skin) and "NONE_COSMETIC" or weaponData.Skin.Name or "NONE_COSMETIC"
	local v4 = CONSTANTS.COSMETIC_IMAGES[v3]
	self._buttons.Skins.Button.Container.Icon.Image = v4 or not weaponData and "" or ItemLibrary:GetViewModelImageFromWeaponData(weaponData) or ""
	self._buttons.Skins.Button.Container.Icon.ImageTransparency = v4 and 0.875 or 0
	self._buttons.Skins.Button.Container.Icon.Size = v4 and UDim2.new(0.4, 0, 0.4, 0) or UDim2.new(1.875, 0, 1.875, 0)
	local v5 = not (weaponData and weaponData.Finisher) and "NONE_COSMETIC" or weaponData.Finisher.Name or "NONE_COSMETIC"
	local v6 = CONSTANTS.COSMETIC_IMAGES[v5]
	self._buttons.Finishers.Button.Container.Icon.Image = v6 or CosmeticLibrary.Cosmetics[weaponData.Finisher.Name].Image
	self._buttons.Finishers.Button.Container.Icon.ImageTransparency = v6 and 0.875 or 0
	self._buttons.Finishers.Button.Container.Icon.Size = v6 and UDim2.new(0.4, 0, 0.4, 0) or UDim2.new(0.75, 0, 0.75, 0)
	self._buttons.Finishers.Button.Container.Icon.UICorner.CornerRadius = v6 and UDim.new(0, 0) or UDim.new(1, 0)
	local v7 = not (weaponData and weaponData.Wrap) and "NONE_COSMETIC" or weaponData.Wrap.Name or "NONE_COSMETIC"
	local v8 = CONSTANTS.COSMETIC_IMAGES[v7]
	self._buttons.Wraps.Button.Container.Icon.Image = v8 or ""
	self._buttons.Wraps.Button.Container.Icon.ImageTransparency = v8 and 0.875 or 0
	self._buttons.Wraps.Button.Container.Icon.Size = v8 and UDim2.new(0.4, 0, 0.4, 0) or UDim2.new(0.75, 0, 0.75, 0)

	if v7 ~= "NONE_COSMETIC" and v7 ~= "RANDOM_COSMETIC" then
		self._wraps_cosmetic_viewport_frame = CosmeticViewportFrame.new(v7)
		self._wraps_cosmetic_viewport_frame.Frame.Parent = self._buttons.Wraps.Button.Container
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = self._wraps_cosmetic_viewport_frame.Frame
	end

	local name = weaponData and weaponData.Charm and weaponData.Charm.Name or "NONE_COSMETIC"
	local v9 = CONSTANTS.COSMETIC_IMAGES[name]
	self._buttons.Charms.Button.Container.Icon.Image = v9 or ""
	self._buttons.Charms.Button.Container.Icon.ImageTransparency = v9 and 0.875 or 0
	self._buttons.Charms.Button.Container.Icon.Size = v9 and UDim2.new(0.4, 0, 0.4, 0) or UDim2.new(0.75, 0, 0.75, 0)

	if name ~= "NONE_COSMETIC" and name ~= "RANDOM_COSMETIC" then
		self._charms_cosmetic_viewport_frame = CosmeticViewportFrame.new(name)
		self._charms_cosmetic_viewport_frame.Frame.Parent = self._buttons.Charms.Button.Container
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = self._charms_cosmetic_viewport_frame.Frame
	end

	local equippedEmotes = PlayerDataController:Get("EquippedEmotes")
	local v10 = not next(equippedEmotes) and "NONE_COSMETIC" or nil
	local v11 = CONSTANTS.COSMETIC_IMAGES[v10]
	self._buttons.Emotes.Button.Container.Icon.Image = v11 or ""
	self._buttons.Emotes.Button.Container.Icon.ImageTransparency = v11 and 0.875 or 0
	self._buttons.Emotes.Button.Container.Icon.Size = v11 and UDim2.new(0.4, 0, 0.4, 0) or UDim2.new(0.75, 0, 0.75, 0)

	if not v10 then
		local names = {}

		for _, equippedEmote in pairs(equippedEmotes) do
			table.insert(names, equippedEmote.Name)
		end

		local v12 = names[math.random(#names)]
		self._emotes_emote_viewport_frame = EmoteViewportFrame.new(v12)
		self._emotes_emote_viewport_frame:HideShadow()
		self._emotes_emote_viewport_frame:SetParent(self._buttons.Emotes.Button.Container)
	end
end

function class:_UpdateButtonVisibility()
	local isOpen = Equipment.IsOpen
	local isOpenEffectDone = Equipment:IsOpenEffectDone()
	local v2 = isOpen and Equipment:IsCareerPageOpen()
	local selectedWeapon = isOpen and Equipment:GetSelectedWeapon()
	local v3 = PlayerDataController:GetWeaponData(selectedWeapon) ~= nil
	local v4 = not Equipment:IsCustomizing()
	local statistic = PlayerDataController:GetStatistic("StatisticDuelsPlayed")
	PlayerDataController:GetStatistic("StatisticDuelsWon")
	self._buttons.Backpack.Visible = not isOpen and #PlayerDataController:Get("UnclaimedRewards") > 0
	self._buttons.Career.Visible = false
	self._buttons.Equipment.Visible = not isOpen
	self._buttons.Tasks.Visible = not isOpen
	self._buttons.Shop.Visible = not isOpen and statistic >= 3
	local battlePass = self._buttons.BattlePass
	local battlePassActive = not isOpen

	if battlePassActive then
		if statistic >= 10 then
			battlePassActive = SeasonLibrary.CurrentSeason.BattlePassActive
		else
			battlePassActive = false
		end
	end

	battlePass.Visible = battlePassActive
	local rewards = self._buttons.Rewards
	local visible = not isOpen

	if visible then
		if statistic >= 5 then
			visible = statistic < 15
		else
			visible = false
		end
	end

	rewards.Visible = visible
	self._buttons.Recover.Visible = not isOpen and #PlayerDataController:Get("StoredStreaks") > 0
	self._buttons.EventOverview.Visible = not isOpen and EventLibrary.IS_ACTIVE and EventLibrary.NUM_GAMES_NEEDED_TO_PARTICIPATE <= statistic
	self._buttons.EquipmentExit.Visible = isOpen and isOpenEffectDone and v4
	self._buttons.Contracts.Visible = false
	self._buttons.Skins.Visible = isOpen and isOpenEffectDone and v3 and v4
	self._buttons.Wraps.Visible = isOpen and isOpenEffectDone and v3 and v4
	self._buttons.Charms.Visible = isOpen and isOpenEffectDone and v3 and v4
	self._buttons.Finishers.Visible = isOpen and isOpenEffectDone and v3 and v4 and ItemLibrary.Items[selectedWeapon] and ItemLibrary.Items[selectedWeapon].CanEliminate
	self._buttons.Emotes.Visible = isOpen and isOpenEffectDone and v2 and v4
	self._buttons.Maps.Visible = false
	self._buttons.DuelHistory.Visible = false
	self._buttons.Collection.Visible = false
	self._buttons.Settings.Visible = not (isOpen or self._buttons.Recover.Visible)
	self:_UpdateButtonInformation()
	self:_PlayButtonVisibilityEffect()
	self:_Unhover()
end

function class:_CreateButton(layoutOrder, value, text, value2, value3, inputName)
	local clone = lobbyButtonSlot:Clone()
	clone.Button.Container.Title.Text = text
	clone.Button.Container.Icon.Image = value3 or ""
	clone.Button.Container.Bubble.Title.Text = value2 or ""
	clone.Button.Inputs.Gamepad.Keybind:SetAttribute("InputName", inputName)
	clone.LayoutOrder = layoutOrder
	local count = 0

	local function open()
		if clone.Button.Container.NotificationBubble.Visible then
			return
		end

		count += 1
		local v2 = count
		local isDescendant = clone:IsDescendantOf(Players)

		if isDescendant then
			clone.Button.Container:TweenPosition(UDim2.new(0.5, 0, 0.375, 0), "Out", "Quint", 0.25, true)
		else
			clone.Button.Container.Position = UDim2.new(0.5, 0, 0.375, 0)
		end

		if value2 then
			clone.Button.Container.Bubble.Visible = true
			clone.Button.Container.Bubble.Position = UDim2.new(0.5, 0, 0, 0)

			if isDescendant then
				clone.Button.Container.Bubble.Size = UDim2.new(0, 0, 0.125, 0)
				clone.Button.Container.Bubble:TweenSize(UDim2.new(5, 0, 0.25, 0), "Out", "Quint", 0.25, true)
			else
				clone.Button.Container.Bubble.Size = UDim2.new(5, 0, 0.25, 0)
			end

			task.spawn(function()
				wait(1)

				while v2 == count do
					if clone:IsDescendantOf(Players) then
						clone.Button.Container.Bubble:TweenPosition(
							UDim2.new(0.5, 0, -0.125, 0),
							"Out",
							"Sine",
							0.5,
							true
						)
					end

					wait(0.5)

					if v2 ~= count then
						break
					end

					if clone:IsDescendantOf(Players) then
						clone.Button.Container.Bubble:TweenPosition(UDim2.new(0.5, 0, 0, 0), "In", "Sine", 0.5, true)
					end

					wait(0.5)
				end
			end)
		end
	end

	clone.Button.MouseEnter:Connect(open)

	if value == "Tasks" and PlayerDataController:Get("BeginnerTasksCompleted") < TaskLibrary.NUM_BEGINNER_TASKS then
		open()
	end

	if value == "Shop" then
		clone.Button.Container.NotificationBubble.Title.Text = "Claim your FREE reward now!"
		local v2 = false
		clone.Button.MouseButton1Click:Connect(function()
			v2 = true
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function notification_bubble()
			clone.Button.Container.NotificationBubble.Visible = not (v2 or Pages.PageSystem.CurrentPage) and not PlayerDataController:Get("ClaimedLoginRewardToday") and PlayerDataController:GetStatistic("StatisticDuelsPlayed") > 3
		end

		PlayerDataController:GetDataChangedSignal("ClaimedLoginRewardToday"):Connect(notification_bubble)
		PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(notification_bubble)
		Pages.PageSystem.PageOpened:Connect(notification_bubble)
		Pages.PageSystem.PageClosed:Connect(notification_bubble)
		notification_bubble() -- equivalent call inferred; original call site unknown
	elseif value == "Backpack" then
		local count2 = #(PlayerDataController:Get("UnclaimedRewards") or {})
		local total = 0
		PlayerDataController:GetDataChangedSignal("UnclaimedRewards"):Connect(function()
			local count3 = #(PlayerDataController:Get("UnclaimedRewards") or {})
			total += math.max(0, count3 - count2)
			count2 = count3
			clone.Button.Container.Notification.Visible = total > 0
			clone.Button.Container.Notification.Title.Text = total
		end)
		Pages.PageSystem.PageOpened:Connect(function()
			if Pages.PageSystem.CurrentPage.Name == "Backpack" then
				total = 0
				clone.Button.Container.Notification.Visible = false
			end
		end)
	elseif value == "Tasks" then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			local text2 = #PlayerDataController:Get("Tasks") - PlayerDataController:GetNumTasksCompleted()
			clone.Button.Container.Notification.Visible = text2 > 0
			clone.Button.Container.Notification.Title.Text = text2
		end

		PlayerDataController:GetDataChangedSignal("BonusTasks"):Connect(update)
		PlayerDataController:GetDataChangedSignal("Tasks"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	elseif value == "BattlePass" then
		local function update()
			local v2 = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
			local battlePass = v2 and v2.BattlePass
			local v3 = not battlePass and 0 or battlePass.PassLevel or 0
			local v4 = not battlePass and 0 or battlePass.MaxPassTrackNum or 0
			local count2 = 0

			for i = 1, v3 do
				for i2 = 1, v4 do
					if not (SeasonLibrary.CurrentSeason.BattlePassRewards[i] and SeasonLibrary.CurrentSeason.BattlePassRewards[i][i2]) then
						continue
					end

					local v5

					if i <= v3 then
						v5 = i2 <= v4
					else
						v5 = false
					end

					local v6 = battlePass and battlePass.RewardsClaimed[tostring(i)] and battlePass.RewardsClaimed[tostring(i)][tostring(i2)]

					if not v5 or v6 then
						continue
					end

					count2 += 1
				end
			end

			clone.Button.Container.Notification.Visible = count2 > 0
			clone.Button.Container.Notification.Title.Text = count2
		end

		PlayerDataController:GetDataChangedSignal("Seasons"):Connect(update)
		update()
	elseif value == "Equipment" or value == "Skins" or value == "Wraps" or value == "Charms" or value == "Finishers" or value == "Emotes" then
		local function update_cosmetic_notifications()
			local cosmeticNotifications = PlayerDataController:Get("CosmeticNotifications")
			local unlockedWeapons = PlayerDataController:GetUnlockedWeapons(true)
			local selectedWeapon = Equipment:GetSelectedWeapon()
			local text2

			if value == "Equipment" then
				text2 = CosmeticLibrary:CountNotifications(cosmeticNotifications, nil, unlockedWeapons)
			else
				text2 = CosmeticLibrary:CountNotificationsByCosmeticType(
					cosmeticNotifications,
					string.sub(value, 1, #value - 1),
					selectedWeapon,
					unlockedWeapons
				)
			end

			clone.Button.Container.Notification.Visible = text2 > 0
			clone.Button.Container.Notification.Title.Text = text2
		end

		PlayerDataController:GetDataChangedSignal("CosmeticNotifications"):Connect(update_cosmetic_notifications)
		PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(update_cosmetic_notifications)
		Equipment.SelectedWeaponChanged:Connect(update_cosmetic_notifications)
		update_cosmetic_notifications()
	end

	if value == "Equipment" then
		local function notification_bubble()
			if Pages.PageSystem.CurrentPage then
				clone.Button.Container.NotificationBubble.Visible = false
				return
			end

			local unlockTokens = PlayerDataController:Get("UnlockTokens")
			local v2

			if unlockTokens then
				if unlockTokens > 0 then
					v2 = not PlayerDataController:OwnsAllWeapons("Standard", true, true)
				else
					v2 = false
				end
			else
				v2 = unlockTokens
			end

			local count2 = 0

			for k in pairs(PlayerDataController:Get("FreeWeaponUnlockCheck")) do
				if PlayerDataController:GetWeaponData(k) then
					continue
				end

				count2 += 1

				if count2 >= 2 then
					break
				end
			end

			clone.Button.Container.NotificationBubble.Visible = count2 > 0 or v2
			clone.Button.Container.NotificationBubble.Title.Text = count2 > 1 and "Unlock your new weapons now!" or count2 == 1 and "Unlock your new weapon now!" or not v2 and "" or "You have " .. unlockTokens .. " free weapon unlock" .. (unlockTokens == 1 and "" or "s") .. "!" or ""
		end

		PlayerDataController:GetDataChangedSignal("FreeWeaponUnlockCheck"):Connect(notification_bubble)
		PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(notification_bubble)
		PlayerDataController:GetDataChangedSignal("UnlockTokens"):Connect(notification_bubble)
		Pages.PageSystem.PageOpened:Connect(notification_bubble)
		Pages.PageSystem.PageClosed:Connect(notification_bubble)
		notification_bubble()
	end

	self._unhover_functions[value] = function()
		count += 1
		clone.Button.Container:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 0.25, true)
		clone.Button.Container.Bubble.Visible = false
	end

	clone.Button.MouseLeave:Connect(self._unhover_functions[value])
	clone.Visible = false
	clone.Parent = self.Frame.Container.List
	self._buttons[value] = clone
	ButtonEffect:Add(clone.Button)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update_background()
		clone.Button.Container.Bubble.Background.Size = UDim2.new(
			0,
			clone.Button.Container.Bubble.Title.TextBounds.X + clone.Button.Container.Bubble.Background.AbsoluteSize.Y,
			1,
			0
		)
	end

	clone.Button.Container.Bubble.Title:GetPropertyChangedSignal("TextBounds"):Connect(update_background)
	clone.Button.Container.Bubble.Background:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_background)
	update_background() -- equivalent call inferred; original call site unknown
end

function class:_OnButtonClicked(p2, onMouseButton1Click)
	self._buttons[p2].Button.MouseButton1Click:Connect(onMouseButton1Click)
	self._button_callbacks[p2] = onMouseButton1Click
end

function class:_Setup()
	for k, list in pairs(v) do
		self:_CreateButton(k, table.unpack(list))
	end

	self:_OnButtonClicked("Career", function()
		Pages.PageSystem:CloseCurrentPage()
		Equipment:Open()
		Equipment:OpenCareerPage(true)
	end)
	self:_OnButtonClicked("Equipment", function()
		Pages.PageSystem:CloseCurrentPage()
		Equipment:Open()

		if Equipment:IsCareerPageOpen() then
			Equipment:SelectWeapon(CONSTANTS.DEFAULT_WEAPONS[1])
		end
	end)
	self:_OnButtonClicked("EquipmentExit", function()
		Equipment:CloseRequest()
	end)
	self:_OnButtonClicked("Tasks", function()
		Pages.PageSystem:OpenPage("Tasks")
	end)
	self:_OnButtonClicked("Settings", function()
		Pages.PageSystem:OpenPage("Settings")
	end)
	self:_OnButtonClicked("Charms", function()
		Equipment:StartCustomizing("Charm")
	end)
	self:_OnButtonClicked("Finishers", function()
		Equipment:StartCustomizing("Finisher")
	end)
	self:_OnButtonClicked("Wraps", function()
		Equipment:StartCustomizing("Wrap")
	end)
	self:_OnButtonClicked("Skins", function()
		Equipment:StartCustomizing("Skin")
	end)
	self:_OnButtonClicked("Contracts", function()
		Pages.PageSystem:OpenPage("Contracts")
		Pages.PageSystem:WaitForPage("Contracts"):SetWeapon(Equipment:GetSelectedWeapon())
	end)
	self:_OnButtonClicked("Shop", function()
		Pages.PageSystem:OpenPage("Shop")
		Pages.PageSystem:WaitForPage("Shop"):SetPage("Home")
	end)
	self:_OnButtonClicked("Rewards", function()
		Pages.PageSystem:OpenPage("Rewards")
	end)
	self:_OnButtonClicked("Backpack", function()
		Pages.PageSystem:OpenPage("Backpack")
	end)
	self:_OnButtonClicked("Collection", function()
		Pages.PageSystem:OpenPage("Collection")
	end)
	self:_OnButtonClicked("Recover", function()
		Pages.PageSystem:OpenPage("StreakRecovery")
	end)
	self:_OnButtonClicked("EventOverview", function()
		Pages.PageSystem:OpenPage("EventOverview")
	end)
	self:_OnButtonClicked("DuelHistory", function()
		Pages.PageSystem:OpenPage("DuelHistory")
	end)
	self:_OnButtonClicked("Maps", function()
		Pages.PageSystem:OpenPage("Maps")
	end)
	self:_OnButtonClicked("Emotes", function()
		Equipment:StartCustomizing("Emote")
	end)
	self:_OnButtonClicked("BattlePass", function()
		Pages.PageSystem:OpenPage("BattlePass")
	end)
	self._buttons.Career.Button.Container.Icon.Image = string.format(
		CONSTANTS.HEADSHOT_IMAGE,
		Players.LocalPlayer.UserId
	)
	self._buttons.Equipment.Button.Container.Icon.Image = ItemLibrary.ViewModels["Assault Rifle"].Image
	self._buttons.Equipment.Button.Container.Icon.Size = UDim2.new(1.875, 0, 1.875, 0)
	self._buttons.EventOverview.Button.Container.Icon.Image = EventLibrary.EVENT_DETAILS.OVERVIEW_BUTTON_IMAGE
	self._buttons.EventOverview.Button.Container.Icon.Size = UDim2.new(1, 0, 1, 0)
	self._buttons.BattlePass.Button.Container.Icon.Position = UDim2.new(0.55, 0, 0.5, 0)
	self._buttons.BattlePass.Button.Container.Icon.Size = UDim2.new(0.875, 0, 0.875, 0)
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = self._buttons.Career.Button.Container.Icon
	local clone = uICorner:Clone()
	clone.Parent = self._buttons.Finishers.Button.Container.Icon
end

function class:_Init()
	self.Frame.Container.List.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Frame.Container.Background.Visible = self.Frame.Container.List.Layout.AbsoluteContentSize.X > 0
		self.Frame.Container.Background.Size = UDim2.new(
			0.5,
			self.Frame.Container.List.Layout.AbsoluteContentSize.X,
			0.5,
			0
		)
	end)
	Equipment.Opened:Connect(function()
		self:_UpdateButtonVisibility()
	end)
	Equipment.SelectedWeaponChanged:Connect(function()
		self:_UpdateButtonVisibility()
	end)
	Equipment.CareerPageOpened:Connect(function()
		self:_UpdateButtonVisibility()
	end)
	Equipment.CustomizingChanged:Connect(function()
		self:_UpdateButtonVisibility()
	end)
	Equipment.FinishedOpenEffect:Connect(function()
		self:_UpdateButtonVisibility()
	end)
	Equipment.UnlockingChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageOpened:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageClosed:Connect(function()
		self:_UpdateVisibility()
	end)
	Queue.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	PlayerDataController:GetDataChangedSignal("Seasons"):Connect(function()
		self:_UpdateButtonInformation()
	end)
	PlayerDataController:GetDataChangedSignal("WeaponInventory"):Connect(function()
		self:_UpdateButtonInformation()
		self:_UpdateButtonVisibility()
	end)
	PlayerDataController:GetDataChangedSignal("UnclaimedRewards"):Connect(function()
		self:_UpdateButtonVisibility()
	end)
	PlayerDataController:GetDataChangedSignal("StoredStreaks"):Connect(function()
		self:_UpdateButtonVisibility()
	end)
	PlayerDataController:GetDataChangedSignal("StatisticDuelsPlayed"):Connect(function()
		self:_UpdateButtonVisibility()
	end)
	PlayerDataController:GetDataChangedSignal("StatisticDuelsWon"):Connect(function()
		self:_UpdateButtonVisibility()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateVisibility()
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not (self.IsOpen and self.Frame.Visible) then
			return
		end

		for _, v2 in pairs(v) do
			local v3 = v2[1]
			local v4 = v2[5]

			if not (v4 and self._buttons[v3].Visible and InputLibrary:InputIs(input, v4)) then
				continue
			end

			self._button_callbacks[v3]()
			break
		end
	end)
	self:_Setup()
	self:_UpdateButtonVisibility()
	self:_UpdateVisibility()
end

return class._new()