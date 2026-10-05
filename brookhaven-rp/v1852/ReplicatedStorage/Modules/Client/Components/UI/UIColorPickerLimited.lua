local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local v = Component.new({
	Tag = "UIColorPickerLimited"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Show(text: string, instance, callback)
	self.title.Text = text
	self.callback = callback
	self.currentSelection = nil

	for _, guiObject in self.colorLimitsGrid:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject.Name ~= "Template" then
			guiObject:Destroy()
		end
	end

	local v2 = {}

	for _, child in instance:GetChildren() do
		local isDefault = child:GetAttribute("IsDefault") ~= nil
		table.insert(v2, {
			Name = child.Name,
			Value = child.Value,
			isDefault = isDefault
		})
	end

	table.sort(v2, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)

	for _, v3 in v2 do
		local clone = self.colorLimitsGrid.Template:Clone()
		clone.Name = v3.Name
		clone.BackgroundColor3 = v3.Value
		clone.Parent = self.colorLimitsGrid
		clone.Visible = true
		local v4 = v3
		clone.Activated:Connect(function()
			if self.currentSelection then
				self.currentSelection:RemoveTag("Checked")
			end

			self.callback(v4.Value)
			clone:AddTag("Checked")
			self.currentSelection = clone
		end)

		if not v3.isDefault then
			continue
		end

		clone:AddTag("Checked")
		self.currentSelection = clone
	end

	local v3 = math.ceil(#instance:GetChildren() / 5)
	self.colorLimitsGrid.UIGridLayout.CellSize = UDim2.new(0.2, -4, 1 / v3, -4)
	PanelController.OpenPanelByContext("MainGUIHandler", "ColorPickerLimited")
end

function v:ClosePanel()
	PanelController.Close("MainGUIHandler", "ColorPickerLimited")
end

function v:Start()
	local panel = self.Instance:WaitForChild("Panel")
	self.colorLimitsGrid = panel:WaitForChild("Grid")
	self.title = panel:WaitForChild("Title")
	self.CloseButton = panel:WaitForChild("Close")
	self._Janitor:Add(self.CloseButton.Activated:Connect(function()
		self:ClosePanel()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v