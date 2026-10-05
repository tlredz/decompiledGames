local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local PartyEndConfirm = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Party.PartyEndConfirm)
local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
local Semaphore = require(ReplicatedStorage.Modules.Shared.Async.Semaphore)
local RepeatableDevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.RepeatableDevProducts)
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local RobloxFriendsUtil = require(ReplicatedStorage.Modules.Shared.Utils.RobloxFriendsUtil)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = nil
local v2 = Component.new({
	Tag = "PartySelect"
})

function v2:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function v2:enableButton()
	self.button.Icon.ImageTransparency = 0
	self.button.Frame.Title.TextTransparency = 0
	self.button.Frame.Text.TextTransparency = 0
	self.button.Interactable = true
end

function v2:disableButton()
	self.button.Icon.ImageTransparency = 0.5
	self.button.Frame.Title.TextTransparency = 0.5
	self.button.Frame.Text.TextTransparency = 0.5
	self.button.Interactable = false
end

function v2:SetData(partyName: string, party: string, p2)
	self.PartyName = partyName
	self.Party = party
	local partyId

	if p2 ~= nil then
		partyId = RepeatableDevProducts.GetId(p2)
	end

	self.PartyId = partyId
end

function v2:SetPreviousPanel(targetPanel: string?)
	local close = self.Instance:WaitForChild("Close")

	if targetPanel == nil then
		close:RemoveTag("TogglePanelButton")
		close:AddTag("ClosePanelButton")
		self.button.Frame.Title.Text = "Invite to party!"
		self.button.Frame.Title.Size = UDim2.fromScale(1, 1)
		self.button.Frame.Text.Visible = false
		self.GlobalEnabled = true
	else
		close:RemoveTag("TogglePanelButton")
		close:AddTag("TogglePanelButton")
		close:SetAttribute("TargetPanel", targetPanel)
		self.button.Frame.Title.Text = "Start party!"
		self.button.Frame.Title.Size = UDim2.fromScale(1, 0.6)
		self.button.Frame.Text.Visible = true
		self.GlobalEnabled = false
	end
end

function v2:promptGift()
	self:disableButton()
	self.categoriesLocked = true
	local v3 = v.WaitForPanel("MainGUIHandler", "PartySelect")
	local selectedPlayers = self.selectedPlayers

	if v3:IsOpen() then
		v.Close("MainGUIHandler", "PartySelect")
	end

	if self.GlobalEnabled then
		Remotes.fireServer("PartyInviteMore", selectedPlayers)
	elseif self.PartyId == nil then
		Remotes.fireServer("StartFreeParty", self.Party, selectedPlayers)
	else
		Remotes.fireServer("PromptRepeatableProduct", "Party", self.PartyId, selectedPlayers)
	end

	if self.playersJanitor ~= nil then
		self.playersJanitor:Destroy()
		self.playersJanitor = nil
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

	if self.recipientCategory ~= "SERVER" then
		return nil
	end

	local players = Players:GetPlayers()
	local result = {}

	for _, player in pairs(players) do
		if player ~= Players.LocalPlayer or RunService:IsStudio() then
			table.insert(result, {
				Name = player.Name,
				DisplayName = player.DisplayName,
				UserId = player.UserId
			})
		end
	end

	local v5 = {}

	if v3 then
		for _, friend in pairs(v4.Friends) do
			v5[friend.UserId] = true
		end
	end

	table.sort(result, function(a, b)
		local v6 = v5[a.UserId]
		local v7 = v5[b.UserId]

		if v6 and not v7 then
			return true
		end

		return not (v7 and not v6) and a.Name < b.Name
	end)
	return result
end

local userThumbnailAsyncsByUserId = {}
local v3 = Semaphore.new(1)

function v2:refreshPlayers(p)
	local insideBox = self.Instance:WaitForChild("InsideBox")
	local textBox = insideBox:WaitForChild("SearchBar"):WaitForChild("SearchBox"):WaitForChild("TextBox")
	local scrollingFrame = insideBox:WaitForChild("ScrollBoxFrame"):WaitForChild("ScrollBoxOuter"):WaitForChild("ScrollingFrame")
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

	if p and self.GlobalEnabled and self.recipientCategory == "GLOBAL" then
		local expect = ReplicatedDataController.GetSessionReplicaPromise():expect()

		if not expect.Data.Party then
			return
		end

		local globalDisabled = insideBox:WaitForChild("GlobalDisabled")
		globalDisabled.Visible = true

		if self.canInvite then
			local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
			experienceInviteOptions.LaunchData = expect.Data.Party.uid
			experienceInviteOptions.PromptMessage = "Invite your friends to the party!"
			experienceInviteOptions.InviteMessageId = "ecb1d9df-2fbc-d546-b8b7-d900c2ab8905"
			SocialService:PromptGameInvite(Players.LocalPlayer, experienceInviteOptions)
			local globalDisabled_2 = insideBox:WaitForChild("GlobalDisabled")
			globalDisabled_2.TextLabel.Text = "Invite menu opened!"
			local globalDisabled_3 = insideBox:WaitForChild("GlobalDisabled")
			globalDisabled_3.TextLabel.Size = UDim2.fromScale(0.8, 0.2)
		else
			local globalDisabled_4 = insideBox:WaitForChild("GlobalDisabled")
			globalDisabled_4.TextLabel.Text = "You cannot invite offline players"
			local globalDisabled_5 = insideBox:WaitForChild("GlobalDisabled")
			globalDisabled_5.TextLabel.Size = UDim2.fromScale(0.8, 0.55)
		end

		local searchBar = insideBox:WaitForChild("SearchBar")
		searchBar.Visible = false
		local scrollBoxFrame = insideBox:WaitForChild("ScrollBoxFrame")
		scrollBoxFrame.Visible = false
	elseif self.players == nil then
		if p then
			local globalDisabled_6 = insideBox:WaitForChild("GlobalDisabled")
			globalDisabled_6.Visible = true

			if self.canInvite then
				local globalDisabled_7 = insideBox:WaitForChild("GlobalDisabled")
				globalDisabled_7.TextLabel.Text = "Start a party to invite offline players!"
			else
				local globalDisabled_8 = insideBox:WaitForChild("GlobalDisabled")
				globalDisabled_8.TextLabel.Text = "You cannot invite offline players"
			end

			local globalDisabled_9 = insideBox:WaitForChild("GlobalDisabled")
			globalDisabled_9.TextLabel.Size = UDim2.fromScale(0.8, 0.55)
			local searchBar_2 = insideBox:WaitForChild("SearchBar")
			searchBar_2.Visible = false
			local scrollBoxFrame_2 = insideBox:WaitForChild("ScrollBoxFrame")
			scrollBoxFrame_2.Visible = false
		end
	else
		if p then
			local globalDisabled_10 = insideBox:WaitForChild("GlobalDisabled")
			globalDisabled_10.Visible = false
			local searchBar_3 = insideBox:WaitForChild("SearchBar")
			searchBar_3.Visible = true
			local scrollBoxFrame_3 = insideBox:WaitForChild("ScrollBoxFrame")
			scrollBoxFrame_3.Visible = true

			if not self.GlobalEnabled then
				self:enableButton()
			end
		end

		local text = textBox.Text
		local players2 = {}

		for _, player in players do
			if not (match(text, player.DisplayName) or match(text, player.Name) or match(
				text,
				(tostring(player.UserId))
			)) then
				continue
			end

			table.insert(players2, player)
		end

		for k, v5 in players2 do
			if v5 ~= Players.LocalPlayer or RunService:IsStudio() then
				self:addGiftPlayer(v5, k, playersJanitor)
			end
		end

		scrollingFrame.CanvasSize = UDim2.new(
			0,
			0,
			0,
			scrollingFrame:WaitForChild("UIGridLayout").AbsoluteContentSize.Y + 12
		)
	end
end

function v2:addGiftPlayer(player, p, maid)
	local clone = ReplicatedStorage:WaitForChild("UiClone"):WaitForChild("Gifting"):WaitForChild("Giftee"):Clone()
	clone.LayoutOrder = -p

	if player.DisplayName == nil then
		clone.NameBox.Username.Size = UDim2.fromScale(1, 1)
		clone.NameBox.PlayerName.Text = ""
	else
		clone.NameBox.PlayerName.Text = player.DisplayName
	end

	clone.NameBox.Username.Text = player.Name
	clone:SetAttribute("PlayerId", player.UserId)

	if userThumbnailAsyncsByUserId[player.UserId] then
		local imageLabel = clone:FindFirstChild("ImageLabel")

		if imageLabel ~= nil then
			imageLabel.Image = userThumbnailAsyncsByUserId[player.UserId]
		end
	else
		task.spawn(function()
			local userId = player.UserId
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

	if table.find(self.selectedPlayers, player.UserId) ~= nil then
		clone.BackgroundColor3 = Color3.fromRGB(174, 255, 152)
		clone.CheckmarkBox.Checkmark.Visible = true
	end

	if not Janitor.Is(maid) then
		clone:Destroy()
		return
	end

	clone.Parent = scrollingFrame
	maid:Add(clone.Activated:Connect(function()
		local index = table.find(self.selectedPlayers, player.UserId)

		if index == nil then
			if #self.selectedPlayers == 0 and self.GlobalEnabled then
				self:enableButton()
			end

			table.insert(self.selectedPlayers, player.UserId)
			clone.BackgroundColor3 = Color3.fromRGB(174, 255, 152)
			clone.CheckmarkBox.Checkmark.Visible = true
		else
			table.remove(self.selectedPlayers, index)
			clone.CheckmarkBox.Checkmark.Visible = false
			clone.BackgroundColor3 = Color3.new(1, 1, 1)

			if #self.selectedPlayers == 0 and self.GlobalEnabled then
				self:disableButton()
			end
		end
	end))
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
	self.button = insideBox:WaitForChild("BottomBox"):WaitForChild("Button")
	local button = self.Instance:WaitForChild("EndParty"):WaitForChild("Button")
	self._Janitor:Add(button.Activated:Connect(function()
		PartyEndConfirm.SetData(function()
			Remotes.fireServer("PartyEnd")
		end)
		v.OpenPanelByContext("MainGUIHandler", "PartyEndConfirm")
	end))
	self._Janitor:Add(self.button.Activated:Connect(function()
		if not self.button.Interactable then
			return
		end

		self:promptGift()
	end))
	self._Janitor:Add(MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, p, p2)
		if not RepeatableDevProducts.Exists(p) then
			return
		end

		if not p2 then
			v.OpenPanelByContext("MainGUIHandler", "PartySelect")
		elseif v.WaitForPanel("MainGUIHandler", "PartySelect"):IsOpen() then
			v.Close("MainGUIHandler", "PartySelect")
		end
	end))
	local title = insideBox:WaitForChild("Title")
	local v4 = v.WaitForPanel("MainGUIHandler", "PartySelect")
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
		self:refreshPlayers(true)
	end))
	local textBox = insideBox:WaitForChild("SearchBar"):WaitForChild("SearchBox"):WaitForChild("TextBox")
	self._Janitor:Add(textBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:refreshPlayers(false)
	end))
	local text = self.button:WaitForChild("Frame"):WaitForChild("Text")
	v4:RegisterListener(self, v4.Events.Opening, function(_)
		task.spawn(function()
			if not self.canInvite then
				self.canInvite = SocialService:CanSendGameInviteAsync(Players.LocalPlayer)
			end
		end)
		button.Parent.Visible = self.GlobalEnabled
		self.selectedPlayers = {}
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
		title.Text = "Invite to " .. self.PartyName

		if self.PartyId == nil then
			text.Text = "FREE"
		else
			self._Promise = Promise.new(function(callback, callback2, _)
				local v7, v8 = GetProductInfo(self.PartyId, Enum.InfoType.Product, 2)

				if v7 then
					callback(v8)
				else
					callback2()
				end
			end):timeout(10):andThen(function(p)
				text.Text = "" .. tostring(p.PriceInRobux)
			end, function(_)
				text.Text = "?"
			end)
		end

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

		self:disableButton()
		self:clearPlayers()
		self.recipientCategory = nil
		self.selectedPlayers = {}
		self.categoriesLocked = nil
		title.Text = "Invite to party"
		textBox.Text = ""
		text.Text = ""
	end)
	self._Janitor:Add(MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, _, _)
		local v5 = v.WaitForPanel("MainGUIHandler", "PartySelect")

		if not v5:IsOpen() then
			return
		end

		v5:Close()
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