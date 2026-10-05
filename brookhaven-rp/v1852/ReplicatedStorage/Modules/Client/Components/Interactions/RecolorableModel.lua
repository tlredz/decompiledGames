local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local InteractUIColorPicker = require(ReplicatedStorage.Modules.Client.UI.InteractUIColorPicker)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PropertyObjectUtil = require(ReplicatedStorage.Modules.Shared.Housing.Objects.PropertyObjectUtil)
local PropertyPermissions = require(ReplicatedStorage.Modules.Client.Components.Housing.PropertyPermissions)
local v = Component.new({
	Tag = "RecolorableModel"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._debounce = false
	self._propertyPermissions = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"PropertyPermissions",
		PropertyPermissions
	)
	self._promptText = self.Instance:GetAttribute("ColorChangePromptText") or "Change Color"
end

function v:Start()
	local uIColorPicker = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("NoResetGUIHandler"):WaitForChild("UIColorPicker")
	self._interactUIColorPicker = ComponentUtil.GetComponentFromInstance(uIColorPicker, InteractUIColorPicker)

	for _, part in self.Instance:GetChildren() do
		if not (part:IsA("BasePart") and part.Name == "Click") then
			continue
		end

		local v2 = self._Janitor:Add(Instance.new("ClickDetector"))
		v2.Parent = part
		self._Janitor:Add(v2.MouseClick:Connect(function()
			self:PartClicked()
		end))
	end

	self._Janitor:Add(self._interactUIColorPicker.ColorChanged:Connect(function(color: Color3)
		self:ChangeColor(color)
	end))
end

function v:PartClicked()
	if not self:HasPermission() then
		return
	end

	local color = self.Instance:FindFirstChild("Color")

	if color then
		self._interactUIColorPicker:Open(self._promptText, color.Color)
	else
		print("No color part found")
	end
end

function v:ChangeColor(color: Color3)
	if self._debounce then
		return
	end

	self._debounce = true
	Remotes.fireServerComponent(self.Instance, "SetColor", color)
	task.delay(1, function()
		self._debounce = false
	end)
end

function v:HasPermission()
	if self._propertyPermissions then
		return PropertyObjectUtil.HasPermissionAndIsCloseEnough(
			Players.LocalPlayer,
			self.Instance,
			37,
			self._propertyPermissions,
			{ "Owner", "Roommate" }
		)
	end

	return true
end

function v:Stop()
	self._Janitor:Destroy()
end

return v