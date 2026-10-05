local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LoadableEntries = require(ReplicatedStorage.Modules.Client.Components.UI.Utils.Loadables.LoadableEntries)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local LegacyGame8Settings = require(ReplicatedStorage.Modules.Client.UI.LegacyGame8Settings)
local clearTools = LegacyGame8Settings.ClearTools
local v = Component.new({
	Tag = "GunWeaponMenu"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._gunSniperEntriesJanitor = self._Janitor:Add(Janitor.new())
	self._dbGunClose = false
	self._dbClickWeapon = false
end

function v:Start()
	for _, button in self.Instance.Catalog.Header.CategoryTabs:GetChildren() do
		if button:IsA("TextButton") or button:IsA("ImageButton") then
			button.SelectionOrder = 2000
		end
	end

	local component = ComponentUtil.GetComponentFromInstance(
		self.Instance.Catalog.Container.ScrollingFrame,
		LoadableEntries
	)
	self._Janitor:Add(component.Loaded:Connect(function()
		for _, child in self.Instance.Catalog.Container.ScrollingFrame:GetChildren() do
			self:SetupGunSniperButton(child)
		end
	end))

	if component:IsLoaded() then
		for _, child in self.Instance.Catalog.Container.ScrollingFrame:GetChildren() do
			child:SetAttribute("AttachedConnection", nil)
			self:SetupGunSniperButton(child)
		end
	end

	self._Janitor:Add(component.Added:Connect(function(items)
		for _, item in items do
			self:SetupGunSniperButton(item)
		end
	end))
	self._Janitor:Add(component.Unloaded:Connect(function()
		self._gunSniperEntriesJanitor:Cleanup()

		for _, child in self.Instance.Catalog.Container.ScrollingFrame:GetChildren() do
			child:SetAttribute("AttachedConnection", nil)
		end
	end))
	self._Janitor:Add(self.Instance.Catalog.Header.CategoryTabs.Close.MouseButton1Click:connect(function()
		if self._dbGunClose == false then
			self._dbGunClose = true
			PanelController.Close("NoResetGUIHandler", "GunWeaponMenu")
			wait(0.5)
			self._dbGunClose = false
		end
	end))
end

function v:ClearCheckMarksGunSniper()
	for _, child in pairs(self.Instance.Catalog.Container.ScrollingFrame:GetChildren()) do
		if child:isA("ImageButton") then
			child:RemoveTag("Checked")
		end
	end
end

function v:SetupGunSniperButton(button)
	if button:IsA("ImageButton") then
		if button:GetAttribute("AttachedConnection") ~= nil then
			return
		end

		button:SetAttribute("AttachedConnection", true)
		self._gunSniperEntriesJanitor:Add(button.MouseButton1Click:Connect(function()
			local name = button.Name

			if self._dbClickWeapon == false and button ~= nil then
				self._dbClickWeapon = true
				self:ClearCheckMarksGunSniper()

				if button.Name == "Skins" then
					if button.Name == "Skins" then
						PanelController.Close("NoResetGUIHandler", "GunWeaponMenu")
						PanelController.Open("NoResetGUIHandler", "GunSkinsMenu")
					end
				else
					clearTools:FireServer("RequestingAccessory", name)

					if button.Name ~= "Silencer" and button.Name ~= "Flashlight" then
						button:AddTag("Checked")
					end
				end

				wait(0.7)
				self._dbClickWeapon = false
			end
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v