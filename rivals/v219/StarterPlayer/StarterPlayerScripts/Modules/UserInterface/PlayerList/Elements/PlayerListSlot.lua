local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local PlayerDataUtility = require(ReplicatedStorage.Modules.PlayerDataUtility)
require(ReplicatedStorage.Modules.DebugLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local MatchmakingController = require(Players.LocalPlayer.PlayerScripts.Controllers.MatchmakingController)
local LeaderboardController = require(Players.LocalPlayer.PlayerScripts.Controllers.LeaderboardController)
require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local SocialController = require(Players.LocalPlayer.PlayerScripts.Controllers.SocialController)
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules.WeaponStatusHandler)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules.RankIcon)
local playerListSlot = Players.LocalPlayer.PlayerScripts.UserInterface.PlayerListSlot
local v = { 0.45, "rbxassetid://89686341813708" }
local v2 = { 0.625, "rbxassetid://140099562989635" }
local v3 = { 0.45, "rbxassetid://114408044569826" }
local v4 = { 0.6, "rbxassetid://134084662516990" }
local v5 = { 0.5, "rbxassetid://108431611670429" }
local v6 = { 0.5, "rbxassetid://104322490200835" }
local v7 = { 0.4, "rbxassetid://97625610157994" }
local v8 = { 0.5, "rbxassetid://118031781381166" }
local v9 = { 0.4, "rbxassetid://105897927" }
local v10 = { 0.6, "rbxassetid://113059239" }
local v11 = { 0.6, "rbxassetid://134032333" }
local PlayerListSlot = {}
PlayerListSlot.__index = PlayerListSlot

function PlayerListSlot.new(elements, clientFighter)
	local self = setmetatable({}, PlayerListSlot)
	self.Clicked = Signal.new()
	self.Elements = elements
	self.ClientFighter = clientFighter
	self.Frame = playerListSlot:Clone()
	self.Button = self.Frame:WaitForChild("Button")
	self.RequestsFrame = self.Frame:WaitForChild("Requests")
	self.HighlightFrame = self.Frame:WaitForChild("Highlight")
	self.LeaderstatFrame = self.Frame:WaitForChild("Leaderstat")
	self.LeaderstatTitle = self.LeaderstatFrame:WaitForChild("Title")
	self.LeaderstatRankContainer = self.LeaderstatFrame:WaitForChild("RankContainer")
	self.PlayerContainer = self.Frame:WaitForChild("Player"):WaitForChild("Container")
	self.PlayerIcon = self.PlayerContainer:WaitForChild("Icon")
	self.PlayerTitle = self.PlayerContainer:WaitForChild("Title")
	self.PlayerTitleIcon = self.PlayerTitle:WaitForChild("Icon")
	self._connections = {}
	self._is_highlighted = false
	self._is_hovered = false
	self._leaderstat_name = nil
	self._leaderstat_rank_icon = nil
	self._is_friend = nil
	self._is_blocked = nil
	self._request_effect_threads = {}
	self:_Init()
	return self
end

function PlayerListSlot:IsFriend()
	return self._is_friend
end

function PlayerListSlot:IsBlocked()
	return self._is_blocked
end

function PlayerListSlot:SetParent(parent)
	self.Frame.Parent = parent
end

function PlayerListSlot:SetLeaderstat(leaderstat_name)
	self._leaderstat_name = leaderstat_name
	self:_UpdateLeaderstat()
end

function PlayerListSlot:SetHighlighted(is_highlighted)
	self._is_highlighted = is_highlighted
	self:_UpdateHighlight()
end

function PlayerListSlot:SetIsFriend(is_friend)
	if self._is_friend == is_friend then
		return
	end

	self._is_friend = is_friend
	self:_UpdateIcon()
end

function PlayerListSlot:SetIsBlocked(is_blocked)
	if self._is_blocked == is_blocked then
		return
	end

	self._is_blocked = is_blocked
	self:_UpdateIcon()
end

function PlayerListSlot:SetRequestDuration(p2, p3)
	if self._request_effect_threads[p2] then
		task.cancel(self._request_effect_threads[p2])
		self._request_effect_threads[p2] = nil
	end

	self._request_effect_threads[p2] = task.spawn(function()
		local v12 = tick() + p3
		local v13 = self.RequestsFrame[p2]
		local uIGradient = v13.UIStroke.UIGradient
		v13.Visible = true

		while tick() < v12 do
			uIGradient.Rotation = tick() * 90 % 360
			RunService.RenderStepped:Wait()
		end

		v13.Visible = false
	end)
end

function PlayerListSlot:OnOpened()
	self:_UpdateLeaderstat()
	self:_UpdateIcon()
	self:_UpdateVisuals()
	self:_UpdateStatus()
end

function PlayerListSlot:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for _, _request_effect_thread in pairs(self._request_effect_threads) do
		pcall(task.cancel, _request_effect_thread)
	end

	if self._leaderstat_rank_icon then
		self._leaderstat_rank_icon:Destroy()
		self._leaderstat_rank_icon = nil
	end

	self.Clicked:Destroy()
	self.Frame:Destroy()
end

function PlayerListSlot:_UpdateVisuals()
	if not self.Elements.PlayerList.IsOpen then
		return
	end

	task.delay(0, function()
		self.PlayerTitleIcon.Position = UDim2.new(0, self.PlayerTitle.TextBounds.X, 0.5, 0)
	end)
end

function PlayerListSlot:_UpdateIcon()
	if not self.Elements.PlayerList.IsOpen then
		return
	end

	local v12

	if self._is_blocked then
		v12 = v7
	elseif self._is_friend then
		v12 = v8
	elseif self.ClientFighter.Player.UserId == 261 then
		v12 = v9
	elseif self.ClientFighter.Player.UserId == 13268404 then
		v12 = v10
	elseif self.ClientFighter.Player.UserId == 7210880 then
		v12 = v11
	elseif self.ClientFighter.Player:GetAttribute("DisableTeamVisuals") or not self.ClientFighter.Player:GetAttribute("IsAdministrator") then
		if self.ClientFighter.Player:GetAttribute("DisableTeamVisuals") or not PlayerDataUtility:IsNosniyGamesTeamMemberRaw(HttpService:JSONDecode(self.ClientFighter.Player:GetAttribute("GroupRoleIDs") or {})) then
			if self.ClientFighter.Player:GetAttribute("IsRobloxEmployee") then
				v12 = v3
			elseif self.ClientFighter.Player:GetAttribute("IsInfluencer") then
				v12 = v4
			elseif self.ClientFighter.Player.HasRobloxSubscription then
				v12 = v6
			elseif self.ClientFighter.Player.MembershipType == Enum.MembershipType.Premium then
				v12 = v5
			end
		else
			v12 = v2
		end
	else
		v12 = v
	end

	self.PlayerIcon.Image = not v12 and "" or v12[2] or ""
	self.PlayerIcon.Size = v12 and UDim2.new(v12[1], 0, v12[1], 0) or UDim2.new(0, 0, 0, 0)
	self.PlayerTitleIcon.Image = CONSTANTS.CONTROLS_IMAGES_CENTERED[self.ClientFighter:Get("Controls")] or ""
end

function PlayerListSlot:_UpdateStatus()
	if not self.Elements.PlayerList.IsOpen then
		return
	end

	WeaponStatusHandler:ClearStatusElements(self.PlayerTitle)
	WeaponStatusHandler:ApplyItemStatusToText(self.PlayerTitle, self.ClientFighter.Player:GetAttribute("PlayerStatus"))
end

function PlayerListSlot:_UpdateLeaderstat()
	if not self.Elements.PlayerList.IsOpen then
		return
	end

	if self._leaderstat_rank_icon then
		self._leaderstat_rank_icon:Destroy()
		self._leaderstat_rank_icon = nil
	end

	local child = self._leaderstat_name and self.ClientFighter.Player:FindFirstChild("CustomLeaderstats") and self.ClientFighter.Player.CustomLeaderstats:FindFirstChild(self._leaderstat_name)
	self.Frame.LayoutOrder = not child and 1 or -child.Value or 1

	if not child or child:GetAttribute("StillLoading") then
		self.LeaderstatTitle.Text = "• • •"
		return
	end

	if self._leaderstat_name ~= "Current ELO" then
		self.LeaderstatTitle.Text = not child.Value and "• • •" or Utility:PrettyNumber(child.Value)
		return
	end

	self.LeaderstatTitle.Text = ""

	if not CONSTANTS.IS_MATCHMAKING_SERVER or MatchmakingController:Get("MatchmadeGameOver") then
		self._leaderstat_rank_icon = RankIcon.new(child.Value, self.ClientFighter.Player.UserId)
		self._leaderstat_rank_icon:SetParent(self.LeaderstatRankContainer)
	end
end

function PlayerListSlot:_UpdateHighlight()
	self.HighlightFrame.BackgroundTransparency = self._is_highlighted and 0.875 or self._is_hovered and 0.95 or 1
end

function PlayerListSlot:_SetHovered(is_hovered)
	self._is_hovered = is_hovered
	self:_UpdateHighlight()
end

function PlayerListSlot:_FetchIsBlocked()
	local success, core = pcall(StarterGui.GetCore, StarterGui, "GetBlockedUserIds")
	self:SetIsBlocked(success and table.find(core, self.ClientFighter.Player.UserId) ~= nil)
end

function PlayerListSlot:_FetchIsFriend()
	if self.ClientFighter.IsLocalPlayer then
		self:SetIsFriend(false)
	else
		self:SetIsFriend(SocialController:IsFriendsWith(self.ClientFighter.Player.UserId))
	end
end

function PlayerListSlot:_SetupLeaderstats()
	local customLeaderstats = self.ClientFighter.Player:WaitForChild("CustomLeaderstats")
	table.insert(self._connections, customLeaderstats.ChildRemoved:Connect(function()
		self:_UpdateLeaderstat()
	end))

	local function object_added(instance, p)
		instance:GetPropertyChangedSignal("Value"):Connect(function()
			self:_UpdateLeaderstat()
		end)
		instance:GetAttributeChangedSignal("StillLoading"):Connect(function()
			self:_UpdateLeaderstat()
		end)

		if not p then
			self:_UpdateLeaderstat()
		end
	end

	table.insert(self._connections, customLeaderstats.ChildAdded:Connect(object_added))

	for _, child in pairs(customLeaderstats:GetChildren()) do
		task.spawn(object_added, child, true)
	end

	self:_UpdateLeaderstat()
end

function PlayerListSlot:_Setup()
	self.PlayerTitle.Text = Utility:GetName(self.ClientFighter.Player, self.ClientFighter.Player.DisplayName, true)
end

function PlayerListSlot:_Init()
	self.Button.MouseButton1Click:Connect(function()
		self.Clicked:Fire()
	end)
	self.Button.MouseEnter:Connect(function()
		self:_SetHovered(true)
	end)
	self.Button.MouseLeave:Connect(function()
		self:_SetHovered(false)
	end)
	self.PlayerTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateVisuals()
	end)
	self.PlayerTitle:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateVisuals()
	end)
	self.PlayerTitle:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateVisuals()
	end)
	table.insert(self._connections, self.ClientFighter:GetDataChangedSignal("Controls"):Connect(function()
		self:_UpdateIcon()
	end))
	table.insert(
		self._connections,
		self.ClientFighter.Player:GetAttributeChangedSignal("GroupRoleIDs"):Connect(function()
			self:_UpdateIcon()
		end)
	)
	table.insert(
		self._connections,
		self.ClientFighter.Player:GetAttributeChangedSignal("IsAdministrator"):Connect(function()
			self:_UpdateIcon()
		end)
	)
	table.insert(
		self._connections,
		self.ClientFighter.Player:GetAttributeChangedSignal("IsRobloxEmployee"):Connect(function()
			self:_UpdateIcon()
		end)
	)
	table.insert(
		self._connections,
		self.ClientFighter.Player:GetAttributeChangedSignal("IsInfluencer"):Connect(function()
			self:_UpdateIcon()
		end)
	)
	table.insert(
		self._connections,
		self.ClientFighter.Player:GetPropertyChangedSignal("MembershipType"):Connect(function()
			self:_UpdateIcon()
		end)
	)
	table.insert(
		self._connections,
		self.ClientFighter.Player:GetAttributeChangedSignal("DisableTeamVisuals"):Connect(function()
			self:_UpdateIcon()
		end)
	)
	table.insert(
		self._connections,
		self.ClientFighter.Player:GetAttributeChangedSignal("PlayerStatus"):Connect(function()
			self:_UpdateStatus()
		end)
	)
	table.insert(
		self._connections,
		LeaderboardController:GetLeaderboardRefreshedSignal("Highest ELO"):Connect(function()
			self:_UpdateLeaderstat()
		end)
	)
	table.insert(self._connections, UserInputService.WindowFocused:Connect(function()
		self:_UpdateVisuals()
	end))
	table.insert(self._connections, UserInputService.WindowFocusReleased:Connect(function()
		self:_UpdateVisuals()
	end))
	table.insert(self._connections, MatchmakingController:GetDataChangedSignal("MatchmadeGameOver"):Connect(function()
		self:_UpdateLeaderstat()
	end))
	self:_Setup()
	self:_UpdateIcon()
	self:_UpdateStatus()
	self:_UpdateVisuals()
	self:_UpdateHighlight()
	self:_UpdateLeaderstat()
	task.spawn(self._FetchIsFriend, self)
	task.spawn(self._FetchIsBlocked, self)
	task.spawn(self._SetupLeaderstats, self)
	ButtonEffect:Add(self.Button, true)
end

return PlayerListSlot