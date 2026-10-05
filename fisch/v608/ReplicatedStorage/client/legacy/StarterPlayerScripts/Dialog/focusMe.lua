local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

local function focusMe(instance)
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Name = "Anchor"
	bodyPosition.Position = humanoidRootPart.Position
	bodyPosition.MaxForce = createVector(1e999, 0, 1e999)
	bodyPosition.Parent = humanoidRootPart
	local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")
	currentCamera.CameraType = Enum.CameraType.Scriptable
	TweenService:Create(currentCamera, TweenInfo.new(1), {
		CFrame = humanoidRootPart2.CFrame * CFrame.new(0, 0, -8) * CFrame.Angles(0, 3.141592653589793, 0),
		FieldOfView = 60
	}):Play()

	local function cleanup()
		bodyPosition:Destroy()
		currentCamera.CameraType = Enum.CameraType.Custom
	end

	task.delay(3, cleanup)
	return cleanup
end

return focusMe