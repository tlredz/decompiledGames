local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("GuiService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local MonetizationLibrary = require(ReplicatedStorage.Modules.MonetizationLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local MonetizationController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MonetizationController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local PromptSystem = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PromptSystem"))
local DropdownSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("DropdownSlot"))
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RewardSlot"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local giftPlayerEmptySlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("GiftPlayerEmptySlot")
local giftProductSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("GiftProductSlot")
local giftPlayerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("GiftPlayerSlot")
local v = {
	"None",
	"Enjoy!",
	"Thanks!",
	"Surprise!",
	"I appreciate you!",
	"You're the best!",
	"Thanks for everything!",
	"You played well!",
	"You owe me!",
	"Happy birthday!",
	"Merry Christmas!",
	"Happy holidays!",
	"Congratulations!",
	"Custom"
}
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.PromptsFrame = self.PageFrame:WaitForChild("Prompts")
	self.BackButton = self.PageFrame:WaitForChild("Back")
	self.Container = self.PageFrame:WaitForChild("Container")
	self.SelectPlayerFrame = self.Container:WaitForChild("SelectPlayer")
	self.PlayersList = self.SelectPlayerFrame:WaitForChild("List")
	self.PlayersContainer = self.PlayersList:WaitForChild("Container")
	self.PlayersLayout = self.PlayersContainer:WaitForChild("Layout")
	self.PlayersGiftRewardFrame = self.PlayersContainer:WaitForChild("GiftReward")
	self.PlayersGiftRewardProgressBar = self.PlayersGiftRewardFrame:WaitForChild("Progress"):WaitForChild("Bar")
	self.PlayersGiftRewardContainer = self.PlayersGiftRewardFrame:WaitForChild("Container")
	self.PlayersGiftRewardGoalText = self.PlayersGiftRewardFrame:WaitForChild("Goal")
	self.PlayersOfflineGiftFrame = self.PlayersContainer:WaitForChild("OfflineGift")
	self.PlayersOfflineGiftBox = self.PlayersOfflineGiftFrame:WaitForChild("Input"):WaitForChild("Box")
	self.PlayersOfflineGiftButton = self.PlayersOfflineGiftFrame:WaitForChild("Button")
	self.PlayersOfflineGiftButtonOn = self.PlayersOfflineGiftButton:WaitForChild("On")
	self.PlayersOfflineGiftButtonOff = self.PlayersOfflineGiftButton:WaitForChild("Off")
	self.PlayersOfflineGiftButtonIcon = self.PlayersOfflineGiftButton:WaitForChild("Icon")
	self.PlayersOfflineGiftButtonCountdown = self.PlayersOfflineGiftButton:WaitForChild("Countdown")
	self.SelectProductFrame = self.Container:WaitForChild("SelectProduct")
	self.ProductsEmptyFrame = self.SelectProductFrame:WaitForChild("Empty")
	self.ProductsDotsFrame = self.SelectProductFrame:WaitForChild("Dots")
	self.ProductsList = self.SelectProductFrame:WaitForChild("List")
	self.ProductsContainer = self.ProductsList:WaitForChild("Container")
	self.ProductsLayout = self.ProductsContainer:WaitForChild("Layout")
	self.ProductsPlayerFrame = self.ProductsContainer:WaitForChild("Player")
	self.ProductsPlayerPicture = self.ProductsPlayerFrame:WaitForChild("Picture")
	self.ProductsPlayerUsernameText = self.ProductsPlayerFrame:WaitForChild("Username")
	self.ProductsPlayerDisplayNameText = self.ProductsPlayerFrame:WaitForChild("DisplayName")
	self.ConfirmPurchaseFrame = self.Container:WaitForChild("ConfirmPurchase")
	self.ConfirmPurchaseDotsFrame = self.ConfirmPurchaseFrame:WaitForChild("Dots")
	self.ConfirmPurchaseList = self.ConfirmPurchaseFrame:WaitForChild("List")
	self.ConfirmPurchaseContainer = self.ConfirmPurchaseList:WaitForChild("Container")
	self.ConfirmPurchaseLayout = self.ConfirmPurchaseContainer:WaitForChild("Layout")
	self.ConfirmPurchasePlayerFrame = self.ConfirmPurchaseContainer:WaitForChild("Player")
	self.ConfirmPurchasePlayerPicture = self.ConfirmPurchasePlayerFrame:WaitForChild("Picture")
	self.ConfirmPurchasePlayerUsernameText = self.ConfirmPurchasePlayerFrame:WaitForChild("Username")
	self.ConfirmPurchasePlayerDisplayNameText = self.ConfirmPurchasePlayerFrame:WaitForChild("DisplayName")
	self.ConfirmPurchaseProductFrame = self.ConfirmPurchaseContainer:WaitForChild("Product")
	self.ConfirmPurchaseProductIcon = self.ConfirmPurchaseProductFrame:WaitForChild("Icon")
	self.ConfirmPurchaseProductTitleText = self.ConfirmPurchaseProductFrame:WaitForChild("DisplayName")
	self.ConfirmPurchaseWarningsFrame = self.ConfirmPurchaseContainer:WaitForChild("Warnings")
	self.ConfirmPurchaseWarningsGiftTicketsFrame = self.ConfirmPurchaseWarningsFrame:WaitForChild("GiftTickets")
	self.ConfirmPurchaseWarningsGiftTicketsText = self.ConfirmPurchaseWarningsGiftTicketsFrame:WaitForChild("Icon"):WaitForChild("Quantity")
	self.ConfirmPurchaseWarningsOfflineGiftingFrame = self.ConfirmPurchaseWarningsFrame:WaitForChild("OfflineGifting")
	self.ConfirmPurchaseBuyFrame = self.ConfirmPurchaseContainer:WaitForChild("Buy")
	self.ConfirmPurchaseBuyButton = self.ConfirmPurchaseBuyFrame:WaitForChild("Button")
	self.ConfirmPurchaseBuyButtonGiftTicketIcon = self.ConfirmPurchaseBuyButton:WaitForChild("GiftTicket")
	self.ConfirmPurchaseBuyButtonRobuxPrice = self.ConfirmPurchaseBuyButton:WaitForChild("Robux")
	self.ConfirmPurchaseSettingsFrame = self.ConfirmPurchaseContainer:WaitForChild("Settings")
	self.ConfirmPurchaseSettingsContainer = self.ConfirmPurchaseSettingsFrame:WaitForChild("Container")
	self.ConfirmPurchaseSettingsLayout = self.ConfirmPurchaseSettingsContainer:WaitForChild("Layout")
	self.ConfirmPurchaseSettingsNoteFrame = self.ConfirmPurchaseSettingsContainer:WaitForChild("Note")
	self.ConfirmPurchaseSettingsNoteDropdownFrame = self.ConfirmPurchaseSettingsNoteFrame:WaitForChild("Dropdown")
	self.ConfirmPurchaseSettingsNoteDropdownButton = self.ConfirmPurchaseSettingsNoteDropdownFrame:WaitForChild("Button")
	self.ConfirmPurchaseSettingsNoteDropdownButtonTitle = self.ConfirmPurchaseSettingsNoteDropdownButton:WaitForChild("Title")
	self.ConfirmPurchaseSettingsCustomNoteFrame = self.ConfirmPurchaseSettingsContainer:WaitForChild("CustomNote")
	self.ConfirmPurchaseSettingsCustomNoteContainer = self.ConfirmPurchaseSettingsCustomNoteFrame:WaitForChild("Container")
	self.ConfirmPurchaseSettingsCustomNoteLockedFrame = self.ConfirmPurchaseSettingsCustomNoteContainer:WaitForChild("Locked")
	self.ConfirmPurchaseSettingsCustomNoteUnlockedFrame = self.ConfirmPurchaseSettingsCustomNoteContainer:WaitForChild("Unlocked")
	self.ConfirmPurchaseSettingsCustomNoteBox = self.ConfirmPurchaseSettingsCustomNoteUnlockedFrame:WaitForChild("Box")
	self.ConfirmPurchaseSettingsCustomNoteCount = self.ConfirmPurchaseSettingsCustomNoteUnlockedFrame:WaitForChild("Count")
	self.ConfirmPurchaseSettingsAnonymousFrame = self.ConfirmPurchaseSettingsContainer:WaitForChild("Anonymous")
	self.ConfirmPurchaseSettingsAnonymousTitle = self.ConfirmPurchaseSettingsAnonymousFrame:WaitForChild("Title")
	self.ConfirmPurchaseSettingsAnonymousButton = self.ConfirmPurchaseSettingsAnonymousFrame:WaitForChild("Button")
	self.ConfirmPurchaseSettingsAnonymousEmpty = self.ConfirmPurchaseSettingsAnonymousButton:WaitForChild("Empty")
	self.ConfirmPurchaseSettingsAnonymousFilled = self.ConfirmPurchaseSettingsAnonymousButton:WaitForChild("Filled")
	self.PromptSystem = PromptSystem.new(self.PromptsFrame)
	self._open_animation_disabled = true
	self._selected_player_input = nil
	self._selected_product_id = nil
	self._selected_player_lookup = nil
	self._player_slots = {}
	self._gift_slots = {}
	self._fetch_player_data_hash = 0
	self._generate_hash = 0
	self._dont_redirect = nil
	self:_Init()
	return self
end

function object:CloseRequest()
	if not self._dont_redirect then
		self.OpenPage:Fire("Shop", true)
		return
	end

	self._dont_redirect = nil
	Page.CloseRequest(self)
end

function object:Open(...)
	Page.Open(self, ...)
	self:SelectPlayer(nil)
	task.spawn(self._FetchGiftImages, self)
	task.spawn(self._GeneratePlayers, self)
end

function object:Close(...)
	self:SelectPlayer(nil)
	self:_StopNoteDropdown()
	Page.Close(self, ...)
end

function object:DontRedirect()
	self._dont_redirect = true
end

function object:SelectPlayer(player)
	local v2 = not player

	if not v2 then
		if typeof(player) == "string" then
			v2 = true
		elseif typeof(player) == "Instance" then
			v2 = player:IsA("Player")
		else
			v2 = false
		end
	end

	assert(v2, "Argument 1 invalid, expected a Player or string or nil, got " .. tostring(player))
	self._fetch_player_data_hash += 1
	self._selected_player_input = player
	self._selected_player_lookup = nil
	self:_UpdateFrameVisibility()

	if self._selected_player_input then
		task.spawn(self._FetchSelectedPlayerData, self)
	else
		self:SelectProduct(nil)
	end

	task.spawn(self._GeneratePlayers, self)
end

function object:SelectProduct(selected_product_id)
	assert(
		not selected_product_id or typeof(selected_product_id) == "number",
		"Argument 1 invalid, expected a number or nil, got " .. tostring(selected_product_id)
	)
	self._fetch_player_data_hash += 1
	self._selected_product_id = selected_product_id
	self:_UpdateFrameVisibility()
end

function object:ConfirmPurchase()
	if not (self._selected_player_input and self._selected_product_id) then
		return
	end

	self.ConfirmPurchaseList.Visible = false
	self.ConfirmPurchaseDotsFrame.Visible = true
	self.ConfirmPurchaseDotsFrame:AddTag("UILoadingDots")
	ReplicatedStorage.Remotes.Misc.PromptGiftProductPurchase:InvokeServer(
		self._selected_product_id,
		self._selected_player_lookup.UserID,
		self._selected_player_lookup.IsOfflineGift,
		self:_GetGiftNote(),
		self.ConfirmPurchaseSettingsAnonymousFilled.Visible
	)
	self.ConfirmPurchaseList.Visible = true
	self.ConfirmPurchaseDotsFrame.Visible = false
	self.ConfirmPurchaseDotsFrame:RemoveTag("UILoadingDots")
	self:SelectPlayer(nil)
end

function object:_StopNoteDropdown()
	if self._note_dropdown_slot then
		self._note_dropdown_slot:Cancel()
		self._note_dropdown_slot = nil
	end

	self.ConfirmPurchaseSettingsNoteDropdownButton.Visible = true
end

function object:_StartNoteDropdown()
	self:_StopNoteDropdown()
	self.ConfirmPurchaseSettingsNoteDropdownButton.Visible = false
	self._note_dropdown_slot = DropdownSlot.new(self.ConfirmPurchaseSettingsNoteDropdownFrame, v)
	self._note_dropdown_slot.Selected:Connect(function(text)
		if text then
			self.ConfirmPurchaseSettingsNoteDropdownButtonTitle.Text = text
		end

		self:_StopNoteDropdown()
	end)
end

function object:_GetGiftNote()
	local text = self.ConfirmPurchaseSettingsNoteDropdownButtonTitle.Text

	if text == "None" then
		return ""
	end

	if text ~= "Custom" then
		return text
	end

	if self.ConfirmPurchaseSettingsCustomNoteUnlockedFrame.Visible then
		return self.ConfirmPurchaseSettingsCustomNoteBox.Text
	end

	return ""
end

function object:_VerifyNote()
	self.ConfirmPurchaseSettingsCustomNoteBox.Text = MonetizationLibrary:SanitizeGiftNote(self.ConfirmPurchaseSettingsCustomNoteBox.Text) or ""
	self.ConfirmPurchaseSettingsCustomNoteCount.Text = #self.ConfirmPurchaseSettingsCustomNoteBox.Text .. " / " .. MonetizationLibrary.MAX_GIFTING_NOTE_CHARACTER_COUNT
	self.ConfirmPurchaseSettingsCustomNoteCount.TextColor3 = #self.ConfirmPurchaseSettingsCustomNoteBox.Text >= MonetizationLibrary.MAX_GIFTING_NOTE_CHARACTER_COUNT and Color3.fromRGB(
		255,
		50,
		50
	) or Color3.fromRGB(255, 255, 255)
	self.ConfirmPurchaseSettingsCustomNoteCount.TextTransparency = #self.ConfirmPurchaseSettingsCustomNoteBox.Text >= MonetizationLibrary.MAX_GIFTING_NOTE_CHARACTER_COUNT and 0 or 0.5
end

function object:_UpdateGiftReward()
	local giftRobuxSpentProgress = PlayerDataController:Get("GiftRobuxSpentProgress")
	local giftRewardRobuxSpentRequirement = MonetizationLibrary:GetGiftRewardRobuxSpentRequirement(PlayerDataController:Get("GiftRobuxSpentRewardsClaimed"))
	self.PlayersGiftRewardProgressBar.Size = UDim2.new(
		math.clamp(giftRobuxSpentProgress / giftRewardRobuxSpentRequirement, 0, 1),
		0,
		1,
		2
	)
	self.PlayersGiftRewardGoalText.Text = Utility:PrettyNumber(giftRobuxSpentProgress) .. " / " .. Utility:PrettyNumber(giftRewardRobuxSpentRequirement) .. " points"
end

function object._OfflineGiftingCooldown(p)
	p.PlayersOfflineGiftButtonCountdown.Visible = true
	p.PlayersOfflineGiftButtonIcon.Visible = false

	for i = 15, 1, -1 do
		p.PlayersOfflineGiftButtonCountdown.Text = i
		wait(1)
	end

	p.PlayersOfflineGiftButtonCountdown.Visible = false
	p.PlayersOfflineGiftButtonIcon.Visible = true
end

function object:_UpdateOfflineGiftingButton()
	local playersOfflineGiftButtonOn = self.PlayersOfflineGiftButtonOn
	local visible = self.PlayersOfflineGiftButtonIcon.Visible

	if visible then
		if self.PlayersOfflineGiftBox.Text == "" then
			visible = false
		else
			visible = string.lower(self.PlayersOfflineGiftBox.Text) ~= string.lower(Players.LocalPlayer.Name) or CONSTANTS.IS_STUDIO
		end
	end

	playersOfflineGiftButtonOn.Visible = visible
	self.PlayersOfflineGiftButtonOff.Visible = not self.PlayersOfflineGiftButtonOn.Visible
end

function object:_FetchGiftImages()
	for k, gift in pairs(MonetizationLibrary.Gifts) do
		if gift.ImageID then
			continue
		end

		local v2 = gift
		local v3 = k
		task.spawn(function()
			local success, productInfoAsync = pcall(
				MarketplaceService.GetProductInfoAsync,
				MarketplaceService,
				v2.ProductID,
				Enum.InfoType.Product
			)

			if v2.ImageID then
				return
			end

			if not success then
				warn("Failed to fetch gamepass info:", productInfoAsync)
				return
			end

			v2.ImageID = "rbxassetid://" .. productInfoAsync.IconImageAssetId
			self._gift_slots[v3].Slot.Icon.Image = v2.ImageID
		end)
	end
end

function object:_FetchSelectedPlayerData()
	self._fetch_player_data_hash += 1
	local _fetch_player_data_hash = self._fetch_player_data_hash
	self.ProductsDotsFrame.Visible = true
	self.ProductsDotsFrame:AddTag("UILoadingDots")
	self.ProductsList.Visible = false
	self._selected_player_lookup = nil
	wait(0.25)

	if self._fetch_player_data_hash ~= _fetch_player_data_hash then
		return
	end

	local v2, selected_player_lookup = ReplicatedStorage.Remotes.Misc.RequestGiftingDetails:InvokeServer(self._selected_player_input)

	if self._fetch_player_data_hash ~= _fetch_player_data_hash then
		return
	end

	self.ProductsDotsFrame:RemoveTag("UILoadingDots")
	self.ProductsDotsFrame.Visible = false
	self.ProductsList.Visible = true

	if v2 and selected_player_lookup then
		self._selected_player_lookup = selected_player_lookup
	else
		if selected_player_lookup then
			self.PromptSystem:Open("ErrorMessage", "Whoops!", selected_player_lookup)
		end

		self:SelectPlayer(nil)
	end

	self:_UpdateProducts()
end

function object:_UpdateConfirmPurchasePage()
	if not (self._selected_player_input and self._selected_product_id) then
		return
	end

	local gift = MonetizationLibrary.Gifts[tostring(self._selected_product_id)]
	local v2 = PlayerDataController:Get("GiftTickets")[tostring(self._selected_product_id)] or 0
	local visible = typeof(self._selected_player_input) == "string"
	self.ConfirmPurchasePlayerPicture.Image = string.format(
		CONSTANTS.HEADSHOT_IMAGE,
		self._selected_player_lookup.UserID
	)
	self.ConfirmPurchasePlayerUsernameText.Text = not self._selected_player_lookup.DisplayName and "" or self._selected_player_lookup.DisplayName == self._selected_player_lookup.Name and "" or "@" .. self._selected_player_lookup.Name
	self.ConfirmPurchasePlayerDisplayNameText.Text = self._selected_player_lookup.DisplayName or "@" .. self._selected_player_lookup.Name
	self.ConfirmPurchasePlayerDisplayNameText.Position = self.ConfirmPurchasePlayerUsernameText.Text == "" and UDim2.new(
		0.15,
		0,
		0.5,
		0
	) or UDim2.new(0.15, 0, 0.4, 0)
	self.ConfirmPurchaseProductIcon.Image = gift.ImageID or ""
	self.ConfirmPurchaseProductTitleText.Text = gift.DisplayName
	self.ConfirmPurchaseSettingsAnonymousTitle.Text = "Hide my name from " .. (self._selected_player_lookup.DisplayName or self._selected_player_lookup.Name)
	self.ConfirmPurchaseSettingsCustomNoteLockedFrame.Visible = visible
	self.ConfirmPurchaseSettingsCustomNoteUnlockedFrame.Visible = not visible
	self.ConfirmPurchaseWarningsGiftTicketsFrame.Visible = v2 > 0
	self.ConfirmPurchaseWarningsGiftTicketsText.Text = "×" .. v2
	self.ConfirmPurchaseBuyButtonGiftTicketIcon.Visible = v2 > 0
	self.ConfirmPurchaseBuyButtonRobuxPrice.Visible = v2 <= 0
	self.ConfirmPurchaseWarningsOfflineGiftingFrame.Visible = visible
	MonetizationController:SetRobuxText(
		self.ConfirmPurchaseBuyButtonRobuxPrice,
		self._selected_product_id,
		Enum.InfoType.Product
	)
end

function object:_UpdateFrameVisibility()
	self.BackButton.Visible = self._selected_player_input ~= nil
	self.SelectPlayerFrame.Visible = not self._selected_player_input
	self.SelectProductFrame.Visible = self._selected_player_input and not self._selected_product_id
	self.ConfirmPurchaseFrame.Visible = self._selected_player_input and self._selected_product_id
	self.PlayersList.CanvasPosition = Vector2.new(0, 0)
	self.ProductsList.CanvasPosition = Vector2.new(0, 0)
	self.ConfirmPurchaseSettingsAnonymousFilled.Visible = false
	self.ConfirmPurchaseSettingsAnonymousEmpty.Visible = true
	self.ConfirmPurchaseSettingsCustomNoteBox.Text = ""
	self.ConfirmPurchaseSettingsNoteDropdownButtonTitle.Text = "Surprise!"
	self:_UpdateProducts()
	self:_UpdateConfirmPurchasePage()
end

function object:_UpdateProducts()
	if not self._selected_player_input or self._selected_product_id then
		return
	end

	local giftTickets = PlayerDataController:Get("GiftTickets")

	for k, _gift_slot in pairs(self._gift_slots) do
		local v2 = giftTickets[k] or 0
		_gift_slot.Slot.Button.GiftTicket.Visible = v2 > 0
		_gift_slot.Slot.Button.GiftTicket.Quantity.Text = "×" .. v2
		local slot = _gift_slot.Slot
		local visible = self._selected_player_lookup and self._selected_player_lookup.CanReceiveGifts and (_gift_slot.Info.GiftType ~= "Gamepass" or not self._selected_player_lookup.GamepassesOwned[_gift_slot.Info.GiftName])

		if visible then
			if _gift_slot.Info.GiftName == "BattlePassLevels10" and not (self._selected_player_lookup.CurrentSeasonPassLevel < SeasonLibrary.CurrentSeason.NumBattlePassTiers) or _gift_slot.Info.GiftName == "primeseason_bundle" and not (self._selected_player_lookup.CurrentSeasonMaxPassTrackNum < MonetizationLibrary.Bundles.primeseason_bundle.BattlePassMaxPassTrackNum) then
				visible = false
			else
				visible = _gift_slot.Info.GiftName ~= "contrabandseason_bundle" or not self._selected_player_lookup.CurrentSeasonSeasonPassBundleOwned
			end
		end

		slot.Visible = visible
	end

	self.ProductsEmptyFrame.Visible = self._selected_player_lookup and not self._selected_player_lookup.CanReceiveGifts
	self.ProductsPlayerFrame.Visible = not self.ProductsEmptyFrame.Visible
	self.ProductsPlayerPicture.Image = not self._selected_player_lookup and "" or string.format(
		CONSTANTS.HEADSHOT_IMAGE,
		self._selected_player_lookup.UserID
	)
	self.ProductsPlayerUsernameText.Text = not self._selected_player_lookup and "" or not self._selected_player_lookup.DisplayName and "" or self._selected_player_lookup.DisplayName == self._selected_player_lookup.Name and "" or "@" .. self._selected_player_lookup.Name
	self.ProductsPlayerDisplayNameText.Text = not self._selected_player_lookup and "" or self._selected_player_lookup.DisplayName or "@" .. self._selected_player_lookup.Name
	self.ProductsPlayerDisplayNameText.Position = self.ProductsPlayerUsernameText.Text == "" and UDim2.new(
		0.15,
		0,
		0.5,
		0
	) or UDim2.new(0.15, 0, 0.4, 0)
end

function object:_GeneratePlayers()
	for _, _player_slot in pairs(self._player_slots) do
		_player_slot:Destroy()
	end

	self._player_slots = {}
	self._generate_hash += 1
	local _generate_hash = self._generate_hash
	local players = Players:GetPlayers()
	table.sort(players, function(a, b)
		return Utility:StringLessThan(a.DisplayName, b.DisplayName)
	end)
	local index = table.find(players, Players.LocalPlayer)

	if index then
		table.remove(players, index)
	end

	table.insert(players, 1, Players.LocalPlayer)

	for k, player in pairs(players) do
		if not (player ~= Players.LocalPlayer or CONSTANTS.IS_STUDIO) then
			continue
		end

		local clone = giftPlayerSlot:Clone()
		clone.Username.Text = player.DisplayName == player.Name and "" or "@" .. player.Name
		clone.DisplayName.Text = player.DisplayName
		clone.DisplayName.Position = clone.Username.Text == "" and UDim2.new(0.175, 0, 0.5, 0) or UDim2.new(
			0.175,
			0,
			0.4,
			0
		)
		clone.Icon.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, player.UserId)
		clone.LayoutOrder = k
		clone.Parent = self.PlayersContainer
		ButtonEffect:Add(clone.Button)
		table.insert(self._player_slots, clone)
		local v2 = player
		clone.Button.MouseButton1Click:Connect(function()
			self:SelectPlayer(v2)
		end)

		if _generate_hash ~= self._generate_hash then
			return
		end
	end

	for _ = #self._player_slots + 1, 6 do
		local clone = giftPlayerEmptySlot:Clone()
		clone.Parent = self.PlayersContainer
		table.insert(self._player_slots, clone)

		if _generate_hash ~= self._generate_hash then
			return
		end
	end

	if typeof(self._selected_player_input) == "Instance" and self._selected_player_input.Parent ~= Players then
		self:SelectPlayer(nil)
	end
end

function object:_Setup()
	for k, v2 in pairs(MonetizationLibrary.GiftOrder) do
		local gift = MonetizationLibrary.Gifts[v2]
		local clone = giftProductSlot:Clone()
		clone.Icon.Image = ""
		clone.DisplayName.Text = gift.DisplayName
		clone.LayoutOrder = k
		clone.Parent = self.ProductsContainer
		ButtonEffect:Add(clone.Button)
		clone.Button.MouseButton1Click:Connect(function()
			self:SelectProduct(gift.ProductID)
		end)
		self._gift_slots[v2] = {
			Slot = clone,
			Info = gift
		}
	end

	RewardSlot.new({
		Name = MonetizationLibrary.GIFT_REWARD_DATA,
		Quantity = 1,
		Weapon = "IsRandom"
	}):SetParent(self.PlayersGiftRewardContainer)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.BackButton.MouseButton1Click:Connect(function()
		if self._selected_product_id then
			self:SelectProduct(nil)
		elseif self._selected_player_input then
			self:SelectPlayer(nil)
		end
	end)
	self.ConfirmPurchaseBuyButton.MouseButton1Click:Connect(function()
		self:ConfirmPurchase()
	end)
	self.ConfirmPurchaseSettingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.ConfirmPurchaseSettingsFrame.Size = UDim2.new(
			1,
			0,
			0,
			self.ConfirmPurchaseSettingsLayout.AbsoluteContentSize.Y
		)
	end)
	self.PlayersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.PlayersList.CanvasSize = UDim2.new(0, 0, 0, self.PlayersLayout.AbsoluteContentSize.Y)
	end)
	self.ProductsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.ProductsList.CanvasSize = UDim2.new(0, 0, 0, self.ProductsLayout.AbsoluteContentSize.Y)
	end)
	self.ConfirmPurchaseLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.ConfirmPurchaseList.CanvasSize = UDim2.new(0, 0, 0, self.ConfirmPurchaseLayout.AbsoluteContentSize.Y)
	end)
	self.ConfirmPurchaseSettingsNoteDropdownButtonTitle:GetPropertyChangedSignal("Text"):Connect(function()
		self.ConfirmPurchaseSettingsCustomNoteFrame.Visible = self.ConfirmPurchaseSettingsNoteDropdownButtonTitle.Text == "Custom"
	end)
	self.PlayersOfflineGiftBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_UpdateOfflineGiftingButton()
	end)
	self.PlayersOfflineGiftButtonIcon:GetPropertyChangedSignal("Visible"):Connect(function()
		self:_UpdateOfflineGiftingButton()
	end)
	self.PlayersOfflineGiftButton.MouseButton1Click:Connect(function()
		if not (self.PlayersOfflineGiftButtonOn.Visible and self.PlayersOfflineGiftButtonIcon.Visible) then
			return
		end

		local text = self.PlayersOfflineGiftBox.Text
		task.defer(self._OfflineGiftingCooldown, self)
		self.PlayersOfflineGiftBox.Text = ""
		self:SelectPlayer(text)
	end)
	self.ConfirmPurchaseSettingsCustomNoteBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_VerifyNote()
	end)
	self.ConfirmPurchaseSettingsAnonymousButton.MouseButton1Click:Connect(function()
		self.ConfirmPurchaseSettingsAnonymousEmpty.Visible = not self.ConfirmPurchaseSettingsAnonymousEmpty.Visible
		self.ConfirmPurchaseSettingsAnonymousFilled.Visible = not self.ConfirmPurchaseSettingsAnonymousEmpty.Visible
	end)
	self.ConfirmPurchaseSettingsNoteDropdownButton.MouseButton1Click:Connect(function()
		self:_StartNoteDropdown()
	end)
	PlayerDataController:GetDataChangedSignal("GiftTickets"):Connect(function()
		self:_UpdateProducts()
	end)
	PlayerDataController:GetDataChangedSignal("GiftRobuxSpentProgress"):Connect(function()
		self:_UpdateGiftReward()
	end)
	PlayerDataController:GetDataChangedSignal("GiftRobuxSpentRewardsClaimed"):Connect(function()
		self:_UpdateGiftReward()
	end)
	MonetizationController.PurchaseFinished:Connect(function()
		self:SelectPlayer(nil)
	end)
	self:_Setup()
	self:SelectPlayer(nil)
	self:_UpdateGiftReward()
	ButtonEffect:Add(self.BackButton)
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.PlayersOfflineGiftButton)
	ButtonEffect:Add(self.ConfirmPurchaseSettingsAnonymousButton)
	ButtonEffect:Add(self.ConfirmPurchaseBuyButton, nil, {
		HoverRatio = UDim2.new(0, 10, 0, 10),
		ReleaseRatio = UDim2.new(0, 10, 0, 10)
	})
	ButtonEffect:Add(self.ConfirmPurchaseSettingsNoteDropdownButton, nil, {
		ReleaseRatio = 1.025,
		HoverRatio = 1.025
	})
end

return object._new()