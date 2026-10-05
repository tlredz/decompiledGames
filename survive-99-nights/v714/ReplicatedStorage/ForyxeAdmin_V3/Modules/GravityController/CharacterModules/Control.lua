local Control = {}
Control.__index = Control
Control.ClassName = "Control"

function Control.new(controller)
	local object = setmetatable({}, Control)
	local player = controller.Player
	local PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
	object.Controller = controller
	object.ControlModule = PlayerModule:GetControls()
	return object
end

function Control:GetMoveVector()
	return self.ControlModule:GetMoveVector()
end

function Control.Destroy(_) end

return Control