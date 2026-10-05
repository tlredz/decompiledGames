local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ScaleFrame"
})
local AvatarEditorController = require(ReplicatedStorage.Modules.Client.AvatarEditor.AvatarEditorController)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local Panel = require(ReplicatedStorage.Modules.Client.Components.UI.Panels.Panel)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local CameraController = require(ReplicatedStorage.Modules.Client.UI.CameraController)
local CharacterBodyController = require(ReplicatedStorage.Modules.Client.AvatarEditor.CharacterBodyController)

function v:UpdateCharacterSize(flag: boolean)
	if not self._AvatarEditorMenuPanel.Visible then
		return
	end

	local text = tonumber(self.Instance.Buttons.Number.Number.Text)

	if text >= 1 and flag or text <= 0.5 and not flag then
		return
	end

	CharacterBodyController.IncrementBodySize(flag)
end

function v:UpdateCamera()
	if not self._AvatarEditorMenuPanel.Visible then
		return
	end

	CameraController.SetAvatarEditorCamera()
end

function v:OnAvatarEditorSlotLoaded(p)
	if not (p and p.scales) then
		return
	end

	self.characterSizeNumber = math.floor(p.scales.height / 0.05) * 0.05
	self.characterSizeNumber = self.characterSizeNumber > 1 and 1 or self.characterSizeNumber
	self.characterSizeNumber = self.characterSizeNumber < 0.5 and 0.5 or self.characterSizeNumber
	local text = string.format("%.2f", self.characterSizeNumber)

	if text:sub(-3) == ".00" then
		text = text:sub(1, -4)
	end

	self.Instance.Buttons.Number.Number.Text = text
	self:UpdateCamera()
end

function v:Construct()
	self._Janitor = Janitor.new()
	self.characterSizeNumber = 1
	self._AvatarEditorMenuPanel = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"AvatarEditorMenu",
		Panel
	):GetInstance()
	self._Janitor:Add(AvatarEditorController.OnResetCharacterAppearance:Connect(function()
		self.characterSizeNumber = 1
		self.Instance.Buttons.Number.Number.Text = "1"
		task.wait(0.5)
		self:UpdateCamera()
	end))
	self._Janitor:Add(CharacterBodyController.OnBodySizeChanged:Connect(function(p)
		self:OnAvatarEditorSlotLoaded(p)
	end))
end

function v:Start()
	local buttons = self.Instance.Buttons
	self._Janitor:Add(buttons.Smaller.Activated:Connect(function()
		self:UpdateCharacterSize(false)
	end))
	self._Janitor:Add(buttons.Bigger.Activated:Connect(function()
		self:UpdateCharacterSize(true)
	end))
	self._Janitor:Add(WearingController.OnPlayerLoadedOutfit:Connect(function(p)
		if self._AvatarEditorMenuPanel.AccessoryAdjustments.Visible then
			return
		end

		self:OnAvatarEditorSlotLoaded(p)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v