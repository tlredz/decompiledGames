local module = require("@game/ReplicatedStorage/Omni")
local currentCamera = workspace.CurrentCamera
local v = nil
local v2 = {
	CameraType = {},
	CameraSubject = {}
}
local Camera = {
	Refresh = function()
		local custom = Enum.CameraType.Custom
		local priority = 0

		for _, v3 in v2.CameraType do
			if not (not custom or priority < v3.Priority) then
				continue
			end

			custom = v3.Type
			priority = v3.Priority
		end

		if custom and currentCamera.CameraType ~= custom then
			currentCamera.CameraType = custom
		end

		local humanoid = module:GetHumanoid()
		local priority2 = 0
		local subject = nil

		for _, v3 in v2.CameraSubject do
			if not (not humanoid or priority2 < v3.Priority) then
				continue
			end

			humanoid = v3.Subject
			priority2 = v3.Priority
			subject = v3.Subject
		end

		if humanoid and currentCamera.CameraSubject ~= humanoid then
			currentCamera.CameraSubject = humanoid

			if humanoid:IsA("BasePart") then
				currentCamera.CFrame = humanoid.CFrame
			end
		end

		v = subject
	end
}

function Camera.AddCameraSubjectModifier(p: string, subject, value: number)
	if v2.CameraSubject[p] then
		return
	end

	v2.CameraSubject[p] = {
		Subject = subject,
		Priority = value or 1
	}
	Camera.Refresh()
end

function Camera.RemoveCameraSubjectModifier(p: string)
	if not v2.CameraSubject[p] then
		return
	end

	v2.CameraSubject[p] = nil
	Camera.Refresh()
end

function Camera.AddCameraTypeModifier(p: string, p2, value: number)
	if v2.CameraType[p] then
		return
	end

	v2.CameraType[p] = {
		Type = p2,
		Priority = value or 1
	}
	Camera.Refresh()
end

function Camera.RemoveCameraTypeModifier(p: string)
	if not v2.CameraType[p] then
		return
	end

	v2.CameraType[p] = nil
	Camera.Refresh()
end

module.Services.RunService.RenderStepped:Connect(function()
	if not v then
		return
	end

	currentCamera.CFrame = v.CFrame
end)
return Camera