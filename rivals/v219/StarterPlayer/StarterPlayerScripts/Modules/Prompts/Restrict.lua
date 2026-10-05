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
	self.CasualLBsFrame = self.PromptFrame:WaitForChild("CasualLBs")
	self.CasualLBsButton = self.CasualLBsFrame:WaitForChild("Button")
	self.CasualLBsButtonEmpty = self.CasualLBsButton:WaitForChild("Empty")
	self.CasualLBsButtonFilled = self.CasualLBsButton:WaitForChild("Filled")
	self.CompLBsFrame = self.PromptFrame:WaitForChild("CompLBs")
	self.CompLBsButton = self.CompLBsFrame:WaitForChild("Button")
	self.CompLBsButtonEmpty = self.CompLBsButton:WaitForChild("Empty")
	self.CompLBsButtonFilled = self.CompLBsButton:WaitForChild("Filled")
	self._ban_data = ban_data
	self:_Init()
	return self
end

function object:Confirm()
	local v = {
		RestrictedFromCasualLeaderboards = self.CasualLBsButtonFilled.Visible,
		RestrictedFromCompetitiveLeaderboards = self.CompLBsButtonFilled.Visible
	}
	ReplicatedStorage.Remotes.Moderator.Restrict:FireServer(self._ban_data.Name, v)
	task.defer(self.CloseRequest, self)
end

function object:_Setup()
	self.TitleText.Text = "@" .. self._ban_data.Name
	self.CasualLBsButtonFilled.Visible = self._ban_data.Restrictions and self._ban_data.Restrictions.RestrictedFromCasualLeaderboards
	self.CasualLBsButtonEmpty.Visible = not self.CasualLBsButtonFilled.Visible
	self.CompLBsButtonFilled.Visible = self._ban_data.Restrictions and self._ban_data.Restrictions.RestrictedFromCompetitiveLeaderboards
	self.CompLBsButtonEmpty.Visible = not self.CompLBsButtonFilled.Visible
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.ConfirmButton.MouseButton1Click:Connect(function()
		self:Confirm()
	end)
	self.CasualLBsButton.MouseButton1Click:Connect(function()
		self.CasualLBsButtonEmpty.Visible = not self.CasualLBsButtonEmpty.Visible
		self.CasualLBsButtonFilled.Visible = not self.CasualLBsButtonEmpty.Visible
	end)
	self.CompLBsButton.MouseButton1Click:Connect(function()
		self.CompLBsButtonEmpty.Visible = not self.CompLBsButtonEmpty.Visible
		self.CompLBsButtonFilled.Visible = not self.CompLBsButtonEmpty.Visible
	end)
	self:_Setup()
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.ConfirmButton)
	ButtonEffect:Add(self.CasualLBsButton)
	ButtonEffect:Add(self.CompLBsButton)
end

return object