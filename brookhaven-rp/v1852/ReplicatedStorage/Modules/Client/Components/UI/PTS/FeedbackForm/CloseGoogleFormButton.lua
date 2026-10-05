local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "CloseGoogleFormButton"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local FormController = require(ReplicatedStorage.Modules.Client.PTS.FeedbackForm.FormController)
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		FormController:ToggleForm((self.Instance:GetAttribute("FormId")))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v