local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.ButtonsFrame = self.PageFrame:WaitForChild("Buttons")
	self.CloseButton = self.ButtonsFrame:WaitForChild("Close")
	self.TeleportButton = self.ButtonsFrame:WaitForChild("Teleport")
	self:_Init()
	return self
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.TeleportButton.MouseButton1Click:Connect(function()
		ReplicatedStorage.Remotes.Misc.MobileDuelsTeleport:FireServer()
		self:CloseRequest()
	end)
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.TeleportButton)
end

return object._new()