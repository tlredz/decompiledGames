local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local prompts = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("Prompts")
local Prompt = {}
Prompt.__index = Prompt

function Prompt.new(childName)
	assert(typeof(childName) == "string", "Argument 1 invalid, expected a string, got " .. tostring(childName))
	local self = setmetatable({}, Prompt)
	self.Closed = Signal.new()
	self.OpenPrompt = Signal.new()
	self.PromptFrame = prompts:WaitForChild(childName):Clone()
	self._destroyed = false
	self._connections = {}
	self._destroy_these = {}
	self:_Init()
	return self
end

function Prompt.GetDefaultElement(p)
	return p.CloseButton or nil
end

function Prompt.CloseRequest(p)
	p.Closed:Fire()
end

function Prompt.Open(p, parent)
	assert(typeof(parent) == "Instance", "Argument 1 invalid, expected an Instance, got " .. tostring(parent))
	p.PromptFrame.Parent = parent
	p.PromptFrame.Position = UDim2.new(0.5, 0, 0.625, 0)
	p.PromptFrame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Back", 0.25, true)
end

function Prompt:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for _, v in pairs(self._destroy_these) do
		v:Destroy()
	end

	self._destroy_these = {}

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self.PromptFrame:Destroy()
	self.Closed:Destroy()
	self.OpenPrompt:Destroy()
end

function Prompt:_Init() end

return Prompt