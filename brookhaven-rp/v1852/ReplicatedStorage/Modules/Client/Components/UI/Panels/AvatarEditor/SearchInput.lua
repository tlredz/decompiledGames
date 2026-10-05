local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "SearchInput"
})
local AvatarEditorController = require(ReplicatedStorage.Modules.Client.AvatarEditor.AvatarEditorController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.FocusLost:Connect(function()
		local text = self.Instance.Text

		if text == "" then
			return
		end

		local searchCategory = self.Instance:GetAttribute("SearchCategory") or "All"
		PanelController.SetAttribute("NoResetGUIHandler", "SearchResultsList", "SearchText", text)
		PanelController.SetAttribute("NoResetGUIHandler", "SearchResultsList", "SearchCategory", searchCategory)
		PanelController.ToggleGroup("AvatarEditorSubcategories", false)
		PanelController.Open("NoResetGUIHandler", "SearchResultsList")
		self.Instance.Text = ""
		AvatarEditorController.OnSearchStarted:Fire()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v