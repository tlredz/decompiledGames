local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "AccessoryAdjustmentsColorPicker"
})
local AccessoryAdjustmentsState = require(ReplicatedStorage.Modules.Client.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsState)
local AccessoryAdjustmentsPanel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsPanel)
local AccessoryAdjustmentsSoundManager = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsSoundManager)
local UIColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPicker)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._colorPicker = ComponentUtil.GetComponentFromInstance(self.Instance, UIColorPicker)
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"AccessoryAdjustmentsPanel",
		AccessoryAdjustmentsPanel
	)
	self._Janitor:Add(self._colorPicker.OnColorConfirmed:Connect(function(p)
		local selectedAssetId = AccessoryAdjustmentsState.GetSelectedAssetId()

		if selectedAssetId == nil then
			return
		end

		if waitForAncestorComponent then
			waitForAncestorComponent:PlaySound(AccessoryAdjustmentsSoundManager.SOUNDS.COLOR_PICKER, 0)
		end

		WearingController.SetAccessoryColor(selectedAssetId, p)
	end))
	local colorPicksFrame = self.Instance:WaitForChild("ColorPicks"):WaitForChild("ColorPicksFrame")
	local palettePicker = colorPicksFrame:WaitForChild("PalettePicker")
	local darknessBar = colorPicksFrame:WaitForChild("DarknessBar")
	local scrollingFrame = waitForAncestorComponent.Instance.Container.MainView.Frame.CurrentlyWearing.ScrollingFrame
	self._Janitor:Add(palettePicker.ChildAdded:Connect(function(child)
		if child.Name == "ConsolePaletteMarker" then
			child.NextSelectionUp = scrollingFrame
		end
	end))
	self._Janitor:Add(darknessBar.ChildAdded:Connect(function(child)
		if child.Name == "ConsoleDarknessMarker" then
			child.NextSelectionUp = scrollingFrame
		end
	end))
	task.spawn(function()
		local consoleDarknessMarker = self.Instance:FindFirstChild("ConsoleDarknessMarker", true)
		local consolePaletteMarker = self.Instance:FindFirstChild("ConsolePaletteMarker", true)

		if consoleDarknessMarker and consolePaletteMarker then
			consoleDarknessMarker.NextSelectionUp = scrollingFrame
			consolePaletteMarker.NextSelectionUp = scrollingFrame
		end
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v