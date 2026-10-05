local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SettingsLibrary = require(ReplicatedStorage.Modules.SettingsLibrary)
local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local SettingsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SettingsController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local settingsProfileSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("SettingsProfileSlot")
local Profiles = {}
Profiles.__index = Profiles

function Profiles.new(page)
	local self = setmetatable({}, Profiles)
	self.Clicked = Signal.new()
	self.Page = page
	self.Frame = self.Page.Container:WaitForChild("Profiles")
	self.Background = self.Frame:WaitForChild("Background")
	self.Container = self.Frame:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.ShareFrame = self.Container:WaitForChild("Share")
	self.ShareButton = self.ShareFrame:WaitForChild("Button")
	self.ShareBubbleFrame = self.ShareFrame:WaitForChild("Bubble")
	self.ShareCloseButton = self.ShareBubbleFrame:WaitForChild("Close")
	self.ShareExportBox = self.ShareBubbleFrame:WaitForChild("Export")
	self.ShareExportSectionBox = self.ShareBubbleFrame:WaitForChild("ExportSection")
	self.ShareExportSectionTitle = self.ShareBubbleFrame:WaitForChild("ExportSectionTitle")
	self.ShareImportFrame = self.ShareBubbleFrame:WaitForChild("Import")
	self.ShareImportButton = self.ShareImportFrame:WaitForChild("Button")
	self.ShareImportButtonTitle = self.ShareImportButton:WaitForChild("Title")
	self.ShareImportButtonSection = self.ShareImportButton:WaitForChild("Section")
	self.ShareImportBox = self.ShareImportFrame:WaitForChild("Box")
	self._slots = {}
	self._update_hash = 0
	self:_Init()
	return self
end

function Profiles:SetPage()
	self:_SetShareBubbleVisible(false)
end

function Profiles:Open()
	self:_SetShareBubbleVisible(false)
end

function Profiles:_ImportSettings()
	local decryptTable, v = EnumLibrary:DecryptTable(self.ShareImportBox.Text)

	if not decryptTable then
		Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
		return
	end

	SettingsController:ChangeSettings(v)
	self:_SetShareBubbleVisible(false)
end

function Profiles:_GetBulkSettings(p)
	local result = {}

	for _, v in pairs(SettingsLibrary.Order) do
		if v.InputType ~= "Divider" and (not p or v.Section == p) then
			table.insert(result, { v.Name, PlayerDataController:GetSetting(v.Name) })
		end
	end

	return result
end

function Profiles:_UpdateImportButton()
	local decryptTable, v = EnumLibrary:DecryptTable(self.ShareImportBox.Text)
	local v2 = nil

	if decryptTable then
		for _, v4 in pairs(v) do
			local section = SettingsLibrary.Info[v4[1]] and SettingsLibrary.Info[v4[1]].Section

			if not section then
				continue
			end

			if v2 then
				if v2 ~= section and v2 ~= section then
					v2 = "Everything"
					break
				end
			else
				v2 = section
			end
		end
	end

	local shareImportButtonTitle = self.ShareImportButtonTitle
	local position

	if decryptTable then
		position = UDim2.new(0.5, 0, 0.35, 0)
	else
		position = UDim2.new(0.5, 0, 0.5, 0)
	end

	shareImportButtonTitle.Position = position
	self.ShareImportButtonSection.Visible = decryptTable
	self.ShareImportButtonSection.Text = v2 or "Nothing"
end

function Profiles:_SetShareBubbleVisible(visible)
	if visible == self.ShareBubbleFrame.Visible then
		return
	end

	self.ShareBubbleFrame.Visible = visible
	self.ShareExportSectionTitle.Text = string.format(
		"Share only your %s settings by copying this: ",
		self.Page.CurrentPage or ""
	)
	self.ShareExportBox.Text = EnumLibrary:EncryptTable(self:_GetBulkSettings(nil))
	self.ShareExportSectionBox.Text = not self.Page.CurrentPage and "???" or EnumLibrary:EncryptTable(self:_GetBulkSettings(self.Page.CurrentPage))
	self.ShareImportBox.Text = ""
end

function Profiles:_Update(p)
	self._update_hash += 1
	local _update_hash = self._update_hash
	local settingsProfile = PlayerDataController:Get("SettingsProfile")

	for k, _slot in pairs(self._slots) do
		local visible = k == settingsProfile
		_slot.Button.Background.Visible = visible
		local title = _slot.Button.Title
		local textColor

		if visible then
			textColor = Color3.fromRGB(0, 0, 0)
		else
			textColor = Color3.fromRGB(255, 255, 255)
		end

		title.TextColor3 = textColor
		_slot.Bubble.Visible = false

		if not visible or p then
			continue
		end

		_slot.Bubble.Visible = true
		_slot.Bubble.Size = UDim2.new(0.5, 0, 0.5, 0)
		_slot.Bubble:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quint", 0.25, true)
		local v3 = _slot
		task.delay(3, function()
			if _update_hash ~= self._update_hash then
				return
			end

			v3.Bubble:TweenSize(UDim2.new(0.5, 0, 0.5, 0), "In", "Quint", 0.25, true)
			task.delay(0.25, function()
				if _update_hash ~= self._update_hash then
					return
				end

				v3.Bubble.Visible = false
			end)
		end)
	end
end

function Profiles:_ButtonEffect(data)
	data.MouseEnter:Connect(function()
		data.OnHover.Visible = true
	end)
	data.MouseLeave:Connect(function()
		data.OnHover.Visible = false
	end)
	ButtonEffect:Add(data)
end

function Profiles:_Setup()
	for i = 1, SettingsLibrary.NUM_PROFILES do
		local clone = settingsProfileSlot:Clone()
		clone.Button.Title.Text = i
		clone.Bubble.Container.Title.Text = "Switched to profile #" .. i
		clone.Parent = self.Container
		local v = i
		clone.Button.MouseButton1Click:Connect(function()
			self.Clicked:Fire(v)
		end)
		self._slots[i] = clone
		self:_ButtonEffect(clone.Button)
	end
end

function Profiles:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Background.Size = UDim2.new(1, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	self.ShareButton.MouseButton1Click:Connect(function()
		self:_SetShareBubbleVisible(true)
	end)
	self.ShareCloseButton.MouseButton1Click:Connect(function()
		self:_SetShareBubbleVisible(false)
	end)
	self.ShareImportButton.MouseButton1Click:Connect(function()
		self:_ImportSettings()
	end)
	self.ShareImportBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_UpdateImportButton()
	end)
	PlayerDataController:GetDataChangedSignal("SettingsProfile"):Connect(function()
		self:_Update()
	end)
	self:_Setup()
	self:_Update(true)
	self:_UpdateImportButton()
	self:_ButtonEffect(self.ShareButton)
	ButtonEffect:Add(self.ShareImportButton, true)
end

return Profiles