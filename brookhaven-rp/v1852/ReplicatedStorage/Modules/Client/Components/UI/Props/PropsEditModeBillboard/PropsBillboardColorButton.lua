local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsBillboardColorButton"
})
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(62, 63, 63)

local function applyButtonAppearance(instance, flag: boolean)
	local v2

	if flag then
		v2 = color
	else
		v2 = color2
	end

	instance.BackgroundColor3 = v2
	instance.ImageColor3 = v2
	local icon = instance:FindFirstChild("Icon")

	if icon and (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
		icon.ImageColor3 = v2
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance

	if not instance:IsA("ImageButton") then
		return
	end

	local currentSelectedPropEditable = PropEditable.GetCurrentSelectedPropEditable()
	local v2 = true

	if currentSelectedPropEditable then
		local changable = currentSelectedPropEditable.Instance:FindFirstChild("Changable")

		if changable == nil then
			instance:SetAttribute("PropNoColor", true)
			local v3 = color2
			instance.BackgroundColor3 = v3
			instance.ImageColor3 = v3
			local icon = instance:FindFirstChild("Icon")

			if icon and (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
				icon.ImageColor3 = v3
			end

			v2 = false
		elseif changable:IsA("BoolValue") and changable.Value == false then
			v2 = false
			local v3 = color2
			instance.BackgroundColor3 = v3
			instance.ImageColor3 = v3
			local icon = instance:FindFirstChild("Icon")

			if icon and (icon:IsA("ImageLabel") or icon:IsA("ImageButton")) then
				icon.ImageColor3 = v3
			end
		end
	end

	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		if not v2 then
			NotificationController.NotifyCenter("This prop cannot be recolored")
			return
		end

		if PanelController.IsOpen("NoResetGUIHandler", "PropTexturePicker") then
			PanelController.Close("NoResetGUIHandler", "PropTexturePicker")
		end

		if PanelController.IsOpen("NoResetGUIHandler", "PropColorPicker") then
			PanelController.Close("NoResetGUIHandler", "PropColorPicker")
		else
			PanelController.Open("NoResetGUIHandler", "PropColorPicker")
		end
	end))
end

function v:Stop()
	PanelController.Close("NoResetGUIHandler", "PropColorPicker")
	self._Janitor:Destroy()
end

return v