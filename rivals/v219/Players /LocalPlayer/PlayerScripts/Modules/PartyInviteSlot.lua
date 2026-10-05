local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local QueuePadController = require(Players.LocalPlayer.PlayerScripts.Controllers.QueuePadController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local SocialController = require(Players.LocalPlayer.PlayerScripts.Controllers.SocialController)
local PartyController = require(Players.LocalPlayer.PlayerScripts.Controllers.PartyController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local partyInviteSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PartyInviteSlot")
local PartyInviteSlot = {}
PartyInviteSlot.__index = PartyInviteSlot

function PartyInviteSlot.new(player_object, userId, displayName, name)
	local self = setmetatable({}, PartyInviteSlot)
	self.Frame = partyInviteSlot:Clone()
	self._destroyed = false
	self._player_object = player_object

	if not userId then
		if self._player_object then
			userId = self._player_object.UserId or nil
		else
			userId = nil
		end
	end

	self._user_id = userId

	if not displayName then
		if self._player_object then
			displayName = self._player_object.DisplayName or nil
		else
			displayName = nil
		end
	end

	self._display_name = displayName

	if not name then
		if self._player_object then
			name = self._player_object.Name or nil
		else
			name = nil
		end
	end

	self._username = name
	self:_Init()
	return self
end

function PartyInviteSlot:StillHere()
	return self._player_object and self._player_object.Parent == Players
end

function PartyInviteSlot:GetUserID()
	return self._user_id
end

function PartyInviteSlot:UpdateCooldowns()
	self.Frame.Buttons.Challenge.Button.Off.Visible = QueuePadController:IsChallengeRequestOnCooldown(self._player_object)
	self.Frame.Buttons.Challenge.Button.On.Visible = not self.Frame.Buttons.Challenge.Button.Off.Visible
	self.Frame.Buttons.Invite.Button.Off.Visible = PartyController:IsInviteRequestOnCooldown(self._player_object)
	self.Frame.Buttons.Invite.Button.On.Visible = not self.Frame.Buttons.Invite.Button.Off.Visible
end

function PartyInviteSlot:Destroy()
	self._destroyed = true
	self.Frame:Destroy()
end

function PartyInviteSlot:_Update()
	self.Frame.DisplayName.Controls.Position = UDim2.new(0, self.Frame.DisplayName.TextBounds.X, 0.5, 0)
end

function PartyInviteSlot:_CheckFriendsWith()
	if self._destroyed or not SocialController:IsFriendsWith(self._user_id) then
		return
	end

	self.Frame.Name = "Friends"
	self.Frame.LayoutOrder += 999999
end

function PartyInviteSlot:_Setup()
	local fighter = FighterController:GetFighter(self._player_object)
	self.Frame.Buttons.Challenge.Visible = QueuePadController:CanChallenge(self._player_object)
	self.Frame.Buttons.Invite.Visible = PartyController:CanInvitePlayerToParty(self._player_object)
	self.Frame.Buttons.InviteExternal.Visible = not self._player_object
	self.Frame.Icon.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, self._user_id)
	self.Frame.DisplayName.Controls.Image = fighter and CONSTANTS.CONTROLS_IMAGES[fighter:Get("Controls")] or ""
	self.Frame.DisplayName.Text = self._player_object and ComplianceController:GetName(self._player_object) or self._display_name or ""
	self.Frame.Username.Text = self._player_object and "@" .. self._player_object.Name or not self._username and "" or "@" .. self._username or ""
	self.Frame.Name = "Lobby"
	self.Frame.LayoutOrder = 0
end

function PartyInviteSlot:_Init()
	self.Frame.DisplayName:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_Update()
	end)
	self.Frame.Buttons.Challenge.Button.MouseButton1Click:Connect(function()
		QueuePadController:SendChallengeRequest(self._player_object)
	end)
	self.Frame.Buttons.Invite.Button.MouseButton1Click:Connect(function()
		PartyController:SendPartyInvite(self._player_object)
	end)
	self.Frame.Buttons.InviteExternal.Button.MouseButton1Click:Connect(function()
		local experienceInviteOptions = Instance.new("ExperienceInviteOptions")
		experienceInviteOptions.PromptMessage = "Invite to your party!"
		experienceInviteOptions.InviteMessageId = "466fc19d-8334-514f-80e7-cba27e22bc22"
		experienceInviteOptions.InviteUser = self._user_id
		experienceInviteOptions.LaunchData = HttpService:JSONEncode({
			PartyInviteHash = ReplicatedStorage.Remotes.Matchmaking.RequestPartyInviteData:InvokeServer()
		})
		SocialService:PromptGameInvite(Players.LocalPlayer, experienceInviteOptions)
		self.Frame.Buttons.InviteExternal.Button.On.Visible = false
		self.Frame.Buttons.InviteExternal.Button.Off.Visible = true
	end)
	self:_Setup()
	self:_Update()
	self:UpdateCooldowns()
	task.defer(self._CheckFriendsWith, self)
	ButtonEffect:Add(self.Frame.Buttons.Invite.Button)
	ButtonEffect:Add(self.Frame.Buttons.InviteExternal.Button)
	ButtonEffect:Add(self.Frame.Buttons.Challenge.Button)
end

return PartyInviteSlot