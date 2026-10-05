local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local PlayerLocalizationConstants = require(ReplicatedStorage.Modules.Shared.Player.PlayerLocalizationConstants)
local PlayerLocalizationController = require(ReplicatedStorage.Modules.Client.Player.PlayerLocalizationController)
local v = Component.new({
	Tag = "PropertyFlagInstance"
})
local PropertyPermissions = require(ReplicatedStorage.Modules.Client.Components.Housing.PropertyPermissions)
local CountrySelectorPanel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.House.CountrySelectorPanel)
local Remotes = require(ReplicatedStorage.Packages.Remotes)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:GetCountryFromCode(p: string)
	local v2 = nil

	for _, v3 in PlayerLocalizationConstants.CountryRegion do
		if v3.Code == p then
			return v3
		end

		if v3.Code == "OTHER" then
			v2 = v3
		end
	end

	return v2
end

function v:UpdateFlag(p: string)
	local countryFromCode = self:GetCountryFromCode(p)

	if not countryFromCode then
		return
	end

	local v2 = tonumber(countryFromCode.AssetId:match("%d+"))
	local content = Content.fromAssetId(v2)

	for _, instance in self.cachedFlags do
		if instance:IsA("ImageLabel") then
			instance.Image = countryFromCode.AssetId
		elseif instance:IsA("Decal") then
			instance.ColorMapContent = content
		end
	end
end

function v:Start()
	self.clickDetector = self.Instance:WaitForChild("ClickDetector")
	self.localFlag = self.Instance:GetAttribute("LocalFlag")

	if self.localFlag then
		self.cachedFlags = {}

		for _, descendant in self.Instance:GetDescendants() do
			if not (descendant.Name == "FlagImage" and (descendant:IsA("ImageLabel") or descendant:IsA("Decal"))) then
				continue
			end

			table.insert(self.cachedFlags, descendant)
		end

		self:UpdateFlag(PlayerLocalizationController.GetCountryRegion())
		self._Janitor:Add(PlayerLocalizationController.CountryRegionChanged:Connect(function()
			self:UpdateFlag(PlayerLocalizationController.GetCountryRegion())
		end))
	else
		self.propertyPermissions = ComponentUtil.FindAndWaitForAncestorComponent(
			self.Instance,
			"PropertyPermissions",
			PropertyPermissions
		)
		self._Janitor:Add(self.clickDetector.MouseClick:Connect(function(p)
			if not self.propertyPermissions:HasAnyRole(p, "Owner", "Roommate") then
				NotificationController.NotifyCenter("You don't have permission to do that")
				return
			end

			PanelController.OpenPanelByContext("MainGUIHandler", "CountrySelectorPanel")
			local panel = PanelController.GetPanel("MainGUIHandler", "CountrySelectorPanel")
			local component = ComponentUtil.GetComponentFromInstance(panel.Instance, CountrySelectorPanel)

			if not component then
				return
			end

			component:Init(function(p2)
				Remotes.fireServerComponent(self.Instance, "ChangeFlag", p2)
			end, Remotes.invokeServerComponent(self.Instance, "GetCurrentFlag").Code)
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v