local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._models = {}
	self:_Init()
	return self
end

function class:_FixPermanentKeyboardBug()
	if not Utility:IsTextBoxFocused() then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = Players.LocalPlayer.PlayerGui
	local textBox = Instance.new("TextBox")
	textBox.BackgroundTransparency = 1
	textBox.Text = ""
	textBox.PlaceholderText = ""
	textBox.TextTransparency = 1
	textBox.Parent = screenGui
	task.defer(function()
		textBox:CaptureFocus()
		task.defer(function()
			textBox:ReleaseFocus()
			textBox:Destroy()
			screenGui:Destroy()
		end)
	end)
end

function class:_UpdatePrompts()
	for k, _model in pairs(self._models) do
		if not CONSTANTS.IS_MOBILE_SERVER and ControlsController.CurrentControls ~= "Touch" then
			k = nil
		end

		_model.Parent = k
	end
end

function class:_PromptAdded(instance)
	local model = instance:WaitForChild("Model")
	local proximityPrompt = model:WaitForChild("Prompt"):WaitForChild("ProximityPrompt")
	proximityPrompt.Triggered:Connect(function()
		ReplicatedStorage.Remotes.Misc.MobileDuelsTeleport:FireServer()
	end)
	proximityPrompt.ActionText = CONSTANTS.IS_MOBILE_SERVER and "Leave" or "Teleport"
	self._models[instance] = model
	task.defer(self._UpdatePrompts, self)
end

function class:_Init()
	Teleporting.EnabledChanged:Connect(function()
		self:_FixPermanentKeyboardBug()
	end)
	CollectionService:GetInstanceAddedSignal("LobbyMobileDuelsPrompt"):Connect(function(p)
		self:_PromptAdded(p)
	end)

	for _, v in pairs(CollectionService:GetTagged("LobbyMobileDuelsPrompt")) do
		task.defer(self._PromptAdded, self, v)
	end

	task.defer(self._UpdatePrompts, self)
	task.defer(self._FixPermanentKeyboardBug, self)
end

return class._new()