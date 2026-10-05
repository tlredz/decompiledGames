local parent = script.Parent.Parent
local BaseController = require(parent:WaitForChild("Character"):WaitForChild("Controller"):WaitForChild("BaseController"))
local TeleportController = require(parent:WaitForChild("Character"):WaitForChild("Controller"):WaitForChild("TeleportController"))
local SmoothLocomotionController = require(parent:WaitForChild("Character"):WaitForChild("Controller"):WaitForChild("SmoothLocomotionController"))
local ControlService = {}
ControlService.__index = ControlService
local v = nil

function ControlService.new()
	local self = setmetatable({
		RegisteredControllers = {}
	}, ControlService)
	local v2 = BaseController.new()
	v2.ActionsToLock = {
		Enum.KeyCode.Thumbstick1,
		Enum.KeyCode.Thumbstick2,
		Enum.KeyCode.ButtonR3,
		Enum.KeyCode.ButtonA
	}
	self:RegisterController("None", v2)
	self:RegisterController("Teleport", (TeleportController.new()))
	self:RegisterController("SmoothLocomotion", (SmoothLocomotionController.new()))
	return self
end

function ControlService.GetInstance()
	if not v then
		v = ControlService.new()
	end

	return v
end

function ControlService:RegisterController(p2: string, p3)
	self.RegisteredControllers[p2] = p3
end

function ControlService:SetActiveController(activeController: string)
	if self.ActiveController == activeController then
		return
	end

	self.ActiveController = activeController

	if self.CurrentController then
		self.CurrentController:Disable()
	end

	self.CurrentController = self.RegisteredControllers[activeController]

	if self.CurrentController then
		self.CurrentController:Enable()
	elseif activeController ~= nil then
		warn((`Nexus VR Character Model controller "{activeController}" is not registered.`))
	end
end

function ControlService:UpdateCharacter()
	if self.CurrentController then
		self.CurrentController:UpdateCharacter()
	end
end

return ControlService