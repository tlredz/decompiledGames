local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Trove = require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.shared.modules.fx)
require(ReplicatedStorage.client.legacyControllers.DataController)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
require(ReplicatedStorage.shared.playerSettings.Types)
require("../Types")
local dropdown = script:WaitForChild("dropdown")
local optionTemplate = script:WaitForChild("optionTemplate")
local _ = ReplicatedStorage.resources.sounds.sfx.ui
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown:UpdateSelected()
	local option = self.Config.Options[self.Value]

	if not option then
		warn((`unknown setting value "{self.Value}" for "{self.Config.Id}" is selected!! help!!`))
		return
	end

	self.GuiObject.control.dropdownSelected.label.Text = option.Name

	for k, v in self.OptionMap do
		v.Visible = k ~= self.Value
	end
end

function Dropdown.GetLocalizedName(p)
	return p.GuiObject.detail.title.title.LocalizedText
end

function Dropdown.new(config, p: string)
	local object = setmetatable({}, Dropdown)
	object.Trove = Trove.new()
	object.Config = config
	object.Value = p
	object.OptionMap = {}
	local guiObject = object.Trove:Add(dropdown:Clone())
	guiObject.detail.title.title.Text = config.Name
	guiObject.LayoutOrder = config.Order
	guiObject.Name = config.Id

	if config.Description then
		guiObject.detail.desc.Text = config.Description
	else
		guiObject.detail.desc.Visible = false
	end

	guiObject.detail.title.title.TextSize = workspace.CurrentCamera.ViewportSize.Y > 650 and 24 or 18
	object.Trove:Add(SettingsController:GetSettingChangedSignal(config.Id):Connect(function(p2)
		object.Value = p2
		object:UpdateSelected()
		guiObject.control.dropdownOptions.Visible = false
	end))
	object.Trove:Add(guiObject.control.dropdownSelected.Activated:Connect(function()
		guiObject.control.dropdownOptions.Visible = not guiObject.control.dropdownOptions.Visible
	end))
	object.Trove:Add(guiObject.control.dropdownOptions:GetPropertyChangedSignal("Visible"):Connect(function()
		guiObject.control.dropdownSelected.ArrowDropDown.Rotation = guiObject.control.dropdownOptions.Visible and 180 or 0
	end))
	guiObject.control.dropdownOptions.UIListLayout.SortOrder = config.SortByName and Enum.SortOrder.Name or Enum.SortOrder.LayoutOrder

	for _, option in config.Options do
		local clone = optionTemplate:Clone()
		clone.Text = option.Name
		clone.Name = option.Name

		if option.Order then
			clone.LayoutOrder = option.Order
		end

		local v2 = option
		clone.Activated:Connect(function()
			SettingsController:EditSetting(config.Id, v2.Id)
		end)
		clone.Parent = guiObject.control.dropdownOptions
		object.OptionMap[option.Id] = clone
	end

	object.GuiObject = guiObject
	object:UpdateSelected()
	return object, guiObject
end

function Dropdown:Destroy()
	self.Trove:Destroy()
	table.clear(self)
end

return Dropdown