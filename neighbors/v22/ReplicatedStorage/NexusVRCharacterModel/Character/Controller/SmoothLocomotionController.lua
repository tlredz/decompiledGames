local BaseController = require(script.Parent:WaitForChild("BaseController"))
local SmoothLocomotionController = {}
SmoothLocomotionController.__index = SmoothLocomotionController
setmetatable(SmoothLocomotionController, BaseController)

function SmoothLocomotionController.new()
	return (setmetatable(BaseController.new(), SmoothLocomotionController))
end

function SmoothLocomotionController:Enable()
	BaseController.Enable(self)
	self.JoystickState = {
		Thumbstick = Enum.KeyCode.Thumbstick2
	}
end

function SmoothLocomotionController:Disable()
	BaseController.Disable(self)
	self.JoystickState = nil
end

function SmoothLocomotionController.UpdateCharacter(player)
	BaseController.UpdateCharacter(player)

	if not player.Character then
		return
	end

	local joystickState, _, v = player:GetJoystickState(player.JoystickState)
	player:UpdateRotating(Enum.UserCFrame.RightHand, joystickState, v)
end

return SmoothLocomotionController