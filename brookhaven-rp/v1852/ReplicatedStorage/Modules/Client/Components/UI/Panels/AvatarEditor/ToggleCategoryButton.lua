local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local instance = nil
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "ToggleCategoryButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
	local PanelController2 = require(ReplicatedStorage.Modules.Client.UI.PanelController)
	PanelController = PanelController2
end

function v:IsInstanceClickable()
	return self.Instance:IsA("TextButton") or self.Instance:IsA("ImageButton")
end

function v:Start()
	if not self:IsInstanceClickable() then
		return
	end

	self.Instance.Activated:Connect(function()
		if instance == self.Instance then
			return
		end

		local targetPanel = self.Instance:GetAttribute("TargetPanel")
		local targetContext = self.Instance:GetAttribute("TargetContext") or PanelController.GetPanelContextByInstance(self.Instance).Name

		if not targetPanel then
			warn("No target panel name found for button", self.Instance)
			return
		end

		PanelController.ToggleGroup("AvatarEditor", false)

		if not self.Instance:GetAttribute("TargetPanelAlt") then
			PanelController.ToggleGroup("AvatarEditorSubcategories", false)
		end

		PanelController.Open(targetContext, targetPanel)
		instance = self.Instance
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v