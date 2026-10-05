local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "VehicleUnderglowSetColorIndexButton"
})
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local VehicleUnderglowColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.Vehicles.UnderglowControls.VehicleUnderglowColorPicker)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local VehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.VehicleController)
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"VehicleUnderglowColorPicker",
		VehicleUnderglowColorPicker
	)

	if not waitForAncestorComponent then
		return
	end

	self._Janitor:Add(waitForAncestorComponent.Instance:GetPropertyChangedSignal("Visible"):Connect(function()
		if waitForAncestorComponent:GetColorIndex() == tonumber(self.Instance.Name) then
			self.Instance.GreenCheck.Visible = true
		else
			self.Instance.GreenCheck.Visible = false
		end
	end))
	self._Janitor:Add(VehicleController.OnUnderglowChanged:Connect(function(_: string, _: string, p2: number)
		if p2 < tonumber(self.Instance.Name) then
			self.Instance.Visible = false
		else
			self.Instance.Visible = true
		end
	end))
	self._Janitor:Add(waitForAncestorComponent.OnColorIndexChanged:Connect(function(p2: number)
		if p2 == tonumber(self.Instance.Name) then
			self.Instance.GreenCheck.Visible = true
		else
			self.Instance.GreenCheck.Visible = false
		end
	end))
	self._Janitor:Add(self.Instance.MouseButton1Click:Connect(function()
		waitForAncestorComponent:SetColorIndex((tonumber(self.Instance.Name)))
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v