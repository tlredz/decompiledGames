local vector = Vector2.new(0, 0)
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local Players = game:GetService("Players")
game:GetService("VRService")
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

function object.Test(_)
	print("LegacyCamera:Test()")
end

function object.SetCameraToSubjectDistance(p, p2)
	return BaseCamera.SetCameraToSubjectDistance(p, p2)
end

function object:Update(_)
	if not self.cameraType then
		return
	end

	local now = tick()
	local v = now - self.lastUpdate
	local currentCamera = workspace.CurrentCamera
	local cFrame = currentCamera.CFrame
	local focus = currentCamera.Focus
	local localPlayer = Players.LocalPlayer
	local humanoid = self:GetHumanoid()
	local cameraSubject = currentCamera and currentCamera.CameraSubject

	if cameraSubject then
		cameraSubject:IsA("VehicleSeat")
	end

	if cameraSubject then
		cameraSubject:IsA("SkateboardPlatform")
	end

	if humanoid then
		local _ = humanoid:GetState() == Enum.HumanoidStateType.Climbing
	end

	if self.lastUpdate == nil or v > 1 then
		self.lastDistanceToSubject = nil
	end

	local subjectPosition = self:GetSubjectPosition()

	if self.cameraType == Enum.CameraType.Fixed then
		if self.lastUpdate then
			local v2 = math.min(0.1, now - self.lastUpdate)
			local v3 = self:UpdateGamepad()
			self.rotateInput += v3 * v2
		end

		if subjectPosition and localPlayer and currentCamera then
			local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
			local newLookVector = self:CalculateNewLookVector()
			self.rotateInput = vector
			focus = currentCamera.Focus
			cFrame = CFrame.new(
				currentCamera.CFrame.p,
				currentCamera.CFrame.p + cameraToSubjectDistance * newLookVector
			)
		end
	elseif self.cameraType == Enum.CameraType.Attach then
		if subjectPosition and currentCamera then
			local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
			local humanoid2 = self:GetHumanoid()

			if self.lastUpdate and humanoid2 and humanoid2.RootPart then
				local v2 = math.min(0.1, now - self.lastUpdate)
				local v3 = self:UpdateGamepad()
				self.rotateInput += v3 * v2
				local lookVector = humanoid2.RootPart.CFrame.lookVector
				local angleBetweenXZVectors = CameraUtils.GetAngleBetweenXZVectors(
					lookVector,
					self:GetCameraLookVector()
				)

				if CameraUtils.IsFinite(angleBetweenXZVectors) then
					self.rotateInput = Vector2.new(angleBetweenXZVectors, self.rotateInput.Y)
				end
			end

			local newLookVector = self:CalculateNewLookVector()
			self.rotateInput = vector
			focus = CFrame.new(subjectPosition)
			cFrame = CFrame.new(subjectPosition - cameraToSubjectDistance * newLookVector, subjectPosition)
		end
	else
		if self.cameraType ~= Enum.CameraType.Watch then
			return currentCamera.CFrame, currentCamera.Focus
		end

		if subjectPosition and localPlayer and currentCamera then
			local humanoid2 = self:GetHumanoid()
			local unit

			if humanoid2 and humanoid2.RootPart then
				local v2 = subjectPosition - currentCamera.CFrame.p
				unit = v2.unit

				if self.lastDistanceToSubject and self.lastDistanceToSubject == self:GetCameraToSubjectDistance() then
					self:SetCameraToSubjectDistance(v2.magnitude)
				end
			end

			local cameraToSubjectDistance = self:GetCameraToSubjectDistance()
			local newLookVector = self:CalculateNewLookVector(unit)
			self.rotateInput = vector
			focus = CFrame.new(subjectPosition)
			cFrame = CFrame.new(subjectPosition - cameraToSubjectDistance * newLookVector, subjectPosition)
			self.lastDistanceToSubject = cameraToSubjectDistance
		end
	end

	self.lastUpdate = now
	return cFrame, focus
end

return object