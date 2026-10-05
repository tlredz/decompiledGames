local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MonetizationController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local SeasonController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SeasonController"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local BundleSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BundleSlot"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local battlePassFooterSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("BattlePassFooterSlot")
local battlePassRewardSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("BattlePassRewardSlot")
local battlePassTrackSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("BattlePassTrackSlot")
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("TopRight"):WaitForChild("Close")
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.BackgroundFrame = self.PageFrame:WaitForChild("Background")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.RewardsFrame = self.Container:WaitForChild("Rewards")
	self.TracksFrame = self.RewardsFrame:WaitForChild("Tracks")
	self.FooterFrame = self.TracksFrame:WaitForChild("Footer")
	self.FooterBackground = self.FooterFrame:WaitForChild("Background")
	self.FooterSlotsFrame = self.FooterFrame:WaitForChild("Slots")
	self.FooterSlotsLayout = self.FooterSlotsFrame:WaitForChild("Layout")
	self.HeaderFrame = self.TracksFrame:WaitForChild("Header")
	self.HeaderContainer = self.HeaderFrame:WaitForChild("Container")
	self.HeaderLevelText = self.HeaderContainer:WaitForChild("Value")
	self.HeaderXPFrame = self.HeaderContainer:WaitForChild("XP")
	self.HeaderXPBarFrame = self.HeaderXPFrame:WaitForChild("Bar")
	self.HeaderNextLevelText = self.HeaderXPBarFrame:WaitForChild("NextLevel")
	self.HeaderXPBarContainer = self.HeaderXPBarFrame:WaitForChild("Container")
	self.HeaderBubbleFrame = self.HeaderContainer:WaitForChild("Bubble")
	self.HeaderBubbleArrow = self.HeaderBubbleFrame:WaitForChild("Arrow")
	self.HeaderBubbleTitle = self.HeaderBubbleFrame:WaitForChild("Title")
	self.HeaderBubbleBackground = self.HeaderBubbleFrame:WaitForChild("Background")
	self.NextButton = self.HeaderContainer:WaitForChild("Next")
	self.NextBackground = self.NextButton:WaitForChild("Background")
	self.NextIcon = self.NextButton:WaitForChild("Icon")
	self.PreviousButton = self.HeaderContainer:WaitForChild("Previous")
	self.PreviousBackground = self.PreviousButton:WaitForChild("Background")
	self.PreviousIcon = self.PreviousButton:WaitForChild("Icon")
	self.PreviewFrame = self.Container:WaitForChild("Preview")
	self.PreviewContainer = self.PreviewFrame:WaitForChild("Container")
	self.PreviewRewardContainer = self.PreviewContainer:WaitForChild("RewardContainer")
	self.PreviewDetailsFrame = self.PreviewFrame:WaitForChild("Details")
	self.PreviewDetailsClaimed = self.PreviewDetailsFrame:WaitForChild("Claimed")
	self.PreviewDetailsTitle = self.PreviewDetailsFrame:WaitForChild("Title")
	self.PreviewDetailsDescription = self.PreviewDetailsFrame:WaitForChild("Description")
	self.PreviewUnlockFrame = self.PreviewFrame:WaitForChild("Unlock")
	self.PreviewUnlockContainer = self.PreviewUnlockFrame:WaitForChild("Container")
	self.PreviewUnlockDetailsFrame = self.PreviewUnlockContainer:WaitForChild("Details")
	self.PreviewUnlockTiersText = self.PreviewUnlockDetailsFrame:WaitForChild("Tiers")
	self.PreviewUnlockTitleText = self.PreviewUnlockDetailsFrame:WaitForChild("Title")
	self.PreviewUnlockButtonFrame = self.PreviewUnlockContainer:WaitForChild("Buy")
	self.PreviewUnlockButton = self.PreviewUnlockButtonFrame:WaitForChild("Button")
	self.PreviewUnlockButtonTitle = self.PreviewUnlockButton:WaitForChild("Title")
	self.PreviewUnlockViewContentsFrame = self.PreviewUnlockContainer:WaitForChild("ViewContents")
	self.PreviewUnlockViewContentsButton = self.PreviewUnlockViewContentsFrame:WaitForChild("Button")
	self.PreviewUnlockClaimFrame = self.PreviewUnlockContainer:WaitForChild("Claim")
	self.PreviewUnlockClaimButton = self.PreviewUnlockClaimFrame:WaitForChild("Button")
	self.BundlesFrame = self.Container:WaitForChild("Bundles")
	self.PrimeSeasonBundleFrame = self.BundlesFrame:WaitForChild("primeseason_bundle")
	self.ContrabandSeasonBundleFrame = self.BundlesFrame:WaitForChild("contrabandseason_bundle")
	self.EndingSoonFrame = self.Container:WaitForChild("EndingSoon")
	self.EndingSoonTitle = self.EndingSoonFrame:WaitForChild("Title")
	self.HidePartyDisplay = true
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self.PrimeSeasonBundleSlot = BundleSlot.new("primeseason_bundle")
	self.ContrabandSeasonBundleSlot = BundleSlot.new("contrabandseason_bundle")
	self._open_animation_disabled = true
	self._current_page = 1
	self._footer_slots = {}
	self._track_slots = {}
	self._xp_slots = {}
	self._reward_slots = {}
	self._preview_data = nil
	self._scroll_delta = 0
	self._refreshed_input_tags = false
	self._completed_all_tasks_thread = nil
	self:_Init()
	return self
end

function object:InspectBundle(p2)
	self.PromptSystem:Open("InspectBundle", p2)
end

function object:UnlockNow()
	if not self._preview_data then
		return
	end

	local _GetUnlockNowProductInfo = self:_GetUnlockNowProductInfo(
		self._preview_data.Tier,
		self._preview_data.PassTrackNum
	)

	if _GetUnlockNowProductInfo then
		MonetizationController:PromptProductPurchase(_GetUnlockNowProductInfo.ProductID)
	end
end

function object:Preview(tier, passTrackNum)
	local rewardData = SeasonLibrary.CurrentSeason.BattlePassRewards[tier] and SeasonLibrary.CurrentSeason.BattlePassRewards[tier][passTrackNum]

	if self._preview_data and self._preview_data.RewardSlot then
		self._preview_data.RewardSlot:Destroy()
		self._preview_data.RewardSlot = nil
	end

	self._preview_data = nil
	self.PreviewDetailsTitle.Text = ""
	self.PreviewDetailsDescription.Text = ""
	WeaponStatusHandler:ClearStatusElements(self.PreviewDetailsTitle)
	WeaponStatusHandler:ClearStatusElements(self.PreviewDetailsDescription)
	WeaponStatusHandler:ClearStatusElements(self.PreviewUnlockTiersText)
	TweenService:Create(self.BackgroundFrame, tweenInfo, {
		BackgroundColor3 = (ItemLibrary.StatusByPassTrackNum[passTrackNum] or ItemLibrary.Statuses.Standard).Color
	}):Play()
	TweenService:Create(self.List, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		CanvasPosition = Vector2.zero
	}):Play()

	if rewardData and tier and passTrackNum then
		task.defer(self._SetPage, self, (math.ceil(tier / 7)))
		self._preview_data = {
			RewardData = rewardData,
			Tier = tier,
			PassTrackNum = passTrackNum,
			RewardSlot = nil
		}
		local v2 = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
		local battlePass = v2 and v2.BattlePass
		local v3 = not battlePass and 0 or battlePass.PassLevel or 0
		local v4 = not battlePass and 0 or battlePass.MaxPassTrackNum or 0
		local v5

		if tier <= v3 then
			v5 = passTrackNum <= v4
		else
			v5 = false
		end

		local visible = battlePass and battlePass.RewardsClaimed[tostring(tier)] and battlePass.RewardsClaimed[tostring(tier)][tostring(passTrackNum)]
		local _GetUnlockNowProductInfo = self:_GetUnlockNowProductInfo(tier, passTrackNum)
		local rewardSlot = RewardSlot.new(rewardData)
		rewardSlot:ZoomOutViewportFrame()
		rewardSlot:UseHighResolutionImage()
		rewardSlot:HideBackground()
		rewardSlot:HideWeaponVisual()
		rewardSlot:SetNameText("")
		rewardSlot:SetInteractable(false)
		rewardSlot.Frame.Parent = self.PreviewRewardContainer
		self._preview_data.RewardSlot = rewardSlot
		self.PreviewDetailsClaimed.Visible = visible
		self.PreviewDetailsTitle.Text = rewardSlot:GetRewardBubbleTitle()
		self.PreviewDetailsDescription.Text = rewardSlot:GetRewardBubbleDescription()

		if ItemLibrary.Items[rewardData.Name] then
			local status = ItemLibrary.Items[rewardData.Name].Status
			WeaponStatusHandler:ApplyItemStatusToText(self.PreviewDetailsTitle, status)
			WeaponStatusHandler:ApplyItemStatusToText(self.PreviewDetailsDescription, status)
		elseif ItemLibrary.Items[rewardData.Weapon] then
			WeaponStatusHandler:ApplyItemStatusToText(
				self.PreviewDetailsDescription,
				ItemLibrary.Items[rewardData.Weapon] and ItemLibrary.Items[rewardData.Weapon].Status
			)
		end

		self.PreviewUnlockClaimFrame.Visible = v5 and not visible
		self.PreviewUnlockButtonFrame.Visible = _GetUnlockNowProductInfo and not visible
		local previewUnlockTiersText = self.PreviewUnlockTiersText
		local text

		if _GetUnlockNowProductInfo and _GetUnlockNowProductInfo.BattlePassLevelIncrement then
			text = string.format(
				"+%s Level%s",
				Utility:PrettyNumber(_GetUnlockNowProductInfo.BattlePassLevelIncrement),
				_GetUnlockNowProductInfo.BattlePassLevelIncrement == 1 and "" or "s"
			)
		else
			text = not (_GetUnlockNowProductInfo and _GetUnlockNowProductInfo.BattlePassMaxPassTrackNum and _GetUnlockNowProductInfo.UnlockNowDisplayName) and "" or _GetUnlockNowProductInfo.UnlockNowDisplayName
		end

		previewUnlockTiersText.Text = text
		self.PreviewUnlockTitleText.Visible = self.PreviewUnlockTiersText.Text ~= ""
		self.PreviewUnlockViewContentsFrame.Visible = CosmeticLibrary.Rewards[rewardData.Name] and CosmeticLibrary.Rewards[rewardData.Name].Type == "Lootbox"

		if _GetUnlockNowProductInfo then
			MonetizationController:SetRobuxText(
				self.PreviewUnlockButtonTitle,
				_GetUnlockNowProductInfo.ProductID,
				Enum.InfoType.Product
			)

			if _GetUnlockNowProductInfo.BattlePassMaxPassTrackNum and _GetUnlockNowProductInfo.UnlockNowWeaponStatusUIEffect then
				WeaponStatusHandler:ApplyItemStatusToText(
					self.PreviewUnlockTiersText,
					_GetUnlockNowProductInfo.UnlockNowWeaponStatusUIEffect
				)
			end
		end

		local v9 = visible and 0.2 or 0
		self.PreviewDetailsTitle.Position = UDim2.new(0.5 + v9, 0, 0.775, 0)
		self.PreviewDetailsDescription.Position = UDim2.new(0.5 + v9, 0, 0.9, 0)
		rewardSlot.Frame.Position = UDim2.new(0.5, 0, 0.75, 0)
		self.PreviewDetailsTitle:TweenPosition(UDim2.new(0.15 + v9, 0, 0.775, 0), "Out", "Quint", 0.5, true)
		self.PreviewDetailsDescription:TweenPosition(UDim2.new(0.15 + v9, 0, 0.9, 0), "Out", "Quint", 0.625, true)
		rewardSlot.Frame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 0.375, true)
		self.PreviewFrame.Visible = true
		self.PreviewFrame:TweenSize(UDim2.new(1, 0, 0.3, 0), "Out", "Quint", 0.25, true)
	else
		self.PreviewFrame.Visible = false
		self.PreviewFrame.Size = UDim2.new(1, 0, 0, 0)
	end
end

function object:Open(...)
	Page.Open(self, ...)
	table.insert(self._open_connections, PlayerDataController:GetDataChangedSignal("Seasons"):Connect(function()
		self:_Update()

		if self._preview_data then
			self:Preview(self._preview_data.Tier, self._preview_data.PassTrackNum)
		end
	end))
	table.insert(self._open_connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.ButtonL1 then
			self:_SetPage(self._current_page - 1)
		elseif input.KeyCode == Enum.KeyCode.ButtonR1 then
			self:_SetPage(self._current_page + 1)
		end
	end))
	table.insert(self._open_connections, UserInputService.InputChanged:Connect(function(_, _) end))
	table.insert(self._open_threads, task.spawn(function()
		while true do
			self:_UpdateEndingSoon()
			wait(1)
		end
	end))

	if not self._refreshed_input_tags then
		self._refreshed_input_tags = true

		for _, parent in pairs({ self.NextButton, self.PreviousButton }) do
			local inputs = parent:WaitForChild("Inputs")
			inputs.Parent = nil
			inputs.Parent = parent
		end
	end

	self.PrimeSeasonBundleSlot.Frame.Position = UDim2.new(0.5, 0, 4, 0)
	self.ContrabandSeasonBundleSlot.Frame.Position = UDim2.new(0.5, 0, 4, 0)
	self.PrimeSeasonBundleSlot.Frame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 1, true)
	self.ContrabandSeasonBundleSlot.Frame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 1.5, true)
	local v = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local battlePass = v and v.BattlePass
	local v2 = math.ceil((battlePass and battlePass.PassLevel or 0) / 7)
	self:Preview(nil)
	self:_SetPage(v2)
	self:_Update()
end

function object:Close(...)
	self:_Clear()
	Page.Close(self, ...)
end

function object:_UpdateEndingSoon()
	self.EndingSoonFrame.Visible = SeasonController:GetTimeRemaining() ~= nil
	self.EndingSoonTitle.Text = (SeasonController:GetCountdownText() or "") .. " — Complete the Season Pass and collect your rewards before they're gone forever!"
end

function object:_UpdateVisuals()
	local v = self.HeaderXPBarContainer.AbsolutePosition.X + self.HeaderXPBarContainer.AbsoluteSize.X - self.HeaderBubbleFrame.AbsolutePosition.X
	local v2 = math.min(
		math.abs(v),
		self.HeaderBubbleFrame.AbsoluteSize.X / 2 - self.HeaderBubbleArrow.AbsoluteSize.X - 8
	) * math.sign(v)
	self.HeaderBubbleArrow.Position = UDim2.new(0, v2, 1, -2)
	self.HeaderBubbleBackground.Size = UDim2.new(0.05, self.HeaderBubbleTitle.TextBounds.X, 1, 0)
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	self.FooterBackground.Size = UDim2.new(
		0,
		(self.FooterSlotsLayout.AbsoluteContentSize.X + self.FooterSlotsLayout.Padding.Scale * self.FooterSlotsFrame.AbsoluteSize.X) * 1.00878,
		1,
		0
	)
end

function object:_UpdateListVisibility()
	self.List.Visible = not self.PromptSystem.CurrentPrompt
end

function object:_GetUnlockNowProductInfo(p, p2)
	local v = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local battlePass = v and v.BattlePass

	if (not battlePass and 0 or battlePass.MaxPassTrackNum or 0) < p2 then
		return MonetizationLibrary.Bundles.primeseason_bundle
	end

	local v2 = p - (battlePass and battlePass.PassLevel or 0)

	if not (v2 > 0) then
		return
	end

	for _, v3 in pairs(MonetizationLibrary.BATTLE_PASS_LEVELS) do
		local product = MonetizationLibrary.Products[v3]

		if v2 <= product.BattlePassLevelIncrement then
			return product
		end
	end

	return nil
end

function object:_GetMaxPage()
	return (math.ceil(SeasonLibrary.CurrentSeason.NumBattlePassTiers / 7))
end

function object:_SetPage(value)
	local _current_page = self._current_page
	self._current_page = math.clamp(value, 1, (self:_GetMaxPage()))

	if _current_page == self._current_page then
		return
	end

	local v = math.sign(self._current_page - _current_page)

	if v == 0 then
		v = nil
	end

	self:_Update(v)
end

function object:_Clear()
	for _, _reward_slot in pairs(self._reward_slots) do
		_reward_slot:Destroy()
	end

	for _, _track_slot in pairs(self._track_slots) do
		_track_slot:Destroy()
	end

	for _, _footer_slot in pairs(self._footer_slots) do
		_footer_slot:Destroy()
	end

	for _, _xp_slot in pairs(self._xp_slots) do
		_xp_slot:Destroy()
	end

	self._reward_slots = {}
	self._track_slots = {}
	self._footer_slots = {}
	self._xp_slots = {}

	if self._completed_all_tasks_thread then
		task.cancel(self._completed_all_tasks_thread)
		self._completed_all_tasks_thread = nil
	end
end

function object:_Update(p)
	self:_Clear()

	for i = 1, SeasonLibrary.CurrentSeason.NumBattlePassTracks do
		local clone = battlePassTrackSlot:Clone()
		clone.Side.Background.ImageColor3 = ItemLibrary.StatusByPassTrackNum[i].PassColor
		clone.Side["Icon" .. i].Visible = true
		clone.LayoutOrder = i
		clone.Parent = self.TracksFrame
		self._track_slots[i] = clone
	end

	local v = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local battlePass = v and v.BattlePass
	local text = not battlePass and 0 or battlePass.PassLevel or 0
	local v3 = not battlePass and 0 or battlePass.MaxPassTrackNum or 0
	self.HeaderLevelText.Text = text
	self.HeaderNextLevelText.Text = "Level " .. text + 1
	local v4 = false

	for i = 1, 7 do
		local text2 = (self._current_page - 1) * 7 + i

		if SeasonLibrary.CurrentSeason.NumBattlePassTiers < text2 then
			continue
		end

		local v6 = text2 <= text
		local clone = battlePassFooterSlot:Clone()
		clone.Tier.Text = text2
		clone.LayoutOrder = i
		clone.Bar.BackgroundColor3 = v6 and Color3.fromRGB(100, 255, 50) or Color3.fromRGB(255, 255, 255)
		clone.Bar.BackgroundTransparency = v6 and 0 or 0.75
		clone.Parent = self.FooterSlotsFrame
		table.insert(self._footer_slots, clone)

		for i2 = 1, SeasonLibrary.CurrentSeason.NumBattlePassTracks do
			local v7 = SeasonLibrary.CurrentSeason.BattlePassRewards[text2] and SeasonLibrary.CurrentSeason.BattlePassRewards[text2][i2]
			local v8 = ItemLibrary.StatusByPassTrackNum[i2]
			local v9 = battlePass and battlePass.RewardsClaimed[tostring(text2)] and battlePass.RewardsClaimed[tostring(text2)][tostring(i2)]
			local visible = v9 or v6 and i2 <= v3
			local clone2 = battlePassRewardSlot:Clone()
			clone2.Container.Claimed.Visible = visible
			clone2.Container.Unclaimed.Visible = not visible
			clone2.Container.Unclaimed.Status.ImageColor3 = v8.PassColor
			clone2.Container.Unclaimed.Background.ImageColor3 = v8.DarkPassColor
			clone2.Container.Claimed.Status.ImageColor3 = v8.DarkPassColor
			clone2.Container.Claimed.Claimed.Visible = v9 and v7
			clone2.Container.Claimed.Background.ImageColor3 = v8.DarkPassColor
			clone2.Container.Claimed.Container.GroupTransparency = v9 and 0.75 or 0
			clone2.Container.Claimed.ClaimNowBubble.Visible = v7 and not v9
			clone2.LayoutOrder = i
			clone2.Parent = self._track_slots[i2]

			if v7 then
				local v11 = RewardSlot.new(v7)
				v11.Frame.Parent = visible and clone2.Container.Claimed.Container or clone2.Container.Unclaimed.Container
				table.insert(self._reward_slots, v11)
				local text3 = text2
				local v13 = i2
				v11:OnClick(function()
					self:Preview(text3, v13)
				end)
				local v14 = (v7.Quantity or 1) == 1
				local cosmetic = CosmeticLibrary.Cosmetics[v7.Name]
				local item = ItemLibrary.Items[v7.Name]
				local v15 = CosmeticLibrary.Rewards[v7.Name] and CosmeticLibrary.Rewards[v7.Name].Type == "Currency"

				if v14 and not (cosmetic or item or v15) then
					v11:SetNameText("")
				end
			end

			if p then
				local v11 = (i + i2 - 1) / 7

				if p < 0 then
					v11 = 1 - v11
				end

				clone2.Container.Position = UDim2.new(0.5 + 0.5 * p, 0, 0.5, 0)
				clone2.Container:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", v11 * 0.5 + 0.25, true)
			end

			if v4 or i2 ~= 1 or not v7 then
				continue
			end

			v4 = true
		end
	end

	local v5 = not battlePass and 0 or battlePass.NumPassTasksCompleted or 0
	local v6 = not (battlePass and battlePass.PassTaskProgress) and 0 or battlePass.PassTaskProgress.RoundsWon or 0
	local playtime = battlePass and battlePass.PassTaskProgress and battlePass.PassTaskProgress.Playtime or 0
	local v7 = SeasonLibrary:GetCurrentSeasonWeek() * SeasonLibrary.CurrentSeason.BattlePassTasksPerWeek <= v5
	local v8 = math.max(
		v6 / SeasonLibrary.CurrentSeason.BattlePassTaskRequirements.RoundsWon,
		playtime / SeasonLibrary.CurrentSeason.BattlePassTaskRequirements.Playtime
	)
	self.HeaderXPBarContainer.Size = UDim2.new(math.clamp(v8, 0, 1), 0, 1, 0)

	local function update_bubble_title()
		if v7 then
			self.HeaderBubbleTitle.Text = string.format(
				"All done! You can level up again in <font transparency=\"0\" weight=\"800\">%s</font>",
				Utility:TimeFormat2((math.ceil((SeasonLibrary:GetTimeUntilNextSeasonWeek()))))
			)
			return
		end

		local v9 = string.format("%.1f", playtime / 60)
		self.HeaderBubbleTitle.Text = string.format(
			"Win (<font transparency=\"0\" weight=\"800\">%s</font> / %s) rounds in duels or play for (<font transparency=\"0\" weight=\"800\">%s</font> / %s) minutes to level up",
			v6,
			SeasonLibrary.CurrentSeason.BattlePassTaskRequirements.RoundsWon,
			v9 == "0.0" and "0" or v9,
			string.format("%.0f", SeasonLibrary.CurrentSeason.BattlePassTaskRequirements.Playtime / 60)
		)
	end

	update_bubble_title()

	if v7 then
		self._completed_all_tasks_thread = task.spawn(function()
			while true do
				wait(1)
				update_bubble_title()
			end
		end)
	end

	local v9 = self._current_page < self:_GetMaxPage()
	local v10 = self._current_page > 1
	self.NextBackground.BackgroundTransparency = v9 and 0 or 0.75
	self.NextIcon.ImageTransparency = v9 and 0 or 0.75
	self.PreviousBackground.BackgroundTransparency = v10 and 0 or 0.75
	self.PreviousIcon.ImageTransparency = v10 and 0 or 0.75
end

function object:_Setup()
	self.PrimeSeasonBundleSlot:SetParent(self.PrimeSeasonBundleFrame)
	self.ContrabandSeasonBundleSlot:SetParent(self.ContrabandSeasonBundleFrame)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.PromptSystem.PromptAdded:Connect(function()
		self:_UpdateListVisibility()
	end)
	self.PromptSystem.PromptRemoved:Connect(function()
		self:_UpdateListVisibility()
	end)
	self.NextButton.MouseButton1Click:Connect(function()
		self:_SetPage(self._current_page + 1)
	end)
	self.PreviousButton.MouseButton1Click:Connect(function()
		self:_SetPage(self._current_page - 1)
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateVisuals()
	end)
	self.FooterSlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateVisuals()
	end)
	self.HeaderBubbleTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateVisuals()
	end)
	self.HeaderXPBarContainer:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateVisuals()
	end)
	self.HeaderXPBarContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateVisuals()
	end)
	self.HeaderBubbleFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateVisuals()
	end)
	self.HeaderBubbleFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateVisuals()
	end)
	self.HeaderBubbleArrow:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateVisuals()
	end)
	self.PreviewUnlockClaimButton.MouseButton1Click:Connect(function()
		ReplicatedStorage.Remotes.Data.ClaimBattlePassReward:FireServer(
			self._preview_data.Tier,
			self._preview_data.PassTrackNum
		)
	end)
	self.PreviewUnlockButton.MouseButton1Click:Connect(function()
		self:UnlockNow()
	end)
	self.PreviewUnlockViewContentsButton.MouseButton1Click:Connect(function()
		self.PromptSystem:Open(
			"InspectLootbox",
			self._preview_data.RewardData.Name,
			self._preview_data.RewardData.Weapon
		)
	end)
	self.PrimeSeasonBundleSlot.Tapped:Connect(function()
		if ControlsController.CurrentControls == "Touch" then
			self:InspectBundle(self.PrimeSeasonBundleSlot.Name)
		else
			self.PrimeSeasonBundleSlot:PurchaseRequest()
		end
	end)
	self.ContrabandSeasonBundleSlot.Tapped:Connect(function()
		if ControlsController.CurrentControls == "Touch" then
			self:InspectBundle(self.ContrabandSeasonBundleSlot.Name)
		else
			self.ContrabandSeasonBundleSlot:PurchaseRequest()
		end
	end)
	self:_Setup()
	self:_UpdateVisuals()
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.NextButton)
	ButtonEffect:Add(self.PreviousButton)
	ButtonEffect:Add(self.PreviewUnlockButton)
	ButtonEffect:Add(self.PreviewUnlockClaimButton)
	ButtonEffect:Add(self.PreviewUnlockViewContentsButton)
end

return object._new()