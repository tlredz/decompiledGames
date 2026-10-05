local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self:_Init()
	return self
end

function class:_UpdateElement(instance)
	local mouseKeyboard = instance:WaitForChild("MouseKeyboard")
	mouseKeyboard.Visible = ControlsController.CurrentControls == "MouseKeyboard"
	local gamepad = instance:WaitForChild("Gamepad")
	gamepad.Visible = ControlsController.CurrentControls == "Gamepad"
	local touch = instance:WaitForChild("Touch")
	touch.Visible = ControlsController.CurrentControls == "Touch"
end

function class:_UpdateAllElements()
	for _, v in pairs(CollectionService:GetTagged("UIInputFrame")) do
		self:_UpdateElement(v)
	end
end

function class:_Init()
	CollectionService:GetInstanceAddedSignal("UIInputFrame"):Connect(function(p)
		self:_UpdateElement(p)
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_UpdateAllElements()
	end)
	task.spawn(self._UpdateAllElements, self)
end

return class._new()