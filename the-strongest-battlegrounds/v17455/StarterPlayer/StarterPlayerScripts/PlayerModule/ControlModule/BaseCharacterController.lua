local createVector = vector.create
local BaseCharacterController = {}
BaseCharacterController.__index = BaseCharacterController

function BaseCharacterController.new()
	local self = setmetatable({}, BaseCharacterController)
	self.enabled = false
	self.moveVector = createVector(0, 0, 0)
	self.moveVectorIsCameraRelative = true
	self.isJumping = false
	return self
end

function BaseCharacterController.OnRenderStepped(_, _: number) end

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