local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local ConnectionUtil = require(commonUtils:WaitForChild("ConnectionUtil"))
local vector = Vector3.new()
local BaseCharacterController = {}
BaseCharacterController.__index = BaseCharacterController

function BaseCharacterController.new()
	local self = setmetatable({}, BaseCharacterController)
	self.enabled = false
	self.moveVector = vector
	self.moveVectorIsCameraRelative = true
	self.isJumping = false
	self._connectionUtil = ConnectionUtil.new()
	return self
end

function BaseCharacterController.GetMoveVector(p)
	return p.moveVector
end

function BaseCharacterController.IsMoveVectorCameraRelative(p)
	return p.moveVectorIsCameraRelative
end

function BaseCharacterController.GetIsJumping(p)
	return p.isJumping
end

function BaseCharacterController.Enable(_, _: boolean)
	error("BaseCharacterController:Enable must be overridden in derived classes and should not be called.")
	return false
end

return BaseCharacterController