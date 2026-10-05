local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PrivateServerController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PrivateServerController"))
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local QueuePadController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("QueuePadController"))
local PartyController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PartyController"))
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("DuelController"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Pages"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local uDim = UDim2.new(1.25, 0, 0.5, 0)
local uDim2 = UDim2.new(0, 0, 0.5, 0)
local playerListInspectActionSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PlayerListInspectActionSlot")
local v = {
	HoverRatio = 1,
	ReleaseRatio = 1
}
local v2 = {
	{
		"Invite",
		"Party Invite",
		Color3.fromRGB(100, 255, 0),
		"rbxassetid://89570813431745",
		0.55
	},
	{
		"Friend",
		"Add Friend",
		Color3.fromRGB(100, 255, 0),
		"rbxassetid://95245645462537"
	},
	{
		"Challenge",
		"Challenge",
		Color3.fromRGB(255, 150, 0),
		"rbxassetid://18525954682"
	},
	{
		"Spectate",
		"Spectate",
		Color3.fromRGB(255, 150, 0),
		"rbxassetid://77908042044589"
	},
	{
		"ViewProfile",
		"View Profile",
		Color3.fromRGB(0, 150, 255),
		"rbxassetid://113844621753627",
		0.65
	},
	{
		"ViewAvatar",
		"View Avatar",
		Color3.fromRGB(0, 150, 255),
		"rbxassetid://113844621753627",
		0.65
	},
	{
		"Gift",
		"Send Gift",
		Color3.fromRGB(255, 149, 253),
		"rbxassetid://127400882945494",
		0.65
	},
	{
		"Unfriend",
		"Remove Friend",
		Color3.fromRGB(255, 50, 50),
		"rbxassetid://99528569460280"
	},
	{
		"Block",
		"Block",
		Color3.fromRGB(255, 50, 50),
		"rbxassetid://71490041005019"
	},
	{
		"Unblock",
		"Unblock",
		Color3.fromRGB(255, 50, 50),
		"rbxassetid://71490041005019"
	},
	{
		"Kick",
		"Server Kick",
		Color3.fromRGB(255, 50, 50),
		"rbxassetid://76417427319315",
		0.65
	},
	{
		"Ban",
		"Server Ban",
		Color3.fromRGB(255, 50, 50),
		"rbxassetid://76417427319315"
	}
}
local Inspect = {}
Inspect.__index = Inspect

function Inspect.new(playerList)
	local self = setmetatable({}, Inspect)
	self.PlayerList = playerList
	self.Frame = self.PlayerList.Container:WaitForChild("Inspect")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.PlayerFrame = self.Container:WaitForChild("Player")
	self.PlayerHeadshot = self.PlayerFrame:WaitForChild("Headshot")
	self.PlayerUsername = self.PlayerFrame:WaitForChild("Username")
	self.PlayerDisplayName = self.PlayerFrame:WaitForChild("DisplayName")
	self._selected_player_list_slot = false
	self._action_slots = {}
	self:_Init()
	return self
end

function Inspect.SetScale(p, p2)
	p.Frame.Size = UDim2.new(0.95 * p2, 0, 5, 0)
end

function Inspect:SelectPlayer(selected_player_list_slot)
	if selected_player_list_slot == self._selected_player_list_slot or selected_player_list_slot and not self.PlayerList.IsOpen then
		return
	end

	self._selected_player_list_slot = selected_player_list_slot

	for _, playerListSlot in pairs(self.PlayerList.Elements.PlayerListSlots) do
		playerListSlot:SetHighlighted(self._selected_player_list_slot == playerListSlot)
	end

	local uDim3

	if self._selected_player_list_slot then
		uDim3 = UDim2.new(
			0,
			-4,
			0,
			self._selected_player_list_slot.Frame.AbsolutePosition.Y - self.PlayerList.Container.AbsolutePosition.Y
		)
	else
		uDim3 = self.Frame.Position
	end

	local position

	if self._selected_player_list_slot then
		position = uDim2
	else
		position = uDim
	end

	self.Frame.Position = uDim3
	local container = self.Container
	local position2

	if self._selected_player_list_slot then
		position2 = uDim
	else
		position2 = self.Container.Position
	end

	container.Position = position2

	if self.Container:IsDescendantOf(Players.LocalPlayer.PlayerGui) then
		self.Container:TweenPosition(position, "Out", "Quint", 0.25, true)
	else
		self.Container.Position = position
	end

	if not self._selected_player_list_slot then
		return
	end

	local player = self._selected_player_list_slot.ClientFighter.Player
	local isLocalPlayer = self._selected_player_list_slot.ClientFighter.IsLocalPlayer
	local isBlocked = self._selected_player_list_slot:IsBlocked()
	local v5 = not isBlocked and self._selected_player_list_slot:IsFriend()
	local IS_PRIVATE_SERVER_OWNER = CONSTANTS.IS_PRIVATE_SERVER_OWNER(Players.LocalPlayer.UserId)
	self._action_slots.Invite.Visible = not isBlocked and PartyController:CanInvitePlayerToParty(player)
	self._action_slots.Friend.Visible = not (isBlocked or v5) and not isLocalPlayer and true
	self._action_slots.Challenge.Visible = not isBlocked and QueuePadController:CanChallenge(player)
	self._action_slots.Spectate.Visible = not isBlocked and DuelController:GetDuel(player) ~= nil
	self._action_slots.ViewProfile.Visible = not isBlocked
	self._action_slots.ViewAvatar.Visible = not isBlocked
	self._action_slots.Unfriend.Visible = not isBlocked and v5 and not isLocalPlayer and true
	self._action_slots.Block.Visible = not (isBlocked or isLocalPlayer)
	self._action_slots.Unblock.Visible = isBlocked and not isLocalPlayer
	self._action_slots.Gift.Visible = not (isBlocked or isLocalPlayer)
	self._action_slots.Kick.Visible = not isLocalPlayer and IS_PRIVATE_SERVER_OWNER
	self._action_slots.Ban.Visible = not isLocalPlayer and IS_PRIVATE_SERVER_OWNER
	self.PlayerHeadshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, player.UserId)
	self.PlayerDisplayName.Text = Utility:GetName(
		self._selected_player_list_slot.ClientFighter.Player,
		player.DisplayName,
		true
	)
	self.PlayerUsername.Text = "@" .. player.Name
	WeaponStatusHandler:ClearStatusElements(self.PlayerDisplayName)
	WeaponStatusHandler:ApplyItemStatusToText(self.PlayerDisplayName, player:GetAttribute("PlayerStatus"))
	self:_UpdateCooldowns()
end

function Inspect:OnOpened()
	self.PlayerList:AddOpenedConnection(QueuePadController.ChallengeRequestCooldownChanged:Connect(function()
		self:_UpdateCooldowns()
	end))
	self.PlayerList:AddOpenedConnection(PartyController.InviteRequestCooldownChanged:Connect(function()
		self:_UpdateCooldowns()
	end))
	self.PlayerList:AddOpenedConnection(UserInputService.InputBegan:Connect(function(input)
		if UILibrary:IsMouseWithinBounds(self.Container.AbsolutePosition, self.Layout.AbsoluteContentSize) or UILibrary:IsMouseWithinBounds(
			self.PlayerList.Elements.Frame.AbsolutePosition,
			self.PlayerList.Elements.Frame.AbsoluteSize
		) then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self:SelectPlayer(nil)
		end
	end))
	self:_UpdateCooldowns()
end

function Inspect:_UpdateCooldowns()
	local player = self._selected_player_list_slot and self._selected_player_list_slot.ClientFighter.Player
	self._action_slots.Challenge.Button.Cooldown.Visible = player and QueuePadController:IsChallengeRequestOnCooldown(player)
	self._action_slots.Challenge.Button.Icon.Visible = not self._action_slots.Challenge.Button.Cooldown.Visible
	self._action_slots.Invite.Button.Cooldown.Visible = player and PartyController:IsInviteRequestOnCooldown(player)
	self._action_slots.Invite.Button.Icon.Visible = not self._action_slots.Invite.Button.Cooldown.Visible
end

function Inspect:_SlotAdded(object)
	object.Clicked:Connect(function()
		local v4

		if self._selected_player_list_slot ~= object then
			v4 = object
		end

		self:SelectPlayer(v4)
	end)
	object:SetHighlighted(self._selected_player_list_slot == object)
end

function Inspect:_Setup()
	for _, list in pairs(v2) do
		local v3, text, imageColor, image, v7 = table.unpack(list)
		local clone = playerListInspectActionSlot:Clone()
		clone.Button.Background.ImageColor3 = imageColor
		clone.Button.Icon.Image = image
		clone.Button.Icon.Size = UDim2.new(0.2, 0, v7 or 0.75, 0)
		clone.Button.Title.Text = text
		clone.Parent = self.Container
		self._action_slots[v3] = clone
		ButtonEffect:Add(clone.Button, nil, v)

		local function unhover()
			clone.Button.Background.ImageColor3 = imageColor
			clone.Button.Background.ImageTransparency = 0.5
			clone.Button.Background.UIGradient.Enabled = true
			clone.Button.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
			clone.Button.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
		end

		clone.Button.MouseLeave:Connect(unhover)
		local v10 = clone

		local function hover()
			v10.Button.Background.ImageColor3 = Color3.fromRGB(255, 255, 255)
			v10.Button.Background.ImageTransparency = 0
			v10.Button.Background.UIGradient.Enabled = false
			v10.Button.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
			v10.Button.Title.TextColor3 = Color3.fromRGB(0, 0, 0)
		end

		clone.Button.MouseEnter:Connect(hover)
	end

	self._action_slots.Invite.Button.MouseButton1Click:Connect(function()
		PartyController:SendPartyInvite(self._selected_player_list_slot.ClientFighter.Player)
	end)
	self._action_slots.Friend.Button.MouseButton1Click:Connect(function()
		StarterGui:SetCore("PromptSendFriendRequest", self._selected_player_list_slot.ClientFighter.Player)
	end)
	self._action_slots.Challenge.Button.MouseButton1Click:Connect(function()
		QueuePadController:SendChallengeRequest(self._selected_player_list_slot.ClientFighter.Player)
	end)
	self._action_slots.Spectate.Button.MouseButton1Click:Connect(function()
		self._action_slots.Spectate.Visible = false
		local duel = DuelController:GetDuel(self._selected_player_list_slot.ClientFighter.Player)

		if duel then
			SpectateController:SpectateDuelRequest(duel)
		end
	end)
	self._action_slots.ViewProfile.Button.MouseButton1Click:Connect(function()
		local player = self._selected_player_list_slot.ClientFighter.Player
		Pages.PageSystem:OpenPage("ViewProfile")
		Pages.PageSystem:WaitForPage("ViewProfile"):Fetch(player)
	end)
	self._action_slots.ViewAvatar.Button.MouseButton1Click:Connect(function()
		GuiService:InspectPlayerFromUserId(self._selected_player_list_slot.ClientFighter.Player.UserId)
	end)
	self._action_slots.Unfriend.Button.MouseButton1Click:Connect(function()
		StarterGui:SetCore("PromptUnfriend", self._selected_player_list_slot.ClientFighter.Player)
	end)
	self._action_slots.Block.Button.MouseButton1Click:Connect(function()
		StarterGui:SetCore("PromptBlockPlayer", self._selected_player_list_slot.ClientFighter.Player)
	end)
	self._action_slots.Unblock.Button.MouseButton1Click:Connect(function()
		StarterGui:SetCore("PromptUnblockPlayer", self._selected_player_list_slot.ClientFighter.Player)
	end)
	self._action_slots.Gift.Button.MouseButton1Click:Connect(function()
		local player = self._selected_player_list_slot.ClientFighter.Player
		Pages.PageSystem:OpenPage("Gifting")
		Pages.PageSystem:WaitForPage("Gifting"):SelectPlayer(player)
		Pages.PageSystem:WaitForPage("Gifting"):DontRedirect()
	end)
	self._action_slots.Kick.Button.MouseButton1Click:Connect(function()
		PrivateServerController:ServerKick(self._selected_player_list_slot.ClientFighter.Player)
	end)
	self._action_slots.Ban.Button.MouseButton1Click:Connect(function()
		PrivateServerController:ServerBan(self._selected_player_list_slot.ClientFighter.Player)
	end)
end

function Inspect:_Init()
	self.PlayerList.OpenedChanged:Connect(function()
		if not self.PlayerList.IsOpen then
			self:SelectPlayer(nil)
		end
	end)
	self.PlayerList.Elements.PlayerListSlotRemoved:Connect(function(p)
		if p == self._selected_player_list_slot then
			self:SelectPlayer(nil)
		end
	end)
	self.PlayerList.Elements.PlayerListSlotAdded:Connect(function(p)
		self:_SlotAdded(p)
	end)

	for _, playerListSlot in pairs(self.PlayerList.Elements.PlayerListSlots) do
		task.defer(self._SlotAdded, self, playerListSlot)
	end

	self:_Setup()
	self:SelectPlayer(nil)
end

return Inspect