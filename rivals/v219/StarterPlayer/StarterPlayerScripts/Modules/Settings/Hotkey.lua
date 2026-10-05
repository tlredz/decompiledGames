local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local SettingSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("SettingSlot"))
local object = setmetatable({}, SettingSlot)
object.__index = object

function object.new(...)
	local self = setmetatable(SettingSlot.new(...), object)
	self.HotkeyContainer = self.ControlsSettingFrame:WaitForChild("Container")
	self.HotkeyBackground = self.HotkeyContainer:WaitForChild("Background")
	self.HotkeyButton = self.HotkeyContainer:WaitForChild("Button")
	self.HotkeyValueText = self.HotkeyContainer:WaitForChild("Value")
	self._destroyed = false
	self._listening = false
	self._listen_connections = {}
	self:_Init()
	return self
end

function object.GetSelection(p)
	return p.HotkeyButton
end

function object:Destroy()
	self._destroyed = true

	for _, _listen_connection in pairs(self._listen_connections) do
		_listen_connection:Disconnect()
	end

	SettingSlot.Destroy(self)
end

function object:_Update()
	self:_StopListening()
	self.HotkeyValueText.Text = typeof(self.Value) == "EnumItem" and self.Value.Name or self.Value or ""
end

function object:_Input(p)
	self:_StopListening()
	self:SetValue(self.SettingsInfo.VerifyInput(p))
end

function object:_StartListening()
	if self._listening or self._destroyed then
		return
	end

	self._listening = true
	table.insert(self._listen_connections, UserInputService.InputBegan:Connect(function(input)
		local v2

		if input.KeyCode == Enum.KeyCode.Unknown then
			v2 = input.UserInputType.Name
		else
			v2 = input.KeyCode.Name
		end

		self:_Input(v2)
	end))
	table.insert(self._listen_connections, UserInputService.InputChanged:Connect(function(_) end))
	self.HotkeyBackground.ImageColor3 = Color3.fromRGB(127, 127, 127)
	self.HotkeyValueText.TextStrokeColor3 = Color3.fromRGB(64, 64, 64)
	self.HotkeyValueText.Text = "• • •"
end

function object:_StopListening()
	if not self._listening then
		return
	end

	self._listening = false

	for _, _listen_connection in pairs(self._listen_connections) do
		_listen_connection:Disconnect()
	end

	self.HotkeyBackground.ImageColor3 = Color3.fromRGB(0, 150, 255)
	self.HotkeyValueText.TextStrokeColor3 = Color3.fromRGB(0, 75, 127)
end

function object:_Setup()
	self.HotkeyButton.NextSelectionRight = self.HotkeyButton
	self.HotkeyButton.NextSelectionLeft = self.HotkeyButton
end

function object:_Init()
	self.Changed:Connect(function()
		self:_Update()
	end)
	self.HotkeyButton.MouseButton1Click:Connect(function()
		RunService.Heartbeat:Wait()

		if ControlsController.CurrentControls == "Touch" then
			return
		end

		self:_StartListening()
	end)
	self:_Setup()
	self:_Update()
	ButtonEffect:Add(self.HotkeyButton, true)
end

return object