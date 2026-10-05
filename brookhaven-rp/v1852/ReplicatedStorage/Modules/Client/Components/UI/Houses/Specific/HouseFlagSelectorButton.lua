local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local CountrySelectorPanel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.CountrySelectorPanel)
require(ReplicatedStorage.Packages.Remotes)
local PlayerLocalizationConstants = require(ReplicatedStorage.Modules.Shared.Player.PlayerLocalizationConstants)
local PlayerLocalizationController = require(ReplicatedStorage.Modules.Client.Player.PlayerLocalizationController)
local v = Component.new({
	Tag = "HouseFlagSelectorButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:OnCountrySelected(p)
	if self.debounce then
		return
	end

	self.debounce = true
	self.playersHouseRemote:FireServer("ChangeFlag", p)
	task.wait(0.3)
	self.debounce = false
end

function v:Start()
	self.debounce = false
	self.playersHouseRemote = ReplicatedStorage.RE:WaitForChild("1Player1sHous1e")
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		if PanelController.IsOpen("MainGUIHandler", "CountrySelectorPanel") then
			PanelController.Close("MainGUIHandler", "CountrySelectorPanel")
			return
		end

		PanelController.OpenPanelByContext("MainGUIHandler", "CountrySelectorPanel")
		local panel = PanelController.GetPanel("MainGUIHandler", "CountrySelectorPanel")
		local component = ComponentUtil.GetComponentFromInstance(panel.Instance, CountrySelectorPanel)

		if not component then
			return
		end

		component:Init(function(p)
			self:OnCountrySelected(p)
		end, "")
	end))
	local countryRegion = PlayerLocalizationController:GetCountryRegion()

	for _, v2 in PlayerLocalizationConstants.CountryRegion do
		if v2.Code ~= countryRegion then
			continue
		end

		self:OnCountrySelected(v2)
		break
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v