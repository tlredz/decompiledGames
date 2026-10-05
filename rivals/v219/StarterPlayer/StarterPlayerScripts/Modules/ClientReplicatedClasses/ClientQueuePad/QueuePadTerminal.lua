local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local QueuePadTerminal = {}
QueuePadTerminal.__index = QueuePadTerminal

function QueuePadTerminal.new(clientQueuePad)
	local self = setmetatable({}, QueuePadTerminal)
	self.ClientQueuePad = clientQueuePad
	self._model = self.ClientQueuePad:Get("Model"):WaitForChild("Visuals"):WaitForChild("Terminal")
	self._proximity_prompt = self._model:WaitForChild("Prompt"):WaitForChild("ProximityPrompt")
	self:_Init()
	return self
end

function QueuePadTerminal.Destroy(_) end

function QueuePadTerminal:_Setup()
	self._proximity_prompt.ObjectText = self.ClientQueuePad:Get("Model").Name
	self._proximity_prompt.MaxActivationDistance = 8

	if not CONSTANTS.IS_PRIVATE_SERVER_OWNER(Players.LocalPlayer.UserId) then
		task.defer(self._model.Destroy, self._model)
	end
end

function QueuePadTerminal:_Init()
	self._proximity_prompt.Triggered:Connect(function()
		Pages.PageSystem:OpenPage("EditQueuePad", true)
		Pages.PageSystem:WaitForPage("EditQueuePad"):SetQueuePad(self.ClientQueuePad)
	end)
	self:_Setup()
end

return QueuePadTerminal