local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "PitcherPlantCannon"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._launchJanitor = self._Janitor:Add(Janitor.new())
	self._launchToken = 0
end

function v:_playSitAnimation(instance, instance2)
	local animator = instance2:FindFirstChildOfClass("Animator")

	if animator == nil then
		return
	end

	local v2 = instance:FindFirstChild("SitAnim", true)

	if v2 == nil or not v2:IsA("Animation") then
		v2 = Instance.new("Animation")
		v2.AnimationId = "rbxassetid://98983598181881"
		self._launchJanitor:Add(v2)
	end

	local track = animator:LoadAnimation(v2)
	track.Priority = Enum.AnimationPriority.Action4
	track.Looped = true
	track:Play(0)
	self._launchJanitor:Add(function()
		track:Stop(0.15)
	end)
end

function v:_launch(vector2: Vector3)
	local character = Players.LocalPlayer.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return
	end

	local rootAttachment = humanoidRootPart:FindFirstChild("RootAttachment")

	if rootAttachment == nil then
		return
	end

	self._launchJanitor:Cleanup()
	self._launchToken += 1
	local _launchToken = self._launchToken
	humanoid.AutoRotate = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	self._launchJanitor:Add(function()
		if humanoid.Parent ~= nil then
			humanoid.AutoRotate = true
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)

			if humanoid:GetState() == Enum.HumanoidStateType.Physics then
				humanoid:ChangeState(Enum.HumanoidStateType.Landed)
			end
		end
	end)
	self:_playSitAnimation(character, humanoid)
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = rootAttachment
	alignOrientation.RigidityEnabled = true
	alignOrientation.CFrame = humanoidRootPart.CFrame.Rotation
	alignOrientation.Parent = humanoidRootPart
	self._launchJanitor:Add(alignOrientation)
	local launchPower = self.Instance:GetAttribute("LaunchPower")
	local v2 = typeof(launchPower) ~= "number" and 180 or launchPower
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	humanoidRootPart.AssemblyLinearVelocity = createVector(0, 0, 0)
	humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	humanoidRootPart:ApplyImpulse(vector2.Unit * humanoidRootPart.AssemblyMass * v2)
	self._launchJanitor:Add(task.delay(0.2, function()
		if _launchToken ~= self._launchToken or humanoid.Parent == nil then
			return
		end

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { character }
		self._launchJanitor:Add(RunService.Heartbeat:Connect(function()
			if _launchToken ~= self._launchToken or humanoidRootPart.Parent == nil or humanoidRootPart.AssemblyLinearVelocity.Y > 0 then
				return
			end

			if workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -(humanoid.HipHeight + 2), 0), raycastParams) ~= nil then
				self._launchJanitor:Cleanup()
			end
		end))
	end))
end

function v:Start()
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "PitcherPlantCannonFire", function(vector2: Vector3)
		if typeof(vector2) ~= "Vector3" then
			return
		end

		self:_launch(vector2)
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v