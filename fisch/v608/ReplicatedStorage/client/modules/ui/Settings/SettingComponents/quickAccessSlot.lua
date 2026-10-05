local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local Players = game:GetService("Players")
local v = assert(Players.LocalPlayer)
local Trove = require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.shared.modules.fx)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
require(ReplicatedStorage.shared.playerSettings.Types)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local TargetHandlers = require(ReplicatedStorage.client.legacyControllers.QuickAccessController.TargetHandlers)
local marketplace = require(ReplicatedStorage.shared.utils.marketplace)
require("../Types")
local quickAccessSlot = script:WaitForChild("quickAccessSlot")
local optionTemplate = script:WaitForChild("optionTemplate")
local _ = ReplicatedStorage.resources.sounds.sfx.ui
local v2 = {
	none = {
		Id = "none",
		OptionDisplay = "None",
		TargetDisplay = nil,
		Order = 0
	},
	rod = {
		Id = "rod",
		OptionDisplay = "Equip Rod",
		TargetDisplay = "Target Fishing Rod",
		Order = 1
	},
	item = {
		Id = "item",
		OptionDisplay = "Equip Item",
		TargetDisplay = "Target Item",
		Order = 2
	},
	menu = {
		Id = "menu",
		OptionDisplay = "Open Menu",
		TargetDisplay = "Target Menu",
		Order = 3
	},
	bait = {
		Id = "bait",
		OptionDisplay = "Equip Bait",
		TargetDisplay = "Target Bait",
		Order = 4
	},
	companion = {
		Id = "companion",
		OptionDisplay = "Equip Companion",
		TargetDisplay = "Target Companion",
		Order = 5,
		IsVisible = function(p, instance)
			local stats = instance:FindFirstChild("Stats")

			if not stats then
				return false
			end

			local realLevel = stats:FindFirstChild("realLevel")

			if realLevel and realLevel:IsA("NumberValue") and not (realLevel.Value < 30) then
				return next(p.Companions.Owned) ~= nil
			end

			return false
		end
	},
	accessory = {
		Id = "accessory",
		OptionDisplay = "Toggle Accessory",
		TargetDisplay = "Target Accessory",
		Order = 6
	},
	spear = {
		Id = "spear",
		OptionDisplay = "Equip Spear",
		TargetDisplay = "Target Spear",
		Order = 7,
		IsVisible = function(p)
			local spears = p.Spears
			return spears ~= nil and next(spears) ~= nil
		end
	},
	harpoon = {
		Id = "harpoon",
		OptionDisplay = "Equip Harpoon Gun",
		TargetDisplay = "Target Harpoon Gun",
		Order = 8,
		IsVisible = function(p)
			local harpoonGuns = p.HarpoonGuns
			return harpoonGuns ~= nil and next(harpoonGuns) ~= nil
		end
	},
	boat = {
		Id = "boat",
		OptionDisplay = "Spawn Boat",
		TargetDisplay = "Target Boat",
		Order = 9,
		IsVisible = function(_, _)
			return marketplace.userHasGamepassAsync(v, 986687236)
		end
	},
	command = {
		Id = "command",
		OptionDisplay = "Run Command",
		TargetDisplay = "Command",
		Order = 10,
		IsVisible = function(_, _)
			return v:GetAttribute("FullConchAccess") ~= nil
		end
	}
}
local QuickAccessSlot = {}
QuickAccessSlot.__index = QuickAccessSlot

function QuickAccessSlot:UpdateSelected()
	local v3 = v2[self.Value.type]

	if v3 then
		self.GuiObject.targetType.control.dropdownSelected.label.Text = v3.OptionDisplay
	else
		warn((`unknown setting value "{self.Value.type}" for "{self.Config.Id}" is selected!! help!!`))
	end
end

function QuickAccessSlot.GetLocalizedName(p)
	return p.GuiObject.targetType.detail.title.title.LocalizedText
end

function QuickAccessSlot:UpdateTargetInput()
	local v3 = v2[self.Value.type] or v2.none

	if v3.Id ~= self._loadedType then
		self._loadedType = v3.Id

		for _, guiObject in self.TargetOptionMap do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		table.clear(self.TargetOptionMap)

		if not v3.TargetDisplay then
			self.GuiObject.targetName.Visible = false
			return
		end

		self.GuiObject.targetName.detail.title.title.Text = v3.TargetDisplay
		local targetHandler = TargetHandlers[v3.Id]
		self.TargetIsFree = not targetHandler or targetHandler.FreeInput or false

		if targetHandler then
			local options = targetHandler.GetOptions()

			for k, option in options do
				local clone = optionTemplate:Clone()
				clone.Text = option
				clone.Name = option
				clone.LayoutOrder = k
				local text = option
				clone.Activated:Connect(function(p)
					self.GuiObject.targetName.control.inputBox.Text = text
					self.GuiObject.targetName.control.inputBox:ReleaseFocus(true)
				end)
				clone.Parent = self.GuiObject.targetName.control.dropdownOptions
				self.TargetOptionMap[option] = clone
			end
		end

		self.GuiObject.targetName.Visible = true
	end

	self:UpdateVisibleTargets()
end

function QuickAccessSlot:UpdateVisibleTargets()
	local v3 = self.GuiObject.targetName.control.inputBox.Text:lower():gsub("%s+", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", "")

	for _, v4 in self.TargetOptionMap do
		local v5 = v4.Name:lower():gsub("%s+", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", "")
		local v6 = v4.LocalizedText:lower():gsub("%s+", ""):gsub("['\"′‵‘’‚‛″‶“”„‟‴‷⁗]", "")
		v4.Visible = v5:find(v3, 1, true) ~= nil or v6:find(v3, 1, true) ~= nil
		local v7 = v4.LayoutOrder >= 100000 and v4.LayoutOrder - 100000 or v4.LayoutOrder
		v4.LayoutOrder = (v5:sub(1, #v3) == v3 or v6:sub(1, #v3) == v3) and v7 or v7 + 100000
	end
end

function QuickAccessSlot.new(config, p)
	local object = setmetatable({}, QuickAccessSlot)
	object.Trove = Trove.new()
	object.Config = config
	object.Value = p
	object.OptionMap = {}
	object.TargetOptionMap = {}
	local guiObject = object.Trove:Add(quickAccessSlot:Clone())
	local targetType = guiObject.targetType
	local targetName = guiObject.targetName
	targetType.detail.title.title.Text = config.Name
	guiObject.LayoutOrder = config.Order
	guiObject.Name = config.Id
	object.Trove:Add(SettingsController:GetSettingChangedSignal(config.Id):Connect(function(p2)
		object.Value = p2
		object:UpdateSelected()
		object:UpdateTargetInput()
		targetType.control.dropdownOptions.Visible = false
		targetName.control.dropdownOptions.Visible = false
	end))
	object.Trove:Add(targetType.control.dropdownSelected.Activated:Connect(function()
		targetType.control.dropdownOptions.Visible = not targetType.control.dropdownOptions.Visible
	end))
	object.Trove:Add(targetType.control.dropdownOptions:GetPropertyChangedSignal("Visible"):Connect(function()
		targetType.control.dropdownSelected.ArrowDropDown.Rotation = targetType.control.dropdownOptions.Visible and 180 or 0
	end))
	object.Trove:Add(targetName.control.inputBox.Focused:Connect(function()
		object:UpdateTargetInput()
		targetName.control.dropdownOptions.Visible = true
	end))
	object.Trove:Add(targetName.control.inputBox:GetPropertyChangedSignal("Text"):Connect(function()
		object:UpdateVisibleTargets()
	end))
	object.Trove:Add(targetName.control.inputBox.FocusLost:Connect(function(_, p2)
		local basePlayerGui = guiObject:FindFirstAncestorWhichIsA("BasePlayerGui")

		if p2 and basePlayerGui then
			local guiObjectsAtPosition = basePlayerGui:GetGuiObjectsAtPosition(p2.Position.X, p2.Position.Y)

			for _, button in guiObjectsAtPosition do
				if button:IsA("TextButton") and button.Parent == targetName.control.dropdownOptions then
					targetName.control.inputBox.Text = button.Text
				end
			end
		end

		targetName.control.dropdownOptions.Visible = false
		local text = targetName.control.inputBox.Text
		local v4 = text:lower():gsub("%s+", "")

		if v4 == "" then
			targetName.control.inputBox.Text = object.Value.target
			return
		end

		if not (object.TargetIsFree or object.TargetOptionMap[text]) then
			local descendants = targetName.control.dropdownOptions:QueryDescendants("TextButton[Visible = true]")
			local v5 = false

			for _, descendant in descendants do
				if not (descendant.Name:lower():gsub("%s+", "") == v4 or descendant.LocalizedText:lower():gsub(
					"%s+",
					""
				) == v4) then
					continue
				end

				text = descendant.Name
				v5 = true
				break
			end

			if not v5 then
				table.sort(descendants, function(a, b)
					return a.LayoutOrder < b.LayoutOrder
				end)

				if descendants[1] then
					text = descendants[1].Name
				else
					targetName.control.inputBox.Text = object.Value.target or ""
					return
				end
			end
		end

		if targetName.control.inputBox.Text ~= text then
			targetName.control.inputBox.Text = text
		end

		local clone = table.clone(object.Value)
		clone.target = text
		SettingsController:EditSetting(config.Id, clone)
	end))
	DataController.PlayerDataReplicator:WaitForLoaded()
	local v4 = assert(DataController.PlayerDataReplicator.Data)
	local fetched = legacyLocalPlayerData.fetch()

	for _, v5 in v2 do
		if not (not v5.IsVisible or v5.IsVisible(v4, fetched)) then
			continue
		end

		local clone = optionTemplate:Clone()
		clone.Text = v5.OptionDisplay
		clone.Name = v5.Id

		if v5.Order then
			clone.LayoutOrder = v5.Order
		end

		local v6 = v5
		clone.Activated:Connect(function()
			local clone2 = table.clone(object.Value)
			clone2.type = v6.Id
			clone2.target = ""
			targetName.control.inputBox.Text = ""
			SettingsController:EditSetting(config.Id, clone2)
		end)
		clone.Parent = targetType.control.dropdownOptions
		object.OptionMap[v5.Id] = clone
	end

	object.GuiObject = guiObject
	object:UpdateSelected()
	local visible

	if v2[object.Value.type] == nil then
		visible = false
	else
		visible = v2[object.Value.type].TargetDisplay ~= nil
	end

	targetName.Visible = visible

	if v2[object.Value.type] and v2[object.Value.type].TargetDisplay then
		targetName.detail.title.title.Text = v2[object.Value.type].TargetDisplay
	end

	targetName.control.inputBox.Text = object.Value.target or ""
	return object, guiObject
end

function QuickAccessSlot:Destroy()
	self.Trove:Destroy()
	table.clear(self)
end

return QuickAccessSlot