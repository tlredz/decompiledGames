local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportOnTouch = require(ReplicatedStorage.Modules.Client.Components.Interactions.TeleportOnTouch)
local SnowboardMobileUI = require(ReplicatedStorage.Modules.Client.Components.UI.Snowboard.SnowboardMobileUI)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PlayerModule = require(Players.LocalPlayer.PlayerScripts.PlayerModule)
local controls = PlayerModule:GetControls()
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Grinding = require(ReplicatedStorage.Modules.Client.Components.Interactions.Olympics.Grinding)
local GrindingRail = require(ReplicatedStorage.Modules.Client.Components.Interactions.Olympics.GrindingRail)
local EmotesController = require(ReplicatedStorage.Modules.Client.Emotes.EmotesController)
local CameraShakeController = require(ReplicatedStorage.Modules.Client.PlayerController.CameraShakeController)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)
local NoMotorVehicleController = require(ReplicatedStorage.Modules.Client.Vehicles.NoMotorVehicleController)
local Input = require(ReplicatedStorage.Packages.Input)
local gamepad = Input.Gamepad
local v = Component.new({
	Tag = "Snowboard",
	Extensions = { OnlyRunOnPlayerHotbar }
})
local random = Random.new()
local v2 = gamepad.new()

function v:Construct()
	self._Janitor = Janitor.new()
	self._whileActiveJanitor = self._Janitor:Add(Janitor.new())
	self._active = false
	self._verticalVelocity = 0
	self._speed = 0
	self._lastFloorCFrame = CFrame.new()
	self._isLeftFacing = true
	self._isFlying = false
	self._flightStartTime = 0
	self._flightEndTime = 0
	self._equipped = false
	self._wasPitchDualInputed = false
	self._goalSpeed = 0
	self._flipCheck = 0
	self.adjustedTurnAngleCFrame = CFrame.new()
	self._currentMoveNormalTimePosition = 0.5
	self._currentMoveFlippedTimePosition = 0.5
	self._currentDiveBombNormalTimePosition = 0.5
	self._currentDiveBombFlippedTimePosition = 0.5
	self._animations = {}
	self._lastFloorResult = nil
end

function v:Start()
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self._equipped = true
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self._equipped = false

		if self._holdingIdleTrack then
			self._holdingIdleTrack:Stop()
			self._holdingIdleTrack = nil
		end
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "StartSnowboard", function()
		self:_StartSnowboard()
	end))
	self._Janitor:Add(Remotes.connectComponentRemote(self.Instance, "StopSnowboard", function()
		self:_StopSnowboard()
	end))
	self._Janitor:Add(Grinding.Started:Connect(function(p)
		local character = Players.LocalPlayer.Character

		if not character then
			return
		end

		if p.Instance == character then
			self:_StartGrinding(p)
		end
	end))
	self._Janitor:Add(Grinding.Stopped:Connect(function(p)
		local character = Players.LocalPlayer.Character

		if not character then
			return
		end

		if p.Instance == character then
			self:_StopGrinding()
		end
	end))
end

function v:_StartGrinding(grindingComponent)
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

	local grindingAlignPosition = self._whileActiveJanitor:Add(Instance.new("AlignPosition"))
	grindingAlignPosition.RigidityEnabled = true
	grindingAlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	grindingAlignPosition.Attachment0 = humanoidRootPart:WaitForChild("RootAttachment")
	grindingAlignPosition.Parent = humanoidRootPart
	local grindingAlignOrientation = self._whileActiveJanitor:Add(Instance.new("AlignOrientation"))
	grindingAlignOrientation.RigidityEnabled = true
	grindingAlignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	grindingAlignOrientation.Attachment0 = humanoidRootPart:WaitForChild("RootAttachment")
	grindingAlignOrientation.Parent = humanoidRootPart
	self._grindingAlignPosition = grindingAlignPosition
	self._grindingAlignOrientation = grindingAlignOrientation
	self._grindingComponent = grindingComponent
	self.Instance.Handle.RailGrind:Play()

	for _, emitter in character:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") or emitter.Name ~= "Sparks" or emitter:IsDescendantOf(self.Instance) then
			continue
		end

		emitter.Enabled = true
	end
end

function v:_StopGrinding()
	if not self._grindingComponent then
		return
	end

	local character = Players.LocalPlayer.Character

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	if self._grindingAlignPosition then
		self._grindingAlignPosition:Destroy()
		self._grindingAlignPosition = nil
	end

	if self._grindingAlignOrientation then
		self._grindingAlignOrientation:Destroy()
		self._grindingAlignOrientation = nil
	end

	self._grindingComponent = nil
	self.Instance.Handle.RailGrind:Stop()

	for _, emitter in character:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") or emitter.Name ~= "Sparks" or emitter:IsDescendantOf(self.Instance) then
			continue
		end

		emitter.Enabled = false
	end
end

function v:_StartSnowboard()
	self._active = true
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	self._verticalVelocity = humanoidRootPart.AssemblyLinearVelocity.Y
	local _CreateColliders = self:_CreateColliders(character)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {
		table.unpack(_CreateColliders),
		character,
		CollectionService:GetTagged("MilitaryVehicleCollider")
	}
	raycastParams.RespectCanCollide = true
	self._raycastParams = raycastParams

	for _, v3 in CollectionService:GetTagged("SnowboardCollider") do
		v3.CanCollide = true
	end

	local linearVelocity = self._whileActiveJanitor:Add((self.Instance.LinearVelocity:Clone()))
	local alignOrientation = self._whileActiveJanitor:Add((self.Instance.AlignOrientation:Clone()))
	linearVelocity.Parent = humanoidRootPart
	alignOrientation.Parent = humanoidRootPart
	local rootRigAttachment = humanoidRootPart:WaitForChild("RootRigAttachment")
	linearVelocity.Attachment0 = rootRigAttachment
	alignOrientation.Attachment0 = rootRigAttachment
	alignOrientation.CFrame = humanoidRootPart.CFrame
	self._linearVelocity = linearVelocity
	self._alignOrientation = alignOrientation
	self._isLeftFacing = true
	self._speed = humanoidRootPart.AssemblyLinearVelocity:Dot(humanoidRootPart.CFrame.LookVector)
	self:_SetPartsMassless()
	self._whileActiveJanitor:Add(RunService.RenderStepped:Connect(function(dt: number)
		self:_RenderSteppedUpdate(dt)
	end))
	self:_LoadAnimations()
	self:_PlayAnimation("idle")
	self._isFlying = false
	self._flightStartTime = os.clock()
	self._whileActiveJanitor:Add(UserInputService.JumpRequest:Connect(function()
		self:_Jump()
	end))
	self._lastFloorCFrame = self:_GetFloorAlignedCFrame() or humanoidRootPart.CFrame
	local _GetMobileUI = self:_GetMobileUI()
	_GetMobileUI:Open()
	self._whileActiveJanitor:Add(_GetMobileUI.JumpSignal:Connect(function()
		self:_Jump()
	end))

	if self._holdingIdleTrack then
		self._holdingIdleTrack:Stop()
	end

	self._whileActiveJanitor:Add(TeleportOnTouch.OnTeleported:Connect(function(cFrame: CFrame)
		self._alignOrientation.CFrame = cFrame
	end))
	NoMotorVehicleController.RemoveNoMotorVehicle()
end

function v:_GetMobileUI()
	local panel = PanelController.GetPanel("Snowboard", "SnowboardMobileUI")

	if panel then
		return ComponentUtil.GetComponentFromInstance(panel.Instance, SnowboardMobileUI)
	end

	return nil
end

function v:_StopSnowboard()
	self._whileActiveJanitor:Cleanup()
	self._active = false
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	humanoid.PlatformStand = false

	for _, _animation in self._animations do
		for _, v3 in _animation do
			v3:Stop()
		end
	end

	self:_GetMobileUI():Close()
	workspace.CurrentCamera.FieldOfView = 70
	local touchGui = Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")

	if touchGui then
		touchGui.Enabled = true
	end

	self:_StopGrinding()

	if not self._equipped then
		return
	end

	if self._holdingIdleTrack then
		self._holdingIdleTrack:Play()
	else
		local animator = humanoid:WaitForChild("Animator")
		self._holdingIdleTrack = self._Janitor:Add(animator:LoadAnimation(self.Instance.Animations.Idle))
		self._holdingIdleTrack:Play()
	end

	for _, v3 in CollectionService:GetTagged("SnowboardCollider") do
		v3.CanCollide = false
	end
end

function v:_GetMobileMoveVector()
	return self:_GetMobileUI():GetMoveVector()
end

function v:_IsMobileUIActive()
	return self:_GetMobileUI():IsMobileUIActive()
end

function v:_GetJumpDown()
	local _GetMobileUI = self:_GetMobileUI()
	local isKeyDown = UserInputService:IsKeyDown(Enum.KeyCode.Space)
	local v3 = v2:IsConnected() and v2:IsButtonDown(Enum.KeyCode.ButtonA)
	local jumpDown = self:_IsMobileUIActive() and _GetMobileUI:GetJumpDown()
	return isKeyDown or v3 or jumpDown
end

function v:_IsPitchDisabled()
	local _GetLongGroundRaycastResult = self:_GetLongGroundRaycastResult()

	if _GetLongGroundRaycastResult and _GetLongGroundRaycastResult.Distance < 10 then
		return true
	end

	return self:_GetMobileUI():IsPitchDisabled()
end

function v:_LoadAnimations()
	local animator = self.Instance.Parent:WaitForChild("Humanoid"):WaitForChild("Animator")
	local animations = self.Instance.Animations

	local function loadAnimation(instance)
		for _, child in instance:GetChildren() do
			local v3 = {}

			for _, child2 in child:GetChildren() do
				local v4 = self._whileActiveJanitor:Add(animator:LoadAnimation(child2))
				v4.Looped = child:GetAttribute("ShouldLoop")
				v4:AdjustSpeed(child2:GetAttribute("Speed") or 1)
				v3[child2.Name] = v4
			end

			self._animations[child.Name] = v3
		end
	end

	loadAnimation(animations.core)
	loadAnimation(animations.tricks)
end

function v:_CreateColliders(parent)
	local leftFoot = parent:FindFirstChild("LeftFoot")
	local rightFoot = parent:FindFirstChild("RightFoot")

	if not (leftFoot and rightFoot) then
		return nil
	end

	local vector2 = Vector3.new(leftFoot.Size.Y, leftFoot.Size.Y, leftFoot.Size.Y)
	local v3 = self._whileActiveJanitor:Add(Instance.new("Part"))
	v3.Name = "LeftSnowboardCollider"
	v3.Shape = Enum.PartType.Ball
	v3.Size = vector2
	v3.Transparency = 1
	local v4 = self._whileActiveJanitor:Add(Instance.new("Part"))
	v4.Name = "RightSnowboardCollider"
	v4.Shape = Enum.PartType.Ball
	v4.Size = vector2
	v4.Transparency = 1
	local v5 = self._whileActiveJanitor:Add(Instance.new("Weld"))
	v5.Part0 = v3
	v5.Part1 = leftFoot
	v5.Parent = v3
	local v6 = self._whileActiveJanitor:Add(Instance.new("Weld"))
	v6.Part0 = v4
	v6.Part1 = rightFoot
	v6.Parent = v4
	v3.Parent = parent
	v4.Parent = parent
	self._whileActiveJanitor:Add(leftFoot:GetPropertyChangedSignal("Size"):Connect(function()
		v3.Size = Vector3.new(leftFoot.Size.Y, leftFoot.Size.Y, leftFoot.Size.Y)
	end))
	self._whileActiveJanitor:Add(rightFoot:GetPropertyChangedSignal("Size"):Connect(function()
		v4.Size = Vector3.new(rightFoot.Size.Y, rightFoot.Size.Y, rightFoot.Size.Y)
	end))
	return { v3 }
end

function v:_PlayAnimation(p2: string, p3: number?)
	local _animation = self._animations[p2]

	if not _animation then
		return
	end

	local normal

	if self._isLeftFacing then
		normal = _animation.normal
	else
		normal = _animation.flipped
	end

	local flipped

	if self._isLeftFacing then
		flipped = _animation.flipped
	else
		flipped = _animation.normal
	end

	if normal.IsPlaying then
		return
	end

	if p3 then
		normal:Play(p3)
		flipped:Stop(p3)
	else
		normal:Play()
		flipped:Stop()
	end

	return normal
end

function v:_StopAnimation(p2: string, p3: number?)
	local _animation = self._animations[p2]

	if not _animation then
		return
	end

	if p3 then
		_animation.normal:Stop(p3)
		_animation.flipped:Stop(p3)
	else
		_animation.normal:Stop()
		_animation.flipped:Stop()
	end
end

function v:_SetAnimationWeight(p2: string, value: number, p3: number?)
	local _animation = self._animations[p2]

	if not _animation then
		return
	end

	local v3 = math.clamp(value, 0.01, 1)

	if p3 then
		_animation.normal:AdjustWeight(v3, p3)
		_animation.flipped:AdjustWeight(v3, p3)
	else
		_animation.normal:AdjustWeight(v3)
		_animation.flipped:AdjustWeight(v3)
	end
end

function v:_SetPartsMassless()
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	for _, part in character:GetDescendants() do
		if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart") then
			continue
		end

		local v3 = part
		local massless = part.Massless
		self._whileActiveJanitor:Add(function()
			v3.Massless = massless
		end)
		part.Massless = true
	end

	self._whileActiveJanitor:Add(character.ChildAdded:Connect(function(part)
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			local massless = part.Massless
			self._whileActiveJanitor:Add(function()
				part.Massless = massless
			end)
			part.Massless = true
		end
	end))
end

function v:_Jump()
	if self._isFlying then
		return
	end

	self._jumping = true
	local _GetSlopeAngle = self:_GetSlopeAngle()
	self._verticalVelocity = math.clamp(math.map(_GetSlopeAngle, -90, 0, 12.5, 50), 0, 50)
	self._whileActiveJanitor:Add(task.delay(0.1, function()
		self._jumping = false
	end))

	for _, v3 in GrindingRail:GetAll() do
		v3:StopGrinding()
	end
end

function v:_RenderSteppedUpdate(p: number)
	if not self._active then
		return
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not (humanoid and character:FindFirstChild("HumanoidRootPart")) then
		return
	end

	if self._grindingComponent then
		local point = self._grindingComponent:GetPoint()
		self:_StopFlying()

		if point then
			local cFrame = point * CFrame.new(0, humanoid.HipHeight, 0)
			self._grindingAlignPosition.Position = cFrame.Position
			self._grindingAlignOrientation.CFrame = cFrame
		end
	else
		self._lastFloorResult = nil
		self._lastFloorResult = self:_GetFloorResult()
		local touchGui = Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")

		if touchGui then
			touchGui.Enabled = not self:_IsMobileUIActive()
		end

		humanoid.PlatformStand = true
		self:_UpdateInput(p)
		self:_UpdateGroundedAnimations(p)
		local v3 = math.clamp(self._speed / 110, 0, 1)
		local fieldOfView = math.map(v3, 0, 1, 70, 100)
		workspace.CurrentCamera.FieldOfView = fieldOfView

		if EmotesController.IsPlayingEmote() then
			NotificationController.Notify("Cannot emote while snowboarding!")
			EmotesController.StopEmote()
		end
	end
end

function v:_GetMoveVector()
	local _GetMobileUI = self:_GetMobileUI()

	if _GetMobileUI:IsMobileUIActive() then
		return _GetMobileUI:GetMoveVector()
	end

	return controls:GetMoveVector()
end

function v:_UpdateInput(value: number)
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	if PanelController.IsOpen("NoResetGUIHandler", "AvatarEditorMenu") then
		self._linearVelocity.VectorVelocity = createVector(0, 0, 0)
		return
	end

	local _GetMoveVector = self:_GetMoveVector()

	if math.abs(_GetMoveVector.Z) < 0.05 then
		self._wasPitchDualInputed = true
	end

	local cframe = self:_GetFloorAlignedCFrame()
	local _GetLongGroundRaycastResult = self:_GetLongGroundRaycastResult()
	local _GetRaycastCeilingResult = self:_GetRaycastCeilingResult()

	if cframe and _GetLongGroundRaycastResult and not _GetRaycastCeilingResult and math.deg((math.acos((cframe.UpVector:Dot(_GetLongGroundRaycastResult.Normal))))) > 25 then
		cframe = CFrame.fromMatrix(cframe.Position, cframe.RightVector, _GetLongGroundRaycastResult.Normal)
	end

	if cframe then
		self:_StopFlying()
		self._lastFloorCFrame = cframe
	else
		cframe = self._lastFloorCFrame
		self:_StartFlying()
	end

	if self._isFlying then
		if self._isFlying then
			self._flipCheck += math.clamp(value, 0, 0.2)
		end
	else
		self._flipCheck = math.max(self._flipCheck - value, 0)
		local v3 = math.clamp(self:_GetSlopeAngle(), -90, 0)
		local v4 = math.map(v3, -90, 0, 2, 0.5)
		local v5 = math.map(v3, -90, 0, 110, 50)
		local goalSpeed = -_GetMoveVector.Z * v5
		local v7 = math.abs(_GetMoveVector.Z) < 0.05 and 0.1 or v4

		if math.sign(_GetMoveVector.Z) == 1 then
			goalSpeed = math.clamp(goalSpeed, -10, 0)
			v7 = 0.5
		end

		self._speed = math.lerp(self._speed, goalSpeed, value * v7)
		self._goalSpeed = goalSpeed
		local vector2 = Vector3.new(
			self._linearVelocity.VectorVelocity.X,
			self._linearVelocity.VectorVelocity.Y,
			self._linearVelocity.VectorVelocity.Z
		)
		local vector3 = Vector3.new(
			self._alignOrientation.CFrame.LookVector.X,
			self._alignOrientation.CFrame.LookVector.Y,
			self._alignOrientation.CFrame.LookVector.Z
		)

		if _GetLongGroundRaycastResult and _GetLongGroundRaycastResult.Normal:Dot(createVector(0, 1, 0)) > 0.9 then
			vector2 = Vector3.new(vector2.X, 0, vector2.Z)
		end

		local v8 = not (vector2.Magnitude > 0.001 and vector3.Magnitude > 0.001) and 0 or vector3.Unit:Angle(vector2.Unit)

		if self._flipCheck > 0 and v8 > 0.7853981633974483 and _GetLongGroundRaycastResult and _GetLongGroundRaycastResult.Distance < 5 then
			self._flipCheck = 0
			local Y = vector3.Unit:Cross(vector2.Unit).Y
			local v9 = Y == 0 and 1 or math.sign(Y) or 1
			self.adjustedTurnAngleCFrame = CFrame.Angles(0, v9 * v8, 0)
		end
	end

	local _GetFloorResult = self:_GetFloorResult()
	local v3 = cframe.LookVector * self._speed
	local hipHeight = humanoid.HipHeight
	local _isFlying = self._isFlying or _GetFloorResult and hipHeight < _GetFloorResult.Distance
	local v4 = workspace.Gravity / 2 * value

	if _isFlying or self._jumping then
		self._verticalVelocity -= v4
	else
		local v5 = self._verticalVelocity - v4
		self._verticalVelocity = math.max(v3.Y, v5)
	end

	if math.abs(self._verticalVelocity) < 1 then
		self._verticalVelocity = -2
	end

	local vector2 = Vector3.new(v3.X, self._verticalVelocity, v3.Z)
	local v5 = math.clamp(self._speed / 110, 0, 1)
	local v6 = self._isFlying and 6.283185307179586 or math.map(v5, 0, 1, 3.141592653589793, 1.5707963267948966)
	local v7 = -_GetMoveVector.X * v6 * value
	local v8 = self._isFlying and _GetMoveVector.Z * v6 * value or 0
	local v9 = os.clock() - self._flightStartTime
	local v10 = v9 < 0.1 and 0 or v8
	local _isFlying2 = false

	if self:_IsPitchDisabled() then
		v10 = 0
		local v11 = v9 > 0.1
		local v12 = v9 > 10

		if _GetLongGroundRaycastResult and (not _GetFloorResult or v12) and v11 and _GetLongGroundRaycastResult.Distance < 10 and (_GetFloorResult and _GetLongGroundRaycastResult.Normal:Dot(_GetFloorResult.Normal) < 0.5 or not _GetFloorResult) then
			_isFlying2 = self._isFlying
			local normal = _GetLongGroundRaycastResult.Normal
			local lookVector = cframe.LookVector

			if self._alignOrientation.CFrame.UpVector:Dot(normal) < 0 then
				local vectorVelocity = self._linearVelocity.VectorVelocity
				lookVector = Vector3.new(vectorVelocity.X, 0, vectorVelocity.Z).Unit
			end

			local v13 = -(lookVector - normal * lookVector:Dot(normal))
			local unit = normal:Cross(v13).Unit
			cframe = CFrame.fromMatrix(cframe.Position, unit, normal, v13)
		end
	end

	local cframe2 = cframe * CFrame.Angles(0, v7, 0)

	if self._isFlying and not _isFlying2 then
		self._alignOrientation.CFrame *= CFrame.Angles(v10, 0, 0)
		self._alignOrientation.CFrame *= CFrame.Angles(0, v7, 0)
	else
		self._alignOrientation.CFrame = cframe2:Orthonormalize()
	end

	if self._alignOrientation and self.adjustedTurnAngleCFrame then
		character:PivotTo(character:GetPivot() * self.adjustedTurnAngleCFrame)
		self.adjustedTurnAngleCFrame = CFrame.new()
	end

	local v11 = math.clamp((os.clock() - self._flightEndTime) / 2, 0, 1)
	self._linearVelocity.VectorVelocity = self._linearVelocity.VectorVelocity:Lerp(vector2, v11)

	if self:_GetJumpDown() and self._isFlying then
		self:_StartTrick()
	else
		self:_StopTrick()
	end
end

function v:_StartTrick()
	if self._trickTrack then
		return
	end

	local v3 = {}

	for _, child in self.Instance.Animations.tricks:GetChildren() do
		table.insert(v3, self._animations[child.Name])
	end

	local integer = random:NextInteger(1, #v3)
	local v4 = v3[integer]

	if not v4 then
		warn("No trick track found", integer)
		return
	end

	local normal

	if self._isLeftFacing then
		normal = v4.normal
	else
		normal = v4.flipped
	end

	normal.Priority = Enum.AnimationPriority.Action3
	normal:Play(0.5)
	self._trickTrack = normal
end

function v:_StopTrick()
	if self._trickTrack then
		self._trickTrack:Stop(0.5)
		self._trickTrack = nil
	end
end

function v:_StartFlying()
	if self._isFlying then
		return
	end

	self._isFlying = true
	self._wasPitchDualInputed = false
	self:_SetAnimationWeight("move", 0, 0.5)
	self:_SetAnimationWeight("diveBomb", 0, 0.5)
	self:_PlayAnimation("falling", 0.5)
	self._flightStartTime = os.clock()
end

function v:_StopFlying()
	if not self._isFlying or os.clock() - self._flightStartTime < 0.1 then
		return
	end

	self._isFlying = false
	self._flightEndTime = os.clock()
	self:_PlayAnimation("onLand", 0)
	self:_ApplyLandingEffects()
	self:_StopAnimation("falling", 0)
	self:_PlayAnimation("idle")
	self:_SetAnimationWeight("move", 0, 0.5)
	self:_SetAnimationWeight("diveBomb", 0, 0.5)
end

function v:_CheckAndFlipFacing()
	local humanoidRootPart = self.Instance.Parent:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart or self.Instance:GetAttribute("PreventFlip") then
		return
	end

	local vectorVelocity = self._linearVelocity.VectorVelocity

	if math.max(math.abs(vectorVelocity.X), (math.abs(vectorVelocity.Z))) < 5 and math.abs(vectorVelocity.Y) < 20 then
		return
	end

	local lookVector = self._alignOrientation.CFrame.LookVector
	local unit = self._linearVelocity.VectorVelocity.Unit
	local dot = unit:Dot(lookVector)

	if (-unit):Dot(lookVector) - dot > 0.3 then
		humanoidRootPart.CFrame *= CFrame.Angles(0, 3.141592653589793, 0)
		self._alignOrientation.CFrame *= CFrame.Angles(0, 3.141592653589793, 0)
		self._isLeftFacing = not self._isLeftFacing
	end
end

function v:_UpdateGroundedAnimations(p: number)
	local _GetMoveVector = self:_GetMoveVector()
	local v3 = self._goalSpeed < self._speed

	if _GetMoveVector.Z > 0 and v3 and not self._isFlying then
		local v4 = math.clamp(self._speed, 0, 1)
		self:_PlayAnimation("stop")
		self:_SetAnimationWeight("move", 1 - v4)
		self:_SetAnimationWeight("diveBomb", 0)
		self:_SetAnimationWeight("stop", v4)
	elseif _GetMoveVector.Z < 0 then
		self:_StopAnimation("stop", 0.5)
		local v4 = math.map(self._speed, 50, 110, 1, 0)
		local v5 = math.map(self._speed, 50, 110, 0, 1)
		local v6 = math.clamp(v4, 0.01, 1)
		local v7 = math.clamp(v5, 0.01, 1)

		if self._animations.move and self._animations.diveBomb then
			self:_PlayAnimation("move", 0.5)
			self:_PlayAnimation("diveBomb", 0.5)
			self._animations.move.normal:AdjustSpeed(0)
			self._animations.move.flipped:AdjustSpeed(0)
			self._animations.diveBomb.normal:AdjustSpeed(0)
			self._animations.diveBomb.flipped:AdjustSpeed(0)
			self:_SetAnimationWeight("move", v6, 0.5)
			self:_SetAnimationWeight("diveBomb", v7, 0.5)
			self:_UpdateAnimationTimePosition(p)
		end
	else
		self:_SetAnimationWeight("move", 0.01, 0.5)
		self:_SetAnimationWeight("diveBomb", 0.01, 0.5)
		self:_StopAnimation("stop", 0.5)
	end
end

function v:_UpdateAnimationTimePosition(p: number)
	local _GetMoveVector = self:_GetMoveVector()
	local v3 = math.clamp(math.clamp(self._speed / 50, 0, 1), 0, 1)
	local v4 = math.map(_GetMoveVector.X, -1, 1, 0.9, 0.1)
	local v5 = math.map(_GetMoveVector.X, -1, 1, 0.1, 0.9)
	local v6 = math.lerp(0.5, v4, v3)
	local v7 = math.lerp(0.5, v5, v3)

	if self.Instance:GetAttribute("FlipMoveLeaning") then
		v7, v6 = v6, v7
	end

	self._currentMoveNormalTimePosition = math.lerp(self._currentMoveNormalTimePosition, v6, p * 5)
	self._currentMoveFlippedTimePosition = math.lerp(self._currentMoveFlippedTimePosition, v7, p * 5)
	self._currentDiveBombNormalTimePosition = math.lerp(self._currentDiveBombNormalTimePosition, v6, p * 5)
	self._currentDiveBombFlippedTimePosition = math.lerp(self._currentDiveBombFlippedTimePosition, v7, p * 5)
	self._animations.move.normal.TimePosition = self._currentMoveNormalTimePosition
	self._animations.move.flipped.TimePosition = self._currentMoveFlippedTimePosition
	self._animations.diveBomb.normal.TimePosition = self._currentDiveBombNormalTimePosition
	self._animations.diveBomb.flipped.TimePosition = self._currentDiveBombFlippedTimePosition
end

function v:_ApplyLandingEffects()
	local v3 = math.clamp(self._speed / 110, 0, 1)
	local v4 = math.map(v3, 0, 1, 0, 3)
	CameraShakeController.CamShake:ShakeOnce(v4, 4, 0, 0.75)
end

function v:_GetFloorAlignedCFrame()
	local humanoidRootPart = self.Instance.Parent:FindFirstChild("HumanoidRootPart")
	local _GetFloorResult = self:_GetFloorResult()

	if not _GetFloorResult then
		return nil
	end

	local normal = _GetFloorResult.Normal
	local position = _GetFloorResult.Position
	local lookVector = humanoidRootPart.CFrame.LookVector
	local unit = normal:Cross(-(lookVector - lookVector:Dot(normal) * normal).Unit).Unit
	local _ = unit:Cross(normal).Unit
	return CFrame.fromMatrix(position, unit, normal) * CFrame.new(0, 0.1, 0) * CFrame.Angles(0.017453292519943295, 0, 0)
end

function v:_GetFloorResult()
	if self._lastFloorResult then
		return self._lastFloorResult
	end

	local parent = self.Instance.Parent
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local humanoid = parent:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local rootRigAttachment = humanoidRootPart:FindFirstChild("RootRigAttachment")

	if not rootRigAttachment then
		return
	end

	local worldCFrame = rootRigAttachment.WorldCFrame
	local value = humanoid.BodyHeightScale.Value
	local v3 = humanoid.HipHeight + 1
	local v4 = 4 * value
	local position = (worldCFrame * CFrame.new(0, -0.5, -v4)).Position
	local position2 = (worldCFrame * CFrame.new(0, -0.5, v4)).Position
	local position3 = (worldCFrame * CFrame.new(v4 / 2, -0.5, 0)).Position
	local position4 = (worldCFrame * CFrame.new(-v4 / 2, -0.5, 0)).Position
	local raycastResult = workspace:Raycast(position, -worldCFrame.UpVector * v3, self._raycastParams)
	local raycastResult2 = workspace:Raycast(position2, -worldCFrame.UpVector * v3, self._raycastParams)
	local raycastResult3 = workspace:Raycast(worldCFrame.Position, -worldCFrame.UpVector * v3 * 2, self._raycastParams)
	local raycastResult4 = workspace:Raycast(position3, -worldCFrame.UpVector * v3, self._raycastParams)
	local raycastResult5 = workspace:Raycast(position4, -worldCFrame.UpVector * v3, self._raycastParams)

	if not (raycastResult and raycastResult2 and raycastResult4 and raycastResult5) then
		return raycastResult3
	end

	if not raycastResult3 then
		return nil
	end

	local vector2 = -CFrame.lookAt(raycastResult2.Position, raycastResult.Position).LookVector:Cross(CFrame.lookAt(
		raycastResult5.Position,
		raycastResult4.Position
	).LookVector).Unit
	local position5 = (raycastResult.Position + raycastResult2.Position + raycastResult3.Position) / 3
	local distance = (raycastResult.Distance + raycastResult2.Distance + raycastResult3.Distance) / 3

	if vector2.Y < 0.5 then
		return {
			Normal = (raycastResult.Normal + raycastResult3.Normal + raycastResult2.Normal).Unit,
			Position = raycastResult3.Position,
			Distance = (raycastResult.Distance + raycastResult2.Distance + raycastResult3.Distance) / 3
		}
	end

	if vector2:Dot(raycastResult3.Normal) < 0.9 then
		return raycastResult3
	end

	return {
		Normal = vector2,
		Position = position5,
		Distance = distance
	}
end

function v:_GetLongGroundRaycastResult()
	local parent = self.Instance.Parent
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local humanoid = parent:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local rootRigAttachment = humanoidRootPart:FindFirstChild("RootRigAttachment")

	if not rootRigAttachment then
		return
	end

	local worldCFrame = rootRigAttachment.WorldCFrame
	local bodyHeightScale = humanoid:FindFirstChild("BodyHeightScale")
	local v3 = not (bodyHeightScale and bodyHeightScale:IsA("NumberValue")) and 1 or bodyHeightScale.Value
	local v4 = worldCFrame.LookVector * (v3 * 4)
	local position = worldCFrame.Position
	local v5 = position + v4
	local v6 = position - v4
	local raycastResult = workspace:Raycast(position, createVector(-0, -10, -0), self._raycastParams)
	local raycastResult2 = workspace:Raycast(v5, createVector(-0, -10, -0), self._raycastParams)
	local raycastResult3 = workspace:Raycast(v6, createVector(-0, -10, -0), self._raycastParams)
	local v7

	if raycastResult and raycastResult2 and raycastResult3 then
		local v8 = (raycastResult.Normal + raycastResult2.Normal + raycastResult3.Normal) / 3
		local unit

		if v8.Magnitude > 0.001 then
			unit = v8.Unit
		else
			unit = raycastResult.Normal
		end

		local distance = (raycastResult.Distance + raycastResult2.Distance + raycastResult3.Distance) / 3
		v7 = {
			Normal = unit,
			Position = raycastResult.Position,
			Distance = distance
		}
	end

	return v7 or workspace:Raycast(
		humanoidRootPart.Position,
		-humanoidRootPart.CFrame.UpVector * humanoidRootPart.Size.Y * humanoid.HipHeight,
		self._raycastParams
	)
end

function v:_GetRaycastCeilingResult()
	local parent = self.Instance.Parent
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local humanoid = parent:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local rootRigAttachment = humanoidRootPart:FindFirstChild("RootRigAttachment")

	if not rootRigAttachment then
		return
	end

	local worldCFrame = rootRigAttachment.WorldCFrame
	return (workspace:Raycast(worldCFrame.Position, createVector(0, 10, 0), self._raycastParams))
end

function v:_GetSlopeAngle()
	local _GetFloorResult = self:_GetFloorResult()

	if not _GetFloorResult then
		return 0
	end

	local normal = _GetFloorResult.Normal
	local v3 = math.tan((math.acos((math.clamp(normal.Y, 0, 1))))) * 100
	local parent = self.Instance.Parent
	local humanoidRootPart = parent and parent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		local lookVector = humanoidRootPart.CFrame.LookVector
		local vector2 = Vector3.new(normal.X, 0, normal.Z)

		if vector2.Magnitude > 0.01 then
			if lookVector:Dot(vector2.Unit) < 0 then
				v3 = -v3
			end
		else
			v3 = 0
		end
	else
		v3 = -v3
	end

	return -v3
end

function v:Stop()
	self:_StopSnowboard()
	self._holdingIdleTrack:Stop()
	self._Janitor:Destroy()
end

return v