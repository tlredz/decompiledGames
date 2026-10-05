local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local UIColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPicker)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local v = Component.new({
	Tag = "InteractUIColorPicker"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._title = self.Instance:FindFirstChild("Title", true)
	self._finalColorButton = self.Instance:FindFirstChild("FinalColorButton", true)
	self.ColorChanged = self._Janitor:Add(Signal.new())
end

function v:Start()
	local component = ComponentUtil.GetComponentFromInstance(self.Instance, UIColorPicker)
	self._Janitor:Add(component.OnColorConfirmed:Connect(function(p)
		self.ColorChanged:Fire(p)

		if self.callback then
			self.callback(p)
		end
	end))
end

function v:Open(text: string, color: Color3?, callback)
	self._title.Text = text
	self._finalColorButton.BackgroundColor3 = color or Color3.new(1, 1, 1)
	self.Instance.Visible = true
	self.callback = callback
end

function v:Stop()
	self._Janitor:Destroy()
end

return v