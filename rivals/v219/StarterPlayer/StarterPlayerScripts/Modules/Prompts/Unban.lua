local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(ban_data)
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.ConfirmButton = self.PromptFrame:WaitForChild("Confirm")
	self.TitleText = self.PromptFrame:WaitForChild("Title")
	self._ban_data = ban_data
	self:_Init()
	return self
end

function object:_Setup()
	self.TitleText.Text = "Unban " .. self._ban_data.Name
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.ConfirmButton.MouseButton1Click:Connect(function()
		ReplicatedStorage.Remotes.Moderator.Unban:FireServer(self._ban_data.Name)
		RunService.Heartbeat:Wait()
		self:CloseRequest()
	end)
	self:_Setup()
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.ConfirmButton)
end

return object