local Players = game:GetService("Players")
Players = Players.LocalPlayer
local parent = script.Parent
local humanoid = parent:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
humanoid.AutoJumpEnabled = false

local function onPostSimulation(p)
	local state = humanoid:GetState()

	if (state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics) and humanoid.WalkSpeed >= 50 and humanoidRootPart.AssemblyLinearVelocity.Magnitude > 10 then
		humanoidRootPart.AssemblyLinearVelocity += Vector3.new(0, -50 * p, 0)
	end
end

local postSimulationConnection = RunService.PostSimulation:Connect(onPostSimulation)
humanoid.Died:Connect(function()
	postSimulationConnection:Disconnect()
end)