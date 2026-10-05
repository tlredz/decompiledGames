local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
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

function object:Confirm()
	local success, result = pcall(
		ReplicatedStorage.Remotes.Moderator.PardonRedFlags.InvokeServer,
		ReplicatedStorage.Remotes.Moderator.PardonRedFlags,
		self._ban_data.Name
	)
	local v = ""

	for k, v2 in pairs(success and result or {}) do
		v ..= v2 .. (k < #result and "\n" or "")
	end

	self.OpenPrompt:Fire(
		"ErrorMessage",
		success and v ~= "" and "Success!" or "Whoops!",
		success and v ~= "" and "Successfully pardoned this player's red flags:\n" .. v or success and v == "" and "This player has no red flags!" or "Failed to pardon this player's red flags, please try again!"
	)
end

function object:_Setup()
	self.TitleText.Text = "Pardon " .. self._ban_data.Name
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.ConfirmButton.MouseButton1Click:Connect(function()
		self:Confirm()
	end)
	self:_Setup()
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.ConfirmButton)
end

return object