local createVector = vector.create
local humanoid = script.Parent:WaitForChild("Humanoid")
local currentCamera = workspace.CurrentCamera
humanoid.Seated:Connect(function(p, instance)
	local parent = instance and instance.Parent

	if p and parent and parent:GetAttribute("IsSubmarine") and parent:FindFirstChild("Base") and parent:FindFirstChild("PlanePart") and (instance.Name == "passenger" or instance.Name == "owner") then
		local v = parent:FindFirstChild("CameraPivot")

		if not v then
			v = Instance.new("Part")
			v.Name = "CameraPivot"
			v.Size = createVector(1, 1, 1)
			v.Transparency = 1
			v.CanCollide = false
			v:PivotTo(parent.Base:GetPivot())
			local attachment = Instance.new("Attachment")
			attachment.Parent = v
			local clone = parent.PlanePart.Plane0:Clone()
			clone.Name = "Fixed"
			clone.Parent = parent.PlanePart
			local planeConstraint = Instance.new("PlaneConstraint")
			planeConstraint.Attachment0 = clone
			planeConstraint.Attachment1 = attachment
			planeConstraint.Parent = v
			local alignPosition = Instance.new("AlignPosition")
			alignPosition.Attachment0 = attachment
			alignPosition.Attachment1 = parent.Base.Base1
			alignPosition.Parent = v
			v.Parent = parent
		end

		currentCamera.CameraType = Enum.CameraType.Track
		currentCamera.CameraSubject = v
	end
end)