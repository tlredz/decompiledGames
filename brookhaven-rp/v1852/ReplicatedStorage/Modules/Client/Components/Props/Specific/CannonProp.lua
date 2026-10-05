local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "CannonProp"
})
local v2 = false

function v:Construct()
	self._Janitor = Janitor.new()
	local HumanoidController = require(ReplicatedStorage.Modules.Client.Player.HumanoidController)
	v2 = HumanoidController
end

function v.Start(p)
	Remotes.connectComponentRemote(p.Instance, "CannonFirePlayer", function(_: Vector3, attachment)
		local character = game.Players.LocalPlayer.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")

		if not humanoid then
			return
		end

		local rootAttachment = humanoidRootPart:FindFirstChild("RootAttachment")

		if not rootAttachment then
			return
		end

		local attachment2 = Instance.new("Attachment")
		attachment2.Parent = humanoidRootPart
		attachment2.WorldCFrame = CFrame.new(
			humanoidRootPart.CFrame.Position,
			humanoidRootPart.CFrame.Position + humanoidRootPart.AssemblyLinearVelocity.Unit
		)
		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.AlignType = Enum.AlignType.AllAxes
		alignOrientation.Attachment0 = rootAttachment
		alignOrientation.Attachment1 = attachment
		alignOrientation.Parent = humanoidRootPart
		alignOrientation.Responsiveness = 200
		alignOrientation.MaxAngularVelocity = 500
		alignOrientation.MaxTorque = 5000
		alignOrientation.RigidityEnabled = false
		local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			attachment.CFrame *= CFrame.Angles(0, 39.269908169872416 * dt, 0)
			attachment2.WorldCFrame = CFrame.new(
				humanoidRootPart.CFrame.Position,
				humanoidRootPart.CFrame.Position + humanoidRootPart.AssemblyLinearVelocity.Unit
			)
		end)
		local vectorForce = Instance.new("VectorForce")
		vectorForce.Parent = humanoidRootPart
		vectorForce.Attachment0 = rootAttachment
		vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
		vectorForce.Force = createVector(0, 1, 0) * workspace.Gravity * humanoidRootPart.AssemblyMass
		vectorForce.ApplyAtCenterOfMass = true
		vectorForce.Enabled = true
		humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
		local launchPower = p.Instance:GetAttribute("LaunchPower")
		humanoidRootPart:ApplyImpulse(humanoidRootPart.CFrame.UpVector * humanoidRootPart.AssemblyMass * launchPower)
		task.delay(0.2, function()
			alignOrientation.Attachment1 = attachment2
			vectorForce:Destroy()
		end)
		local lastTime = tick()

		repeat
			task.wait(0.1)
		until character:FindFirstChild("Glider") and tick() - lastTime > 0.2 or tick() - lastTime > 1

		renderSteppedConnection:Disconnect()
		alignOrientation:Destroy()

		if character:FindFirstChild("Glider") and tick() - lastTime > 0.5 then
			RunService.Stepped:Wait()
			humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			humanoidRootPart.CFrame = CFrame.new(
				humanoidRootPart.CFrame.Position,
				humanoidRootPart.CFrame.Position + humanoidRootPart.AssemblyLinearVelocity.Unit
			)
		end
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v