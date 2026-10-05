local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleSelectColorPartButton"
})
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local UIColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPicker)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
			self.Instance,
			"UIColorPicker",
			UIColorPicker
		)

		if not waitForAncestorComponent then
			return
		end

		waitForAncestorComponent.Instance:SetAttribute("DefaultColor", instance.ColorValue.Value)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v