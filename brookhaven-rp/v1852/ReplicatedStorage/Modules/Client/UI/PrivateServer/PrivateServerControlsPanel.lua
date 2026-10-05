local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TextChatService = game:GetService("TextChatService")
local GamepadService = game:GetService("GamepadService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local KickConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.PrivateServer.KickConfirmationPanel)
local PrivateServerConstants = require(ReplicatedStorage.Modules.Shared.PrivateServer.PrivateServerConstants)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "PrivateServerControlsPanel"
})
local PSConfirmationPanel = require(ReplicatedStorage.Modules.Client.UI.PrivateServer.PSConfirmationPanel)

function v:Construct()
	self._Janitor = Janitor.new()
	self.Instance.Visible = false
	self.dbClose = false
end

function v:SwitchToTab(instance)
	if self.currentTab then
		self.currentTab.Visible = false
		self.currentTab = nil
	end

	if self.currentCheckmark then
		self.currentCheckmark.Visible = false
	end

	if self.content:FindFirstChild(instance.Name) then
		self.currentTab = self.content:WaitForChild(instance.Name)
		self.currentTab.Visible = true
		self.currentCheckmark = instance:WaitForChild("Checkmark")

		if self.currentCheckmark then
			self.currentCheckmark.Visible = true
		end
	end
end

function v:Start()
	local tabsMenu = self.Instance:WaitForChild("Top"):WaitForChild("TabsMenu")
	local list = tabsMenu:WaitForChild("List")
	self.content = self.Instance:WaitForChild("Content")
	self.checkmark = tabsMenu:WaitForChild("CheckMark")
	local close = self.Instance:WaitForChild("Close")
	self._Janitor:Add(close.MouseButton1Click:Connect(function()
		self:CloseButtonPressed()
	end))

	for _, button in list:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v2 = button
		button.MouseButton1Click:Connect(function()
			self:SwitchToTab(v2)
		end)
	end

	self:SwitchToTab((list:FindFirstChild("TimeDay")))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "ClosePanel", function()
		self:CloseButtonPressed()
	end))
	local kickConfirmationPanel = self.Instance:WaitForChild("KickConfirmationPanel")
	self.kickConfirmationPanel = ComponentUtil.GetComponentFromInstance(kickConfirmationPanel, KickConfirmationPanel)
	self.kickConfirmationPanel.Instance.Visible = false
	local areYouSure = self.Instance:WaitForChild("AreYouSure")
	self.removeAllPropsPanel = ComponentUtil.GetComponentFromInstance(areYouSure, PSConfirmationPanel)
	self.removeAllPropsPanel.Instance.Visible = false
	self._Janitor:Add(GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"):Connect(function()
		self:VirtualCursorChanged()
	end), "Disconnect", "GamepadCursorEnabledChanged")
	self.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if not self.Instance.Visible then
			return
		end

		self:VirtualCursorChanged()
	end)
	self:VirtualCursorChanged()
end

function v:CloseAllPanels()
	if self.kickConfirmationPanel then
		self.kickConfirmationPanel.Instance.Visible = false
	end

	if self.removeAllPropsPanel then
		self.removeAllPropsPanel.Instance.Visible = false
	end
end

function v:VirtualCursorChanged()
	if GamepadService.GamepadCursorEnabled then
		self._originalChatWindowHeight = TextChatService.ChatWindowConfiguration.HeightScale
		self._originalChatWindowWidth = TextChatService.ChatWindowConfiguration.WidthScale
		TweenService:Create(
			TextChatService.ChatWindowConfiguration,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				HeightScale = self._originalChatWindowHeight / 2,
				WidthScale = self._originalChatWindowWidth * 0.7
			}
		):Play()
	elseif self._originalChatWindowHeight then
		TweenService:Create(
			TextChatService.ChatWindowConfiguration,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				HeightScale = self._originalChatWindowHeight,
				WidthScale = self._originalChatWindowWidth
			}
		):Play()
		self._originalChatWindowHeight = nil
		self._originalChatWindowWidth = nil
	end
end

function v:KickPlayer(p, callback)
	self:CloseAllPanels()

	if self.kickConfirmationPanel then
		self.kickConfirmationPanel:Init(p, PrivateServerConstants.Notification.KickMessage, callback)
	else
		warn("KickConfirmationPanel not found")
	end
end

function v:BanPlayer(p, callback)
	self:CloseAllPanels()

	if self.kickConfirmationPanel then
		self.kickConfirmationPanel:Init(p, PrivateServerConstants.Notification.BanMessage, callback)
	else
		warn("BanConfirmationPanel not found")
	end
end

function v:RemoveAllProps(p: string, callback)
	self:CloseAllPanels()

	if self.removeAllPropsPanel then
		self.removeAllPropsPanel:Init(p, callback)
	else
		warn("RemoveAllPropsPanel not found")
	end
end

function v:CloseButtonPressed()
	if self.dbClose then
		return
	end

	self.dbClose = true
	task.delay(0.5, function()
		self.dbClose = false
	end)

	if self._originalChatWindowHeight then
		TweenService:Create(
			TextChatService.ChatWindowConfiguration,
			TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				HeightScale = self._originalChatWindowHeight,
				WidthScale = self._originalChatWindowWidth
			}
		):Play()
		self._originalChatWindowHeight = nil
		self._originalChatWindowWidth = nil
	end

	self:CloseAllPanels()
	PanelController.Close("PrivateServerControlsGUI", "PrivateServerControlsPanel")
end

function v:Stop()
	self._Janitor:Destroy()
end

return v