local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
	self.DetailsFrame = self.PromptFrame:WaitForChild("Details")
	self.ReasonCustomBox = self.DetailsFrame:WaitForChild("ReasonCustom"):WaitForChild("Input"):WaitForChild("Box")
	self._ban_data = ban_data
	self:_Init()
	return self
end

function object:Confirm()
	local text = self.ReasonCustomBox.Text

	if #text < 5 or #text > 100 then
		return
	end

	ReplicatedStorage.Remotes.Moderator.Warn:FireServer(self._ban_data.Name, text)
	task.defer(self.CloseRequest, self)
end

function object:_Setup()
	self.TitleText.Text = "@" .. self._ban_data.Name
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