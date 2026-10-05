local parent = script.Parent.Parent
local CommonCamera = require(parent:WaitForChild("Character"):WaitForChild("Camera"):WaitForChild("CommonCamera"))
local DefaultCamera = require(parent:WaitForChild("Character"):WaitForChild("Camera"):WaitForChild("DefaultCamera"))
local ThirdPersonTrackCamera = require(parent:WaitForChild("Character"):WaitForChild("Camera"):WaitForChild("ThirdPersonTrackCamera"))
local CameraService = {}
CameraService.__index = CameraService
local v = nil

function CameraService.new()
	local self = setmetatable({
		RegisteredCameras = {}
	}, CameraService)
	self:RegisterCamera("Default", (DefaultCamera.new()))
	self:RegisterCamera("ThirdPersonTrack", (ThirdPersonTrackCamera.new()))
	self:RegisterCamera("Disabled", (CommonCamera.new()))
	return self
end

function CameraService.GetInstance()
	if not v then
		v = CameraService.new()
	end

	return v
end

function CameraService:RegisterCamera(p2: string, p3)
	self.RegisteredCameras[p2] = p3
end

function CameraService:SetActiveCamera(activeCamera: string)
	if self.ActiveCamera == activeCamera then
		return
	end

	self.ActiveCamera = activeCamera

	if self.CurrentCamera then
		self.CurrentCamera:Disable()
	end

	self.CurrentCamera = self.RegisteredCameras[activeCamera]

	if self.CurrentCamera then
		self.CurrentCamera:Enable()
	elseif activeCamera ~= nil then
		warn((`Nexus VR Character Model camera "{activeCamera}" is not registered.`))
	end
end

function CameraService:UpdateCamera(cframe: CFrame)
	if self.CurrentCamera then
		self.CurrentCamera:UpdateCamera(cframe)
	end
end

return CameraService