local TweenService = game:GetService("TweenService")
local CameraController = {
	GetDefaultFov = function(_)
		return 70
	end,
	Get = function(self)
		local currentCamera = workspace.CurrentCamera

		while not currentCamera do
			task.wait()
			currentCamera = workspace.CurrentCamera
		end

		return currentCamera
	end
}

function CameraController.Fov(_, p: number, duration: number?, flag: boolean?)
	local fieldOfView = flag == true and 70 or p

	if duration == 0 then
		local get = CameraController:Get()
		get.FieldOfView = fieldOfView
		return
	end

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	TweenService:Create(CameraController:Get(), tweenInfo, {
		FieldOfView = fieldOfView
	}):Play()
end

function CameraController.Blur(_, size: number, duration: number?)
	local v = CameraController:Get():FindFirstChild("Blur")

	if not v then
		v = Instance.new("BlurEffect")
		v.Size = 0
		v.Parent = CameraController:Get()
	end

	if duration == 0 then
		v.Size = size
		return
	end

	TweenService:Create(v, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = size
	}):Play()
end

return CameraController