local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ModerationLibrary = require(ReplicatedStorage.Modules.ModerationLibrary)
local SettingsInfo = require(ReplicatedStorage.Modules.SettingsInfo)
require(ReplicatedStorage.Modules.BanLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local Dropdown = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Settings"):WaitForChild("Dropdown"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local v = {
	"Exploiting",
	"Exploiting - Movement Cheats",
	"Exploiting - Aim Cheats",
	"Exploiting - Vision Cheats",
	"Requesting Exploits",
	"Playing With Exploiters",
	"Fake Reporting",
	"Farming",
	"Abusing Minor Bugs",
	"Harassment / Hate Speech",
	"Ban Evasion",
	"Custom"
}
local v2 = {
	"Permanent",
	"1 day",
	"3 days",
	"7 days",
	"14 days",
	"30 days",
	"90 days",
	"180 days",
	"365 days",
	"Custom"
}
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(ban_data)
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.ConfirmButton = self.PromptFrame:WaitForChild("Confirm")
	self.TitleText = self.PromptFrame:WaitForChild("Title")
	self.RestrictionNotice = self.PromptFrame:WaitForChild("RestrictionNotice")
	self.DetailsFrame = self.PromptFrame:WaitForChild("Details")
	self.ReasonFrame = self.DetailsFrame:WaitForChild("Reason")
	self.ReasonDropdownFrame = self.ReasonFrame:WaitForChild("Dropdown")
	self.ReasonCustomFrame = self.DetailsFrame:WaitForChild("ReasonCustom")
	self.ReasonCustomBox = self.ReasonCustomFrame:WaitForChild("Input"):WaitForChild("Box")
	self.DurationFrame = self.DetailsFrame:WaitForChild("Duration")
	self.DurationDropdownFrame = self.DurationFrame:WaitForChild("Dropdown")
	self.DurationCustomFrame = self.DetailsFrame:WaitForChild("DurationCustom")
	self.DurationCustomBox = self.DurationCustomFrame:WaitForChild("Input"):WaitForChild("Box")
	self.WarnFrame = self.DetailsFrame:WaitForChild("Warn")
	self.WarnContainer = self.WarnFrame:WaitForChild("Container")
	self.WarnButton = self.WarnContainer:WaitForChild("Button")
	self.WarnButtonEmpty = self.WarnButton:WaitForChild("Empty")
	self.WarnButtonFilled = self.WarnButton:WaitForChild("Filled")
	self.CasualLBsFrame = self.DetailsFrame:WaitForChild("CasualLBs")
	self.CasualLBsContainer = self.CasualLBsFrame:WaitForChild("Container")
	self.CasualLBsButton = self.CasualLBsContainer:WaitForChild("Button")
	self.CasualLBsButtonEmpty = self.CasualLBsButton:WaitForChild("Empty")
	self.CasualLBsButtonFilled = self.CasualLBsButton:WaitForChild("Filled")
	self.CompLBsFrame = self.DetailsFrame:WaitForChild("CompLBs")
	self.CompLBsContainer = self.CompLBsFrame:WaitForChild("Container")
	self.CompLBsButton = self.CompLBsContainer:WaitForChild("Button")
	self.CompLBsButtonEmpty = self.CompLBsButton:WaitForChild("Empty")
	self.CompLBsButtonFilled = self.CompLBsButton:WaitForChild("Filled")
	self.ReasonDropdown = Dropdown.new(SettingsInfo.new("", "", "", "", "", "Dropdown", v[1], v))
	self.DurationDropdown = Dropdown.new(SettingsInfo.new("", "", "", "", "", "Dropdown", v2[1], v2))
	self._ban_data = ban_data
	self:_Init()
	return self
end

function object:Confirm()
	local text

	if self.ReasonDropdown.Value == "Custom" then
		text = self.ReasonCustomBox.Text
	else
		text = self.ReasonDropdown.Value
	end

	local text2

	if self.DurationDropdown.Value == "Custom" then
		text2 = tonumber(self.DurationCustomBox.Text)
	else
		text2 = self.DurationDropdown.Value == "Permanent" and -1 or tonumber((string.sub(
			self.DurationDropdown.Value,
			1,
			string.find(self.DurationDropdown.Value, " ") - 1
		)))
	end

	if not text2 or (#text < 5 or #text > 100) then
		return
	end

	if ModerationLibrary:CanWarnTemplate(PlayerDataController:Get("PermissionsRoles")) then
		local _ = self.WarnButtonFilled.Visible
	end

	local v3 = ModerationLibrary:CanRestrict(PlayerDataController:Get("PermissionsRoles")) and {
		RestrictedFromCasualLeaderboards = self.CasualLBsButtonFilled.Visible or self._ban_data.Restrictions and self._ban_data.Restrictions.RestrictedFromCasualLeaderboards,
		RestrictedFromCompetitiveLeaderboards = self.CompLBsButtonFilled.Visible or self._ban_data.Restrictions and self._ban_data.Restrictions.RestrictedFromCompetitiveLeaderboards
	} or nil
	ReplicatedStorage.Remotes.Moderator.Ban:FireServer(
		self._ban_data.Name,
		text2,
		text,
		self.WarnButtonFilled.Visible,
		v3
	)
	task.defer(self.CloseRequest, self)
end

function object.Destroy(p)
	p.ReasonDropdown:Destroy()
	p.DurationDropdown:Destroy()
	Prompt.Destroy(p)
end

function object:_Update()
	local value = self.ReasonDropdown.Value
	local value2 = self.DurationDropdown.Value
	self.ReasonCustomFrame.Visible = value == "Custom"
	self.DurationFrame.Visible = true
	self.DurationCustomFrame.Visible = value2 == "Custom"
end

function object:_FormatSettingSlot(data)
	data.SettingFrame.Size = UDim2.new(1, 0, 1, 0)
	data.SettingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	data.SettingFrame.SizeConstraint = Enum.SizeConstraint.RelativeXY
	data.ControlsFrame.Size = UDim2.new(1, 0, 1, 0)
	data.ControlsFrame.SizeConstraint = Enum.SizeConstraint.RelativeXY
	data.DropdownContainer.Size = UDim2.new(1, 0, 1, 0)
	data.Background.Visible = false
	data.DetailsResetButton.Size = UDim2.new(0, 0, 0, 0)
end

function object:_Setup()
	self.TitleText.Text = "@" .. self._ban_data.Name
	self.ReasonDropdown.SettingFrame.Parent = self.ReasonDropdownFrame
	self.DurationDropdown.SettingFrame.Parent = self.DurationDropdownFrame
	self.WarnFrame.Visible = ModerationLibrary:CanWarnTemplate(PlayerDataController:Get("PermissionsRoles"))
	self.CasualLBsFrame.Visible = ModerationLibrary:CanRestrict(PlayerDataController:Get("PermissionsRoles"))
	self.CompLBsFrame.Visible = ModerationLibrary:CanRestrict(PlayerDataController:Get("PermissionsRoles"))
	self.RestrictionNotice.Visible = ModerationLibrary:CanRestrict(PlayerDataController:Get("PermissionsRoles"))
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.ConfirmButton.MouseButton1Click:Connect(function()
		self:Confirm()
	end)
	self.DurationCustomBox.FocusLost:Connect(function()
		if self.DurationCustomBox.Text ~= "" then
			self.DurationCustomBox.Text = tonumber(self.DurationCustomBox.Text) and math.clamp(
				math.floor((tonumber(self.DurationCustomBox.Text))),
				1,
				999
			) or ""
		end
	end)
	self.ReasonDropdown.Replicate:Connect(function()
		self:_Update()
	end)
	self.DurationDropdown.Replicate:Connect(function()
		self:_Update()
	end)
	self.WarnButton.MouseButton1Click:Connect(function()
		self.WarnButtonFilled.Visible = not self.WarnButtonFilled.Visible
		self.WarnButtonEmpty.Visible = not self.WarnButtonFilled.Visible
	end)
	self.CasualLBsButton.MouseButton1Click:Connect(function()
		self.CasualLBsButtonFilled.Visible = not self.CasualLBsButtonFilled.Visible
		self.CasualLBsButtonEmpty.Visible = not self.CasualLBsButtonFilled.Visible
	end)
	self.CompLBsButton.MouseButton1Click:Connect(function()
		self.CompLBsButtonFilled.Visible = not self.CompLBsButtonFilled.Visible
		self.CompLBsButtonEmpty.Visible = not self.CompLBsButtonFilled.Visible
	end)
	self:_Setup()
	self:_FormatSettingSlot(self.ReasonDropdown)
	self:_FormatSettingSlot(self.DurationDropdown)
	self:_Update()
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.ConfirmButton)
	ButtonEffect:Add(self.WarnButton)
	ButtonEffect:Add(self.CasualLBsButton)
	ButtonEffect:Add(self.CompLBsButton)
end

return object