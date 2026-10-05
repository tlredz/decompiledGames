require(script.Parent:WaitForChild("CameraUtils"))
game:GetService("Players")
local v = { "Humanoid", "VehicleSeat", "SkateboardPlatform" }
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserPortraitPopperFix")
end)
local v2 = success and result
local BaseOcclusion = require(script.Parent:WaitForChild("BaseOcclusion"))
local object = setmetatable({}, BaseOcclusion)
object.__index = object

function object.new()
	local self = setmetatable(BaseOcclusion.new(), object)
	self.camera = nil
	self.cameraSubjectChangeConn = nil
	self.subjectPart = nil
	self.playerCharacters = {}
	self.vehicleParts = {}
	self.lastPopAmount = 0
	self.lastZoomLevel = 0
	self.popperEnabled = false
	return self
end

function object.GetOcclusionMode(_)
	return Enum.DevCameraOcclusionMode.Zoom
end

function object.Enable(_, _) end

function object.CharacterAdded(p, p2, p3)
	p.playerCharacters[p3] = p2
end

function object.CharacterRemoving(p, _, p2)
	p.playerCharacters[p2] = nil
end

function object:Update(_, cFrame, focus)
	if not self.popperEnabled then
		return cFrame, focus
	end

	self.camera = game.Workspace.CurrentCamera
	local p = focus.p

	if v2 and self.subjectPart then
		p = self.subjectPart.CFrame.p
	end

	local v3 = cFrame
	local v4 = {}

	for _, playerCharacter in pairs(self.playerCharacters) do
		v4[#v4 + 1] = playerCharacter
	end

	for i = 1, #self.vehicleParts do
		v4[#v4 + 1] = self.vehicleParts[i]
	end

	local _ = self.camera.CFrame
	self.camera.CFrame = cFrame
	self.camera.Focus = focus
	local largestCutoffDistance = self.camera:GetLargestCutoffDistance(v4)
	local magnitude = (cFrame.p - p).Magnitude

	if math.abs(magnitude - self.lastZoomLevel) > 0.001 then
		self.lastPopAmount = 0
	end

	if largestCutoffDistance < self.lastPopAmount then
		largestCutoffDistance = self.lastPopAmount
	end

	if largestCutoffDistance > 0 then
		v3 = cFrame + cFrame.lookVector * largestCutoffDistance
		self.lastPopAmount = largestCutoffDistance - 0.3

		if self.lastPopAmount < 0 then
			self.lastPopAmount = 0
		end
	end

	self.lastZoomLevel = magnitude
	return v3, focus
end

function object:OnCameraSubjectChanged(instance)
	self.vehicleParts = {}
	self.lastPopAmount = 0

	if instance then
		self.popperEnabled = false

		for _, className in pairs(v) do
			if not instance:IsA(className) then
				continue
			end

			self.popperEnabled = true
			break
		end

		if instance:IsA("VehicleSeat") then
			self.vehicleParts = instance:GetConnectedParts(true)
		end

		if v2 then
			if instance:IsA("BasePart") then
				self.subjectPart = instance
			elseif instance:IsA("Model") then
				if instance.PrimaryPart then
					self.subjectPart = instance.PrimaryPart
					return
				end

				for _, part in pairs(instance:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					self.subjectPart = part
					return
				end
			elseif instance:IsA("Humanoid") then
				self.subjectPart = instance.RootPart
			end
		end
	end
end

return object