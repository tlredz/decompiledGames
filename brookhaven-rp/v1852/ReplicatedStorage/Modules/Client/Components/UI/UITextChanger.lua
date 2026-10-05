local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local DontRunUnderStarterGear = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.DontRunUnderStarterGear)
local v = Component.new({
	Tag = "UITextChanger",
	Extensions = { DontRunUnderStarterGear }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._textBeforeEdit = self.Instance.Text
end

function v:Start()
	local instance = self.Instance

	if instance then
		self._Janitor:Add(instance.FocusLost:Connect(function()
			local textBeforeEdit = Remotes.invokeServerComponent(self.Instance, "ChangeText", instance.Text)

			if not textBeforeEdit then
				instance.Text = self._textBeforeEdit
				return
			end

			self._textBeforeEdit = textBeforeEdit
			instance.Text = self._textBeforeEdit
		end))
	else
		warn("UITextChanger is not a TextBox")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v