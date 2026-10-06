local createVector = vector.create
local VRService = game:GetService("VRService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local commonUtils = script.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local v = nil
local localPlayer = Players.LocalPlayer
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local userFlag = FlagUtil.getUserFlag("UserRaycastUpdateAPI")

local function IsFinite(p: number)
	return p == p and p ~= 1e999 and p ~= -1e999
end

local function IsFiniteVector3(data)
	local x = data.x
	local v2

	if x == x and x ~= 1e999 then
		v2 = x ~= -1e999
	else
		v2 = false
	end

	if not v2 then
		return v2
	end

	local y = data.y

	if y == y and y ~= 1e999 then
		v2 = y ~= -1e999
	else
		v2 = false
	end

	if not v2 then
		return v2
	end

	local z = data.z

	if z == z and z ~= 1e999 then
		return z ~= -1e999
	else
		return false
	end

	return v2
end

local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Name = "MovementUpdate"
bindableEvent.Parent = script
coroutine.wrap(function()
	local pathDisplay = script.Parent:WaitForChild("PathDisplay")

	if pathDisplay then
		local module = require(pathDisplay)
		v = module
	end
end)()
local BaseCharacterController = require(script.Parent:WaitForChild("BaseCharacterController"))
local object = setmetatable({}, BaseCharacterController)
object.__index = object

function object.new(CONTROL_ACTION_PRIORITY)
	local self = setmetatable(BaseCharacterController.new(), object)
	self.CONTROL_ACTION_PRIORITY = CONTROL_ACTION_PRIORITY
	self.navigationRequestedConn = nil
	self.heartbeatConn = nil
	self.currentDestination = nil
	self.currentPath = nil
	self.currentPoints = nil
	self.currentPointIdx = 0
	self.expectedTimeToNextPoint = 0
	self.timeReachedLastPoint = tick()
	self.moving = false
	self.isJumpBound = false
	self.moveLatch = false
	self.userCFrameEnabledConn = nil
	return self
end

function object:SetLaserPointerMode(p)
	pcall(function()
		StarterGui:SetCore("VRLaserPointerMode", p)
	end)
end

function object:GetLocalHumanoid()
	local character = localPlayer.Character

	if not character then
		return
	end

	for _, humanoid in pairs(character:GetChildren()) do
		if humanoid:IsA("Humanoid") then
			return humanoid
		end
	end

	return nil
end

function object:HasBothHandControllers()
	return VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand) and VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand)
end

function object:HasAnyHandControllers()
	return VRService:GetUserCFrameEnabled(Enum.UserCFrame.RightHand) or VRService:GetUserCFrameEnabled(Enum.UserCFrame.LeftHand)
end

function object:IsMobileVR()
	return UserInputService.TouchEnabled
end

function object:HasGamepad()
	return UserInputService.GamepadEnabled
end

function object:ShouldUseNavigationLaser()
	if self:IsMobileVR() then
		return true
	end

	if self:HasBothHandControllers() then
		return false
	end

	if self:HasAnyHandControllers() then
		return true
	end

	return not self:HasGamepad()
end

function object:StartFollowingPath(p)
	currentPath = p
	currentPoints = currentPath:GetPointCoordinates()
	currentPointIdx = 1
	moving = true
	timeReachedLastPoint = tick()
	local localHumanoid = self:GetLocalHumanoid()

	if localHumanoid and localHumanoid.Torso and #currentPoints >= 1 then
		expectedTimeToNextPoint = (currentPoints[1] - localHumanoid.Torso.Position).magnitude / localHumanoid.WalkSpeed
	end

	bindableEvent:Fire("targetPoint", self.currentDestination)
end

function object:GoToPoint(p)
	currentPath = true
	currentPoints = { p }
	currentPointIdx = 1
	moving = true
	local localHumanoid = self:GetLocalHumanoid()
	local v2 = (localHumanoid.Torso.Position - p).magnitude / localHumanoid.WalkSpeed
	timeReachedLastPoint = tick()
	expectedTimeToNextPoint = v2
	bindableEvent:Fire("targetPoint", p)
end

function object:StopFollowingPath()
	currentPath = nil
	currentPoints = nil
	currentPointIdx = 0
	moving = false
	self.moveVector = createVector(0, 0, 0)
end

function object:TryComputePath(total: Vector3, total2: Vector3)
	local v2 = nil
	local count = 0

	while not v2 and count < 5 do
		v2 = PathfindingService:ComputeSmoothPathAsync(total, total2, 200)
		count += 1

		if v2.Status == Enum.PathStatus.ClosestNoPath or v2.Status == Enum.PathStatus.ClosestOutOfRange then
			return nil
		end

		if v2 and v2.Status == Enum.PathStatus.FailStartNotEmpty then
			total += (total2 - total).Unit
			v2 = nil
		end

		if not (v2 and v2.Status == Enum.PathStatus.FailFinishNotEmpty) then
			continue
		end

		total2 += createVector(0, 1, 0)
		v2 = nil
	end

	return v2
end

function object:OnNavigationRequest(cframe: CFrame, _: CFrame)
	local position = cframe.Position
	local currentDestination = self.currentDestination
	local x = position.x
	local v2

	if x == x and x ~= 1e999 then
		v2 = x ~= -1e999
	else
		v2 = false
	end

	if v2 then
		local y = position.y

		if y == y and y ~= 1e999 then
			v2 = y ~= -1e999
		else
			v2 = false
		end

		if v2 then
			local z = position.z

			if z == z and z ~= 1e999 then
				v2 = z ~= -1e999
			else
				v2 = false
			end
		end
	end

	if not v2 then
		return
	end

	self.currentDestination = position
	local localHumanoid = self:GetLocalHumanoid()

	if not (localHumanoid and localHumanoid.Torso) then
		return
	end

	local position2 = localHumanoid.Torso.Position

	if (self.currentDestination - position2).magnitude < 12 then
		self:GoToPoint(self.currentDestination)
	elseif currentDestination and not ((self.currentDestination - currentDestination).magnitude > 4) then
		if moving then
			self.currentPoints[#currentPoints] = self.currentDestination
		else
			self:GoToPoint(self.currentDestination)
		end
	else
		local v3 = self:TryComputePath(position2, self.currentDestination)

		if v3 then
			self:StartFollowingPath(v3)

			if v then
				v.setCurrentPoints(self.currentPoints)
				v.renderPath()
			end
		else
			self:StopFollowingPath()

			if v then
				v.clearRenderedPath()
			end
		end
	end
end

function object:OnJumpAction(_, p2, _)
	if p2 == Enum.UserInputState.Begin then
		self.isJumping = true
	end

	return Enum.ContextActionResult.Sink
end

function object:BindJumpAction(p)
	if p then
		if not self.isJumpBound then
			self.isJumpBound = true
			ContextActionService:BindActionAtPriority("VRJumpAction", function()
				return self:OnJumpAction()
			end, false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.ButtonA)
		end
	elseif self.isJumpBound then
		self.isJumpBound = false
		ContextActionService:UnbindAction("VRJumpAction")
	end
end

function object:ControlCharacterGamepad(_, p, p2)
	if p2.KeyCode ~= Enum.KeyCode.Thumbstick1 then
		return
	end

	if p == Enum.UserInputState.Cancel then
		self.moveVector = createVector(0, 0, 0)
		return
	end

	if p == Enum.UserInputState.End then
		self.moveVector = createVector(0, 0, 0)

		if self:ShouldUseNavigationLaser() then
			self:BindJumpAction(false)
			self:SetLaserPointerMode("Navigation")
		end

		if self.moveLatch then
			self.moveLatch = false
			bindableEvent:Fire("offtrack")
		end
	else
		self:StopFollowingPath()

		if v then
			v.clearRenderedPath()
		end

		if self:ShouldUseNavigationLaser() then
			self:BindJumpAction(true)
			self:SetLaserPointerMode("Hidden")
		end

		if p2.Position.magnitude > 0.22 then
			self.moveVector = Vector3.new(p2.Position.X, 0, -p2.Position.Y)

			if self.moveVector.magnitude > 0 then
				self.moveVector = self.moveVector.unit * math.min(1, p2.Position.magnitude)
			end

			self.moveLatch = true
		end
	end

	return Enum.ContextActionResult.Sink
end

function object:OnHeartbeat(p)
	local moveVector = self.moveVector
	local localHumanoid = self:GetLocalHumanoid()

	if not (localHumanoid and localHumanoid.Torso) then
		return
	end

	if self.moving and self.currentPoints then
		local position = localHumanoid.Torso.Position
		local v2 = (currentPoints[1] - position) * createVector(1, 0, 1)
		local magnitude = v2.magnitude
		local v3 = v2 / magnitude

		if magnitude < 1 then
			local currentPoint = currentPoints[1]
			local total = 0

			for k, v4 in pairs(currentPoints) do
				if k == 1 then
					continue
				end

				total += (v4 - currentPoint).magnitude / localHumanoid.WalkSpeed
				currentPoint = v4
			end

			table.remove(currentPoints, 1)
			currentPointIdx += 1

			if #currentPoints == 0 then
				self:StopFollowingPath()

				if v then
					v.clearRenderedPath()
				end

				return
			else
				if v then
					v.setCurrentPoints(currentPoints)
					v.renderPath()
				end

				expectedTimeToNextPoint = (currentPoints[1] - position).magnitude / localHumanoid.WalkSpeed
				timeReachedLastPoint = tick()
			end
		else
			if userFlag then
				raycastParams.FilterDescendantsInstances = {
					game.Players.LocalPlayer.Character,
					workspace.CurrentCamera
				}
				local raycastResult = workspace:Raycast(position - createVector(0, 1, 0), v3 * 3, raycastParams)

				if raycastResult then
					local v4 = workspace:Raycast(
						raycastResult.Position + v3 * 0.5 + createVector(0, 100, 0),
						createVector(-0, -100, -0),
						raycastParams
					).Position.Y - position.Y

					if v4 < 6 and v4 > -2 then
						localHumanoid.Jump = true
					end
				end
			else
				local v4 = { game.Players.LocalPlayer.Character, workspace.CurrentCamera }
				local ray = Ray.new(position - createVector(0, 1, 0), v3 * 3)
				local part, v5, _ = workspace:FindPartOnRayWithIgnoreList(ray, v4)

				if part then
					local ray2 = Ray.new(v5 + v3 * 0.5 + createVector(0, 100, 0), createVector(-0, -100, -0))
					local _, v6, _ = workspace:FindPartOnRayWithIgnoreList(ray2, v4)
					local v7 = v6.Y - position.Y

					if v7 < 6 and v7 > -2 then
						localHumanoid.Jump = true
					end
				end
			end

			if tick() - timeReachedLastPoint > expectedTimeToNextPoint + 2 then
				self:StopFollowingPath()

				if v then
					v.clearRenderedPath()
				end

				bindableEvent:Fire("offtrack")
			end

			moveVector = self.moveVector:Lerp(v3, p * 10)
		end
	end

	local x = moveVector.x
	local v2

	if x == x and x ~= 1e999 then
		v2 = x ~= -1e999
	else
		v2 = false
	end

	if v2 then
		local y = moveVector.y

		if y == y and y ~= 1e999 then
			v2 = y ~= -1e999
		else
			v2 = false
		end

		if v2 then
			local z = moveVector.z

			if z == z and z ~= 1e999 then
				v2 = z ~= -1e999
			else
				v2 = false
			end
		end
	end

	if v2 then
		self.moveVector = moveVector
	end
end

function object:OnUserCFrameEnabled()
	if self:ShouldUseNavigationLaser() then
		self:BindJumpAction(false)
		self:SetLaserPointerMode("Navigation")
	else
		self:BindJumpAction(true)
		self:SetLaserPointerMode("Hidden")
	end
end

function object:Enable(p)
	self.moveVector = createVector(0, 0, 0)
	self.isJumping = false

	if p then
		self.navigationRequestedConn = VRService.NavigationRequested:Connect(function(p2, p3)
			self:OnNavigationRequest(p2, p3)
		end)
		self.heartbeatConn = RunService.Heartbeat:Connect(function(dt)
			self:OnHeartbeat(dt)
		end)
		ContextActionService:BindAction("MoveThumbstick", function(p2, p3, p4)
			return self:ControlCharacterGamepad(p2, p3, p4)
		end, false, self.CONTROL_ACTION_PRIORITY, Enum.KeyCode.Thumbstick1)
		ContextActionService:BindActivate(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)
		self.userCFrameEnabledConn = VRService.UserCFrameEnabled:Connect(function()
			self:OnUserCFrameEnabled()
		end)
		self:OnUserCFrameEnabled()
		VRService:SetTouchpadMode(Enum.VRTouchpad.Left, Enum.VRTouchpadMode.VirtualThumbstick)
		VRService:SetTouchpadMode(Enum.VRTouchpad.Right, Enum.VRTouchpadMode.ABXY)
		self.enabled = true
	else
		self:StopFollowingPath()
		ContextActionService:UnbindAction("MoveThumbstick")
		ContextActionService:UnbindActivate(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)
		self:BindJumpAction(false)
		self:SetLaserPointerMode("Disabled")

		if self.navigationRequestedConn then
			self.navigationRequestedConn:Disconnect()
			self.navigationRequestedConn = nil
		end

		if self.heartbeatConn then
			self.heartbeatConn:Disconnect()
			self.heartbeatConn = nil
		end

		if self.userCFrameEnabledConn then
			self.userCFrameEnabledConn:Disconnect()
			self.userCFrameEnabledConn = nil
		end

		self.enabled = false
	end
end

return object