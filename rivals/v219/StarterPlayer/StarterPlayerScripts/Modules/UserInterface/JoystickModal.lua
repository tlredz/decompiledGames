local Players = game:GetService("Players")
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "JoystickModal")
	self:_Init()
	return self
end

function class:_Update()
	self.Frame.Visible = Pages.PageSystem.CurrentPage ~= nil
end

function class:_Init()
	Pages.PageSystem.PagesActivity:Connect(function()
		self:_Update()
	end)
	self:_Update()
end

return class._new()