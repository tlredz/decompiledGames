local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = false
local AvatarEditorMenu = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AvatarEditorMenu)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local instance = nil
local v2 = Component.new({
	Tag = "ToggleSubcategoryButton"
})

function v2:Construct()
	self._Janitor = Janitor.new()
	local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	v = PanelController
end

function v2:IsInstanceClickable()
	return self.Instance:IsA("TextButton") or self.Instance:IsA("ImageButton")
end

function v2:Start()
	if not self:IsInstanceClickable() then
		return
	end

	self._avatarEditorMenu = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"AvatarEditorMenu",
		AvatarEditorMenu
	)
	self.Instance.Activated:Connect(function()
		if self._avatarEditorMenu:IsPerformingSearch() then
			return
		end

		local targetPanel = self.Instance:GetAttribute("TargetPanel")

		if not targetPanel then
			warn("No target panel name found for button", self.Instance)
			return
		end

		if self.Instance:GetAttribute("TargetPanelAlt") then
			targetPanel = self.Instance:GetAttribute("TargetPanelAlt")
		end

		if v.IsOpen("NoResetGUIHandler", targetPanel) and instance == self.Instance then
			return
		end

		v.ToggleGroup("AvatarEditorSubcategories", false)
		v.SetAttribute("NoResetGUIHandler", targetPanel, "Subcategory", self.Instance.Name)
		v.Open("NoResetGUIHandler", targetPanel)
		instance = self.Instance
	end)
end

function v2:Stop()
	self._Janitor:Destroy()
end

return v2