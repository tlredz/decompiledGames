local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "PropsBillboardTexturesButton"
})
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local PropEditable = require(ReplicatedStorage.Modules.Client.Components.Props.PropEditable)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(62, 63, 63)

-- equivalent calls inferred from this helper; original call sites unknown
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

	if not currentSelectedPropEditable then
		return
	end

	local v2 = currentSelectedPropEditable.Instance:FindFirstChild("Changable") ~= nil
	local v3 = currentSelectedPropEditable.Instance:FindFirstChild("ChangeableTexture") ~= nil
	local v4 = v2 and v3

	if not v4 then
		instance:SetAttribute("PropNoTextures", true)
	end

	applyButtonAppearance(instance, v4) -- equivalent call inferred; original call site unknown
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		if not v4 then
			NotificationController.NotifyCenter("Changing textures is only available for certain props")
			return
		end

		if PanelController.IsOpen("NoResetGUIHandler", "PropColorPicker") then
			PanelController.Close("NoResetGUIHandler", "PropColorPicker")
		end

		if PanelController.IsOpen("NoResetGUIHandler", "PropTexturePicker") then
			PanelController.Close("NoResetGUIHandler", "PropTexturePicker")
		else
			PanelController.Open("NoResetGUIHandler", "PropTexturePicker")
		end
	end))
end

function v:Stop()
	PanelController.Close("NoResetGUIHandler", "PropTexturePicker")
	self._Janitor:Destroy()
end

return v