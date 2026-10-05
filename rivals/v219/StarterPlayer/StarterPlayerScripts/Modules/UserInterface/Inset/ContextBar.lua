local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PermissionsLibrary = require(ReplicatedStorage.Modules.PermissionsLibrary)
local ModerationLibrary = require(ReplicatedStorage.Modules.ModerationLibrary)
local DebugLibrary = require(ReplicatedStorage.Modules.DebugLibrary)
local ShootingRangeController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ShootingRangeController"))
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local SettingsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SettingsController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("CameraController"))
local PlayerList = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("PlayerList"))
local InsetButtonsBar = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("InsetButtonsBar"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local v = {
	{
		"StopFreecam",
		"Turn off freecam mode",
		"rbxassetid://17548980857",
		nil,
		nil,
		nil
	},
	{
		"LeaveShootingRange",
		"Leave the Shooting Range",
		"rbxassetid://17498605048",
		nil,
		nil,
		nil
	},
	{
		"PlayerList",
		"Open the player list",
		"rbxassetid://108950719202626",
		nil,
		nil,
		nil
	},
	{
		"HUD",
		"Enable your HUD",
		"rbxassetid://126633805196326",
		nil,
		nil,
		nil
	},
	{
		"Debug",
		"Test things out using commands",
		"rbxassetid://18223601855",
		nil,
		UDim2.new(0.6, 0, 0.6, 0),
		"Debug"
	},
	{
		"Moderation",
		"Search, join, & ban cheaters",
		"rbxassetid://118920750856778",
		nil,
		nil,
		"Moderation"
	},
	{
		"Permissions",
		"Promote & demote team members",
		"rbxassetid://95626460059631",
		nil,
		UDim2.new(0.75, 0, 0.75, 0),
		"Permissions"
	}
}
local ContextBar = {}
ContextBar.__index = ContextBar

function ContextBar.new(inset)
	local self = setmetatable({}, ContextBar)
	self.Inset = inset
	self.Bar = InsetButtonsBar.new(
		UILibrary.BUTTON_BACKGROUND_TRANSPARENCY,
		UILibrary.BUTTON_BACKGROUND_COLOR,
		UILibrary.BUTTON_ICON_COLOR,
		true
	)
	self._local_fighter = nil
	self:_Init()
	return self
end

function ContextBar:SetVisible(visible, p2)
	self.Bar.Frame.Visible = visible
	self.Bar.Frame.Size = p2 or self.Bar.Frame.Size
	self.Bar:Toggle(true)
end

function ContextBar:_UpdateVisibility()
	self.Bar.Buttons.StopFreecam.Frame.Visible = CameraController:GetPublicState() == CameraController.CameraState.States.CustomFreecam
	self.Bar.Buttons.PlayerList.Frame.Visible = PlayerList.ClosedByInputs and PlayerList:GetBaseVisibility()
	self.Bar.Buttons.HUD.Frame.Visible = PlayerDataController:GetSetting("Hide HUD")
	self.Bar.Buttons.LeaveShootingRange.Frame.Visible = self._local_fighter and self._local_fighter:Get("IsInShootingRange")
	self.Bar.Buttons.Debug.Frame.Visible = not PlayerDataController:GetSetting("Staff Team Tools Disabled") and DebugLibrary:CanViewDebugPage(PlayerDataController:Get("PermissionsRoles"))
	self.Bar.Buttons.Moderation.Frame.Visible = not PlayerDataController:GetSetting("Staff Team Tools Disabled") and ModerationLibrary:CanViewModerationPage(PlayerDataController:Get("PermissionsRoles"))
	self.Bar.Buttons.Permissions.Frame.Visible = not PermissionsLibrary.USE_GROUP_ROLES_INSTEAD_OF_DATASTORES and not PlayerDataController:GetSetting("Staff Team Tools Disabled Leads") and PermissionsLibrary:CanViewPermissionsPage(PlayerDataController:Get("PermissionsRoles"))
	self:SetVisible(self.Bar.Frame.Visible)
end

function ContextBar:_HookFighter()
	self._local_fighter = FighterController:WaitForLocalFighter()
	self._local_fighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:_UpdateVisibility()
end

function ContextBar:_Setup()
	for k, list in pairs(v) do
		local v2, v3, v4, v5, v6, v7 = table.unpack(list)
		self.Bar:CreateButton(k, v2, v3, v4, v5, v6).Clicked:Connect(function()
			if v7 then
				Pages.PageSystem:OpenPage(v7)
			end
		end)
	end

	self.Bar.Buttons.StopFreecam.Clicked:Connect(function()
		CameraController.CameraState:SetCustomFreecamEnabled(false)
	end)
	self.Bar.Buttons.LeaveShootingRange.Clicked:Connect(function()
		ShootingRangeController:Leave()
	end)
	self.Bar.Buttons.PlayerList.Clicked:Connect(function()
		PlayerList:SetClosedByInputs(not PlayerList.ClosedByInputs)
	end)
	self.Bar.Buttons.HUD.Clicked:Connect(function()
		SettingsController:ChangeSetting("Hide HUD", false)
	end)
	self.Bar.Frame.Parent = self.Inset.RightButtonsFrame
end

function ContextBar:_Init()
	PlayerDataController:GetSettingChangedSignal("Staff Team Tools Disabled"):Connect(function()
		self:_UpdateVisibility()
	end)
	PlayerDataController:GetSettingChangedSignal("Staff Team Tools Disabled Leads"):Connect(function()
		self:_UpdateVisibility()
	end)
	PlayerDataController:GetSettingChangedSignal("Hide HUD"):Connect(function()
		self:_UpdateVisibility()
	end)
	PlayerDataController:GetDataChangedSignal("PermissionsRoles"):Connect(function()
		self:_UpdateVisibility()
	end)
	PlayerList.ClosedByInputsChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	PlayerList.BaseVisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	CameraController.CustomFreecamStateChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	CameraController.CameraState.FreecamAccessChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	self:_Setup()
	self:_UpdateVisibility()
	task.defer(self._HookFighter, self)
end

return ContextBar