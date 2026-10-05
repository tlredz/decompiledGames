local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
require(ReplicatedStorage.Modules.DebugLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("CameraController"))
local InsetButtonsBar = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("InsetButtonsBar"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local Inbox = require(Players.LocalPlayer.PlayerScripts.Modules.Pages:WaitForChild("Inbox"))
local inboxNotification = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("InboxNotification")
local v = {
	{
		"Open",
		"See more",
		"rbxassetid://14641612286",
		nil,
		nil,
		nil
	},
	{
		"Settings",
		"Change your crosshair & hotkeys",
		"rbxassetid://14641612286",
		nil,
		nil,
		"Settings"
	},
	{
		"PatchNotes",
		"Read the latest news",
		"rbxassetid://18457336026",
		nil,
		nil,
		"PatchNotes"
	},
	{
		"Restrictions",
		"",
		"rbxassetid://120647688402991",
		nil,
		nil,
		nil
	},
	{
		"Inbox",
		"View your recent notifications",
		"rbxassetid://96509180790493",
		nil,
		nil,
		"Inbox"
	},
	{
		"PrivateServerControls",
		"Edit your private server",
		"rbxassetid://12343093905",
		nil,
		nil,
		"PrivateServerControls"
	},
	{
		"MobileEditor",
		"Move & resize your touch buttons",
		"rbxassetid://98757786697658",
		UDim2.new(0.525, 0, 0.525, 0),
		UDim2.new(0.55, 0, 0.55, 0),
		nil
	},
	{
		"Freecam",
		"Turn on freecam mode",
		"rbxassetid://17548980857",
		nil,
		nil,
		nil
	}
}
local MainBar = {}
MainBar.__index = MainBar

function MainBar.new(inset)
	local self = setmetatable({}, MainBar)
	self.Inset = inset
	self.Bar = InsetButtonsBar.new(
		UILibrary.BUTTON_BACKGROUND_TRANSPARENCY,
		UILibrary.BUTTON_BACKGROUND_COLOR,
		UILibrary.BUTTON_ICON_COLOR,
		true
	)
	self._inbox_notification_frame = inboxNotification:Clone()
	self:_Init()
	return self
end

function MainBar.GetNotificationGoal(p)
	if p.Bar.IsOpen then
		return p.Bar.Buttons.Inbox
	end

	return p.Bar.Buttons.Open
end

function MainBar:SetVisible(visible, p2)
	self.Bar.Frame.Visible = visible
	self.Bar.Frame.Size = p2 or self.Bar.Frame.Size
	local bar = self.Bar
	local v2

	if self.Bar.Frame.Visible then
		v2 = self.Bar.IsOpen
	else
		v2 = false
	end

	bar:Toggle(v2)
end

function MainBar:_UpdateRestrictions()
	local v2 = PlayerDataController:Get("WinsFromDuelPadsToday") >= CONSTANTS.MAX_DUEL_PAD_WINS_PER_DAY_BEFORE_BEING_BLOCKED
	local isRestrictedFromCasualLeaderboards = PlayerDataController:Get("IsRestrictedFromCasualLeaderboards")
	local isRestrictedFromCompetitiveLeaderboards = PlayerDataController:Get("IsRestrictedFromCompetitiveLeaderboards")
	local v3 = (("" .. (v2 and "You've reached the max amount of wins from duel pads today\n" or "")) .. (isRestrictedFromCasualLeaderboards and "You've been restricted from casual leaderboards due to your ban history\n" or "")) .. (isRestrictedFromCompetitiveLeaderboards and "You've been restricted from competitive leaderboards due to your ban history\n" or "")
	local v4 = v3 == "" and "" or string.sub(v3, 1, #v3 - 1)
	self.Bar.Buttons.Restrictions:SetBubbleText(v4)
	self.Bar.Buttons.Restrictions.Frame.Visible = v4 ~= ""
end

function MainBar:_UpdateFreecam()
	local hasFreecamAccess = CameraController.CameraState:HasFreecamAccess()
	local v2 = CameraController:GetPublicState() == CameraController.CameraState.States.CustomFreecam
	self.Bar.Buttons.Freecam.Frame.Visible = hasFreecamAccess and not v2 and ControlsController.CurrentControls == "MouseKeyboard"
end

function MainBar:_UpdateInbox()
	local numNewNotifications = Inbox:GetNumNewNotifications()
	self.Bar.Buttons.Inbox.Frame.Visible = Inbox:GetNumNotifications() > 0
	self._inbox_notification_frame.Title.Text = Utility:PrettyNumber(numNewNotifications)
	local _inbox_notification_frame = self._inbox_notification_frame
	local button

	if not (numNewNotifications <= 0) then
		if self.Bar.IsOpen then
			button = self.Bar.Buttons.Inbox.Frame.Button
		else
			button = self.Bar.Buttons.Open.Frame.Button
		end
	end

	_inbox_notification_frame.Parent = button
end

function MainBar:_UpdateOpenButton()
	local open = self.Bar.Buttons.Open
	local image = open.Frame.Button.Icon.Image
	open.Frame.Button.OnHover.Bubble.Container.Title.Text = self.Bar.IsOpen and "See less" or "See more"
	open.Frame.Button.Icon.Image = self.Bar.IsOpen and "rbxassetid://108220438104376" or "rbxassetid://14641612286"

	if open.Frame.Button.Icon.Image ~= image then
		if open.Frame.Button:IsDescendantOf(Players) then
			open.Frame.Button.Icon.Size = UDim2.new(0, 0, 0, 0)
			open.Frame.Button.Icon:TweenSize(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quint", 0.25, true)
		else
			open.Frame.Button.Icon.Size = UDim2.new(0.5, 0, 0.5, 0)
		end
	end
end

function MainBar:_UpdateMobileEditorVisibility()
	local visible = ControlsController.CurrentControls == "Touch"
	self.Bar.Buttons.MobileEditor.Frame.Visible = visible

	if self.Inset.MobileEditorBar.Bar.Frame.Visible and not visible then
		self.Inset.MobileEditorBar:SetVisible(false)
	end
end

function MainBar:_Setup()
	for k, list in pairs(v) do
		local v2, v3, v4, v5, v6, v7 = table.unpack(list)
		self.Bar:CreateButton(k, v2, v3, v4, v5, v6).Clicked:Connect(function()
			if v7 then
				Pages.PageSystem:OpenPage(v7)
			end
		end)
	end

	self.Bar.Buttons.Open.Clicked:Connect(function()
		self.Bar:Toggle()
	end)
	self.Bar.Buttons.MobileEditor.Clicked:Connect(function()
		self.Inset.MobileEditorBar:SetVisible(true, self.Bar.Frame.Size)
	end)
	self.Bar.Buttons.Freecam.Clicked:Connect(function()
		CameraController.CameraState:SetCustomFreecamEnabled(CameraController:GetPublicState() ~= CameraController.CameraState.States.CustomFreecam)
	end)
	self.Bar.Buttons.PrivateServerControls.Frame.Visible = CONSTANTS.IS_PRIVATE_HUB_SERVER and CONSTANTS.IS_PRIVATE_SERVER_OWNER(Players.LocalPlayer.UserId)
	self.Bar.Buttons.Open.Frame.Visible = true
end

function MainBar:_Init()
	self.Bar.OpenedChanged:Connect(function()
		self:_UpdateOpenButton()
		self:_UpdateInbox()
	end)
	Inbox.NotificationAdded:Connect(function()
		self:_UpdateInbox()
	end)
	Inbox.NotificationQueued:Connect(function()
		self:_UpdateInbox()
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_UpdateMobileEditorVisibility()
		self:_UpdateFreecam()
	end)
	CameraController.CustomFreecamStateChanged:Connect(function()
		self:_UpdateFreecam()
	end)
	CameraController.CameraState.FreecamAccessChanged:Connect(function()
		self:_UpdateFreecam()
	end)
	PlayerDataController:GetDataChangedSignal("IsBadGuy"):Connect(function()
		self:_UpdateRestrictions()
	end)
	PlayerDataController:GetDataChangedSignal("IsBadGuy2"):Connect(function()
		self:_UpdateRestrictions()
	end)
	PlayerDataController:GetDataChangedSignal("WinsFromDuelPadsToday"):Connect(function()
		self:_UpdateRestrictions()
	end)
	self:_Setup()
	self:_UpdateInbox()
	self:_UpdateFreecam()
	self:_UpdateOpenButton()
	self:_UpdateRestrictions()
	self:_UpdateMobileEditorVisibility()
	self:SetVisible(true)
end

return MainBar