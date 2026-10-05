local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
Players.LocalPlayer.CharacterAdded:Connect(function(character)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)

	if not humanoidRootPart then
		return
	end

	RunService.RenderStepped:Wait()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local lookVector = humanoidRootPart.CFrame.LookVector
	local v = humanoidRootPart.Position - lookVector * 12 + createVector(0, 4, 0)
	currentCamera.CFrame = CFrame.lookAt(v, humanoidRootPart.Position + createVector(0, 1, 0))
end)