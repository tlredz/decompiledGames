local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local Trove = require(ReplicatedStorage.packages.Trove)
local fx = require(ReplicatedStorage.shared.modules.fx)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
require(ReplicatedStorage.shared.playerSettings.Types)
require("../Types")
local checkbox = script:WaitForChild("checkbox")
local optionTemplate = script:WaitForChild("optionTemplate")
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local Checkbox = {}
Checkbox.__index = Checkbox

function Checkbox:UpdateCheckboxStates()
	for k, visible in self.Value do
		local v2 = self.OptionMap[k]

		if not v2 then
			continue
		end

		v2.checkbox.check.Visible = visible
		v2.UIStroke.Transparency = visible and 0 or 0.65
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addGradient(parent, color)
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = color
	uIGradient.Parent = parent
end

function Checkbox.GetLocalizedName(p)
	return p.GuiObject.title.title.LocalizedText
end

function Checkbox.new(config, p)
	local object = setmetatable({}, Checkbox)
	object.Trove = Trove.new()
	object.Config = config
	object.Value = p
	object.OptionMap = {}
	local guiObject = object.Trove:Add(checkbox:Clone())
	guiObject.title.title.Text = config.Name
	guiObject.LayoutOrder = config.Order
	guiObject.Name = config.Id

	if config.Description then
		guiObject.desc.Text = config.Description
	else
		guiObject.desc.Visible = false
	end

	guiObject.title.title.TextSize = workspace.CurrentCamera.ViewportSize.Y > 650 and 24 or 18
	object.Trove:Add(SettingsController:GetSettingChangedSignal(config.Id):Connect(function(p2)
		object.Value = p2
		object:UpdateCheckboxStates()
	end))
	guiObject.UIListLayout.SortOrder = config.SortByName and Enum.SortOrder.Name or Enum.SortOrder.LayoutOrder

	for _, option in config.Options do
		if not (not object.Config.VisibleFilter or object.Config.VisibleFilter(
			option,
			DataController.PlayerDataReplicator.Data
		)) then
			continue
		end

		local clone = optionTemplate:Clone()
		clone.label.Text = option.Name
		clone.Name = option.Name

		if option.Order then
			clone.LayoutOrder = option.Order
		end

		if typeof(option.Color) == "ColorSequence" then
			addGradient(clone, option.Color) -- equivalent call inferred; original call site unknown
			addGradient(clone.UIStroke, option.Color) -- equivalent call inferred; original call site unknown
			addGradient(clone.label, option.Color) -- equivalent call inferred; original call site unknown
		elseif typeof(option.Color) == "Color3" then
			addGradient(clone, ColorSequence.new(option.Color)) -- equivalent call inferred; original call site unknown
			clone.UIStroke.Color = option.Color
			clone.label.TextColor3 = option.Color
		end

		local v2 = option
		clone.Activated:Connect(function()
			local v4 = not object.Value[v2.Id]
			object.Value[v2.Id] = v4
			SettingsController:EditSetting(config.Id, object.Value)

			if v4 then
				fx:PlaySound(ui.settingEnabled, clone, false)
			else
				fx:PlaySound(ui.settingDisabled, clone, false)
			end
		end)
		clone.Parent = guiObject.optionContainer
		object.OptionMap[option.Id] = clone
	end

	object.GuiObject = guiObject
	object:UpdateCheckboxStates()
	return object, guiObject
end

function Checkbox:Destroy()
	self.Trove:Destroy()
	table.clear(self)
end

return Checkbox