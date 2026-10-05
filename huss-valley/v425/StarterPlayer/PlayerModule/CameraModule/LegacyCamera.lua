require(script.Parent:WaitForChild("CameraUtils"))
local CameraInput = require(script.Parent:WaitForChild("CameraInput"))
local Players = game:GetService("Players")
local BaseCamera = require(script.Parent:WaitForChild("BaseCamera"))
local object = setmetatable({}, BaseCamera)
object.__index = object

function object.new()
	local self = setmetatable(BaseCamera.new(), object)
	self.cameraType = Enum.CameraType.Fixed
	self.lastUpdate = tick()
	self.lastDistanceToSubject = nil
	return self
end

function object.GetModuleName(_)
	return "LegacyCamera"
end

function object:Update(p: number)
	if not self.cameraType then
		return nil, nil
	end

	local now = tick()
	local v = now - self.lastUpdate
	local currentCamera = workspace.CurrentCamera
	local cFrame = currentCamera.CFrame
	local focus = currentCamera.Focus
	local localPlayer = Players.LocalPlayer
	local rotation = CameraInput.getRotation(p)

	if self.lastUpdate == nil or v > 1 then
		self.lastDistanceToSubject = nil
	end

	local subjectPosition = self:GetSubjectPosition()

	if self.cameraType == Enum.CameraType.Fixed then
		if subjectPosition and localPlayer and currentCamera then
			local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
			local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(nil, rotation)
			focus = currentCamera.Focus
			cFrame = CFrame.new(
				currentCamera.CFrame.Position,
				currentCamera.CFrame.Position + cameraToSubjectDistance * newLookVectorFromArg
			)
		end
	elseif self.cameraType == Enum.CameraType.Attach then
		local subjectCFrame = self:GetSubjectCFrame()
		local eulerAnglesYXZ = currentCamera.CFrame:ToEulerAnglesYXZ()
		local _, v2 = subjectCFrame:ToEulerAnglesYXZ()
		local v3 = math.clamp(eulerAnglesYXZ - rotation.Y, -1.3962634015954636, 1.3962634015954636)
		focus = CFrame.new(subjectCFrame.Position) * CFrame.fromEulerAnglesYXZ(v3, v2, 0)
		cFrame = focus * CFrame.new(0, 0, self:StepZoom(p))
	else
		if self.cameraType ~= Enum.CameraType.Watch then
			return currentCamera.CFrame, currentCamera.Focus
		end

		if subjectPosition and localPlayer and currentCamera then
			local unit = nil

			if subjectPosition == currentCamera.CFrame.Position then
				warn("Camera cannot watch subject in same position as itself")
				return currentCamera.CFrame, currentCamera.Focus
			end

			local humanoid = self:GetHumanoid()

			if humanoid and humanoid.RootPart then
				local v2 = subjectPosition - currentCamera.CFrame.Position
				unit = v2.unit

				if self.lastDistanceToSubject and self.lastDistanceToSubject == self:GetCameraToSubjectDistance() then
					self:SetCameraToSubjectDistance(v2.magnitude)
				end
			end

			local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
			local newLookVectorFromArg = self:CalculateNewLookVectorFromArg(unit, rotation)
			focus = CFrame.new(subjectPosition)
			cFrame = CFrame.new(subjectPosition - cameraToSubjectDistance * newLookVectorFromArg, subjectPosition)
			self.lastDistanceToSubject = cameraToSubjectDistance
		end
	end

	self.lastUpdate = now
	return cFrame, focus
end

return object