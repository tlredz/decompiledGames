local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(title, desc)
	assert(typeof(title) == "string", "Argument 1 invalid, expected a string, got " .. tostring(title))
	assert(typeof(desc) == "string", "Argument 2 invalid, expected a string, got " .. tostring(desc))
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.TitleText = self.PromptFrame:WaitForChild("Title")
	self.DescriptionText = self.PromptFrame:WaitForChild("Description")
	self._title = title
	self._desc = desc
	self:_Init()
	return self
end

function object:_Setup()
	self.TitleText.Text = self._title
	self.DescriptionText.Text = self._desc
	Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self:_Setup()
	ButtonEffect:Add(self.CloseButton)
end

return object