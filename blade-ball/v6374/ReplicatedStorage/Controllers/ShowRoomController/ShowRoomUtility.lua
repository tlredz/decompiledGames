local ShowRoomUtility = {}
ShowRoomUtility.CameraOffset = nil
ShowRoomUtility.CameraOffsetSolo = nil
ShowRoomUtility.HoloPadLayout = nil

function ShowRoomUtility:GetPartFitDistance(p, instance)
	local _ = instance.CFrame
	local size = instance.Size
	local viewportSize = p.ViewportSize
	local v = math.min(1, viewportSize.X / viewportSize.Y)
	local v2 = math.atan(math.tan((math.rad(p.FieldOfView / 2))) * v)
	return size.Magnitude / 2 / math.sin(v2)
end

function ShowRoomUtility.GetShowRoomCamera(_, instance)
	local camera = instance:FindFirstChild("Camera")
	local lookAt = camera and camera:FindFirstChild("LookAt")

	if camera and lookAt then
		return CFrame.lookAt(camera.CFrame.Position, lookAt.WorldPosition)
	end

	return nil
end

function ShowRoomUtility:GetCameraCFrameFor(p, instance)
	local camera = instance:WaitForChild("Camera")
	local cframe = CFrame.lookAt(camera.CFrame.Position, camera:FindFirstChild("LookAt").WorldPosition)
	local partFitDistance = self:GetPartFitDistance(p, (instance:WaitForChild("CameraViewport")))
	local cframe2 = cframe - cframe.LookVector * partFitDistance / 4
	local cameraOffset = self.CameraOffset
	local holoPads = instance:FindFirstChild("HoloPads")

	if (holoPads and #holoPads:GetChildren() or 0) < 2 and cameraOffset then
		local NPCS = instance:FindFirstChild("NPCS")
		local v = NPCS and NPCS:GetChildren()[1]

		if v then
			local objectSpace = cframe2:ToObjectSpace(v:GetPivot())
			cameraOffset = CFrame.new(objectSpace.Position.X, cameraOffset.Y, cameraOffset.Z)
		else
			cameraOffset = self.CameraOffsetSolo or cameraOffset
		end
	end

	if cameraOffset then
		return cframe2 * cameraOffset
	end

	return cframe2
end

return ShowRoomUtility