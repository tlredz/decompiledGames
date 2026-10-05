local class = {}
class.__index = class

function class.new()
	local self = setmetatable({}, class)
	self.cameras = require(script:WaitForChild("CameraModule"))
	self.controls = require(script:WaitForChild("ControlModule"))
	return self
end

function class.GetCameras(p)
	return p.cameras
end

function class.GetControls(p)
	return p.controls
end

function class:GetClickToMoveController()
	return self.controls:GetClickToMoveController()
end

return class.new()