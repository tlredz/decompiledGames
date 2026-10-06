local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
local currentCamera = workspace.CurrentCamera
return function(p)
	local camCF = p.CamCF
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = camCF * CFrame.new(0, 0, 500)
	TweenService:Create(currentCamera, TweenInfo.new(18.5), {
		CFrame = currentCamera.CFrame * CFrame.new(0, 0, 1000)
	}):Play()
	wait(18.5)
	currentCamera.CameraType = Enum.CameraType.Custom
end