local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local FamilyController = require(ReplicatedStorage.Modules.Client.UI.Family.FamilyController)
local FamilyRoles = require(ReplicatedStorage.Modules.Shared.Family.FamilyRoles)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local v = Component.new({
	Tag = "FamilyManagement"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._activeSelectors = {}
end

function v:SetupHideInvitesButton()
	if FamilyController.AreInvitesHidden() then
		self._bottom.SettingButtons.HideInvites.Box:AddTag("Checked")
	else
		self._bottom.SettingButtons.HideInvites.Box:RemoveTag("Checked")
	end
end

function v:Start()
	self._bottom = self.Instance:WaitForChild("Bottom")
	self._selectors = self.Instance:WaitForChild("Selectors"):WaitForChild("List")
	self._createFamilyButton = self._selectors:FindFirstChild("CreateFamily")
	self._invitePlayerButton = self._selectors:FindFirstChild("InvitePlayer")
	self._playerInfoTemplate = self._selectors:FindFirstChild("PlayerInfo")
	self._createFamilyButton.Visible = true
	self._invitePlayerButton.Visible = false
	self._playerInfoTemplate.Visible = false
	self._Janitor:Add(self._selectors.CreateFamily.Activated:Connect(function()
		Remotes.fireServer("CreateFamily")
	end))
	self._Janitor:Add(self._selectors.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self._selectors.CanvasSize = UDim2.fromOffset(0, self._selectors.UIListLayout.AbsoluteContentSize.Y + 10)
	end))
	self._Janitor:Add(self._invitePlayerButton.Activated:Connect(function()
		PanelController.ToggleGroup("FamilyPrompts", false)
		PanelController.Open("MainGUIHandler", "FamilyInvitePlayers")
	end))
	self._Janitor:Add(self.Instance.LeaveFamily.Activated:Connect(function()
		PanelController.ToggleGroup("FamilyPrompts", false)
		PanelController.OpenPanelByContext("MainGUIHandler", "LeaveFamily")
	end))
	self:SetupBottomButtons()
	self:StateUpdated(nil)
end

function v:SetupBottomButtons()
	self._Janitor:Add(self._bottom.SettingButtons.HideInvites.Box.Activated:Connect(function()
		FamilyController.ToggleHideInvites()
	end))
	self._Janitor:Add(self._bottom.SettingButtons.HideFamily.Box.Activated:Connect(function()
		FamilyController.ToggleHideFamily()

		if FamilyController.IsFamilyHidden() then
			self._bottom.SettingButtons.HideFamily.Box:AddTag("Checked")
		else
			self._bottom.SettingButtons.HideFamily.Box:RemoveTag("Checked")
		end
	end))
	self._Janitor:Add(FamilyController.FamilyStateChanged:Connect(function(p)
		self:StateUpdated(p)
	end))
	self:SetupHideInvitesButton()
	FamilyController.HideInvitesChanged:Connect(function(_)
		self:SetupHideInvitesButton()
	end)
end

function v:StateUpdated(items)
	for _, guiObject in self._selectors:GetChildren() do
		if not (guiObject:IsA("GuiObject") and guiObject ~= self._createFamilyButton and guiObject ~= self._invitePlayerButton and guiObject ~= self._playerInfoTemplate) then
			continue
		end

		guiObject:Destroy()
	end

	if items then
		self._createFamilyButton.Visible = false
		self._invitePlayerButton.Visible = true
		self.Instance.LeaveFamily.Visible = true
		self._bottom.SettingButtons.HideFamily.Visible = true

		for _, item in items do
			local clone = self._playerInfoTemplate:Clone()
			clone.Name = item.player.Name
			clone.PlayerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={item.player.UserId}&w=150&h=150`
			clone.PlayerName.Text = item.player.DisplayName
			clone.Role.Text = item.role or FamilyRoles[1]
			clone.Visible = true
			local visible = item.player == Players.LocalPlayer
			clone.LayoutOrder = visible and 0 or 1
			clone.Edit.Visible = visible

			if visible and not item.role and UserInputService.MouseEnabled then
				clone.Role.Text = "Click to change role"
			elseif visible and not (item.role or UserInputService.MouseEnabled) then
				clone.Role.Text = "Tap to change role"
			end

			if visible then
				self._Janitor:Add(clone.Activated:Connect(function()
					PanelController.ToggleGroup("FamilyPrompts", false)
					PanelController.Open("MainGUIHandler", "FamilyRoleSelection")
				end))
			end

			clone.Parent = self._selectors
		end

		Platform.Select(self.Instance)
	else
		self._createFamilyButton.Visible = true
		self._invitePlayerButton.Visible = false
		self.Instance.LeaveFamily.Visible = false
		self._bottom.SettingButtons.HideFamily.Visible = false
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v