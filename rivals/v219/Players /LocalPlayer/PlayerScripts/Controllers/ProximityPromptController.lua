local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local Shutdown = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Shutdown"))
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local proximityPrompts = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ProximityPrompts")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._custom_prompt = nil
	self._custom_prompt_hash = 0
	self._custom_prompt_connections = {}
	self:_Init()
	return self
end

function class:_UpdateEnabled()
	ProximityPromptService.Enabled = not (SpectateController.CurrentDuelSubject or MobileInputs.EditorEnabled or Pages.PageSystem.CurrentPage or Teleporting.Enabled or Shutdown.Enabled or Queue:IsVisible() or GuiService.MenuIsOpen or Equipment.IsOpen or PlayerDataController:GetSetting("Hide HUD"))
end

function class:_Cleanup()
	self._custom_prompt_hash += 1

	for _, _custom_prompt_connection in pairs(self._custom_prompt_connections) do
		_custom_prompt_connection:Disconnect()
	end

	self._custom_prompt_connections = {}

	if self._custom_prompt then
		BetterDebris:AddItem(self._custom_prompt, 0.15)

		if self._custom_prompt:FindFirstChild("Button") and self._custom_prompt:IsDescendantOf(Players) then
			self._custom_prompt.Button:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quint", 0.25, true)
		end

		self._custom_prompt = nil
	end
end

function class:_Create(instance)
	self:_Cleanup()
	instance:SetAttribute("ClickablePrompt", instance.ClickablePrompt)
	instance.ClickablePrompt = ControlsController.CurrentControls == "Touch" or instance:GetAttribute("ClickablePrompt")
	self._custom_prompt_hash += 1
	local _custom_prompt_hash = self._custom_prompt_hash
	local proximityPrompt = proximityPrompts[instance:GetAttribute("Style") or "Default"]
	self._custom_prompt = proximityPrompt:Clone()
	self._custom_prompt.Name = "ProximityPrompt - " .. proximityPrompt.Name
	self._custom_prompt.Button.Inputs.MouseKeyboard.KeyText.Text = instance.KeyboardKeyCode.Name
	self._custom_prompt.Button.Inputs.Gamepad.Container:SetAttribute("EnumType", "KeyCode")
	self._custom_prompt.Button.Inputs.Gamepad.Container:SetAttribute("EnumName", instance.GamepadKeyCode.Name)
	self._custom_prompt.Button.Inputs.Gamepad.Container:AddTag("UIKeybindContainer")
	self._custom_prompt.Button.Interactable = instance.ClickablePrompt
	self._custom_prompt.Adornee = instance.Parent
	self._custom_prompt.Parent = Players.LocalPlayer.PlayerGui

	local function update()
		self._custom_prompt.Button.ObjectText.Text = instance.ObjectText
		self._custom_prompt.Button.ActionText.Text = instance.ActionText
		WeaponStatusHandler:ClearStatusElements(self._custom_prompt.Button.ObjectText)
		WeaponStatusHandler:ApplyItemStatusToText(
			self._custom_prompt.Button.ObjectText,
			ItemLibrary.Items[instance.ObjectText] and ItemLibrary.Items[instance.ObjectText].Status
		)
	end

	table.insert(self._custom_prompt_connections, instance:GetPropertyChangedSignal("ObjectText"):Connect(update))
	table.insert(self._custom_prompt_connections, instance:GetPropertyChangedSignal("ActionText"):Connect(update))
	update()
	self._custom_prompt.Button.Size = UDim2.new(
		self._custom_prompt.Button.Size.X.Scale * 0.5,
		self._custom_prompt.Button.Size.X.Offset * 0.5,
		self._custom_prompt.Button.Size.Y.Scale * 0.5,
		self._custom_prompt.Button.Size.Y.Offset * 0.5
	)
	self._custom_prompt.Button:TweenSize(proximityPrompt.Button.Size, "Out", "Quint", 0.25, true, function()
		if self._custom_prompt_hash ~= _custom_prompt_hash or not instance.ClickablePrompt then
			return
		end

		self._custom_prompt.Button.MouseButton1Down:Connect(function()
			instance:InputHoldBegin()
		end)
		self._custom_prompt.Button.MouseButton1Up:Connect(function()
			instance:InputHoldEnd()
		end)
		self._custom_prompt.Button.MouseLeave:Connect(function()
			instance:InputHoldEnd()
		end)
		ButtonEffect:Add(self._custom_prompt.Button, nil, {
			DontReposition = true
		})
	end)
	self:_UpdateEnabled()
end

function class:_Init()
	ProximityPromptService.PromptShown:Connect(function(p)
		if p.Style ~= Enum.ProximityPromptStyle.Custom then
			return
		end

		self:_Create(p)
	end)
	ProximityPromptService.PromptHidden:Connect(function(p)
		if p.Style ~= Enum.ProximityPromptStyle.Custom then
			return
		end

		self:_Cleanup()
	end)
	Pages.PageSystem.PageOpened:Connect(function()
		self:_UpdateEnabled()
	end)
	Pages.PageSystem.PageClosed:Connect(function()
		self:_UpdateEnabled()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_UpdateEnabled()
	end)
	Shutdown.EnabledChanged:Connect(function()
		self:_UpdateEnabled()
	end)
	Queue.VisibilityChanged:Connect(function()
		self:_UpdateEnabled()
	end)
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_UpdateEnabled()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateEnabled()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateEnabled()
	end)
	Equipment.Opened:Connect(function()
		self:_UpdateEnabled()
	end)
	PlayerDataController:GetSettingChangedSignal("Hide HUD"):Connect(function()
		self:_UpdateEnabled()
	end)
	self:_UpdateEnabled()
end

return class._new()