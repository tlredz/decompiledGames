local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "PogoStick"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self.verticalVelocity = createVector(0, 0, 0)
	self.isRebound = false
	self.velocityMultiplier = 1
end

function v:AnimationSpeed()
	while true do
		self.verticalVelocity = self.model.Velocity.Y
		task.wait()

		if self.isJumping or self.isFalling then
			self.adjustPosition = false
		else
			local v2 = self.model.Velocity.magnitude / 25
			local magnitude = Vector3.new(self.model.Velocity.X, 0, self.model.Velocity.Z).Magnitude
			self.fallingAnimation:Stop()

			if v2 > 0.4 then
				if not self.walkAnimation.IsPlaying then
					self.walkAnimation:Play(nil, nil, 1)

					if self.adjustPosition then
						local v3 = (self.idleAnimation.TimePosition / self.idleAnimation.Length + 0.05) % 1
						self.walkAnimation.TimePosition = v3 * self.walkAnimation.Length

						if magnitude < 0.1 then
							self.walkAnimation.TimePosition = 0
						end
					end

					self.adjustPosition = true
				end

				self.walkAnimation:AdjustSpeed(v2)
				self.idleAnimation:Stop(0.1)
			else
				if not self.idleAnimation.IsPlaying then
					self.idleAnimation:Play(nil, nil, 1)

					if self.adjustPosition then
						local v3 = (self.walkAnimation.TimePosition / self.walkAnimation.Length + 0.05) % 1
						self.idleAnimation.TimePosition = v3 * self.idleAnimation.Length

						if magnitude < 0.1 then
							self.idleAnimation.TimePosition = 0
						end
					end

					self.adjustPosition = true
				end

				self.walkAnimation:Stop(0.1)
			end
		end
	end
end

function v:PlaySound()
	Remotes.fireServerComponent(self.Instance, "PlaySound")
	self.sound:Play()
end

function v:SetupAnimation()
	local animations = self.Instance:WaitForChild("Animations")
	local walkAnimation = animations:WaitForChild("WalkAnimation")
	local idleAnimation = animations:WaitForChild("IdleAnimation")
	local fallingAnimation = animations:WaitForChild("FallingAnimation")
	local jumpAnimation = animations:WaitForChild("JumpAnimation")
	local jumpAnimation2 = animations:WaitForChild("JumpAnimation2")
	local jumpAnimation3 = animations:WaitForChild("JumpAnimation3")
	local flipAnimation = animations:WaitForChild("FlipAnimation")
	local humanoid = self.Instance.Parent:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	self.Instance.Parent:WaitForChild("HumanoidRootPart")
	self.model = self.Instance:WaitForChild("Middle")
	self.sound = self.model:WaitForChild("Sound")
	self.walkAnimation = animator:LoadAnimation(walkAnimation)
	self.idleAnimation = animator:LoadAnimation(idleAnimation)
	self.jumpAnimation = {
		animator:LoadAnimation(jumpAnimation),
		animator:LoadAnimation(jumpAnimation2),
		animator:LoadAnimation(jumpAnimation3)
	}

	for _, v2 in self.jumpAnimation do
		v2.Priority = Enum.AnimationPriority.Action3
	end

	self.flipAnimation = animator:LoadAnimation(flipAnimation)
	self.flipAnimation.Priority = Enum.AnimationPriority.Action2
	self.fallingAnimation = animator:LoadAnimation(fallingAnimation)
	self.fallingAnimation.Looped = false

	for _, v2 in self.jumpAnimation do
		v2.Looped = false
		self._Janitor:Add(v2.Stopped:Connect(function()
			self.isJumping = false
			self.isFalling = humanoid.FloorMaterial == Enum.Material.Air

			if self.isFalling then
				self.fallingAnimation:Play(nil, nil, 1)
			end
		end))
	end

	self._Janitor:Add(self.flipAnimation.Ended:Connect(function()
		if self.isFalling then
			self.fallingAnimation:Play(nil, nil, 1)
		end
	end))
	self._Janitor:Add(humanoid.Jumping:Connect(function(p)
		if p and not self.isJumping then
			self.isJumping = true

			if self.humanoid.JumpPower > 89 and math.random() < 0.25 then
				self.flipAnimation:Play(nil, nil, 1)
			else
				local v2 = math.random(1, #self.jumpAnimation)
				self.jumpAnimation[v2]:Play(nil, nil, 1.3 / self.velocityMultiplier)
			end

			self.jumpSound:Play()
			self.idleAnimation:Stop()
			self.walkAnimation:Stop()
			self.humanoid.JumpPower = (self.customJumpForce or math.min(self.humanoid.JumpPower + 10, 100)) * self.velocityMultiplier
			self.customJumpForce = nil
			self._Janitor:Add(humanoid.StateChanged:Connect(function(_, p2)
				if p2 == Enum.HumanoidStateType.Landed then
					self.humanoid.JumpPower = 75
				end
			end))
		end
	end))
	self._Janitor:Add(humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		if (self.isJumping or self.isFalling) and humanoid.FloorMaterial ~= Enum.Material.Air then
			local verticalVelocity = math.abs(self.verticalVelocity)

			if verticalVelocity > 120 then
				self.customJumpForce = verticalVelocity / 1.25
				self.isRebound = true
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			elseif self.isRebound then
				self.customJumpForce = verticalVelocity / 2
				self.isRebound = false
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end

			self.isJumping = false
			self.isFalling = false
		end

		if not self.isJumping and not self.isFalling and humanoid.FloorMaterial == Enum.Material.Air then
			self.fallingAnimation:Play(nil, nil, 0.1)
			self.idleAnimation:Stop()
			self.walkAnimation:Stop()
			self.isFalling = true
		end
	end))
	self.animationSpeedTask = task.spawn(function()
		self:AnimationSpeed()
	end)

	if not self.walkAnimation.IsPlaying then
		self.walkAnimation:Play(nil, nil, 1)
	end
end

function v:SetupSound()
	self.jumpSound = self.model:WaitForChild("JumpSound")
	self._Janitor:Add(self.walkAnimation:GetMarkerReachedSignal("PogoStick"):Connect(function(_)
		self:PlaySound()
	end))
	self._Janitor:Add(self.idleAnimation:GetMarkerReachedSignal("PogoStick"):Connect(function(_)
		self:PlaySound()
	end))
end

function v:UpdateVelocityMultiplier()
	self.velocityMultiplier = self.Instance:GetAttribute("VelocityMultiplier") or 1
end

function v:Start()
	self.model = self.Instance:WaitForChild("Middle")
	self.model:WaitForChild("SpringMotor")
	self.model:WaitForChild("SpringWeld")
	self.newObject = self.model:Clone()
	self.newObject.Parent = self.Instance.Parent
	local color = self.model:WaitForChild("Color")
	self.newObjectColor = self.newObject:WaitForChild("Color")
	self.humanoid = self.Instance.Parent:WaitForChild("Humanoid")
	self.humanoid.JumpPower = 75
	self._Janitor:Add(color:GetPropertyChangedSignal("Color"):Connect(function()
		if not self.newObjectColor then
			return
		end

		self.newObjectColor.Color = color.Color
	end))
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("VelocityMultiplier"):Connect(function()
		self:UpdateVelocityMultiplier()
	end))
	self:UpdateVelocityMultiplier()
	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("Wrap"):Connect(function()
		for _, part in self.newObject:GetDescendants() do
			if not (part:IsA("BasePart") and part.Name == "Color") then
				continue
			end

			part:SetAttribute("Wrap", self.Instance:GetAttribute("Wrap"))
			part:AddTag("VehicleWrapPart")
		end
	end))
	local lowerTorso = self.Instance.Parent:WaitForChild("LowerTorso")
	self.newObject.Parent = self.Instance
	self.newObject.CFrame = lowerTorso.CFrame
	local middle = self.newObject:WaitForChild("Middle")
	middle.Parent = lowerTorso
	middle.Part0 = lowerTorso
	middle.Part1 = self.newObject
	middle.Name = "Middle"
	local springMotor = self.newObject:WaitForChild("SpringMotor")
	springMotor.Enabled = true
	local springWeld = self.newObject:WaitForChild("SpringWeld")
	springWeld.Enabled = false

	for _, part in self.model:GetDescendants() do
		if not (part:IsA("MeshPart") or part:IsA("Part") or part:IsA("BasePart")) then
			continue
		end

		part.Transparency = 1
	end

	self._Janitor:Add(middle, "Destroy")

	if self.Instance.Parent.Name == Players.LocalPlayer.Name then
		self:SetupAnimation()
		self:SetupSound()
	end
end

function v:Stop()
	if self.animationSpeedTask then
		task.cancel(self.animationSpeedTask)
		self.walkAnimation:Stop()
		self.idleAnimation:Stop()

		for _, v2 in self.jumpAnimation do
			v2:Stop()
		end

		self.fallingAnimation:Stop()
	end

	self.newObject:Destroy()
	self._Janitor:Destroy()

	if self.humanoid then
		self.humanoid.JumpPower = StarterPlayer.CharacterJumpPower
	end
end

return v