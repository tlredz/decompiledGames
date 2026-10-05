local createVector = vector.create
local Camera = {}
Camera.__index = Camera
Camera.ClassName = "Camera"

function Camera.new(controller)
	local object = setmetatable({}, Camera)
	local player = controller.Player
	local PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
	object.Controller = controller
	object.CameraModule = PlayerModule:GetCameras()
	init(object)
	return object
end

function init(p)
	function p.CameraModule.GetUpVector(_, _)
		return p.Controller._gravityUp
	end
end

function Camera.Destroy(p)
	function p.CameraModule.GetUpVector(_, _)
		return createVector(0, 1, 0)
	end
end

return Camera