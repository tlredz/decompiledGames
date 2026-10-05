local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Maid = require(script.Maid)

local function InPart(zone, position, value)
	local pointToObjectSpace = zone.CFrame:PointToObjectSpace(position)
	local size = zone.Size
	return math.abs(pointToObjectSpace.x) <= size.x / 2 and math.abs(pointToObjectSpace.y) <= size.y / 2 + (value or 0) and math.abs(pointToObjectSpace.z) <= size.z / 2
end

local densities = {}

for _, v in ipairs(Enum.Material:GetEnumItems()) do
	densities[v] = PhysicalProperties.new(v).Density
end

local localPlayer = Players.LocalPlayer
local SwimController = {}
SwimController.Zones = {}
SwimController.Swimming = false
SwimController.InvalidStartStates = {
	Enum.HumanoidStateType.Seated,
	Enum.HumanoidStateType.PlatformStanding,
	Enum.HumanoidStateType.Dead,
	Enum.HumanoidStateType.Physics,
	Enum.HumanoidStateType.Swimming
}
SwimController.DisabledStates = { Enum.HumanoidStateType.GettingUp }
SwimController.ClampSurfaceMovement = true
SwimController.ProcessWeldedParts = true
SwimController.DragForceMultiplier = 9.85
SwimController.SurfaceDepth = 0.35
SwimController.MaxJumpDepth = 2

function SwimController.AddZone(p, p2)
	if not table.find(p.Zones, p2) then
		table.insert(p.Zones, p2)
	end
end

function SwimController:RemoveZone(p)
	local index = table.find(self.Zones, p)

	if index then
		table.remove(self.Zones, index)
	end

	if self.LastInZone == p then
		self.LastInZone = nil
		self:_stopSwimming()
	end
end

function SwimController:Start()
	self._maid = Maid.new()
	self._stateMaid = Maid.new()
	self._recalcMaid = Maid.new()
	localPlayer:GetPropertyChangedSignal("Character"):Connect(function()
		self:_setCharacter(localPlayer.Character)
	end)

	if localPlayer.Character then
		task.defer(self._setCharacter, self, localPlayer.Character)
	end

	RunService.Heartbeat:connect(function(_)
		if not self.Character then
			return
		end

		debug.profilebegin("PartSwimming")
		local state = self.Humanoid:GetState()
		local position = self.RootPart.Position
		local lastInZone = nil

		for _, zone in pairs(self.Zones) do
			if not InPart(zone, position, self._didJump and -self.SurfaceDepth - self.MaxJumpDepth or 0) then
				continue
			end

			lastInZone = zone
			break
		end

		if self.LastInZone ~= lastInZone then
			self.LastInZone = lastInZone

			if lastInZone then
				self:_startSwimming(lastInZone)
			else
				self:_stopSwimming()
			end
		end

		if self.Swimming then
			if self.Swimming and state == Enum.HumanoidStateType.Swimming or not table.find(
				self.InvalidStartStates,
				state
			) then
				if not self._inSwimmingState then
					self._inSwimmingState = true
					self.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

					for _, disabledState in ipairs(self.DisabledStates) do
						self.Humanoid:SetStateEnabled(disabledState, false)
					end

					self._stateMaid:Add(function()
						for _, disabledState in ipairs(self.DisabledStates) do
							self.Humanoid:SetStateEnabled(disabledState, true)
						end
					end)
					local _stateMaid = self._stateMaid
					local UserInputService = game:GetService("UserInputService")
					_stateMaid:Add(UserInputService.JumpRequest:Connect(function()
						self._didJump = true
					end))

					if self.ClampSurfaceMovement then
						self._stateMaid:Add(self.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
							local moveDirection = self.Humanoid.MoveDirection

							if self._nearSurface and moveDirection.Y > 0.1 then
								local cFrame = workspace.CurrentCamera.CFrame

								if math.abs(cFrame:VectorToObjectSpace(moveDirection).Y) < 0.01 then
									local lookVector = cFrame.LookVector
									local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
									local v3 = CFrame.fromAxisAngle(
										lookVector:Cross(vector2),
										(math.acos((math.clamp(lookVector:Dot(vector2), -1, 1))))
									) * moveDirection
									self.Humanoid:Move(v3)
								end
							end
						end))
					end
				end
			elseif self._inSwimmingState then
				self._inSwimmingState = false
				self._stateMaid:Cleanup()
			end
		end

		if self.Swimming then
			local assemblyLinearVelocity = self.RootPart.AssemblyLinearVelocity

			if self._shouldRecalculateForces or self._assemblyMass ~= self.RootPart.AssemblyMass then
				self:_recalculateForces()
			end

			local v3 = assemblyLinearVelocity * self._dragMultiplier
			local _antigravForce = self._antigravForce
			local v4 = self.SurfaceY - self.SurfaceDepth - position.Y
			self._didJump = false
			self._nearSurface = v4 < 2
			local v5

			if self._nearSurface then
				v5 = _antigravForce + math.clamp(math.min(1, v4) * 12 - assemblyLinearVelocity.y, -10, 100) * 5 * self._assemblyMass
			else
				v5 = _antigravForce + self._buoyancyForce
			end

			self._vectorForce.Force = createVector(0, 1, 0) * v5 - v3
		end

		debug.profileend()
	end)
end

function SwimController:_recalculateForces()
	if not (self.Character and self.Swimming) then
		return
	end

	self._recalcMaid:Cleanup()
	self._shouldRecalculateForces = false
	local assemblyMass = self.RootPart.AssemblyMass
	local gravity = workspace.Gravity
	local buoyancyForce = -assemblyMass * gravity
	local total = 0

	for _, v2 in ipairs(self.RootPart:GetConnectedParts(true)) do
		local v3

		if v2.Parent == self.Character then
			v3 = self.Humanoid:GetBodyPartR15(v2) ~= Enum.BodyPartR15.Unknown or self.Humanoid:GetLimb(v2) ~= Enum.Limb.Unknown
		else
			v3 = false
		end

		if not (v3 or self.ProcessWeldedParts) then
			continue
		end

		self._recalcMaid:Add(v2:GetPropertyChangedSignal("CanCollide"):Connect(function()
			self._shouldRecalculateForces = true
		end))

		if not v2.CanCollide then
			continue
		end

		local mass = v2.Mass

		if mass == 0 and v2.Massless then
			v2.Massless = false
			mass = v2.Mass
			v2.Massless = true
		end

		if mass == 0 then
			continue
		end

		local customPhysicalProperties = v2.CustomPhysicalProperties
		local v4

		if customPhysicalProperties then
			v4 = customPhysicalProperties.Density
		else
			v4 = densities[v2.Material] or 1
		end

		local v5 = mass / v4
		buoyancyForce += v5 * gravity
		total += v5
	end

	self._recalcMaid:Add(workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
		self._shouldRecalculateForces = true
	end))
	self._assemblyMass = assemblyMass
	self._dragMultiplier = total * self.DragForceMultiplier
	self._antigravForce = assemblyMass * gravity
	self._buoyancyForce = buoyancyForce
end

function SwimController:_setCharacter(character)
	if character == self.Character then
		return
	end

	self:_stopSwimming()
	self.Character = nil
	self.RootPart = nil
	self.Humanoid = nil

	if character then
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 60)
		local humanoid = character:WaitForChild("Humanoid", 60)

		if humanoidRootPart and humanoid and character == localPlayer.Character then
			self.Character = character
			self.RootPart = humanoidRootPart
			self.Humanoid = humanoid
		end
	end
end

function SwimController:_stopSwimming()
	if not self.Swimming then
		return
	end

	self.Swimming = false
	self._inSwimmingState = false
	self._nearSurface = false
	self._didJump = false
	self._maid:Cleanup()
	self._stateMaid:Cleanup()
	self._recalcMaid:Cleanup()

	if self.Humanoid and self.Humanoid:GetState() == Enum.HumanoidStateType.Swimming then
		self.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
end

function SwimController:_startSwimming(p)
	self.SurfaceY = p.Position.y + p.Size.y / 2

	if self.Swimming then
		return
	end

	self.Swimming = true
	local attachment = Instance.new("Attachment", self.RootPart)
	attachment.Name = "SwimAttachment"
	local vectorForce = Instance.new("VectorForce", attachment)
	vectorForce.Attachment0 = attachment
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Force = createVector(0, 0, 0)
	self._vectorForce = vectorForce
	self._maid:Add(vectorForce, attachment)
	self._shouldRecalculateForces = true
	self._maid:Add(self.Humanoid.StateChanged:Connect(function()
		RunService.Stepped:Wait()
		self._shouldRecalculateForces = true
	end))
end

return SwimController