local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local QueuePadController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("QueuePadController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local SocialController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SocialController"))
local PartyController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PartyController"))
local MatchmakingCountdown = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("MatchmakingCountdown"))
local PartyInviteSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PartyInviteSlot"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local partyMemberBigSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PartyMemberBigSlot")
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.MembersFrame = self.PageFrame:WaitForChild("Members")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.EmptyFrame = self.Container:WaitForChild("Empty")
	self.TopFrame = self.Container:WaitForChild("Top")
	self.SearchBox = self.TopFrame:WaitForChild("Search"):WaitForChild("Box")
	self.TabsFrame = self.TopFrame:WaitForChild("Tabs")
	self.AllButton = self.TabsFrame:WaitForChild("All")
	self.AllButtonText = self.AllButton:WaitForChild("Title")
	self.AllButtonBackground = self.AllButton:WaitForChild("Background")
	self.AllButtonBackgroundGradient = self.AllButtonBackground:WaitForChild("UIGradient")
	self.FriendsButton = self.TabsFrame:WaitForChild("Friends")
	self.FriendsButtonText = self.FriendsButton:WaitForChild("Title")
	self.FriendsButtonBackground = self.FriendsButton:WaitForChild("Background")
	self.FriendsButtonBackgroundGradient = self.FriendsButtonBackground:WaitForChild("UIGradient")
	self.LobbyButton = self.TabsFrame:WaitForChild("Lobby")
	self.LobbyButtonText = self.LobbyButton:WaitForChild("Title")
	self.LobbyButtonBackground = self.LobbyButton:WaitForChild("Background")
	self.LobbyButtonBackgroundGradient = self.LobbyButtonBackground:WaitForChild("UIGradient")
	self.PlayersFrame = self.Container:WaitForChild("Players")
	self.PlayersContainer = self.PlayersFrame:WaitForChild("Container")
	self.PlayersLayout = self.PlayersContainer:WaitForChild("Layout")
	self.HidePartyDisplay = true
	self._member_slots = {}
	self._invite_slots = {}
	self._offline_invite_slots = {}
	self._invite_generation_disabled = 0
	self._leave_buttons = {}
	self:_Init()
	return self
end

function object:Open(...)
	Page.Open(self, ...)
	table.insert(self._open_connections, QueuePadController.ChallengeRequestCooldownChanged:Connect(function()
		self:_UpdateCooldowns()
	end))
	table.insert(self._open_connections, PartyController.InviteRequestCooldownChanged:Connect(function()
		self:_UpdateCooldowns()
	end))
	self:_GenerateMembers()
	self:_GeneratePlayers(true)
	self:_UpdateCooldowns()
	self._invite_generation_disabled = tick() + 0.375
	task.delay(0.375, self._GeneratePlayers, self)
	self.SearchBox.Text = ""
end

function object:_UpdateLayouts()
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	self.PlayersFrame.Size = UDim2.new(1, 0, 0, self.PlayersLayout.AbsoluteContentSize.Y)
	self.EmptyFrame.Visible = self.PlayersLayout.AbsoluteContentSize.Y < 5
end

function object:_UpdateLeaveButtons()
	local isVisible = MatchmakingCountdown:IsVisible()

	for _, _leave_button in pairs(self._leave_buttons) do
		_leave_button.Visible = isVisible
	end
end

function object:_UpdateCooldowns()
	for _, _invite_slot in pairs(self._invite_slots) do
		_invite_slot:UpdateCooldowns()
	end
end

function object:_SetTab(current_tab)
	self._current_tab = current_tab
	self.AllButtonText.TextColor3 = self._current_tab == "All" and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(
		255,
		255,
		255
	)
	self.AllButtonBackground.ImageColor3 = self._current_tab == "All" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(
		0,
		0,
		0
	)
	self.AllButtonBackground.ImageTransparency = self._current_tab == "All" and 0 or 0.25
	self.AllButtonBackgroundGradient.Enabled = self._current_tab ~= "All"
	self.FriendsButtonText.TextColor3 = self._current_tab == "Friends" and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(
		255,
		255,
		255
	)
	self.FriendsButtonBackground.ImageColor3 = self._current_tab == "Friends" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(
		0,
		0,
		0
	)
	self.FriendsButtonBackground.ImageTransparency = self._current_tab == "Friends" and 0 or 0.25
	self.FriendsButtonBackgroundGradient.Enabled = self._current_tab ~= "Friends"
	self.LobbyButtonText.TextColor3 = self._current_tab == "Lobby" and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(
		255,
		255,
		255
	)
	self.LobbyButtonBackground.ImageColor3 = self._current_tab == "Lobby" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(
		0,
		0,
		0
	)
	self.LobbyButtonBackground.ImageTransparency = self._current_tab == "Lobby" and 0 or 0.25
	self.LobbyButtonBackgroundGradient.Enabled = self._current_tab ~= "Lobby"
	self:_UpdatePlayersVisibility()
end

function object:_UpdatePlayerVisibility(p2)
	local text = string.lower(self.SearchBox.Text)
	local frame = p2.Frame
	frame.Visible = (self._current_tab == "All" or self._current_tab == p2.Frame.Name) and (string.find(
		string.lower(p2.Frame.DisplayName.Text),
		text
	) or string.find(string.lower(p2.Frame.Username.Text), text))
end

function object:_UpdatePlayersVisibility()
	for _, _invite_slot in pairs(self._invite_slots) do
		self:_UpdatePlayerVisibility(_invite_slot)
	end

	for _, _offline_invite_slot in pairs(self._offline_invite_slots) do
		self:_UpdatePlayerVisibility(_offline_invite_slot)
	end
end

function object:_GeneratePlayers(p)
	if not self:IsOpen() then
		return
	end

	for i = #self._invite_slots, 1, -1 do
		local _invite_slot = self._invite_slots[i]

		if not (p or not _invite_slot:StillHere()) then
			continue
		end

		_invite_slot:Destroy()
		table.remove(self._invite_slots, i)
	end

	if p then
		for _, _offline_invite_slot in pairs(self._offline_invite_slots) do
			_offline_invite_slot:Destroy()
		end

		self._offline_invite_slots = {}
	end

	if tick() < self._invite_generation_disabled then
		return
	end

	local v = {}

	for _, _invite_slot in pairs(self._invite_slots) do
		v[tostring(_invite_slot:GetUserID())] = true
	end

	local count = 0

	local function generate_slot(list, p2, userId, p3, p4)
		if not userId then
			if p2 then
				userId = p2.UserId or nil
			else
				userId = nil
			end
		end

		if userId == Players.LocalPlayer.UserId and not CONSTANTS.IS_STUDIO or v[tostring(userId)] then
			return
		end

		v[tostring(userId)] = true
		count += 1
		local v2 = PartyInviteSlot.new(p2, userId, p3, p4)
		v2.Frame.LayoutOrder += count
		v2.Frame.Parent = self.PlayersContainer
		self:_UpdatePlayerVisibility(v2)

		if list then
			table.insert(list, v2)
		end
	end

	for _, object3 in pairs(FighterController.Objects) do
		generate_slot(self._invite_slots, object3.Player)
	end

	if #self._offline_invite_slots == 0 then
		for _, friend in pairs(SocialController.Friends) do
			generate_slot(self._offline_invite_slots, nil, friend.VisitorId, friend.DisplayName, friend.UserName)
		end
	end

	self:_UpdatePlayersVisibility()
end

function object:_GenerateMembers()
	if not self:IsOpen() then
		return
	end

	for _, _member_slot in pairs(self._member_slots) do
		_member_slot:Destroy()
	end

	self._member_slots = {}
	self._leave_buttons = {}
	local currentParty = PartyController.CurrentParty or { Players.LocalPlayer }

	local function generate_slot(layoutOrder, p)
		local fighter = p and FighterController:GetFighter(p)
		local clone = partyMemberBigSlot:Clone()
		clone.Icon.Image = not p and "" or string.format(CONSTANTS.HEADSHOT_IMAGE, p.UserId)
		clone.Leader.Visible = p and PartyController.CurrentParty and layoutOrder == 1
		local kick = clone.Kick
		local currentParty2 = p and PartyController.CurrentParty

		if currentParty2 then
			if Players.LocalPlayer == currentParty[1] then
				currentParty2 = p ~= Players.LocalPlayer
			else
				currentParty2 = false
			end
		end

		kick.Visible = currentParty2
		local promote = clone.Promote
		local currentParty3 = p and PartyController.CurrentParty

		if currentParty3 then
			if Players.LocalPlayer == currentParty[1] then
				currentParty3 = p ~= Players.LocalPlayer
			else
				currentParty3 = false
			end
		end

		promote.Visible = currentParty3
		clone.Leave.Visible = p and PartyController.CurrentParty and p == Players.LocalPlayer
		clone.DisplayName.Controls.Image = fighter and CONSTANTS.CONTROLS_IMAGES[fighter:Get("Controls")] or ""
		clone.DisplayName.Text = not p and "" or ComplianceController:GetName(p)
		clone.Username.Text = not p and "" or "@" .. p.Name
		clone.Background.Visible = p ~= nil
		clone.TransparentBackground.Visible = not p
		clone.LayoutOrder = layoutOrder
		clone.Parent = self.MembersFrame
		table.insert(self._member_slots, clone)
		table.insert(self._leave_buttons, clone.Leave)
		ButtonEffect:Add(clone.Kick)
		ButtonEffect:Add(clone.Leave)
		ButtonEffect:Add(clone.Promote)
		clone.Kick.MouseButton1Click:Connect(function()
			ReplicatedStorage.Remotes.Matchmaking.KickPlayerFromParty:FireServer(p)
		end)
		clone.Leave.MouseButton1Click:Connect(function()
			ReplicatedStorage.Remotes.Matchmaking.TryLeaveParty:FireServer()
		end)
		clone.Promote.MouseButton1Click:Connect(function()
			ReplicatedStorage.Remotes.Matchmaking.TransferPartyLeader:FireServer(p)
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			clone.DisplayName.Controls.Position = UDim2.new(0, clone.DisplayName.TextBounds.X, 0.5, 0)
		end

		clone.DisplayName:GetPropertyChangedSignal("TextBounds"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end

	for k, v in pairs(currentParty) do
		generate_slot(k, v)
	end

	for i = #currentParty + 1, CONSTANTS.MAX_PARTY_SIZE do
		generate_slot(i, nil)
	end
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.PlayersLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateLayouts()
	end)
	self.AllButton.MouseButton1Click:Connect(function()
		self:_SetTab("All")
	end)
	self.FriendsButton.MouseButton1Click:Connect(function()
		self:_SetTab("Friends")
	end)
	self.LobbyButton.MouseButton1Click:Connect(function()
		self:_SetTab("Lobby")
	end)
	self.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_UpdatePlayersVisibility()
	end)
	PartyController.PartyChanged:Connect(function()
		self:_GenerateMembers()
		self:_GeneratePlayers()
	end)
	SocialController.FriendsFetched:Connect(function()
		self:_GeneratePlayers()
	end)
	FighterController.ObjectAdded:Connect(function()
		self:_GeneratePlayers()
	end)
	FighterController.ObjectRemoved:Connect(function()
		self:_GeneratePlayers()
	end)
	MatchmakingCountdown.VisibilityChanged:Connect(function()
		self:_UpdateLeaveButtons()
	end)
	self:_UpdateLayouts()
	self:_UpdateLeaveButtons()
	task.defer(self._SetTab, self, "All")
	task.defer(self._GeneratePlayers, self)
	task.defer(self._GenerateMembers, self)
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.AllButton)
	ButtonEffect:Add(self.FriendsButton)
	ButtonEffect:Add(self.LobbyButton)
end

return object._new()