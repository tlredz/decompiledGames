local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.LeaveButton = self.PageFrame:WaitForChild("Leave")
	self.LeaveButtonOnFrame = self.LeaveButton:WaitForChild("On")
	self.LeaveButtonCountdownFrame = self.LeaveButton:WaitForChild("Countdown")
	self.LeaveButtonCountdownText = self.LeaveButtonCountdownFrame:WaitForChild("Title")
	self._countdown_hash = 0
	self:_Init()
	return self
end

function object:Open(...)
	Page.Open(self, ...)
	task.spawn(self._Countdown, self)
end

function object:_Countdown()
	self._countdown_hash += 1
	local _ = self._countdown_hash
	self.LeaveButtonCountdownFrame.Visible = true
	self.LeaveButtonOnFrame.Visible = false
	self.LeaveButtonCountdownFrame.Visible = false
	self.LeaveButtonOnFrame.Visible = true
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.LeaveButton.MouseButton1Click:Connect(function()
		if self.LeaveButtonOnFrame.Visible then
			ReplicatedStorage.Remotes.Duels.LeaveDuel:FireServer()
			self:CloseRequest()
		end
	end)
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.LeaveButton)
end

return object._new()