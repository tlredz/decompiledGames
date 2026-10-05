local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local AvatarEditorController = require(ReplicatedStorage.Modules.Client.AvatarEditor.AvatarEditorController)
local v = Component.new({
	Tag = "PromptRevertCharacter"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.Buttons.Folder.Yes.Activated:Connect(function()
		AvatarEditorController.ResetCharacterAppearance()
		PanelController.Close("NoResetGUIHandler", self.Instance.Name)
	end))
	self._Janitor:Add(self.Instance.Buttons.Folder.No.Activated:Connect(function()
		PanelController.Close("NoResetGUIHandler", self.Instance.Name)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v