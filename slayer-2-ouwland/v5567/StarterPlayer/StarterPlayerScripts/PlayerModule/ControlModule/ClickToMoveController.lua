local createVector = vector.create
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserExcludeNonCollidableForPathfinding")
end)
local v = success and result
local success2, result2 = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserClickToMoveSupportAgentCanClimb2")
end)
local v2 = success2 and result2
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local CommonUtils = require(script.Parent.Parent:WaitForChild("CommonUtils"))
local flagUtil = CommonUtils.get("FlagUtil")
local userFlag = flagUtil.getUserFlag("UserRaycastUpdateAPI2")
local userFlag2 = flagUtil.getUserFlag("UserPlayerScriptsCTMDirectPlayerData")
local userFlag3 = flagUtil.getUserFlag("UserPSIASClickToMoveRelaxTeleport")
local userFlag4 = flagUtil.getUserFlag("UserPlayerScriptsRefactor2")
local userFlag5 = flagUtil.getUserFlag("UserPlayerScriptsFireThroughScriptableBindings")
local userFlag6 = flagUtil.getUserFlag("UserPlayerScriptsSAuthDirectAPIs2")
local userFlag7 = flagUtil.getUserFlag("UserDoubleJumpButtonFix")
local characterContext = script.Parent.Parent:WaitForChild("InputContexts"):WaitForChild("CharacterContext")
local clickToMoveAction = characterContext:WaitForChild("ClickToMoveAction")
local clickToMovePositionAction = characterContext:WaitForChild("ClickToMovePositionAction")
local v3 = true
local v4 = true
local v5 = false
local v6 = 1
local v7 = 8
local localPlayer = Players.LocalPlayer
local ClickToMoveDisplay = require(script.Parent:WaitForChild("ClickToMoveDisplay"))
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v8 = {}

if not userFlag then
	local FindCharacterAncestor

	FindCharacterAncestor = function(parent)
		if not parent then
			return
		end

		local humanoid = parent:FindFirstChildOfClass("Humanoid")

		if humanoid then
			return parent, humanoid
		end

		return FindCharacterAncestor(parent.Parent)
	end

	v8.FindCharacterAncestor = FindCharacterAncestor
	local Raycast

	Raycast = function(p, flag: boolean, parts)
		local parts2 = parts or {}
		local part, v9, v10, v11 = Workspace:FindPartOnRayWithIgnoreList(p, parts2)

		if not part then
			return nil, nil
		end

		if not flag or part.CanCollide ~= false then
			return part, v9, v10, v11
		end

		local humanoid

		if part then
			humanoid = part:FindFirstChildOfClass("Humanoid")

			if not humanoid then
				local v12
				v12, humanoid = FindCharacterAncestor(part.Parent)
			end
		end

		if humanoid == nil then
			table.insert(parts2, part)
			return Raycast(p, flag, parts2)
		end

		return part, v9, v10, v11
	end

	v8.Raycast = Raycast
end

local v9 = {}

local function findPlayerHumanoid(player)
	local character = player and player.Character

	if not character then
		return
	end

	local v10 = v9[player]

	if v10 and v10.Parent == character then
		return v10
	end

	v9[player] = nil
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		v9[player] = humanoid
	end

	return humanoid
end

local result3 = nil
local v10 = nil
local connection = nil
local connection2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCharacter()
	return localPlayer and localPlayer.Character
end

local function UpdateIgnoreTag(p)
	if p == v10 then
		return
	end

	if connection then
		connection:Disconnect()
		connection = nil
	end

	if connection2 then
		connection2:Disconnect()
		connection2 = nil
	end

	v10 = p
	result3 = { localPlayer and localPlayer.Character }

	if v10 ~= nil then
		local tagged = CollectionService:GetTagged(v10)

		for _, v11 in ipairs(tagged) do
			table.insert(result3, v11)
		end

		connection = CollectionService:GetInstanceAddedSignal(v10):Connect(function(p2)
			table.insert(result3, p2)
		end)
		connection2 = CollectionService:GetInstanceRemovedSignal(v10):Connect(function(p2)
			for i = 1, #result3 do
				if result3[i] ~= p2 then
					continue
				end

				result3[i] = result3[#result3]
				table.remove(result3)
				break
			end
		end)
	end
end

local function getIgnoreList()
	if result3 then
		return result3
	end

	result3 = {}
	assert(result3, "")
	table.insert(result3, localPlayer and localPlayer.Character)
	return result3
end

local function minV(vector2: Vector3, vector3: Vector3)
	return (Vector3.new(
		math.min(vector2.X, vector3.X),
		math.min(vector2.Y, vector3.Y),
		(math.min(vector2.Z, vector3.Z))
	))
end

local function maxV(data, data2)
	return (Vector3.new(math.max(data.X, data2.X), math.max(data.Y, data2.Y), (math.max(data.Z, data2.Z))))
end

local function getCollidableExtentsSize(folder)
	if folder == nil or folder.PrimaryPart == nil then
		return
	end

	assert(folder, "")
	assert(folder.PrimaryPart, "")
	local inverse = folder.PrimaryPart.CFrame:Inverse()
	local vector2 = createVector(1e999, 1e999, 1e999)
	local vector3 = createVector(-1e999, -1e999, -1e999)

	for _, part in pairs(folder:GetDescendants()) do
		if not (part:IsA("BasePart") and part.CanCollide) then
			continue
		end

		local v11 = inverse * part.CFrame
		local vector4 = Vector3.new(part.Size.X / 2, part.Size.Y / 2, part.Size.Z / 2)
		local v12 = {
			Vector3.new(vector4.X, vector4.Y, vector4.Z),
			Vector3.new(vector4.X, vector4.Y, -vector4.Z),
			Vector3.new(vector4.X, -vector4.Y, vector4.Z),
			Vector3.new(vector4.X, -vector4.Y, -vector4.Z),
			Vector3.new(-vector4.X, vector4.Y, vector4.Z),
			Vector3.new(-vector4.X, vector4.Y, -vector4.Z),
			Vector3.new(-vector4.X, -vector4.Y, vector4.Z),
			(Vector3.new(-vector4.X, -vector4.Y, -vector4.Z))
		}

		for _, v13 in ipairs(v12) do
			local v14 = v11 * v13
			vector2 = Vector3.new(math.min(vector2.X, v14.X), math.min(vector2.Y, v14.Y), (math.min(vector2.Z, v14.Z)))
			vector3 = Vector3.new(math.max(vector3.X, v14.X), math.max(vector3.Y, v14.Y), (math.max(vector3.Z, v14.Z)))
		end
	end

	local v11 = vector3 - vector2

	if v11.X < 0 or v11.Y < 0 or v11.Z < 0 then
		return nil
	end

	return v11
end

local function Pather(p, targetSurfaceNormal, directPath: boolean?)
	local class = {}
	local directPath2

	if directPath == nil then
		directPath2 = v5
		directPath = true
	else
		directPath2 = directPath
	end

	class.Cancelled = false
	class.Started = false
	class.Finished = Instance.new("BindableEvent")
	class.PathFailed = Instance.new("BindableEvent")
	class.PathComputing = false
	class.PathComputed = false
	class.OriginalTargetPoint = p
	class.TargetPoint = p
	class.TargetSurfaceNormal = targetSurfaceNormal
	class.DiedConn = nil
	class.SeatedConn = nil
	class.BlockedConn = nil
	class.TeleportedConn = nil
	class.CurrentPoint = 0
	class.HumanoidOffsetFromPath = createVector(0, 0, 0)
	class.CurrentWaypointPosition = nil
	class.CurrentWaypointPlaneNormal = createVector(0, 0, 0)
	class.CurrentWaypointPlaneDistance = 0
	class.CurrentWaypointNeedsJump = false
	class.CurrentHumanoidPosition = createVector(0, 0, 0)
	class.CurrentHumanoidVelocity = 0
	class.NextActionMoveDirection = createVector(0, 0, 0)
	class.NextActionJump = false
	class.Timeout = 0
	local localPlayer2 = localPlayer
	local character = localPlayer2 and localPlayer2.Character
	local humanoid

	if character then
		humanoid = v9[localPlayer2]

		if not humanoid or humanoid.Parent ~= character then
			v9[localPlayer2] = nil
			humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				v9[localPlayer2] = humanoid
			end
		end
	end

	class.Humanoid = humanoid
	class.OriginPoint = nil
	class.AgentCanFollowPath = false
	class.DirectPath = false
	class.DirectPathRiseFirst = false
	class.stopTraverseFunc = nil
	class.setPointFunc = nil
	class.pointList = nil
	local rootPart = class.Humanoid and class.Humanoid.RootPart

	if rootPart then
		class.OriginPoint = rootPart.CFrame.Position
		local agentRadius = 2
		local agentHeight = 5
		local agentCanJump = true
		local seatPart = class.Humanoid.SeatPart

		if seatPart and seatPart:IsA("VehicleSeat") then
			local model = seatPart:FindFirstAncestorOfClass("Model")

			if model then
				local primaryPart = model.PrimaryPart
				model.PrimaryPart = seatPart

				if directPath then
					local extentsSize = model:GetExtentsSize()
					agentRadius = v6 * 0.5 * math.sqrt(extentsSize.X * extentsSize.X + extentsSize.Z * extentsSize.Z)
					agentHeight = v6 * extentsSize.Y
					class.AgentCanFollowPath = true
					class.DirectPath = directPath
					agentCanJump = false
				end

				model.PrimaryPart = primaryPart
			end
		else
			local extentsSize = nil

			if v then
				local character2 = GetCharacter() -- equivalent call inferred; original call site unknown

				if character2 ~= nil then
					extentsSize = getCollidableExtentsSize(character2)
				end
			end

			if extentsSize == nil then
				extentsSize = (localPlayer and localPlayer.Character):GetExtentsSize()
			end

			assert(extentsSize, "")
			agentRadius = v6 * 0.5 * math.sqrt(extentsSize.X * extentsSize.X + extentsSize.Z * extentsSize.Z)
			agentHeight = v6 * extentsSize.Y
			agentCanJump = class.Humanoid.JumpPower > 0
			class.AgentCanFollowPath = true
			class.DirectPath = directPath2
			class.DirectPathRiseFirst = class.Humanoid.Sit
		end

		if v2 then
			class.pathResult = PathfindingService:CreatePath({
				AgentRadius = agentRadius,
				AgentHeight = agentHeight,
				AgentCanJump = agentCanJump,
				AgentCanClimb = true
			})
		else
			class.pathResult = PathfindingService:CreatePath({
				AgentRadius = agentRadius,
				AgentHeight = agentHeight,
				AgentCanJump = agentCanJump
			})
		end
	end

	function class:Cleanup()
		if class.stopTraverseFunc then
			class.stopTraverseFunc()
			class.stopTraverseFunc = nil
		end

		if class.BlockedConn then
			class.BlockedConn:Disconnect()
			class.BlockedConn = nil
		end

		if class.DiedConn then
			class.DiedConn:Disconnect()
			class.DiedConn = nil
		end

		if class.SeatedConn then
			class.SeatedConn:Disconnect()
			class.SeatedConn = nil
		end

		if class.TeleportedConn then
			class.TeleportedConn:Disconnect()
			class.TeleportedConn = nil
		end

		class.Started = false
	end

	function class:Cancel()
		class.Cancelled = true
		class:Cleanup()
	end

	function class:IsActive()
		return class.AgentCanFollowPath and class.Started and not class.Cancelled
	end

	function class:OnPathInterrupted()
		class.Cancelled = true
		class:OnPointReached(false)
	end

	function class:ComputePath()
		if class.OriginPoint then
			if class.PathComputed or class.PathComputing then
				return
			end

			class.PathComputing = true

			if class.AgentCanFollowPath then
				if class.DirectPath then
					class.pointList = {
						PathWaypoint.new(class.OriginPoint, Enum.PathWaypointAction.Walk),
						PathWaypoint.new(
							class.TargetPoint,
							class.DirectPathRiseFirst and Enum.PathWaypointAction.Jump or Enum.PathWaypointAction.Walk
						)
					}
					class.PathComputed = true
				else
					class.pathResult:ComputeAsync(class.OriginPoint, class.TargetPoint)
					class.pointList = class.pathResult:GetWaypoints()
					class.BlockedConn = class.pathResult.Blocked:Connect(function(p2)
						class:OnPathBlocked(p2)
					end)
					class.PathComputed = class.pathResult.Status == Enum.PathStatus.Success
				end
			end

			class.PathComputing = false
		end
	end

	function class:IsValidPath()
		class:ComputePath()
		return class.PathComputed and class.AgentCanFollowPath
	end

	class.Recomputing = false

	function class:OnPathBlocked(p2)
		if not (class.CurrentPoint <= p2) or class.Recomputing then
			return
		end

		class.Recomputing = true

		if class.stopTraverseFunc then
			class.stopTraverseFunc()
			class.stopTraverseFunc = nil
		end

		class.OriginPoint = class.Humanoid.RootPart.CFrame.Position
		class.pathResult:ComputeAsync(class.OriginPoint, class.TargetPoint)
		class.pointList = class.pathResult:GetWaypoints()

		if #class.pointList > 0 then
			class.HumanoidOffsetFromPath = class.pointList[1].Position - class.OriginPoint
		end

		class.PathComputed = class.pathResult.Status == Enum.PathStatus.Success

		if v3 then
			local v13 = class
			local v14 = class
			local pathDisplay, setPointFunc = ClickToMoveDisplay.CreatePathDisplay(class.pointList)
			v13.stopTraverseFunc = pathDisplay
			v14.setPointFunc = setPointFunc
		end

		if class.PathComputed then
			class.CurrentPoint = 1
			class:OnPointReached(true)
		else
			class.PathFailed:Fire()
			class:Cleanup()
		end

		class.Recomputing = false
	end

	function class:OnRenderStepped(p2: number)
		if class.Started and not class.Cancelled then
			class.Timeout += p2
			local timeout = class.Timeout

			if v7 < timeout then
				class:OnPointReached(false)
				return
			end

			class.CurrentHumanoidPosition = class.Humanoid.RootPart.Position + class.HumanoidOffsetFromPath
			class.CurrentHumanoidVelocity = class.Humanoid.RootPart.Velocity

			while class.Started and class:IsCurrentWaypointReached() do
				class:OnPointReached(true)
			end

			if class.Started then
				class.NextActionMoveDirection = class.CurrentWaypointPosition - class.CurrentHumanoidPosition

				if class.NextActionMoveDirection.Magnitude > 1e-6 then
					class.NextActionMoveDirection = class.NextActionMoveDirection.Unit
				else
					class.NextActionMoveDirection = createVector(0, 0, 0)
				end

				if class.CurrentWaypointNeedsJump then
					class.NextActionJump = true
					class.CurrentWaypointNeedsJump = false
				else
					class.NextActionJump = false
				end
			end
		end
	end

	function class:IsCurrentWaypointReached()
		local v13 = class.CurrentWaypointPlaneNormal == createVector(0, 0, 0) or class.CurrentWaypointPlaneNormal:Dot(class.CurrentHumanoidPosition) - class.CurrentWaypointPlaneDistance < math.max(
			1,
			0.0625 * -class.CurrentWaypointPlaneNormal:Dot(class.CurrentHumanoidVelocity)
		)

		if v13 then
			class.CurrentWaypointPosition = nil
			class.CurrentWaypointPlaneNormal = createVector(0, 0, 0)
			class.CurrentWaypointPlaneDistance = 0
		end

		return v13
	end

	function class:OnPointReached(p2)
		if p2 and not class.Cancelled then
			if class.setPointFunc then
				class.setPointFunc(class.CurrentPoint)
			end

			local v13 = class.CurrentPoint + 1

			if #class.pointList < v13 then
				if class.stopTraverseFunc then
					class.stopTraverseFunc()
				end

				class.Finished:Fire()
				class:Cleanup()
			else
				local v14 = class.pointList[class.CurrentPoint]
				local v15 = class.pointList[v13]
				local state = class.Humanoid:GetState()

				if state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
					local v16 = v15.Action == Enum.PathWaypointAction.Jump

					if not v16 and class.CurrentPoint > 1 then
						local v17 = class.pointList[class.CurrentPoint - 1]
						local v18 = v14.Position - v17.Position
						local v19 = v15.Position - v14.Position
						v16 = Vector2.new(v18.x, v18.z).Unit:Dot(Vector2.new(v19.x, v19.z).Unit) < 0.996
					end

					if v16 then
						class.Humanoid.FreeFalling:Wait()
						wait(0.1)
					end
				end

				class:MoveToNextWayPoint(v14, v15, v13)
			end
		else
			class.PathFailed:Fire()
			class:Cleanup()
		end
	end

	function class:MoveToNextWayPoint(p2, data, currentPoint: number)
		class.CurrentWaypointPlaneNormal = p2.Position - data.Position

		if not v2 or data.Label ~= "Climb" then
			class.CurrentWaypointPlaneNormal = Vector3.new(
				class.CurrentWaypointPlaneNormal.X,
				0,
				class.CurrentWaypointPlaneNormal.Z
			)
		end

		if class.CurrentWaypointPlaneNormal.Magnitude > 1e-6 then
			class.CurrentWaypointPlaneNormal = class.CurrentWaypointPlaneNormal.Unit
			class.CurrentWaypointPlaneDistance = class.CurrentWaypointPlaneNormal:Dot(data.Position)
		else
			class.CurrentWaypointPlaneNormal = createVector(0, 0, 0)
			class.CurrentWaypointPlaneDistance = 0
		end

		class.CurrentWaypointNeedsJump = data.Action == Enum.PathWaypointAction.Jump
		class.CurrentWaypointPosition = data.Position
		class.CurrentPoint = currentPoint
		class.Timeout = 0
	end

	function class:Start(p2)
		if not class.AgentCanFollowPath then
			class.PathFailed:Fire()
			return
		end

		if class.Started then
			return
		end

		class.Started = true
		ClickToMoveDisplay.CancelFailureAnimation()

		if v3 and (p2 == nil or p2) then
			local v13 = class
			local v14 = class
			local pathDisplay, setPointFunc = ClickToMoveDisplay.CreatePathDisplay(
				class.pointList,
				class.OriginalTargetPoint
			)
			v13.stopTraverseFunc = pathDisplay
			v14.setPointFunc = setPointFunc
		end

		if #class.pointList > 0 then
			class.HumanoidOffsetFromPath = Vector3.new(0, class.pointList[1].Position.Y - class.OriginPoint.Y, 0)
			class.CurrentHumanoidPosition = class.Humanoid.RootPart.Position + class.HumanoidOffsetFromPath
			class.CurrentHumanoidVelocity = class.Humanoid.RootPart.Velocity
			class.SeatedConn = class.Humanoid.Seated:Connect(function(_, _)
				class:OnPathInterrupted()
			end)
			class.DiedConn = class.Humanoid.Died:Connect(function()
				class:OnPathInterrupted()
			end)

			if userFlag3 then
				class.lastPosition = class.Humanoid.RootPart.CFrame.Position
				class.TeleportedConn = class.Humanoid.RootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
					local position = class.Humanoid.RootPart.CFrame.Position
					local magnitude = (position - class.lastPosition).Magnitude
					class.lastPosition = position

					if class.Humanoid.WalkSpeed < magnitude then
						class:OnPathInterrupted()
					end
				end)
			else
				class.TeleportedConn = class.Humanoid.RootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
					class:OnPathInterrupted()
				end)
			end

			class.CurrentPoint = 1
			class:OnPointReached(true)
		else
			class.PathFailed:Fire()

			if class.stopTraverseFunc then
				class.stopTraverseFunc()
			end
		end
	end

	local v13 = class.TargetPoint + class.TargetSurfaceNormal * 1.5

	if userFlag then
		local v14 = raycastParams

		if not result3 then
			result3 = {}
			assert(result3, "")
			table.insert(result3, localPlayer and localPlayer.Character)
		end

		v14.FilterDescendantsInstances = result3
		local raycastResult = Workspace:Raycast(v13, createVector(-0, -50, -0), raycastParams)

		if raycastResult then
			class.TargetPoint = raycastResult.Position
		end
	else
		local ray = Ray.new(v13, createVector(0, -50, 0))

		if not result3 then
			result3 = {}
			assert(result3, "")
			table.insert(result3, localPlayer and localPlayer.Character)
		end

		local part, targetPoint = Workspace:FindPartOnRayWithIgnoreList(ray, result3)

		if part then
			class.TargetPoint = targetPoint
		end
	end

	class:ComputePath()
	return class
end

local function CheckAlive()
	local localPlayer2 = localPlayer
	local character = localPlayer2 and localPlayer2.Character
	local humanoid

	if not character then
		return humanoid ~= nil and humanoid.Health > 0
	end

	humanoid = v9[localPlayer2]

	if not humanoid or humanoid.Parent ~= character then
		v9[localPlayer2] = nil
		humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			v9[localPlayer2] = humanoid
		end
	end

	return humanoid ~= nil and humanoid.Health > 0
end

local function GetEquippedTool(instance)
	if instance ~= nil then
		for _, tool in pairs(instance:GetChildren()) do
			if tool:IsA("Tool") then
				return tool
			end
		end
	end
end

local function DisconnectEvent(connection3)
	if connection3 then
		connection3:Disconnect()
	end
end

local function calculateLocalMoveVector(nextActionMoveDirection: Vector3)
	local vector2 = Vector3.new(nextActionMoveDirection.X, 0, nextActionMoveDirection.Z)

	if vector2.Magnitude < 1e-6 then
		return Vector2.zero
	end

	local unit = vector2.Unit
	local currentCamera = Workspace.CurrentCamera

	if not currentCamera then
		return Vector2.new(unit.X, -unit.Z)
	end

	local _, v11, _ = currentCamera.CFrame:ToEulerAnglesYXZ()
	local vectorToObjectSpace = CFrame.Angles(0, v11, 0):VectorToObjectSpace(unit)
	return Vector2.new(vectorToObjectSpace.X, -vectorToObjectSpace.Z)
end

local ClickToMoveController = {}
ClickToMoveController.__index = ClickToMoveController

function ClickToMoveController.new(_)
	local self = setmetatable({}, ClickToMoveController)
	self.mouse2DownTime = tick()
	self.mouse2DownPos = Vector2.new()
	self.mouse2UpTime = tick()
	self.humanoidDiedConn = nil
	self.characterChildAddedConn = nil
	self.onCharacterAddedConn = nil
	self.characterChildRemovedConn = nil
	self.renderSteppedConn = nil
	self.menuOpenedConnection = nil
	self.preferredInputChangedConnection = nil

	if not userFlag7 then
		self.jumpEnabled = true
	end

	self.clickPressedConn = nil
	self.clickReleasedConn = nil
	self.shouldCleanupPath = false

	if not userFlag2 then
		self.lastPatherMoveVector = Vector2.new(0, 0)
	end

	self.lastPatherJumped = false
	self.playerData = nil
	self.running = false
	return self
end

local v11 = nil
local eventConnection = nil
local eventConnection2 = nil

function ClickToMoveController:CleanupPath()
	if v11 then
		v11:Cancel()
		v11 = nil
	end

	if eventConnection then
		eventConnection:Disconnect()
		eventConnection = nil
	end

	if eventConnection2 then
		eventConnection2:Disconnect()
		eventConnection2 = nil
	end

	self.shouldCleanupPath = true
end

function ClickToMoveController:HandleMoveTo(object2, p, p2, p3, p4)
	self.shouldCleanupPath = false

	if v11 then
		self:CleanupPath()
	end

	v11 = object2
	object2:Start(p4)
	eventConnection = object2.Finished.Event:Connect(function()
		self:CleanupPath()
		local v12 = p2 and GetEquippedTool(p3)

		if v12 then
			v12:Activate()
		end
	end)
	eventConnection2 = object2.PathFailed.Event:Connect(function()
		self:CleanupPath()

		if p4 == nil or p4 then
			local v12 = v4

			if v12 then
				v12 = not (v11 and v11:IsActive())
			end

			if v12 then
				ClickToMoveDisplay.PlayFailureAnimation()
			end

			ClickToMoveDisplay.DisplayFailureWaypoint(p)
		end
	end)
end

function ClickToMoveController:ShowPathFailedFeedback(p)
	if v11 and v11:IsActive() then
		v11:Cancel()
	end

	if v4 then
		ClickToMoveDisplay.PlayFailureAnimation()
	end

	ClickToMoveDisplay.DisplayFailureWaypoint(p)
end

function ClickToMoveController:OnTap(list, vector2: Vector3?)
	local currentCamera = Workspace.CurrentCamera
	local character = localPlayer.Character
	local localPlayer2 = localPlayer
	local character2 = localPlayer2 and localPlayer2.Character
	local humanoid

	if character2 then
		humanoid = v9[localPlayer2]

		if not humanoid or humanoid.Parent ~= character2 then
			v9[localPlayer2] = nil
			humanoid = character2:FindFirstChildOfClass("Humanoid")

			if humanoid then
				v9[localPlayer2] = humanoid
			end
		end
	end

	local v13

	if humanoid == nil then
		v13 = false
	else
		v13 = humanoid.Health > 0
	end

	if not v13 then
		return
	end

	if #list == 1 or vector2 then
		if not currentCamera then
			return
		end

		local screenPointToRay = currentCamera:ScreenPointToRay(list[1].X, list[1].Y)

		if userFlag then
			local v14 = nil

			if not result3 then
				result3 = {}
				assert(result3, "")
				table.insert(result3, localPlayer and localPlayer.Character)
			end

			local parents = result3

			if not parents then
				parents = {}
			end

			while true do
				local flag = true
				raycastParams.FilterDescendantsInstances = parents
				local raycastResult = Workspace:Raycast(
					screenPointToRay.Origin,
					screenPointToRay.Direction * 1000,
					raycastParams
				)

				if raycastResult then
					local instance = raycastResult.Instance

					if not instance.CanCollide then
						local humanoid2, parent

						while true do
							humanoid2 = instance:FindFirstChildOfClass("Humanoid")
							parent = instance.Parent

							if humanoid2 or not parent then
								break
							end

							instance = parent
						end

						if humanoid2 or not parent then
							v14 = instance
						else
							table.insert(parents, parent)
							flag = false
							v14 = nil
						end
					end
				end

				if not flag then
					continue
				end

				if not (raycastResult and character) then
					return
				end

				local position = raycastResult.Position

				if vector2 then
					position = vector2
					v14 = nil
				end

				self:CleanupPath()
				local pather = Pather(position, raycastResult.Normal)

				if pather:IsValidPath() then
					self:HandleMoveTo(pather, position, v14, character)
					return
				end

				pather:Cleanup()
				self:ShowPathFailedFeedback(position)
				return
			end
		else
			local ray = Ray.new(screenPointToRay.Origin, screenPointToRay.Direction * 1000)
			local raycast = v8.Raycast

			if not result3 then
				result3 = {}
				assert(result3, "")
				table.insert(result3, localPlayer and localPlayer.Character)
			end

			local v16, v17, v18 = raycast(ray, true, result3)
			local characterAncestor, _ = v8.FindCharacterAncestor(v16)

			if vector2 then
				v17 = vector2
				characterAncestor = nil
			end

			if not (v17 and character) then
				return
			end

			self:CleanupPath()
			local pather = Pather(v17, v18)

			if pather:IsValidPath() then
				self:HandleMoveTo(pather, v17, characterAncestor, character)
				return
			end

			pather:Cleanup()
			self:ShowPathFailedFeedback(v17)
		end
	else
		local v14 = #list >= 2 and currentCamera and GetEquippedTool(character)

		if v14 then
			v14:Activate()
		end
	end
end

function ClickToMoveController:DisconnectEvents()
	local humanoidDiedConn = self.humanoidDiedConn

	if humanoidDiedConn then
		humanoidDiedConn:Disconnect()
	end

	local characterChildAddedConn = self.characterChildAddedConn

	if characterChildAddedConn then
		characterChildAddedConn:Disconnect()
	end

	local onCharacterAddedConn = self.onCharacterAddedConn

	if onCharacterAddedConn then
		onCharacterAddedConn:Disconnect()
	end

	local renderSteppedConn = self.renderSteppedConn

	if renderSteppedConn then
		renderSteppedConn:Disconnect()
	end

	local characterChildRemovedConn = self.characterChildRemovedConn

	if characterChildRemovedConn then
		characterChildRemovedConn:Disconnect()
	end

	local menuOpenedConnection = self.menuOpenedConnection

	if menuOpenedConnection then
		menuOpenedConnection:Disconnect()
	end

	local preferredInputChangedConnection = self.preferredInputChangedConnection

	if preferredInputChangedConnection then
		preferredInputChangedConnection:Disconnect()
	end

	local clickPressedConn = self.clickPressedConn

	if clickPressedConn then
		clickPressedConn:Disconnect()
	end

	local clickReleasedConn = self.clickReleasedConn

	if clickReleasedConn then
		clickReleasedConn:Disconnect()
	end
end

function ClickToMoveController:OnPreferredInputChanged()
	local character = localPlayer.Character

	if character then
		local manualActivationOnly = UserInputService.PreferredInput == Enum.PreferredInput.Touch

		for _, tool in pairs(character:GetChildren()) do
			if tool:IsA("Tool") then
				tool.ManualActivationOnly = manualActivationOnly
			end
		end
	end
end

function ClickToMoveController:OnCharacterAdded(instance)
	self:DisconnectEvents()
	self.clickPressedConn = clickToMoveAction.Pressed:Connect(function()
		local guiInset, _ = GuiService:GetGuiInset()
		local state = clickToMovePositionAction:GetState()

		if state.X == -1 and state.Y == -1 then
			return
		end

		local vector2

		if userFlag4 then
			local min = GuiService:GetInsetArea(Enum.ScreenInsets.None).Min
			vector2 = Vector2.new(state.X + min.X, state.Y + min.Y)
		else
			vector2 = Vector2.new(state.X - guiInset.X, state.Y - guiInset.Y)
		end

		self.mouse2DownPos = vector2
		self.mouse2DownTime = tick()
	end)
	self.clickReleasedConn = clickToMoveAction.Released:Connect(function()
		self.mouse2UpTime = tick()
		local mouse2DownPos = self.mouse2DownPos

		if not (self.playerData and self.playerData.actions.MoveAction) then
			return
		end

		local v12 = v11 or self.playerData.actions.MoveAction:GetState().Magnitude <= 0

		if self.mouse2UpTime - self.mouse2DownTime < 0.25 and v12 then
			self:OnTap({ mouse2DownPos })
		end
	end)
	self.menuOpenedConnection = GuiService.MenuOpened:Connect(function()
		self:CleanupPath()
	end)

	local function OnCharacterChildAdded(child)
		if UserInputService.PreferredInput == Enum.PreferredInput.Touch and child:IsA("Tool") then
			child.ManualActivationOnly = true
		end

		if child:IsA("Humanoid") then
			local humanoidDiedConn = self.humanoidDiedConn

			if humanoidDiedConn then
				humanoidDiedConn:Disconnect()
			end

			self.humanoidDiedConn = child.Died:Connect(function() end)
		end
	end

	self.characterChildAddedConn = instance.ChildAdded:Connect(function(child)
		OnCharacterChildAdded(child)
	end)
	self.characterChildRemovedConn = instance.ChildRemoved:Connect(function(tool)
		if UserInputService.PreferredInput == Enum.PreferredInput.Touch and tool:IsA("Tool") then
			tool.ManualActivationOnly = false
		end
	end)

	for _, child in pairs(instance:GetChildren()) do
		OnCharacterChildAdded(child)
	end

	self.preferredInputChangedConnection = UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		self:OnPreferredInputChanged()
	end)
end

function ClickToMoveController:Start()
	self:Enable(true)
end

function ClickToMoveController:Stop()
	self:Enable(false)
end

function ClickToMoveController:Enable(enabled: boolean, flag2: boolean, touchJumpController)
	if enabled then
		if not self.running then
			if localPlayer.Character then
				self:OnCharacterAdded(localPlayer.Character)
			end

			self.onCharacterAddedConn = localPlayer.CharacterAdded:Connect(function(character)
				self:OnCharacterAdded(character)
			end)
			self.running = true
		end

		if not userFlag7 then
			self.touchJumpController = touchJumpController

			if self.touchJumpController then
				self.touchJumpController:Enable(self.jumpEnabled)
			end
		end
	else
		if self.running then
			self:DisconnectEvents()
			self:CleanupPath()

			if UserInputService.PreferredInput == Enum.PreferredInput.Touch then
				local character = localPlayer.Character

				if character then
					for _, tool in pairs(character:GetChildren()) do
						if tool:IsA("Tool") then
							tool.ManualActivationOnly = false
						end
					end
				end
			end

			self.running = false
		end

		if not userFlag7 then
			if self.touchJumpController and not self.jumpEnabled then
				self.touchJumpController:Enable(true)
			end

			self.touchJumpController = nil
		end
	end

	clickToMoveAction.Enabled = enabled
	clickToMovePositionAction.Enabled = enabled
	self.wasdEnabled = enabled and flag2 or false
	self.enabled = enabled
end

function ClickToMoveController:Update(playerData, p)
	assert(playerData.actions.MoveAction)
	assert(playerData.actions.JumpAction)

	if not self.playerData then
		self.playerData = playerData
	end

	local v12 = v11

	if v12 then
		v12:OnRenderStepped(p)

		if v11 and v11 == v12 then
			if userFlag2 then
				local moveVector = calculateLocalMoveVector(v12.NextActionMoveDirection)

				if userFlag6 then
					local clickToMoveScriptableBinding = playerData.actions.MoveAction:FindFirstChild("ClickToMoveScriptableBinding")

					if clickToMoveScriptableBinding then
						clickToMoveScriptableBinding:Fire(moveVector)
					end
				elseif userFlag5 then
					local clickToMoveScriptableBinding = playerData.actions.MoveAction:FindFirstChild("ClickToMoveScriptableBinding")

					if clickToMoveScriptableBinding then
						local success3, _ = pcall(function()
							clickToMoveScriptableBinding.Type = Enum.InputBindingType.Scriptable
							clickToMoveScriptableBinding:Fire(moveVector)
						end)

						if not success3 then
							playerData.actions.MoveAction:Fire(moveVector)
						end
					else
						playerData.actions.MoveAction:Fire(moveVector)
					end
				else
					playerData.actions.MoveAction:Fire(moveVector)
				end

				playerData.moveVector = moveVector

				if v12.NextActionJump then
					if playerData.actions.JumpAction:GetState() ~= true then
						if userFlag6 then
							local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

							if clickToMoveScriptableBinding then
								clickToMoveScriptableBinding:Fire(true)
							end
						elseif userFlag5 then
							local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

							if clickToMoveScriptableBinding then
								local success3, _ = pcall(function()
									clickToMoveScriptableBinding.Type = Enum.InputBindingType.Scriptable
									clickToMoveScriptableBinding:Fire(true)
								end)

								if not success3 then
									playerData.actions.JumpAction:Fire(true)
								end
							else
								playerData.actions.JumpAction:Fire(true)
							end
						else
							playerData.actions.JumpAction:Fire(true)
						end
					end

					self.lastPatherJumped = true
					playerData.isJumping = true
				elseif self.lastPatherJumped then
					if playerData.actions.JumpAction:GetState() == true then
						if userFlag6 then
							local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

							if clickToMoveScriptableBinding then
								clickToMoveScriptableBinding:Fire(false)
							end
						elseif userFlag5 then
							local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

							if clickToMoveScriptableBinding then
								local success3, _ = pcall(function()
									clickToMoveScriptableBinding.Type = Enum.InputBindingType.Scriptable
									clickToMoveScriptableBinding:Fire(false)
								end)

								if not success3 then
									playerData.actions.JumpAction:Fire(false)
								end
							else
								playerData.actions.JumpAction:Fire(false)
							end
						else
							playerData.actions.JumpAction:Fire(false)
						end
					end

					self.lastPatherJumped = false
					playerData.isJumping = false
				end
			else
				local state = playerData.actions.MoveAction:GetState()
				local lastPatherMoveVector = calculateLocalMoveVector(v12.NextActionMoveDirection)

				if (state - self.lastPatherMoveVector).Magnitude > 1e-6 then
					self:CleanupPath()
					ClickToMoveDisplay.CancelFailureAnimation()
				else
					self.lastPatherMoveVector = lastPatherMoveVector

					if userFlag5 then
						local clickToMoveScriptableBinding = playerData.actions.MoveAction:FindFirstChild("ClickToMoveScriptableBinding")

						if clickToMoveScriptableBinding then
							local success3, _ = pcall(function()
								clickToMoveScriptableBinding.Type = Enum.InputBindingType.Scriptable
								clickToMoveScriptableBinding:Fire(lastPatherMoveVector)
							end)

							if not success3 then
								playerData.actions.MoveAction:Fire(lastPatherMoveVector)
							end
						else
							playerData.actions.MoveAction:Fire(lastPatherMoveVector)
						end
					else
						playerData.actions.MoveAction:Fire(lastPatherMoveVector)
					end

					if v12.NextActionJump then
						if playerData.actions.JumpAction:GetState() ~= true then
							if userFlag5 then
								local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

								if clickToMoveScriptableBinding then
									local success3, _ = pcall(function()
										clickToMoveScriptableBinding.Type = Enum.InputBindingType.Scriptable
										clickToMoveScriptableBinding:Fire(true)
									end)

									if not success3 then
										playerData.actions.JumpAction:Fire(true)
									end
								else
									playerData.actions.JumpAction:Fire(true)
								end
							else
								playerData.actions.JumpAction:Fire(true)
							end

							self.lastPatherJumped = true
						end
					elseif self.lastPatherJumped then
						if playerData.actions.JumpAction:GetState() == true then
							if userFlag5 then
								local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

								if clickToMoveScriptableBinding then
									local success3, _ = pcall(function()
										clickToMoveScriptableBinding.Type = Enum.InputBindingType.Scriptable
										clickToMoveScriptableBinding:Fire(false)
									end)

									if not success3 then
										playerData.actions.JumpAction:Fire(false)
									end
								else
									playerData.actions.JumpAction:Fire(false)
								end
							else
								playerData.actions.JumpAction:Fire(false)
							end
						end

						self.lastPatherJumped = false
					end
				end
			end
		else
			if not userFlag2 then
				self.lastPatherMoveVector = Vector2.zero
			end

			if self.lastPatherJumped then
				if playerData.actions.JumpAction:GetState() == true then
					if userFlag6 then
						local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

						if clickToMoveScriptableBinding then
							clickToMoveScriptableBinding:Fire(false)
						end
					elseif userFlag5 then
						local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

						if clickToMoveScriptableBinding then
							local success3, _ = pcall(function()
								clickToMoveScriptableBinding.Type = Enum.InputBindingType.Scriptable
								clickToMoveScriptableBinding:Fire(false)
							end)

							if not success3 then
								playerData.actions.JumpAction:Fire(false)
							end
						else
							playerData.actions.JumpAction:Fire(false)
						end
					else
						playerData.actions.JumpAction:Fire(false)
					end
				end

				self.lastPatherJumped = false
			end
		end
	end

	if self.shouldCleanupPath then
		self.shouldCleanupPath = false

		if userFlag2 then
			if userFlag6 then
				local clickToMoveScriptableBinding = playerData.actions.MoveAction:FindFirstChild("ClickToMoveScriptableBinding")

				if clickToMoveScriptableBinding then
					clickToMoveScriptableBinding:Fire(Vector2.zero)
				end
			elseif userFlag5 then
				local clickToMoveScriptableBinding = playerData.actions.MoveAction:FindFirstChild("ClickToMoveScriptableBinding")

				if clickToMoveScriptableBinding then
					local success3, _ = pcall(function()
						clickToMoveScriptableBinding.Type = Enum.InputBindingType.Scriptable
						clickToMoveScriptableBinding:Fire(Vector2.zero)
					end)

					if not success3 then
						playerData.actions.MoveAction:Fire(Vector2.zero)
					end
				else
					playerData.actions.MoveAction:Fire(Vector2.zero)
				end
			else
				playerData.actions.MoveAction:Fire(Vector2.zero)
			end

			playerData.moveVector = Vector2.zero
			self.lastPatherJumped = false

			if userFlag6 then
				local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

				if clickToMoveScriptableBinding then
					clickToMoveScriptableBinding:Fire(false)
				end
			elseif userFlag5 then
				local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

				if clickToMoveScriptableBinding then
					local success3, _ = pcall(function()
						clickToMoveScriptableBinding.Type = Enum.InputBindingType.Scriptable
						clickToMoveScriptableBinding:Fire(false)
					end)

					if not success3 then
						playerData.actions.JumpAction:Fire(false)
					end
				else
					playerData.actions.JumpAction:Fire(false)
				end
			else
				playerData.actions.JumpAction:Fire(false)
			end

			playerData.isJumping = false
		else
			self.lastPatherMoveVector = Vector2.zero

			if userFlag6 then
				local clickToMoveScriptableBinding = playerData.actions.MoveAction:FindFirstChild("ClickToMoveScriptableBinding")

				if clickToMoveScriptableBinding then
					clickToMoveScriptableBinding:Fire(Vector2.zero)
				end
			elseif userFlag5 then
				local clickToMoveScriptableBinding = playerData.actions.MoveAction:FindFirstChild("ClickToMoveScriptableBinding")

				if clickToMoveScriptableBinding then
					local success3, _ = pcall(function()
						clickToMoveScriptableBinding.Type = Enum.InputBindingType.Scriptable
						clickToMoveScriptableBinding:Fire(Vector2.zero)
					end)

					if not success3 then
						playerData.actions.MoveAction:Fire(Vector2.zero)
					end
				else
					playerData.actions.MoveAction:Fire(Vector2.zero)
				end
			else
				playerData.actions.MoveAction:Fire(Vector2.zero)
			end

			self.lastPatherJumped = false

			if userFlag6 then
				local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

				if clickToMoveScriptableBinding then
					clickToMoveScriptableBinding:Fire(false)
				end
			elseif userFlag5 then
				local clickToMoveScriptableBinding = playerData.actions.JumpAction:FindFirstChild("ClickToMoveScriptableBinding")

				if not clickToMoveScriptableBinding then
					playerData.actions.JumpAction:Fire(false)
					return
				end

				local success3, _ = pcall(function()
					clickToMoveScriptableBinding.Type = Enum.InputBindingType.Scriptable
					clickToMoveScriptableBinding:Fire(false)
				end)

				if not success3 then
					playerData.actions.JumpAction:Fire(false)
				end
			else
				playerData.actions.JumpAction:Fire(false)
			end
		end
	end
end

function ClickToMoveController.SetShowPath(_, p)
	v3 = p
end

function ClickToMoveController.GetShowPath(_)
	return v3
end

function ClickToMoveController.SetWaypointTexture(_, p)
	ClickToMoveDisplay.SetWaypointTexture(p)
end

function ClickToMoveController.GetWaypointTexture(_)
	return ClickToMoveDisplay.GetWaypointTexture()
end

function ClickToMoveController.SetWaypointRadius(_, p)
	ClickToMoveDisplay.SetWaypointRadius(p)
end

function ClickToMoveController.GetWaypointRadius(_)
	return ClickToMoveDisplay.GetWaypointRadius()
end

function ClickToMoveController.SetEndWaypointTexture(_, p)
	ClickToMoveDisplay.SetEndWaypointTexture(p)
end

function ClickToMoveController.GetEndWaypointTexture(_)
	return ClickToMoveDisplay.GetEndWaypointTexture()
end

function ClickToMoveController.SetWaypointsAlwaysOnTop(_, p)
	ClickToMoveDisplay.SetWaypointsAlwaysOnTop(p)
end

function ClickToMoveController.GetWaypointsAlwaysOnTop(_)
	return ClickToMoveDisplay.GetWaypointsAlwaysOnTop()
end

function ClickToMoveController.SetFailureAnimationEnabled(_, p)
	v4 = p
end

function ClickToMoveController.GetFailureAnimationEnabled(_)
	return v4
end

function ClickToMoveController.SetIgnoredPartsTag(_, p)
	UpdateIgnoreTag(p)
end

function ClickToMoveController.GetIgnoredPartsTag(_)
	return v10
end

function ClickToMoveController.SetUseDirectPath(_, p)
	v5 = p
end

function ClickToMoveController.GetUseDirectPath(_)
	return v5
end

function ClickToMoveController.SetAgentSizeIncreaseFactor(_, p: number)
	v6 = p / 100 + 1
end

function ClickToMoveController.GetAgentSizeIncreaseFactor(_)
	return (v6 - 1) * 100
end

function ClickToMoveController.SetUnreachableWaypointTimeout(_, p)
	v7 = p
end

function ClickToMoveController.GetUnreachableWaypointTimeout(_)
	return v7
end

if not userFlag7 then
	function ClickToMoveController:SetUserJumpEnabled(jumpEnabled)
		self.jumpEnabled = jumpEnabled

		if self.touchJumpController then
			self.touchJumpController:Enable(jumpEnabled)
		end
	end

	function ClickToMoveController.GetUserJumpEnabled(p)
		return p.jumpEnabled
	end
end

function ClickToMoveController:MoveTo(p, p2, p3)
	local character = localPlayer.Character

	if character == nil then
		return false
	end

	local pather = Pather(p, createVector(0, 1, 0), p3)

	if pather and pather:IsValidPath() then
		self:HandleMoveTo(pather, p, nil, character, p2)
		return true
	else
		return false
	end
end

return ClickToMoveController