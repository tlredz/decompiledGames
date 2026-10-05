local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local SocialService = game:GetService("SocialService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local FamilySource = require(script.FamilySource)
local ServerSource = require(script.ServerSource)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local FamilyController = require(ReplicatedStorage.Modules.Client.UI.Family.FamilyController)
local v = Component.new({
	Tag = "FamilyInvitePlayers"
})
local _ = {
	Server = "Server",
	Friends = "Friends"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function canSendGameInvite(inviteUser: number)
	local success, result = pcall(function()
		return SocialService:CanSendGameInviteAsync(Players.LocalPlayer, inviteUser)
	end)
	return success and result
end

function match(value: string, value2: string)
	if #value == 0 then
		return true
	end

	local v2 = value:sub(1, 32)
	local v3 = 1

	for i = 1, #value2 do
		if value2:sub(i, i):lower() ~= v2:sub(v3, v3):lower() then
			continue
		end

		v3 += 1

		if #v2 < v3 then
			return true
		end
	end

	return false
end

local function promptGameInvite(userId: number)
	local jSONEncode = HttpService:JSONEncode({
		senderUserID = Players.LocalPlayer.UserId,
		source = "FamilyInvitePlayers"
	})
	local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
	experienceInviteOptions.InviteUser = userId
	experienceInviteOptions.LaunchData = jSONEncode

	if canSendGameInvite(userId) then
		SocialService:PromptGameInvite(Players.LocalPlayer, experienceInviteOptions)
		Remotes.fireServer("FamilyOfflineInviteSent", Players.LocalPlayer, userId)
		return true
	else
		NotificationController.NotifyCenter("You cannot invite this player to your game.")
		return false
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._sourceButtons = self.Instance:WaitForChild("SourceButtons")
	self._playerList = self.Instance:WaitForChild("Selectors"):WaitForChild("List")
	self._familySource = FamilySource.new()
	self._serverSource = ServerSource.new()
	self._sentInvites = {}
	self._activeSource = nil
	self:SetSource("Server")
end

function v:Start()
	self._Janitor:Add(self._sourceButtons.Server.Activated:Connect(function()
		self:SetSource("Server")
	end))
	self._Janitor:Add(self._sourceButtons.Friends.Activated:Connect(function()
		self:SetSource("Friends")
	end))
	self._Janitor:Add(self._serverSource.PlayerAdded:Connect(function(player)
		self:CreateButton({
			Name = player.Name,
			DisplayName = player.DisplayName,
			UserId = player.UserId
		})
	end))
	self._Janitor:Add(self._serverSource.PlayerRemoving:Connect(function(player)
		local child = self._playerList:FindFirstChild(player.Name)

		if child then
			child:Destroy()
		end
	end))
	self._Janitor:Add(self.Instance.SearchBox.Input:GetPropertyChangedSignal("Text"):Connect(function()
		self:UpdateSearchFilter(self.Instance.SearchBox.Input.Text)
	end))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if self.Instance.Visible then
			self:UpdateList()
			return
		end

		self._sentInvites = {}

		for _, guiObject in self._playerList:GetChildren() do
			if not (guiObject:IsA("GuiObject") and guiObject.Name ~= "PlayerInfo") then
				continue
			end

			guiObject.Sent.Visible = false
			guiObject.CheckFrame:RemoveTag("Checked")
		end
	end))
	self._Janitor:Add(FamilyController.FamilyStateChanged:Connect(function()
		if self.Instance.Visible then
			self:UpdateList()
		end
	end))
	self._Janitor:Add(self._playerList.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self._playerList.CanvasSize = UDim2.fromOffset(0, self._playerList.UIListLayout.AbsoluteContentSize.Y + 10)
	end))
end

function v:SetSource(activeSource)
	if self._activeSource == activeSource then
		return
	end

	for _, button in self._sourceButtons:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		if button.Name == activeSource then
			button.CheckFrame:AddTag("Checked")
		else
			button.CheckFrame:RemoveTag("Checked")
		end
	end

	self._activeSource = activeSource
	self:UpdateList()
end

function v:UpdateList()
	local players = self._activeSource == "Server" and self._serverSource:GetPlayers() or self._familySource:GetPlayers()

	for _, guiObject in self._playerList:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject.Name ~= "PlayerInfo" then
			guiObject:Destroy()
		end
	end

	for _, player in players do
		self:CreateButton(player)
	end
end

function v:UpdateSearchFilter(searchFilter: string)
	if searchFilter == "" then
		self._searchFilter = nil

		for _, guiObject in self._playerList:GetChildren() do
			if guiObject:IsA("GuiObject") and guiObject.Name ~= "PlayerInfo" then
				guiObject.Visible = true
			end
		end
	else
		self._searchFilter = searchFilter

		for _, guiObject in self._playerList:GetChildren() do
			if not (guiObject:IsA("GuiObject") and guiObject.Name ~= "PlayerInfo") then
				continue
			end

			local visible

			if self._searchFilter then
				local userId = tostring(guiObject:GetAttribute("UserId"))
				visible = match(self._searchFilter, guiObject.DisplayName.Text) or match(
					self._searchFilter,
					guiObject.Username.Text
				) or match(self._searchFilter, userId)
			else
				visible = true
			end

			guiObject.Visible = visible
		end
	end
end

function v:CreateButton(player)
	local clone = self._playerList.PlayerInfo:Clone()
	clone.Username.Text = player.Name
	clone.DisplayName.Text = player.DisplayName
	clone:SetAttribute("UserId", player.UserId)
	clone.Visible = true
	clone.Name = player.Name
	clone.PlayerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
	clone.Parent = self._playerList

	if player.InServer then
		clone.Status.Text = "In Server"
		clone.LayoutOrder = 0
	elseif player.IsOnline then
		clone.Status.Text = "Online"
		clone.LayoutOrder = 1
	else
		clone.Status.Text = "Offline"
		clone.LayoutOrder = 2
	end

	if self._sentInvites[player.UserId] then
		clone.Sent.Visible = true
		clone.CheckFrame:AddTag("Checked")
	end

	if self._searchFilter then
		local v2 = string.find(player.Name:lower(), self._searchFilter:lower())
		local v3 = string.find(player.DisplayName:lower(), self._searchFilter:lower())

		if not (v2 or v3) then
			clone.Visible = false
		end
	end

	self._Janitor:Add(clone.Activated:Connect(function()
		if self._sentInvites[player.UserId] then
			NotificationController.NotifyCenter((`You already sent an invite to {player.Name}!`))
			return
		end

		local v2 = true

		if Players:GetPlayerByUserId(player.UserId) ~= nil then
			Remotes.fireServer("InvitePlayerToFamily", player.UserId, "FamilyInviteMenu")
		else
			v2 = promptGameInvite(player.UserId)
		end

		if not v2 then
			return
		end

		clone.Sent.Visible = true
		clone.CheckFrame:AddTag("Checked")
		self._sentInvites[player.UserId] = true
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v