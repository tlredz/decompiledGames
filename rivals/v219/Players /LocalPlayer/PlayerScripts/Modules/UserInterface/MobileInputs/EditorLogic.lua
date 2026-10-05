local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local EditorLogic = {}
EditorLogic.__index = EditorLogic

function EditorLogic.new(mobileInputs)
	local self = setmetatable({}, EditorLogic)
	self.EnabledChanged = Signal.new()
	self.MobileInputs = mobileInputs
	self.ModalFrame = self.MobileInputs.Frame:WaitForChild("Modal")
	self.Enabled = false
	self._edits_pending = false
	self:_Init()
	return self
end

function EditorLogic:SetEnabled(p)
	local v = p and true or false

	if v == self.Enabled then
		return
	end

	self.Enabled = v or false
	self.EnabledChanged:Fire()

	if not self.Enabled then
		self:ApplyEdits()
	end
end

function EditorLogic:ResetLayout()
	for _, button in pairs(self.MobileInputs.Buttons.Buttons) do
		button:ResetPositionAndSize()
	end

	self._edits_pending = false
	ReplicatedStorage.Remotes.Data.UpdateMobileButtonSettings:FireServer(
		PlayerDataController:Get("SettingsProfile"),
		nil
	)
end

function EditorLogic:ApplyEdits()
	if not self._edits_pending then
		return
	end

	self._edits_pending = false
	ReplicatedStorage.Remotes.Data.UpdateMobileButtonSettings:FireServer(
		PlayerDataController:Get("SettingsProfile"),
		self.MobileInputs.Buttons:GetCurrentProfile()
	)
end

function EditorLogic:PendEdits()
	self._edits_pending = true
end

function EditorLogic:ImportProfile(p2)
	local decryptTable, v = EnumLibrary:DecryptTable(p2)

	if not decryptTable then
		Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
		return
	end

	self._edits_pending = true
	self.MobileInputs.Buttons:UpdatePositionsAndSizes(v)
end

function EditorLogic:_UpdateModal()
	self.ModalFrame.Visible = self.Enabled
end

function EditorLogic:_Init()
	self.EnabledChanged:Connect(function()
		self:_UpdateModal()
		CameraController:SetIsEditingMobileButtons(self.Enabled)
	end)
	self:_UpdateModal()
end

return EditorLogic