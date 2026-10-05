local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local v = Component.new({
	Tag = "EmoteAdditiveVfxToggleButton"
})

local function findStateImage(instance, childName: string)
	local guiObject = instance:FindFirstChild(childName, true)

	if guiObject == nil or not guiObject:IsA("GuiObject") then
		return nil
	end

	return guiObject
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:ApplyState()
	local isAdditiveVfxEnabled = EmotesController.IsAdditiveVfxEnabled()
	local isAdditiveVfxToggleVisible = EmotesController.IsAdditiveVfxToggleVisible()
	self.Instance.Visible = isAdditiveVfxToggleVisible
	self.Instance:SetAttribute("Enabled", isAdditiveVfxEnabled)

	if self._disabledX ~= nil then
		self._disabledX.Visible = not isAdditiveVfxEnabled
	end

	if self._checkmark ~= nil then
		self._checkmark.Visible = isAdditiveVfxEnabled
	end
end

function v:Toggle()
	if EmotesController.IsAdditiveVfxToggleVisible() == false then
		return
	end

	EmotesController.ToggleAdditiveVfx()
end

function v:Start()
	if not self.Instance:IsA("GuiButton") then
		return
	end

	local X = self.Instance:FindFirstChild("X", true)

	if X == nil or not X:IsA("GuiObject") then
		X = nil
	end

	self._disabledX = X
	local checkmark = self.Instance:FindFirstChild("Checkmark", true)

	if checkmark == nil or not checkmark:IsA("GuiObject") then
		checkmark = nil
	end

	self._checkmark = checkmark
	EmotesController.AddAdditiveVfxHotkeyHandler()
	self._Janitor:Add(function()
		EmotesController.RemoveAdditiveVfxHotkeyHandler()
	end)
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		self:Toggle()
	end))
	self._Janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.E then
			self:Toggle()
		end
	end))
	self._Janitor:Add(EmotesController.OnAdditiveVfxEnabledChanged:Connect(function()
		self:ApplyState()
	end))
	self._Janitor:Add(EmotesController.OnAdditiveVfxToggleVisibleChanged:Connect(function()
		self:ApplyState()
	end))
	self:ApplyState()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v