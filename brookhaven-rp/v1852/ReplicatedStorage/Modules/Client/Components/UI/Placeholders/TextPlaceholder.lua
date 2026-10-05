local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlaceholderController = require(ReplicatedStorage.Modules.Client.Placeholder.PlaceholderController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "TextPlaceholder"
})

function v:_setText(text: string)
	self._internalSet = true
	self.Instance.Text = text
	self._internalSet = false
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._internalSet = false
	self._template = self.Instance.Text
	self:_setText(PlaceholderController.StripUnknownTokens(self._template))
end

function v:Start()
	self:_setText(PlaceholderController.Substitute(self._template))
	self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Text"):Connect(function()
		if self._internalSet then
			return
		end

		self._template = self.Instance.Text
		self:_setText(PlaceholderController.Substitute(self._template))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v