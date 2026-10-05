local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
game:GetService("ContextActionService")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local _ = localPlayer.PlayerScripts
local currentCamera = workspace.CurrentCamera
local v2 = require3(ReplicatedStorage3.Packages.Net)
local v3 = require3(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local animation = Instance.new("Animation")
animation.AnimationId = `http://www.roblox.com/asset/?id={16802283336}`
animation.Parent = script
local animation2 = Instance.new("Animation")
animation2.AnimationId = `http://www.roblox.com/asset/?id={16802284976}`
animation2.Parent = script
local v4 = {
	[Enum.KeyCode.W] = "Forward",
	[Enum.KeyCode.A] = "Left",
	[Enum.KeyCode.S] = "Backward",
	[Enum.KeyCode.D] = "Right",
	[Enum.KeyCode.E] = "Up",
	[Enum.KeyCode.Space] = "Up",
	[Enum.KeyCode.Q] = "Down"
}
local v5 = {
	Backward = false,
	Forward = false,
	Right = false,
	Left = false,
	Down = false,
	Up = false
}
local map = workspace:WaitForChild("Map")
workspace:WaitForChild("Spawn")
local lobbySpawnPlate = workspace:WaitForChild("LobbySpawnPlate")
local remoteFunction = v2:RemoteFunction("UseFlyingDash")
v2:RemoteEvent("DashPowerChanged")
local CharacterFlight = {}
CharacterFlight.__index = CharacterFlight

function CharacterFlight:InitCharacter()
	local v6 = 0
	self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
	self.humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding, true)
	self.humanoid.AutoRotate = false
	local attachment = Instance.new("Attachment")
	attachment.Parent = self.primaryPart
	table.insert(self.instanceCollection, attachment)
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.Attachment0 = attachment
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.MaxForce = 1e999
	alignPosition.Position = self.primaryPart.Position
	alignPosition.Parent = self.primaryPart
	table.insert(self.instanceCollection, alignPosition)
	local alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = attachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.MaxTorque = 9000000000
	alignOrientation.CFrame = self.primaryPart.CFrame
	alignOrientation.Parent = self.primaryPart
	table.insert(self.instanceCollection, alignOrientation)
	local assemblyLinearVelocity = self.primaryPart.AssemblyLinearVelocity
	table.insert(self.connections, RunService.Heartbeat:Connect(function(dt: number)
		local position = self.primaryPart.Position
		v6 = math.fmod(v6 + 1, 2)

		if v6 % 2 == 0 then
			local raycastResult = workspace:Raycast(position, createVector(-0, -150, -0), self._raycastConfiguration)

			if raycastResult then
				if (position - raycastResult.Position).Y <= 10 then
					self.currentDirection.Up = false
					self.currentDirection.Down = false
					self.currentDirection.Up = true
					self._directionLocked = "Up"
				elseif self._directionLocked then
					self.currentDirection[self._directionLocked] = false
					self._directionLocked = nil
					task.defer(function()
						self._directionLocked = nil
					end)
				end
			else
				self.currentDirection.Up = false
				self.currentDirection.Down = false
				self.currentDirection.Down = true
				self._directionLocked = "Down"
			end
		end

		local v7 = dt * 25
		local v8 = dt * 20

		if self.dashing then
			v7 *= 2
			v8 *= 2
		end

		local _ = alignOrientation.CFrame - alignOrientation.CFrame.Position + alignPosition.Position

		if not (self.currentDirection.Forward or self.currentDirection.Backward or self.currentDirection.Up or self.currentDirection.Down or self.currentDirection.Left or self.currentDirection.Right) then
			v7 *= -1
		end

		if self.currentDirection.Up then
			self.currentSpeed += v7
		end

		if self.currentDirection.Down then
			self.currentSpeed += v7
		end

		if self.currentDirection.Forward then
			self.currentSpeed += v7
		end

		if self.currentDirection.Backward then
			self.currentSpeed += v7
		end

		if self.currentDirection.Left then
			self.currentSpeed += v7
		end

		if self.currentDirection.Right then
			self.currentSpeed += v7
		end

		local v9 = self.dashing and 50 or 25
		self.currentSpeed = math.clamp(self.currentSpeed, 3, v9)
		local flySpeedMultiplier = self.humanoid.Parent:GetAttribute("FlySpeedMultiplier") or 1
		local lookVector = GetMovingDirection() * (self.currentSpeed * flySpeedMultiplier)

		if lookVector.Magnitude == 0 then
			lookVector = currentCamera.CFrame.LookVector
			assemblyLinearVelocity = assemblyLinearVelocity:Lerp(createVector(0.001, 0.001, 0.001), 0.25)
		else
			local v10 = self.dashing and 250 or 125
			assemblyLinearVelocity = assemblyLinearVelocity:Lerp(lookVector * (v10 * dt), 0.075)
			GetRotate(lookVector, assemblyLinearVelocity.Unit)
		end

		alignPosition.Position = position + lookVector

		if self.currentDirection.Forward then
			alignOrientation.CFrame = currentCamera.CFrame * CFrame.Angles(-math.rad(self.currentSpeed * v8), 0, 0)
		elseif self.currentDirection.Backward then
			alignOrientation.CFrame = currentCamera.CFrame * CFrame.Angles(math.rad(self.currentSpeed * v8), 0, 0)
		else
			alignOrientation.CFrame = currentCamera.CFrame
		end

		self.humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding, true)
	end))
	table.insert(self.connections, v.InputBegan:Connect(function(input, gameProcessed: boolean)
		if gameProcessed or not self.humanoid then
			return
		end

		if v3:UseBind(input, "Ability") then
			self:Dash(self.humanoid.MoveDirection)
		else
			self:ProcessInput(input.KeyCode, true)
		end
	end))
	table.insert(self.connections, v.InputEnded:Connect(function(input, gameProcessed: boolean)
		if gameProcessed then
			return
		end

		self:ProcessInput(input.KeyCode, false)
	end))
	self.animations.dashAnimation = self:RegisterAnimation(animation, function(p)
		for _, animation3 in self.animations do
			animation3:Stop()
		end

		p.Priority = Enum.AnimationPriority.Action4
		p.Looped = false
	end)
	self.animations.flyingAnimation = self:RegisterAnimation(animation2, function(object)
		for _, animation3 in self.animations do
			animation3:Stop()
		end

		object.Priority = Enum.AnimationPriority.Action3
		object.Looped = true
		object:Play()
	end)
	table.insert(self.connections, self.humanoid.Parent:GetAttributeChangedSignal("Dead"):Connect(function()
		self:Destroy()
	end))
	table.insert(self.connections, self.humanoid.Died:Connect(function()
		self:Destroy()
	end))
	local container = localPlayer.PlayerGui:WaitForChild("LTMDashCharge"):FindFirstChild("Container")

	if container then
		table.insert(self.connections, container.MouseButton1Click:Connect(function()
			if self.humanoid then
				self:Dash(self.humanoid.MoveDirection)
			end
		end))
	end
end

function CharacterFlight:Destroy()
	if self.dead then
		return
	end

	self.dead = true

	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end

	for _, v6 in ipairs(self.instanceCollection) do
		if v6.Parent then
			v6:Destroy()
		end
	end

	for _, animation3 in self.animations do
		animation3:Stop()
	end

	table.clear(self.connections)
	table.clear(self.instanceCollection)
	table.clear(self.animations)
	self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
	self.humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding, false)
	self.humanoid.AutoRotate = true
end

function CharacterFlight:Dash(_: Vector3)
	if self.dead or self.dashing or self.humanoid.MoveDirection == createVector(0, 0, 0) then
		return
	end

	local v6, v7 = remoteFunction:InvokeServer()

	if not v6 then
		return
	end

	self.dashing = true
	self.animations.dashAnimation:Play()
	self.animations.dashAnimation.Ended:Once(function()
		self.animations.dashAnimation:Stop()
	end)
	local length = self.animations.flyingAnimation.Length
	local tween = TweenService:Create(currentCamera, TweenInfo.new(length * 0.9, Enum.EasingStyle.Quart), {
		FieldOfView = 105
	})
	local tween2 = TweenService:Create(currentCamera, TweenInfo.new(length * 1.4, Enum.EasingStyle.Linear), {
		FieldOfView = 70
	})
	tween:Play()
	task.delay(1, function()
		tween2:Play()
	end)
	task.delay(v7 or 2, function()
		if self.dead then
			return
		end

		self.dashing = false
	end)
end

function CharacterFlight:ProcessInput(p, flag: boolean)
	if self._directionLocked then
		return
	end

	local v6 = v4[p]

	if not (v6 and v5[v6] ~= nil) then
		return false
	end

	self.currentDirectionClone[v6] = flag
	self.currentDirection[v6] = flag
	return true
end

function CharacterFlight:RegisterAnimation(animation3, callback)
	local animator = self.humanoid:FindFirstChildWhichIsA("Animator")

	if not animator then
		return
	end

	local track = animator:LoadAnimation(animation3)

	if callback then
		task.spawn(callback, track)
	end

	return track
end

function CharacterFlight.new(instance)
	local object = setmetatable({
		dead = false,
		currentSpeed = 3,
		dashing = false,
		instanceCollection = {},
		connections = {},
		animations = {},
		_directionLocked = nil,
		currentDirection = table.clone(v5),
		currentDirectionClone = table.clone(v5),
		primaryPart = instance:WaitForChild("HumanoidRootPart"),
		humanoid = instance:WaitForChild("Humanoid"),
		_raycastConfiguration = createRaycastConfiguration()
	}, CharacterFlight)
	object:InitCharacter()
	return object
end

function GetMovingDirection()
	local character = localPlayer.Character
	local cFrame = currentCamera.CFrame
	local moveDirection = character.Humanoid.MoveDirection
	local lookVector = cFrame.LookVector
	local v6 = (cFrame * CFrame.new((CFrame.new(
		cFrame.Position,
		cFrame.Position + Vector3.new(lookVector.X, 0, lookVector.Z)
	):VectorToObjectSpace(moveDirection)))).Position - cFrame.Position
	return moveDirection.Magnitude == 0 and moveDirection or v6.Magnitude == 0 and v6 or v6.Unit
end

function GetRotate(p, p2)
	local position = localPlayer.Character.PrimaryPart.CFrame.Position
	local lookVector = (CFrame.new(position, position + p) * CFrame.Angles(0, 1.5707963267948966, 0)).LookVector
	return (math.clamp(90 - math.deg((math.acos(lookVector:Dot(p2) / (lookVector.Magnitude * p2.Magnitude)))), -90, 90))
end

function getCFrame(p, flag: boolean)
	local cframe = CFrame.new(p.CFrame.Position)
	local eulerAnglesXYZ, v6, v7 = (currentCamera.CFrame - currentCamera.CFrame.Position):ToEulerAnglesXYZ()

	if flag then
		eulerAnglesXYZ = v7
	end

	return cframe * CFrame.Angles(eulerAnglesXYZ, v6, v7)
end

function createRaycastConfiguration()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { map, lobbySpawnPlate }
	raycastParams.IgnoreWater = true
	raycastParams.RespectCanCollide = false
	map.ChildAdded:Connect(function()
		local v6 = map:GetChildren()[1]

		if v6 then
			raycastParams.FilterDescendantsInstances = { v6:WaitForChild("FLOOR"), lobbySpawnPlate }
		end
	end)
	map.ChildRemoved:Connect(function()
		raycastParams.FilterDescendantsInstances = { map, lobbySpawnPlate }
	end)
	return raycastParams
end

return CharacterFlight