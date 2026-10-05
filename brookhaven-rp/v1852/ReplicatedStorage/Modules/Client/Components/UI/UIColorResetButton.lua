local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "UIColorResetButton"
})
local UIColorPicker = require(ReplicatedStorage.Modules.Client.Components.UI.UIColorPicker)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"UIColorPicker",
		UIColorPicker
	)

	if not waitForAncestorComponent then
		return
	end

	local colorReferencePart = self.Instance:FindFirstChild("ColorReferencePart")

	if colorReferencePart then
		if not colorReferencePart.Value then
			return
		end

		if colorReferencePart.Value:IsA("BasePart") or colorReferencePart.Value:IsA("MeshPart") then
			waitForAncestorComponent.Instance:SetAttribute("DefaultColor", colorReferencePart.Value.Color)
		else
			return
		end
	end

	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		local defaultColor = waitForAncestorComponent.Instance:GetAttribute("DefaultColor") or waitForAncestorComponent.finalColorButton.BackgroundColor3
		waitForAncestorComponent.OnColorConfirmed:Fire(defaultColor, true)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v