local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Timer = require(ReplicatedStorage.Packages.Timer)
require(ReplicatedStorage.Modules.Shared.Utils.BasePartUtil)
local AdIntegrationsController = require(ReplicatedStorage.Modules.Client.Ads.AdIntegrationsController)
local v = Component.new({
	Tag = "AdIntegrationViewCheck"
})

function v:isLocalPlayerInView(p2)
	if Players.LocalPlayer.Character == nil then
		return false
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera == nil or (currentCamera.CFrame.Position - p2.Position).Magnitude > self.radius then
		return false
	end

	local _, v2 = currentCamera:WorldToScreenPoint(p2.Position)

	if v2 then
		return true
	end

	return false
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.integrationName = self.Instance:GetAttribute("IntegrationName")
	self.radius = self.Instance:GetAttribute("RadiusToCheck") or 80
	self.adGUI = self.Instance:FindFirstChildWhichIsA("AdGUI")
	self.isAdActive = false

	if self.adGUI then
		self.isAdActive = self.adGUI.Status == Enum.AdUnitStatus.Active
		self._Janitor:Add(self.adGUI:GetPropertyChangedSignal("Status"):Connect(function()
			if self.adGUI.Status == Enum.AdUnitStatus.Active then
				self.isAdActive = true
			else
				self.isAdActive = false
			end
		end))
	end

	local v2 = 1 + math.random(1, 100) / 100
	self._timer = Timer.new(v2)
	self.isPlayerInZone = false
	self.currentLabelHash = nil
	self._Janitor:Add(self._timer.Tick:Connect(function()
		local localPlayerInView = self:isLocalPlayerInView(self.Instance)

		if localPlayerInView == self.isPlayerInZone then
			return
		end

		self.isPlayerInZone = localPlayerInView

		if localPlayerInView and not self.isAdActive then
			if not self.currentLabelHash then
				self.currentLabelHash = AdIntegrationsController.DisplayAdLabel(self.integrationName)
			end
		else
			AdIntegrationsController.HideAdLabel(self.currentLabelHash)
			self.currentLabelHash = nil
		end
	end))
	self._Janitor:Add(self._timer)
	self._timer:Start()
end

function v:Stop()
	if self.currentLabelHash then
		AdIntegrationsController.HideAdLabel(self.currentLabelHash)
	end

	self._Janitor:Destroy()
end

return v