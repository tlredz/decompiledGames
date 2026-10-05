local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local GiftingController = require(ReplicatedStorage.Modules.Client.Gifting.GiftingController)
local Semaphore = require(ReplicatedStorage.Modules.Shared.Async.Semaphore)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local RobloxFriendsUtil = require(ReplicatedStorage.Modules.Shared.Utils.RobloxFriendsUtil)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = nil
local v2 = Component.new({
	Tag = "GiftSelectRecipient"
})

function v2:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function v2:enableGiftButton()
	self.giftButton.GiftIcon.ImageTransparency = 0
	self.giftButton.SendGift.TextTransparency = 0
	self.giftButton.Interactable = true
end

function v2:disableGiftButton()
	self.giftButton.GiftIcon.ImageTransparency = 0.5
	self.giftButton.SendGift.TextTransparency = 0.5
	self.giftButton.Interactable = false
end

function v2:SetGiftData(giftId: number, passName: string, source: string)
	self.GiftId = giftId
	self.PassName = passName
	self.Source = source
end

function v2.SetPreviousPanel(p, targetPanel: string?)
	local close = p.Instance:WaitForChild("Close")

	if targetPanel == nil then
		close:RemoveTag("TogglePanelButton")
		close:AddTag("ClosePanelButton")
	else
		close:RemoveTag("TogglePanelButton")
		close:AddTag("TogglePanelButton")
		close:SetAttribute("TargetPanel", targetPanel)
	end
end

function v2:promptGift()
	self:disableGiftButton()
	self.categoriesLocked = true
	local displayName = self.selectedPlayer.DisplayName or self.selectedPlayer.Name
	local success, result = pcall(function()
		return Remotes.invokeServer("Gift", self.selectedPlayer.UserId, self.GiftId, self.Source)
	end)

	if success and result == "SUCCESS" then
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, self.GiftId)

		if self.playersJanitor ~= nil then
			self.playersJanitor:Destroy()
			self.playersJanitor = nil
		end

		self.selectedPlayerId = nil
	else
		local close = self.Instance:WaitForChild("Close")
		local targetPanel

		if close:HasTag("TogglePanelButton") then
			targetPanel = close:GetAttribute("TargetPanel")
		end

		if success and result ~= "BACKEND_ERROR" then
			if result == "IN_PROGRESS" then
				GiftingController.ShowError(
					"Another gift is already in progress. Please wait before sending or receiving another.",
					targetPanel
				)
			elseif result == "OWNED" then
				GiftingController.ShowError(displayName .. " already owns this item!", targetPanel)
			end
		else
			GiftingController.ShowError("Something went wrong. Please try again.", targetPanel)
		end

		local v3 = v.WaitForPanel("MainGUIHandler", "GiftSelectRecipient")

		if v3:IsOpen() then
			v3:Close()
		end
	end
end

function v2:clearPlayers()
	local scrollingFrame = self.Instance:WaitForChild("InsideBox"):WaitForChild("ScrollBoxFrame"):WaitForChild("ScrollBoxOuter"):WaitForChild("ScrollingFrame")

	if self.playersJanitor ~= nil then
		self.playersJanitor:Destroy()
		self.playersJanitor = nil
	end

	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

function v2:refreshCategory()
	local v3, v4 = RobloxFriendsUtil.getFriendsData(Players.LocalPlayer):await()

	if self.recipientCategory == "SERVER" then
		local v5 = Remotes.invokeServer("GiftList", self.GiftId)
		local v6 = {}

		if v3 then
			for _, friend in pairs(v4.Friends) do
				v6[friend.UserId] = true
			end
		end

		table.sort(v5, function(a, b)
			local v7 = v6[a.UserId]
			local v8 = v6[b.UserId]

			if v7 and not v8 then
				return true
			end

			return not (v8 and not v7) and a.Name < b.Name
		end)
		return v5
	else
		local result = {}

		if not v3 then
			return result
		end

		local success, friendsOnline = pcall(Players.LocalPlayer.GetFriendsOnline, Players.LocalPlayer)

		if not success then
			return result
		end

		local v5 = {}

		for _, v6 in friendsOnline do
			v5[v6.VisitorId] = true
		end

		local clone = table.clone(v4.Friends)
		table.sort(clone, function(a, b)
			if Players:GetPlayerByUserId(a.UserId) and not Players:GetPlayerByUserId(b.UserId) then
				return true
			end

			if Players:GetPlayerByUserId(b.UserId) and not Players:GetPlayerByUserId(a.UserId) then
				return false
			end

			if v5[a.UserId] and not v5[b.UserId] then
				return true
			end

			return not (v5[b.UserId] and not v5[a.UserId]) and a.DisplayName:lower() < b.DisplayName:lower()
		end)

		for _, v7 in pairs(clone) do
			table.insert(result, {
				Name = v7.Username,
				DisplayName = v7.DisplayName,
				UserId = v7.UserId
			})

			if #result >= 200 then
				break
			end
		end

		return result
	end
end

local userThumbnailAsyncsByUserId = {}
local v3 = Semaphore.new(1)

function v2:refreshPlayers(p)
	local insideBox = self.Instance:WaitForChild("InsideBox")
	local textBox = insideBox:WaitForChild("SearchBar"):WaitForChild("SearchBox"):WaitForChild("TextBox")
	local scrollingFrame = insideBox:WaitForChild("ScrollBoxFrame"):WaitForChild("ScrollBoxOuter"):WaitForChild("ScrollingFrame")
	local searching = ReplicatedStorage:WaitForChild("UiClone"):WaitForChild("Gifting"):WaitForChild("Searching")
	local players = nil
	local playersJanitor = Janitor.new()
	v3:acquire()
	local success, result = pcall(function()
		if p then
			textBox.Text = ""
			players = self:refreshCategory()
			self.players = players
		else
			players = self.players
		end

		self:clearPlayers()
		self.playersJanitor = playersJanitor
	end)
	v3:release()

	if not success then
		error(result)
	end

	local text = textBox.Text
	local players2 = {}

	for _, player in players do
		if not (match(text, player.DisplayName) or match(text, player.Name) or match(text, (tostring(player.UserId)))) then
			continue
		end

		table.insert(players2, player)
	end

	local v5 = false

	if not p and self.recipientCategory == "GLOBAL" and #text > 0 then
		local v6 = false

		for _, v8 in players2 do
			if v8.Name:lower() ~= text:lower() then
				continue
			end

			v6 = true
			break
		end

		if not v6 then
			v5 = true
		end
	end

	for k, v6 in players2 do
		if v6 ~= Players.LocalPlayer or RunService:IsStudio() then
			self:addGiftPlayer(v6, k, playersJanitor)
		end
	end

	if v5 and Janitor.Is(playersJanitor) then
		local clone = searching:Clone()
		clone.LayoutOrder = -1000
		clone.Parent = scrollingFrame
		playersJanitor:AddPromise(Promise.try(function()
			local userIdFromNameAsync = Players:GetUserIdFromNameAsync(text)
			return userIdFromNameAsync, (Players:GetNameFromUserIdAsync(userIdFromNameAsync))
		end):andThen(function(userId, name)
			clone:Destroy()

			if Janitor.Is(playersJanitor) then
				self:addGiftPlayer({
					DisplayName = nil,
					Name = name,
					UserId = userId
				}, 1000, playersJanitor)
			end
		end, function()
			clone:Destroy()
		end))
		playersJanitor:Add(clone, "Destroy")
	end

	scrollingFrame.CanvasSize = UDim2.new(
		0,
		0,
		0,
		scrollingFrame:WaitForChild("UIGridLayout").AbsoluteContentSize.Y + 12
	)
end

function v2:addGiftPlayer(selectedPlayer, p, maid)
	local clone = ReplicatedStorage:WaitForChild("UiClone"):WaitForChild("Gifting"):WaitForChild("Giftee"):Clone()
	clone.LayoutOrder = -p

	if selectedPlayer.DisplayName == nil then
		clone.NameBox.Username.Size = UDim2.fromScale(1, 1)
		clone.NameBox.PlayerName.Text = ""
	else
		clone.NameBox.PlayerName.Text = selectedPlayer.DisplayName
	end

	clone.NameBox.Username.Text = selectedPlayer.Name
	clone:SetAttribute("PlayerId", selectedPlayer.UserId)

	if userThumbnailAsyncsByUserId[selectedPlayer.UserId] then
		local imageLabel = clone:FindFirstChild("ImageLabel")

		if imageLabel ~= nil then
			imageLabel.Image = userThumbnailAsyncsByUserId[selectedPlayer.UserId]
		end
	else
		task.spawn(function()
			local userId = selectedPlayer.UserId
			local userThumbnailAsync, v4 = Players:GetUserThumbnailAsync(
				userId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size60x60
			)

			if v4 then
				userThumbnailAsyncsByUserId[userId] = userThumbnailAsync
				local imageLabel = clone:FindFirstChild("ImageLabel")

				if imageLabel ~= nil then
					imageLabel.Image = userThumbnailAsync
				end
			end
		end)
	end

	local scrollingFrame = self.Instance:WaitForChild("InsideBox"):WaitForChild("ScrollBoxFrame"):WaitForChild("ScrollBoxOuter"):WaitForChild("ScrollingFrame")

	if not Janitor.Is(maid) then
		clone:Destroy()
		return
	end

	clone.Parent = scrollingFrame
	maid:Add(clone.Activated:Connect(function()
		if self.selected == nil then
			self:enableGiftButton()
		else
			if not self.giftButton.Interactable then
				return
			end

			self.selected.CheckmarkBox.Checkmark.Visible = false
			self.selected.BackgroundColor3 = Color3.new(1, 1, 1)
		end

		self.selectedPlayer = selectedPlayer
		self.selected = clone
		clone.BackgroundColor3 = Color3.fromRGB(174, 255, 152)
		clone.CheckmarkBox.Checkmark.Visible = true

		if Platform.IsConsole() then
			GuiService.SelectedObject = self.giftButton
		end
	end))
	maid:Add(function()
		self.selected = nil
	end, true)
	maid:Add(clone, "Destroy")
end

function match(value: string, value2: string)
	if #value == 0 then
		return true
	end

	local v4 = value:sub(1, 32)
	local v5 = 1

	for i = 1, #value2 do
		if value2:sub(i, i):lower() ~= v4:sub(v5, v5):lower() then
			continue
		end

		v5 += 1

		if #v4 < v5 then
			return true
		end
	end

	return false
end

function v2:Start()
	local insideBox = self.Instance:WaitForChild("InsideBox")
	self.giftButton = insideBox:WaitForChild("GiftButton")
	self._Janitor:Add(self.giftButton.Activated:Connect(function()
		if not self.giftButton.Interactable then
			return
		end

		self:promptGift()
	end))
	self._Janitor:Add(MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2, p3)
		if self.GiftId == nil or p ~= Players.LocalPlayer.UserId or p2 ~= self.GiftId or not p3 then
			return
		end

		local v4 = v.WaitForPanel("MainGUIHandler", "GiftSelectRecipient")

		if v4:IsOpen() then
			v4:Close()
		end
	end))
	local giftingSubtitle = insideBox:WaitForChild("GiftingSubtitle")
	local v4 = v.WaitForPanel("MainGUIHandler", "GiftSelectRecipient")
	local categories = insideBox:WaitForChild("Categories")
	local globalButton = categories:WaitForChild("Global"):WaitForChild("GlobalButton")
	local serverButton = categories:WaitForChild("Server"):WaitForChild("ServerButton")
	self._Janitor:Add(globalButton.Activated:Connect(function()
		if self.categoriesLocked then
			return
		end

		self.recipientCategory = "GLOBAL"
		local v5 = serverButton
		v5.Interactable = true
		local checkmark = v5:FindFirstChild("Checkmark")
		checkmark.ImageTransparency = 1
		v5.BackgroundColor3 = Color3.new(1, 1, 1)
		local v6 = globalButton
		v6.Interactable = false
		local checkmark_2 = v6:FindFirstChild("Checkmark")
		checkmark_2.ImageTransparency = 0
		v6.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
		self:disableGiftButton()
		self.selectedPlayer = nil
		self:refreshPlayers(true)
	end))
	self._Janitor:Add(serverButton.Activated:Connect(function()
		if self.categoriesLocked then
			return
		end

		self.recipientCategory = "SERVER"
		local v5 = serverButton
		v5.Interactable = false
		local checkmark = v5:FindFirstChild("Checkmark")
		checkmark.ImageTransparency = 0
		v5.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
		local v6 = globalButton
		v6.Interactable = true
		local checkmark_2 = v6:FindFirstChild("Checkmark")
		checkmark_2.ImageTransparency = 1
		v6.BackgroundColor3 = Color3.new(1, 1, 1)
		self:disableGiftButton()
		self.selectedPlayer = nil
		self:refreshPlayers(true)
	end))
	local textBox = insideBox:WaitForChild("SearchBar"):WaitForChild("SearchBox"):WaitForChild("TextBox")
	self._Janitor:Add(textBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:refreshPlayers(false)
		self:disableGiftButton()
		self.selectedPlayer = nil

		if self._SearchPromise then
			self._SearchPromise:cancel()
		end
	end))
	v4:RegisterListener(self, v4.Events.Opening, function(_)
		if not (self.PassName and self.GiftId) then
			v4:Close()
			return
		end

		self.recipientCategory = "SERVER"
		local v5 = serverButton
		v5.Interactable = false
		local checkmark = v5:FindFirstChild("Checkmark")
		checkmark.ImageTransparency = 0
		v5.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
		local v6 = globalButton
		v6.Interactable = true
		local checkmark_2 = v6:FindFirstChild("Checkmark")
		checkmark_2.ImageTransparency = 1
		v6.BackgroundColor3 = Color3.new(1, 1, 1)
		self.openJanitor = Janitor.new()
		giftingSubtitle.Text = "<font weight=\"SemiBold\" color=\"#0030FF\">" .. self.PassName .. "</font> for "
		self._Promise = Promise.new(function(callback, callback2, _)
			local v7, v8 = GetProductInfo(self.GiftId, Enum.InfoType.Product, 0)

			if v7 then
				callback(v8)
			else
				callback2()
			end
		end):timeout(10):andThen(function(p)
			giftingSubtitle.Text ..= "<font weight=\"SemiBold\" color=\"#0030FF\">" .. tostring(p.PriceInRobux) .. "</font>"
		end, function(_)
			giftingSubtitle.Text ..= "?"
		end)
		self:refreshPlayers(true)
	end)
	v4:RegisterListener(self, v4.Events.Closing, function(_)
		if self._Promise then
			self._Promise:cancel()
		end

		if self.openJanitor then
			self.openJanitor:Destroy()
			self.openJanitor = nil
		end

		self:disableGiftButton()
		self:clearPlayers()
		self.GiftId = nil
		self.PassName = nil
		self.selectedPlayer = nil
		self.recipientCategory = nil
		self.selected = nil
		self.categoriesLocked = nil
		textBox.Text = ""
	end)
	self._Janitor:Add(MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, _, p)
		local v5 = v.WaitForPanel("MainGUIHandler", "GiftSelectRecipient")

		if not v5:IsOpen() then
			return
		end

		if p then
			v5:Close()
			return
		end

		local open = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGUIHandler"):WaitForChild("ShopButtons"):WaitForChild("Frame"):WaitForChild("Open")

		if open:HasTag("TogglePanelButton") then
			v.OpenPanelByContext("MainGUIHandler", open:GetAttribute("TargetPanel"))
		else
			v5:Close()
		end
	end))
end

function v2:Stop()
	if self.openJanitor then
		self.openJanitor:Destroy()
		self.openJanitor = nil
	end

	self._Janitor:Destroy()
end

return v2