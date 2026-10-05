local createVector = vector.create
task.wait(0.1)
local mouse = game.Players:GetPlayerFromCharacter(script.Parent.Parent.Parent):GetMouse()
local humanoidRootPart = script.Parent.Parent.Parent:WaitForChild("HumanoidRootPart")
local bodyGyro = Instance.new("BodyGyro")
bodyGyro.maxTorque = createVector(10000, 10000, 10000)
bodyGyro.P = 1000000
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.maxForce = createVector(10000, 10000, 10000)
bodyVelocity.P = 10000
bodyGyro.Parent = humanoidRootPart
bodyVelocity.Parent = humanoidRootPart
bodyGyro.CFrame = humanoidRootPart.CFrame
bodyVelocity.Velocity = Vector3.new()
local humanoid = script.Parent.Parent.Parent:WaitForChild("Humanoid")
local _ = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	if humanoid.MoveDirection == createVector(0, 0, 0) then
		bodyVelocity.Velocity = humanoid.MoveDirection
		return
	end

	bodyVelocity.Velocity = humanoid.MoveDirection * 125 + game.Workspace.CurrentCamera.CFrame.lookVector * createVector(
		0,
		200,
		0
	)
	bodyGyro.CFrame = CFrame.new(
		humanoidRootPart.Position,
		(Vector3.new(mouse.Hit.p.x, humanoidRootPart.Position.y, mouse.Hit.p.z))
	)
end)