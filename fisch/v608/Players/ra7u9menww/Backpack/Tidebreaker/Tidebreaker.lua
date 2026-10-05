local createVector = vector.create
game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local parent = script.Parent
local core = script.Parent:WaitForChild("Core")
local vectorForce = core:WaitForChild("VectorForce")
local alignOrientation = core:WaitForChild("AlignOrientation")
local motorSound = core:WaitForChild("MotorSound")
local stateChangedConnection = nil
local preSimulationConnection = nil
local lastTime = nil
local flag = false
local playbackSpeed = motorSound.PlaybackSpeed
local raycastParams = RaycastParams.new()
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v = nil
script.Parent.Unequipped:Connect(function()
	if stateChangedConnection then
		stateChangedConnection:Disconnect()
		stateChangedConnection = nil
	end

	if preSimulationConnection then
		preSimulationConnection:Disconnect()
		preSimulationConnection = nil
	end

	if v then
		v.AutoRotate = true
		v = nil
	end

	vectorForce.Enabled = false
	alignOrientation.Enabled = false
	flag = false
	lastTime = nil
end)

local function Toggle(p)
	local enabled = p == Enum.HumanoidStateType.Swimming or v:GetAttribute("InFakeWater")

	if not enabled and lastTime and tick() - lastTime > 3 and parent.Parent:IsA("Model") and parent.Parent.PrimaryPart then
		core.AssemblyLinearVelocity *= 2
		flag = true
	end

	if enabled and not lastTime then
		lastTime = tick()
	elseif not enabled and lastTime then
		lastTime = nil
	end

	if flag and (p == Enum.HumanoidStateType.Landed or p == Enum.HumanoidStateType.Swimming) then
		flag = false
	end

	vectorForce.Enabled = enabled
	alignOrientation.Enabled = enabled or flag

	if v then
		v.AutoRotate = not (enabled or flag)
	end
end

parent.Equipped:Connect(function()
	local parent2 = parent.Parent
	local humanoid = parent2:FindFirstChildWhichIsA("Humanoid")
	raycastParams:AddToFilter(parent2)
	v = humanoid

	if parent2 and parent2 == Players.LocalPlayer.Character and humanoid then
		stateChangedConnection = humanoid.StateChanged:Connect(function(_, p)
			Toggle(p)
		end)
		preSimulationConnection = RunService.PreSimulation:Connect(function()
			if core:IsGrounded() then
				return
			end

			if lastTime then
				local v2 = math.clamp((tick() - lastTime) / 3, 0, 1)
				motorSound.PlaybackSpeed = v2 * playbackSpeed
				vectorForce.Force = workspace.CurrentCamera.CFrame.LookVector * (v2 * 10000)
				alignOrientation.CFrame = workspace.CurrentCamera.CFrame
			elseif flag then
				if core.AssemblyLinearVelocity.Magnitude > 0 then
					alignOrientation.CFrame = CFrame.lookAlong(createVector(0, 0, 0), core.AssemblyLinearVelocity)
				end

				if workspace:Raycast(core.Position, createVector(0, -5, 0), raycastParams) then
					flag = false
					alignOrientation.Enabled = false
				end
			end

			alignOrientation.MaxTorque = core.AssemblyMass * 10000
		end)
		Toggle(humanoid:GetState())
	end
end)