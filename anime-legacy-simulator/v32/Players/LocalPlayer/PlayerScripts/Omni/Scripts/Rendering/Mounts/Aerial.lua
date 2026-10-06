local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Omni = require(ReplicatedStorage:WaitForChild("Omni"))
local mounts = Omni.Services.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Mounts")
local v = {}
local raycastParams = RaycastParams.new()
raycastParams.RespectCanCollide = true
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Client.Maps }
local class = {}
class.__index = class

function class:Destroy()
	if self.Folder then
		self.Folder:Destroy()
	end

	for k, connection in self.Connections do
		connection:Disconnect()
		self.Connections[k] = nil
	end

	if self.IsLocal then
		local animate = Omni:GetAnimate()

		if animate then
			animate:RemoveForcedState("Mount")

			for _, child in self.AnimationsFolder.Player:GetChildren() do
				animate:RemoveCustomAnimationForState("Mount", child.Name)
			end
		end
	end

	v[self.Character] = nil
end

function class:Update(p: number)
	local position = self.HRP.Position
	local currentCamera = workspace.CurrentCamera
	local moveDirection = self.Humanoid.MoveDirection
	local v2 = moveDirection.Magnitude > 0

	if v2 then
		local unit = moveDirection.Unit
		local v3 = math.max(self.CurrentSpeed + self.Speed * p / self.AccelerationTime, self.StartSpeed)

		if self.MoveDirection and self.CurrentSpeed > 0 then
			local dot = self.MoveDirection:Dot(unit)

			if dot < 0 then
				local v4 = math.abs(dot)
				local v5 = self.Speed * p / self.DecelerationTime * (v4 * 2 + 1)
				self.CurrentSpeed = math.max(self.CurrentSpeed - v5, 0)

				if self.CurrentSpeed == 0 then
					self.MoveDirection = unit
				end
			else
				local v4 = math.clamp(p * 8, 0, 1)
				self.MoveDirection = self.MoveDirection:Lerp(unit, v4).Unit
				self.CurrentSpeed = math.min(v3, self.Speed)
			end
		else
			self.MoveDirection = unit
			self.CurrentSpeed = math.min(v3, self.Speed)
		end
	else
		self.CurrentSpeed = math.max(self.CurrentSpeed - self.Speed * p / self.DecelerationTime, 0)
	end

	if self.MoveDirection and self.CurrentSpeed > 0 then
		local vector = Vector3.new(currentCamera.CFrame.LookVector.X, 0, currentCamera.CFrame.LookVector.Z)
		local magnitude = vector.Magnitude
		local v3 = (not (magnitude > 0.001) and 0 or self.MoveDirection:Dot(vector) / magnitude or 0) * currentCamera.CFrame.LookVector.Y * self.CurrentSpeed
		local v4 = self.MoveDirection * self.CurrentSpeed + Vector3.new(0, v3, 0)
		position += v4

		if self.AlignOrientation and v4.Magnitude > 0.001 then
			self.AlignOrientation.CFrame = CFrame.lookAt(self.HRP.Position, self.HRP.Position + v4.Unit)
		end
	end

	local animationState = "Idle"
	local v4 = position - self.HRP.Position
	local raycastResult

	if v4.Magnitude > 0 then
		raycastResult = workspace:Raycast(self.HRP.Position, v4.Unit * 5, raycastParams)
	end

	if raycastResult and raycastResult.Instance then
		self.CurrentSpeed = 0
		position = self.HRP.Position
	elseif v2 or self.CurrentSpeed > 0 then
		animationState = "Run"
	end

	local animate = animationState ~= self.AnimationState and Omni:GetAnimate()

	if animate then
		if self.AnimationState then
			local mountAnimation = self.MountAnimations[self.AnimationState]

			if mountAnimation then
				mountAnimation:Stop()
			end

			if self.IsLocal then
				animate:RemoveForcedState("Mount")
			end
		end

		self.AnimationState = animationState
		local mountAnimation = self.MountAnimations[animationState]

		if mountAnimation then
			mountAnimation:Play()
		end

		if self.IsLocal then
			animate:AddForcedState("Mount", animationState)
		end
	end

	if self.AlignPosition then
		self.AlignPosition.Position = position
	end
end

local Aerial = {}

function Aerial.Get(p)
	return v[p]
end

function Aerial.Create(player, instance, name: string)
	if v[instance] then
		return true, v[instance]
	end

	local info = Omni.Shared.Mounts.List[name]

	if not info then
		return
	end

	local child = mounts:FindFirstChild(name)

	if not (child and child.Animations and (child.Model and child.Model.PrimaryPart)) then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	local attachment = humanoidRootPart:FindFirstChild("RootAttachment")

	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "RootAttachment"
		attachment.Parent = humanoidRootPart
	end

	local folder = Instance.new("Folder")
	folder.Name = "Mount"
	folder.Parent = instance
	local clone = child.Model:Clone()
	clone.Name = "Mount"
	clone:PivotTo(humanoidRootPart.CFrame)

	for _, part in clone:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local name2 = part.Name
		local child2 = instance:FindFirstChild(name2 == "RootPart" and "HumanoidRootPart" or name2)

		if not child2 then
			continue
		end

		local characterMotor = part:FindFirstChild("CharacterMotor")

		if not characterMotor then
			continue
		end

		characterMotor.Part0 = part
		characterMotor.Part1 = child2
	end

	for _, part in clone:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Massless = true
		part.Anchored = false
		part.CanCollide = false
		part.CollisionGroup = "Units"
	end

	clone.Parent = folder
	local isLocal = player == Omni.Instance
	local alignPosition, alignOrientation

	if isLocal then
		alignPosition = Instance.new("AlignPosition")
		alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
		alignPosition.Attachment0 = attachment
		alignPosition.MaxForce = 1e999
		alignPosition.MaxVelocity = 1e999
		alignPosition.Responsiveness = 30
		alignPosition.Position = humanoidRootPart.Position
		alignPosition.Parent = folder
		alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.Attachment0 = attachment
		alignOrientation.MaxTorque = 1e999
		alignOrientation.MaxAngularVelocity = 1e999
		alignOrientation.Responsiveness = 30
		alignOrientation.CFrame = humanoidRootPart.CFrame
		alignOrientation.Parent = folder
	end

	local tracksByName = {}
	local animationController = clone:FindFirstChildOfClass("AnimationController")

	if animationController then
		local v5 = animationController:FindFirstChildOfClass("Animator")

		if not v5 then
			v5 = Instance.new("Animator")
			v5.Parent = animationController
		end

		for _, animation in child.Animations.Model:GetChildren() do
			if animation.AnimationId == "" then
				continue
			end

			local track = v5:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Action4
			track.Looped = true
			tracksByName[animation.Name] = track
		end
	end

	local object = setmetatable({}, class)
	object.Name = name
	object.Info = info
	object.Player = player
	object.HRP = humanoidRootPart
	object.Humanoid = humanoid
	object.Character = instance
	object.Model = clone
	object.Folder = folder
	object.AlignPosition = alignPosition
	object.AlignOrientation = alignOrientation
	object.AnimationsFolder = child.Animations
	object.MountAnimations = tracksByName
	object.Speed = info.MaxSpeed
	object.StartSpeed = info.StartSpeed
	object.AccelerationTime = info.AccelerationTime
	object.DecelerationTime = info.DecelerationTime
	object.CurrentSpeed = 0
	object.MoveDirection = nil
	object.AnimationState = nil
	object.IsLocal = isLocal
	object.PendingTime = 0
	object.Connections = {}
	object.Connections.Destroyed = instance.AncestryChanged:Connect(function(_, parent)
		if not (instance and parent) then
			object:Destroy()
		end
	end)

	if object.IsLocal then
		local animate = Omni:GetAnimate()

		if animate then
			for _, child2 in object.AnimationsFolder.Player:GetChildren() do
				animate:AddCustomAnimationForState("Mount", child2.Name, {
					Animation = child2,
					Priority = Enum.AnimationPriority.Action4,
					Looped = true
				}, 2)
			end
		end
	end

	object.Connections.Update = Omni.Services.RunService.RenderStepped:Connect(function(dt)
		if object.IsLocal then
			object:Update(dt)
			return
		end

		object.PendingTime += dt

		if object.PendingTime < 0.1 then
			return
		end

		local pendingTime = object.PendingTime
		object.PendingTime = 0
		object:Update(pendingTime)
	end)
	v[instance] = object
	return true, object
end

return Aerial