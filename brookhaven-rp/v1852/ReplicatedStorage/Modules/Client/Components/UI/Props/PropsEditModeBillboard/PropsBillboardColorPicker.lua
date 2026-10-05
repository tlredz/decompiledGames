local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsBillboardColorPicker"
})
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local UIColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPicker)
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local component = ComponentUtil.GetComponentFromInstance(self.Instance, UIColorPicker)
	self._Janitor:Add(component.OnColorConfirmed:Connect(function(p2)
		local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

		if currentSelectedPropEditable then
			currentSelectedPropEditable:ChangeColor(p2)
		end
	end))
	self._Janitor:Add(PropEditable.OnDeselected:Connect(function()
		PanelController.Close("NoResetGUIHandler", "PropColorPicker")
	end))
	self._Janitor:Add(PropEditable.OnSelected:Connect(function()
		local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()

		if currentSelectedPropEditable then
			component.Instance:SetAttribute("DefaultColor", currentSelectedPropEditable:GetDefaultColor())
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v