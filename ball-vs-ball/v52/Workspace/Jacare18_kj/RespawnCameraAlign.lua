local createVector = vector.create
local RunService = game:GetService("RunService")
local humanoidRootPart = script.Parent:WaitForChild("HumanoidRootPart")

local function alignCameraToCharacter()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local cFrame = humanoidRootPart.CFrame
	local v = cFrame * CFrame.new(0, 3, 10) * CFrame.Angles(-0.2617993877991494, 0, 0)
	local cframe = CFrame.new(v.Position, cFrame.Position + createVector(0, 1.5, 0))
	local cameraType = currentCamera.CameraType
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = cframe
	RunService.RenderStepped:Wait()

	if cameraType == Enum.CameraType.Scriptable then
		cameraType = Enum.CameraType.Custom or cameraType
	end

	currentCamera.CameraType = cameraType
end

task.defer(alignCameraToCharacter)