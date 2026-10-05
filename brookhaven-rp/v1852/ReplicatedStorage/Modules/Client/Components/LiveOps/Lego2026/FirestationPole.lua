local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "FirestationPole"
})
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)

function v:Construct()
	self._Janitor = Janitor.new()
	self._whileActiveJanitor = Janitor.new()
	self._active = false
	self._currentDistance = 0
	self._reverse = false
	self._totalDistance = 0
	self._debounce = false
	self.angle = 0
	self._refPart = nil
end

function v:Start()
	local total = 0

	for _, part in self.Instance:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		total += part.Size.Z
		local v2 = part
		self._Janitor:Add(part.Touched:Connect(function(otherPart)
			local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart") or otherPart
			self:FollowPole(v2, humanoidRootPart)
		end))
	end

	self._Janitor:Add(UserInputService.JumpRequest:Connect(function()
		self:StopSliding()
	end))
	self.animation = Instance.new("Animation")
	self.animation.Name = "SlidingAnimation"
	self.animation.AnimationId = "rbxassetid://87781413733715"
	self.animation.Parent = self.Instance
	self._Janitor:Add(self.animation)
	self._totalDistance = total
end

function v:FollowPole(refPart, instance)
	if self._active then
		return
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or not instance:IsDescendantOf(character) or self._debounce then
		return
	end

	self._debounce = true
	self._reverse = refPart.CFrame.LookVector:Dot((refPart.CFrame.Position - humanoidRootPart.Position).Unit) < 0
	local v2 = humanoidRootPart.CFrame:ToObjectSpace(refPart.CFrame) + Vector3.new(0, 0, refPart.Size.Z / 2)
	self._currentDistance = self:_GetDistanceToPoint((tonumber(refPart.Name))) + v2.Z
	self._refPart = refPart
	self._active = true
	self:_StartSliding()
end

function v:SpawnSquarePart(cFrame: CFrame, color: Color3)
	local part = Instance.new("Part")
	part.Name = "SquarePart"
	part.Size = createVector(0.2, 0.2, 0.2)
	part.CFrame = cFrame
	part.Parent = workspace
	part.CanCollide = false
	part.Anchored = true
	part.Color = color
	task.delay(20, function()
		part:Destroy()
	end)
	return part
end

function v:RenderSteppedUpdate(p: number)
	if not self._active then
		return
	end

	local character = Players.LocalPlayer.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local total = 0
	local v2 = nil

	for i = 1, #self.Instance:GetChildren() do
		local v3

		if self._reverse then
			v3 = #self.Instance:GetChildren() - i + 1
		else
			v3 = i
		end

		local child = self.Instance:FindFirstChild(v3)

		if not child then
			continue
		end

		if total + child.Size.Z > self._currentDistance then
			self._refPart = child
			v2 = child
			break
		else
			total += child.Size.Z
		end
	end

	if not v2 or self._totalDistance < total then
		self:StopSliding()
		return
	end

	if self._alignOrientation then
		self._alignOrientation.CFrame = self._alignOrientation.CFrame * CFrame.Angles(0, 6.283185307179586 * p, 0)
	end

	self.angle += 6.283185307179586 * p
	local angle = self.angle
	local v3 = math.sin(angle) * 0.2
	local v4 = math.cos(angle) * 0.2
	local v5 = self._currentDistance - total
	local v6 = (-v5 + v2.Size.Z / 2 + 5) * 1.4
	local v7 = v2.CFrame * CFrame.new(v3, v4, v6)

	if self._reverse then
		local v8 = (v5 - v2.Size.Z / 2 - 5) * 1.4
		v7 = v2.CFrame * CFrame.new(v3, v4, v8) * CFrame.Angles(0, 3.141592653589793, 0)
	end

	self:SpawnSquarePart(v2.CFrame, Color3.new(1, 0, 0))

	if self.slidingAlignPosition then
		self.slidingAlignPosition.Position = v7.Position
	end

	self._currentDistance += p * 10
end

function v:StopSliding()
	if not (Players.LocalPlayer.Character and self._active) then
		self._debounce = false
		return
	end

	self._active = false
	self._currentDistance = 0
	self:_StopSliding()
	task.delay(1, function()
		self._debounce = false
	end)
end

function v:_GetDistanceToPoint(p2: number)
	local total = 0

	for i = 1, p2 - 1 do
		local v2, child

		if self._reverse then
			v2 = #self.Instance:GetChildren() - i + 1

			if v2 <= p2 then
				break
			end
		else
			v2 = i
		end

		child = self.Instance:FindFirstChild(v2)

		if child then
			total += child.Size.Z
		end
	end

	return total
end

function v:_StartSliding()
	if not self._active then
		return
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	TelemetryController.SendClientInteraction("worldInteraction", {
		action = `Fire Pole Sliding{self._reverse and "" or " Reverse"}`,
		location = "LEGO-Fire House"
	})
	local slidingAlignPosition = self._whileActiveJanitor:Add(Instance.new("AlignPosition"))
	slidingAlignPosition.RigidityEnabled = true
	slidingAlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	slidingAlignPosition.Attachment0 = humanoidRootPart:WaitForChild("RootAttachment")
	slidingAlignPosition.Parent = humanoidRootPart
	local alignOrientation = self._whileActiveJanitor:Add(Instance.new("AlignOrientation"))
	alignOrientation.RigidityEnabled = true
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = humanoidRootPart:WaitForChild("RootAttachment")
	alignOrientation.Parent = humanoidRootPart
	self.slidingAlignPosition = slidingAlignPosition
	self._alignOrientation = alignOrientation
	self.angle = -90
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		self.animationTrack = humanoid:LoadAnimation(self.animation)
		self.animationTrack:Play()
	end
end

function v:_StopSliding()
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v2 = humanoidRootPart.AssemblyMass * 0.12
	local lookVector = CFrame.Angles(0, self.angle, 0).LookVector
	local v3 = CFrame.new(humanoidRootPart.CFrame.Position, humanoidRootPart.CFrame.Position + lookVector) * createVector(
		2,
		3,
		0
	) * v2
	local jumpOffAngle = self.Instance:GetAttribute("JumpOffAngle")

	if typeof(jumpOffAngle) == "number" then
		local _refPart = self._refPart or self.Instance:FindFirstChild("1")

		if _refPart ~= nil and _refPart:IsA("BasePart") then
			local v4 = math.rad(jumpOffAngle)
			local vectorToWorldSpace = _refPart.CFrame:VectorToWorldSpace((Vector3.new(math.cos(v4), math.sin(v4), 0)))
			local vector2 = Vector3.new(vectorToWorldSpace.X, 0, vectorToWorldSpace.Z)

			if vector2.Magnitude > 0 then
				local vector3 = Vector3.new(v3.X, 0, v3.Z)
				v3 = vector2.Unit * vector3.Magnitude + Vector3.new(0, v3.Y, 0)
			end
		end
	end

	humanoidRootPart:ApplyImpulse(v3)

	if self.slidingAlignPosition then
		self.slidingAlignPosition:Destroy()
		self.slidingAlignPosition = nil
	end

	if self._alignOrientation then
		self._alignOrientation:Destroy()
		self._alignOrientation = nil
	end

	if self.animationTrack then
		self.animationTrack:Stop()
		self.animationTrack:Destroy()
		self.animationTrack = nil
	end

	self._whileActiveJanitor:Cleanup()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v