local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local ZipLineConstants = require(ReplicatedStorage.Modules.Shared.World.ZipLineConstants)
local v = Component.new({
	Tag = "ZipLine"
})
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)

function v:Construct()
	self._Janitor = Janitor.new()
	self._whileActiveJanitor = Janitor.new()
	self._active = false
	self._slidingCharacter = nil
	self._currentDistance = 0
	self._reverse = false
	self._totalDistance = 0
	self._debounce = false
end

function v:InitializeTest()
	self.dummyPart = Instance.new("Part")
	self.dummyPart.Name = "DummyPart"
	self.dummyPart.Size = createVector(1, 1, 1)
	self.dummyPart.Position = createVector(0, 0, 0)
	self.dummyPart.Color = Color3.fromRGB(255, 0, 221)
	self.dummyPart.Parent = workspace
	self.dummyPart.CanCollide = false
	self.currentPart = nil
	self.testDistance = 0
	self.testReverse = false
end

function v:Start()
	self.zipLineParts = self.Instance:WaitForChild("ZipLineParts")
	local total = 0
	local count = 0

	for _, part in self.zipLineParts:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		total += part.Size.Z
		count += 1
		local v2 = part
		self._Janitor:Add(part.Touched:Connect(function(otherPart)
			local humanoidRootPart = otherPart.Parent:FindFirstChild("HumanoidRootPart") or otherPart
			self:FollowZipLine(v2, humanoidRootPart)
		end))
	end

	self._Janitor:Add(UserInputService.JumpRequest:Connect(function()
		if self._active then
			self:StopSliding()
		end
	end))
	self._Janitor:Add(Players.LocalPlayer.CharacterRemoving:Connect(function(character)
		if self._active and character == self._slidingCharacter then
			self:StopSliding(true)
		end
	end))
	self.animation = Instance.new("Animation")
	self.animation.Name = "SlidingAnimation"
	self.animation.AnimationId = "rbxassetid://103509115297876"
	self.animation.Parent = self.Instance
	self._Janitor:Add(self.animation)
	self._totalDistance = total
	self._totalParts = count
	self.ziplineDirection = self.zipLineParts:WaitForChild((`{self._totalParts}`)).Position - self.zipLineParts:WaitForChild("1").Position
	self:SetupInteractions()
end

function v:SetupInteractions()
	self.initialPart = self.zipLineParts:FindFirstChild("1")
	self.finalPart = self.zipLineParts:FindFirstChild((tostring(self._totalParts)))
	local start = self.Instance:WaitForChild("Start")
	local reverseStart = self.Instance:WaitForChild("ReverseStart")
	local component = ComponentUtil.GetComponentFromInstance(start, InteractionPrompt)
	local component2 = ComponentUtil.GetComponentFromInstance(reverseStart, InteractionPrompt)

	if component ~= nil then
		self._Janitor:Add(component.Interacted:Connect(function()
			self:FollowZipLineFromPrompt(self.initialPart, false)
		end))
	end

	if component2 ~= nil then
		self._Janitor:Add(component2.Interacted:Connect(function()
			self:FollowZipLineFromPrompt(self.finalPart, true)
		end))
	end
end

function v:FollowZipLineFromPrompt(p, flag: boolean?)
	if p == nil then
		return
	end

	local character = Players.LocalPlayer.Character

	if character == nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	self:FollowZipLine(p, humanoidRootPart, 0, flag)
end

function v:FollowZipLine(instance, instance2, currentDistance: number?, reverse: boolean?)
	if self._active then
		return
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or not instance2:IsDescendantOf(character) or self._debounce then
		return
	end

	self._debounce = true

	if reverse == nil then
		reverse = humanoidRootPart.CFrame.LookVector:Dot(self.ziplineDirection.Unit) < 0
	end

	self._reverse = reverse

	if currentDistance then
		self._currentDistance = currentDistance
	else
		local pointToObjectSpace = instance.CFrame:PointToObjectSpace(humanoidRootPart.Position)
		local v2

		if reverse then
			v2 = pointToObjectSpace.Z + instance.Size.Z / 2
		else
			v2 = instance.Size.Z / 2 - pointToObjectSpace.Z
		end

		self._currentDistance = self:_GetDistanceToPoint((tonumber(instance.Name))) + v2
	end

	self._slidingCharacter = character
	self._active = true
	self:_StartSliding()
end

function v:GetDistanceToPoint(p2: number, flag: boolean)
	local total = 0
	local v2 = nil

	for i = 1, self._totalParts do
		local v3

		if flag then
			v3 = self._totalParts - i + 1
		else
			v3 = i
		end

		local child = self.zipLineParts:FindFirstChild((tostring(v3)))

		if not child then
			continue
		end

		if p2 < total + child.Size.Z then
			v2 = child
			break
		else
			total += child.Size.Z
		end
	end

	return v2, total
end

function v:GetPoint(p: number, instance, flag: boolean)
	local v2 = -p + instance.Size.Z / 2
	local v3 = instance.CFrame * CFrame.new(0, 0, v2)

	if flag then
		local v4 = p - instance.Size.Z / 2
		return instance.CFrame * CFrame.new(0, 0, v4) * CFrame.Angles(0, 3.141592653589793, 0)
	end

	return v3
end

function v:TestUpdate(p: number)
	local distanceToPoint, v2 = self:GetDistanceToPoint(self.testDistance, self.testReverse)

	if distanceToPoint and not (self._totalDistance < v2) then
		if self.currentPart ~= distanceToPoint then
			if self.currentPart then
				self.currentPart.Color = Color3.fromRGB(0, 0, 0)
				self.currentPart.Material = Enum.Material.Plastic
			end

			self.currentPart = distanceToPoint
			self.currentPart.Color = Color3.fromRGB(162, 221, 245)
			self.currentPart.Material = Enum.Material.Neon
		end

		local point = self:GetPoint(self.testDistance - v2, distanceToPoint, self.testReverse)
		self.testDistance += p * 50
		self.dummyPart.Position = point.Position
	else
		self.testReverse = not self.testReverse
		self.testDistance = 0
		self.dummyPart.Color = self.testReverse and Color3.fromRGB(171, 255, 180) or Color3.fromRGB(255, 174, 243)
	end
end

function v:RenderSteppedUpdate(p: number)
	if not self._active then
		return
	end

	local character = Players.LocalPlayer.Character
	local v2

	if character ~= nil then
		v2 = character:FindFirstChild("HumanoidRootPart")
	end

	if character ~= self._slidingCharacter or v2 == nil then
		self:StopSliding(true)
		return
	end

	local distanceToPoint, v3 = self:GetDistanceToPoint(self._currentDistance, self._reverse)

	if not distanceToPoint or self._totalDistance < v3 then
		self:StopSliding()
		return
	end

	local point = self:GetPoint(self._currentDistance - v3, distanceToPoint, self._reverse)
	local humanoid = character:FindFirstChild("Humanoid")
	local cFrame = point + Vector3.new(0, -1.5 - (humanoid and humanoid.HipHeight or 2), 0)

	if self.slidingAlignPosition then
		self.slidingAlignPosition.Position = cFrame.Position
	end

	if self._alignOrientation then
		self._alignOrientation.CFrame = cFrame
	end

	self._currentDistance += p * 50
end

function v:StopSliding(flag: boolean?)
	if self._active then
		self._active = false
		self._currentDistance = 0
		self:_StopSliding(flag == true)

		if self.debounceTask then
			task.cancel(self.debounceTask)
		end

		self.debounceTask = task.delay(0.8, function()
			self.debounceTask = nil
			self._debounce = false
		end)
	elseif not self.debounceTask then
		self._debounce = false
	end
end

function v:_GetDistanceToPoint(p: number)
	local total = 0

	for i = 1, self._totalParts do
		local v2

		if self._reverse then
			v2 = self._totalParts - i + 1
		else
			v2 = i
		end

		if v2 == p then
			break
		end

		local child = self.zipLineParts:FindFirstChild((tostring(v2)))

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
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if character == nil or character ~= self._slidingCharacter or humanoidRootPart == nil then
		self:StopSliding(true)
		return
	end

	TelemetryController.SendClientInteraction("worldInteraction", {
		action = "Zip Line",
		location = "Jurassic 2026"
	})
	local slidingAlignPosition = self._whileActiveJanitor:Add(Instance.new("AlignPosition"))
	local rootAttachment = humanoidRootPart:WaitForChild("RootAttachment")
	slidingAlignPosition.RigidityEnabled = true
	slidingAlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	slidingAlignPosition.Attachment0 = rootAttachment
	slidingAlignPosition.Parent = humanoidRootPart
	slidingAlignPosition.Responsiveness = 60
	slidingAlignPosition.Position = rootAttachment.WorldCFrame.Position
	local alignOrientation = self._whileActiveJanitor:Add(Instance.new("AlignOrientation"))
	alignOrientation.RigidityEnabled = true
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.Attachment0 = rootAttachment
	alignOrientation.Parent = humanoidRootPart
	alignOrientation.Responsiveness = 30
	alignOrientation.CFrame = rootAttachment.WorldCFrame
	self.slidingAlignPosition = slidingAlignPosition
	self._alignOrientation = alignOrientation
	local localPlayer = Players.LocalPlayer
	localPlayer:AddTag(ZipLineConstants.HANDLE_TAG)
	Remotes.fireServer(ZipLineConstants.SET_HANDLE_EVENT, true)
	self._whileActiveJanitor:Add(function()
		localPlayer:RemoveTag(ZipLineConstants.HANDLE_TAG)
		Remotes.fireServer(ZipLineConstants.SET_HANDLE_EVENT, false)
	end)
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		self.animationTrack = humanoid:LoadAnimation(self.animation)
		self.animationTrack:Play()
	end
end

function v:_StopSliding(flag: boolean)
	local _slidingCharacter = self._slidingCharacter
	self._slidingCharacter = nil
	local humanoidRootPart

	if _slidingCharacter ~= nil then
		humanoidRootPart = _slidingCharacter:FindFirstChild("HumanoidRootPart")
	end

	if flag ~= true and humanoidRootPart ~= nil and humanoidRootPart.Parent ~= nil then
		local v2 = humanoidRootPart.AssemblyMass * 0.24 * 10
		humanoidRootPart:ApplyImpulse((humanoidRootPart.CFrame.LookVector * 2 + createVector(0, 3, 0)) * v2)
	end

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
	if self._active then
		self:StopSliding(true)
	end

	self._Janitor:Destroy()
	self._whileActiveJanitor:Destroy()
end

return v