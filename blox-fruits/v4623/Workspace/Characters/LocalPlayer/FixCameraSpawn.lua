local currentCamera = workspace.CurrentCamera
local humanoidRootPart = script.Parent:WaitForChild("HumanoidRootPart")

while not humanoidRootPart:IsDescendantOf(workspace.Characters) do
	task.wait()
end

for _ = 1, 60 do
	currentCamera.CFrame = CFrame.new(
		currentCamera.CFrame.p,
		currentCamera.CFrame.p - vector.create(0, 2, 0) + humanoidRootPart.CFrame.lookVector * 10
	)

	if humanoidRootPart:GetAttribute("DoneSpawning") then
		break
	end

	local RunService = game:GetService("RunService")
	RunService.RenderStepped:Wait()
end