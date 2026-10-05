local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local GuiService = game:GetService("GuiService")
local v = true
local v2 = true
local v3 = false
local v4 = 1
local v5 = 8
local v6 = {
	[Enum.KeyCode.W] = true,
	[Enum.KeyCode.A] = true,
	[Enum.KeyCode.S] = true,
	[Enum.KeyCode.D] = true,
	[Enum.KeyCode.Up] = true,
	[Enum.KeyCode.Down] = true
}
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserNavigationClickToMoveSkipPassedWaypoints")
end)
local v7 = success and result
local localPlayer = Players.LocalPlayer
local ClickToMoveDisplay = require(script.Parent:WaitForChild("ClickToMoveDisplay"))
local v8 = {}
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

Raycast = function(p, p2, parts)
	local parts2 = parts or {}
	local part, v9, v10, v11 = Workspace:FindPartOnRayWithIgnoreList(p, parts2)

	if not part then
		return nil, nil
	end

	if not p2 or part.CanCollide ~= false then
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
		return Raycast(p, p2, parts2)
	end

	return part, v9, v10, v11
end

v8.Raycast = Raycast
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

local result2 = nil
local v10 = nil
local connection = nil
local connection2 = nil

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
	result2 = { localPlayer and localPlayer.Character }

	if v10 ~= nil then
		local tagged = CollectionService:GetTagged(v10)

		for _, v11 in ipairs(tagged) do
			table.insert(result2, v11)
		end

		connection = CollectionService:GetInstanceAddedSignal(v10):Connect(function(p2)
			table.insert(result2, p2)
		end)
		connection2 = CollectionService:GetInstanceRemovedSignal(v10):Connect(function(p2)
			for i = 1, #result2 do
				if result2[i] ~= p2 then
					continue
				end

				result2[i] = result2[#result2]
				table.remove(result2)
				break
			end
		end)
	end
end

local function getIgnoreList()
	if result2 then
		return result2
	end

	result2 = {}
	table.insert(result2, localPlayer and localPlayer.Character)
	return result2
end

local function Pather(p, targetSurfaceNormal, directPath)
	local class = {}
	local directPath2

	if directPath == nil then
		directPath2 = v3
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
	local rootPart = class.Humanoid and class.Humanoid.RootPart

	if rootPart then
		class.OriginPoint = rootPart.CFrame.p
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
					agentRadius = v4 * 0.5 * math.sqrt(extentsSize.X * extentsSize.X + extentsSize.Z * extentsSize.Z)
					agentHeight = v4 * extentsSize.Y
					class.AgentCanFollowPath = true
					class.DirectPath = directPath
					agentCanJump = false
				end

				model.PrimaryPart = primaryPart
			end
		else
			local extentsSize = (localPlayer and localPlayer.Character):GetExtentsSize()
			agentRadius = v4 * 0.5 * math.sqrt(extentsSize.X * extentsSize.X + extentsSize.Z * extentsSize.Z)
			agentHeight = v4 * extentsSize.Y
			agentCanJump = class.Humanoid.JumpPower > 0
			class.AgentCanFollowPath = true
			class.DirectPath = directPath2
			class.DirectPathRiseFirst = class.Humanoid.Sit
		end

		class.pathResult = PathfindingService:CreatePath({
			AgentRadius = agentRadius,
			AgentHeight = agentHeight,
			AgentCanJump = agentCanJump
		})
	end

	function class:Cleanup()
		if class.stopTraverseFunc then
			class.stopTraverseFunc()
			class.stopTraverseFunc = nil
		end

		if class.MoveToConn then
			class.MoveToConn:Disconnect()
			class.MoveToConn = nil
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

		class.OriginPoint = class.Humanoid.RootPart.CFrame.p
		class.pathResult:ComputeAsync(class.OriginPoint, class.TargetPoint)
		class.pointList = class.pathResult:GetWaypoints()

		if #class.pointList > 0 then
			class.HumanoidOffsetFromPath = class.pointList[1].Position - class.OriginPoint
		end

		class.PathComputed = class.pathResult.Status == Enum.PathStatus.Success

		if v then
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

	function class:OnRenderStepped(p2)
		if class.Started and not class.Cancelled then
			class.Timeout += p2
			local timeout = class.Timeout

			if v5 < timeout then
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

			local currentPoint = class.CurrentPoint + 1

			if #class.pointList < currentPoint then
				if class.stopTraverseFunc then
					class.stopTraverseFunc()
				end

				class.Finished:Fire()
				class:Cleanup()
			else
				local v14 = class.pointList[class.CurrentPoint]
				local v15 = class.pointList[currentPoint]
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

				if v7 then
					class:MoveToNextWayPoint(v14, v15, currentPoint)
					return
				end

				if class.setPointFunc then
					class.setPointFunc(currentPoint)
				end

				if v15.Action == Enum.PathWaypointAction.Jump then
					class.Humanoid.Jump = true
				end

				class.Humanoid:MoveTo(v15.Position)
				class.CurrentPoint = currentPoint
			end
		else
			class.PathFailed:Fire()
			class:Cleanup()
		end
	end

	function class:MoveToNextWayPoint(p2, p3, currentPoint)
		class.CurrentWaypointPlaneNormal = p2.Position - p3.Position
		class.CurrentWaypointPlaneNormal = Vector3.new(
			class.CurrentWaypointPlaneNormal.X,
			0,
			class.CurrentWaypointPlaneNormal.Z
		)

		if class.CurrentWaypointPlaneNormal.Magnitude > 1e-6 then
			class.CurrentWaypointPlaneNormal = class.CurrentWaypointPlaneNormal.Unit
			class.CurrentWaypointPlaneDistance = class.CurrentWaypointPlaneNormal:Dot(p3.Position)
		else
			class.CurrentWaypointPlaneNormal = createVector(0, 0, 0)
			class.CurrentWaypointPlaneDistance = 0
		end

		class.CurrentWaypointNeedsJump = p3.Action == Enum.PathWaypointAction.Jump
		class.CurrentWaypointPosition = p3.Position
		class.CurrentPoint = currentPoint
		class.Timeout = 0
	end

	function class:Start(p2)
		if not class.AgentCanFollowPath then
			class.PathFailed:Fire()
			return
		end

		local Global = require(game.ReplicatedStorage.Global)

		if Global.BlockingClickToMove then
			class.AgentCanFollowPath = false
			local Global2 = require(game.ReplicatedStorage.Global)
			print(Global2.BlockingClickToMove, "blocking")
			class.PathFailed:Fire()
		elseif game.Players.LocalPlayer.Character:GetAttribute("BlockingClickToMove") then
			class.AgentCanFollowPath = false
			local Global2 = require(game.ReplicatedStorage.Global)
			print(Global2.BlockingClickToMove, "blocking")
			class.PathFailed:Fire()
		else
			if class.Started then
				return
			end

			class.Started = true
			ClickToMoveDisplay.CancelFailureAnimation()

			if v and (p2 == nil or p2) then
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
				class.TeleportedConn = class.Humanoid.RootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
					class:OnPathInterrupted()
				end)
				class.CurrentPoint = 1
				class:OnPointReached(true)
			else
				class.PathFailed:Fire()

				if class.stopTraverseFunc then
					class.stopTraverseFunc()
				end
			end
		end
	end

	local v13 = class.TargetPoint + class.TargetSurfaceNormal * 1.5
	local ray = Ray.new(v13, createVector(0, -50, 0))

	if not result2 then
		result2 = {}
		table.insert(result2, localPlayer and localPlayer.Character)
	end

	local part, targetPoint = Workspace:FindPartOnRayWithIgnoreList(ray, result2)

	if part then
		class.TargetPoint = targetPoint
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

local v11 = nil
local eventConnection = nil
local eventConnection2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function CleanupPath()
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
end

local function HandleMoveTo(object, p, p2, character, p3)
	if v11 then
		CleanupPath() -- equivalent call inferred; original call site unknown
	end

	v11 = object
	object:Start(p3)
	eventConnection = object.Finished.Event:Connect(function()
		CleanupPath() -- equivalent call inferred; original call site unknown
		local v12 = p2 and GetEquippedTool(character)

		if v12 then
			v12:Activate()
		end
	end)
	eventConnection2 = object.PathFailed.Event:Connect(function()
		CleanupPath() -- equivalent call inferred; original call site unknown

		if p3 == nil or p3 then
			local v12 = v2

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

-- equivalent calls inferred from this helper; original call sites unknown
local function ShowPathFailedFeedback(p)
	if v11 and v11:IsActive() then
		v11:Cancel()
	end

	if v2 then
		ClickToMoveDisplay.PlayFailureAnimation()
	end

	ClickToMoveDisplay.DisplayFailureWaypoint(p)
end

function OnTap(list, p, p2)
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

	if #list == 1 or p then
		if currentCamera then
			local screenPointToRay = currentCamera:ScreenPointToRay(list[1].x, list[1].y)
			local ray = Ray.new(screenPointToRay.Origin, screenPointToRay.Direction * 1000)
			local localPlayer3 = localPlayer
			local character3 = localPlayer3 and localPlayer3.Character

			if character3 then
				local v15 = v9[localPlayer3]

				if not v15 or v15.Parent ~= character3 then
					v9[localPlayer3] = nil
					local humanoid2 = character3:FindFirstChildOfClass("Humanoid")

					if humanoid2 then
						v9[localPlayer3] = humanoid2
					end
				end
			end

			local raycast = v8.Raycast

			if not result2 then
				result2 = {}
				table.insert(result2, localPlayer and localPlayer.Character)
			end

			local v17, v18, v19 = raycast(ray, true, result2)
			local characterAncestor, v20 = v8.FindCharacterAncestor(v17)

			if p2 and v20 and StarterGui:GetCore("AvatarContextMenuEnabled") and Players:GetPlayerFromCharacter(v20.Parent) then
				CleanupPath() -- equivalent call inferred; original call site unknown
			else
				if p then
					v18 = p
					characterAncestor = nil
				end

				if v18 and character then
					CleanupPath() -- equivalent call inferred; original call site unknown
					local pather = Pather(v18, v19)

					if pather:IsValidPath() then
						HandleMoveTo(pather, v18, characterAncestor, character)
						return
					end

					pather:Cleanup()
					ShowPathFailedFeedback(v18) -- equivalent call inferred; original call site unknown
				end
			end
		end
	else
		local v14 = #list >= 2 and currentCamera and GetEquippedTool(character)

		if v14 then
			v14:Activate()
		end
	end
end

local function DisconnectEvent(connection3)
	if connection3 then
		connection3:Disconnect()
	end
end

local Keyboard = require(script.Parent:WaitForChild("Keyboard"))
local object = setmetatable({}, Keyboard)
object.__index = object

function object.new(p)
	local self = setmetatable(Keyboard.new(p), object)
	self.fingerTouches = {}
	self.numUnsunkTouches = 0
	self.mouse1Down = tick()
	self.mouse1DownPos = Vector2.new()
	self.mouse2DownTime = tick()
	self.mouse2DownPos = Vector2.new()
	self.mouse2UpTime = tick()
	self.keyboardMoveVector = createVector(0, 0, 0)
	self.tapConn = nil
	self.inputBeganConn = nil
	self.inputChangedConn = nil
	self.inputEndedConn = nil
	self.humanoidDiedConn = nil
	self.characterChildAddedConn = nil
	self.onCharacterAddedConn = nil
	self.characterChildRemovedConn = nil
	self.renderSteppedConn = nil
	self.menuOpenedConnection = nil
	self.running = false
	self.wasdEnabled = false
	return self
end

function object:DisconnectEvents()
	local tapConn = self.tapConn

	if tapConn then
		tapConn:Disconnect()
	end

	local inputBeganConn = self.inputBeganConn

	if inputBeganConn then
		inputBeganConn:Disconnect()
	end

	local inputChangedConn = self.inputChangedConn

	if inputChangedConn then
		inputChangedConn:Disconnect()
	end

	local inputEndedConn = self.inputEndedConn

	if inputEndedConn then
		inputEndedConn:Disconnect()
	end

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
end

function object:OnTouchBegan(p, p2)
	if self.fingerTouches[p] == nil and not p2 then
		self.numUnsunkTouches += 1
	end

	self.fingerTouches[p] = p2
end

function object:OnTouchChanged(p, p2)
	if self.fingerTouches[p] == nil then
		self.fingerTouches[p] = p2

		if not p2 then
			self.numUnsunkTouches += 1
		end
	end
end

function object:OnTouchEnded(p, _)
	if self.fingerTouches[p] ~= nil and self.fingerTouches[p] == false then
		self.numUnsunkTouches -= 1
	end

	self.fingerTouches[p] = nil
end

function object:OnCharacterAdded(instance)
	self:DisconnectEvents()
	self.inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.Touch then
			self:OnTouchBegan(input, gameProcessed)
		end

		if self.wasdEnabled and gameProcessed == false and input.UserInputType == Enum.UserInputType.Keyboard and v6[input.KeyCode] then
			CleanupPath() -- equivalent call inferred; original call site unknown
			ClickToMoveDisplay.CancelFailureAnimation()
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.mouse1DownTime = tick()
			self.mouse1DownPos = input.Position
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.mouse2DownTime = tick()
			self.mouse2DownPos = input.Position
		end
	end)
	self.inputChangedConn = UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.Touch then
			self:OnTouchChanged(input, gameProcessed)
		end
	end)
	self.inputEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.Touch then
			self:OnTouchEnded(input, gameProcessed)
		end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.mouse2UpTime = tick()
			local position = input.Position
			local v12 = v11 or self.keyboardMoveVector.Magnitude <= 0

			if self.mouse2UpTime - self.mouse2DownTime < 0.25 and (position - self.mouse2DownPos).magnitude < 5 and v12 then
				OnTap({ position })
			end
		end
	end)
	self.tapConn = UserInputService.TouchTap:Connect(function(p, p2)
		if not p2 then
			OnTap(p, nil, true)
		end
	end)
	self.menuOpenedConnection = GuiService.MenuOpened:Connect(function()
		CleanupPath() -- equivalent call inferred; original call site unknown
	end)

	local function OnCharacterChildAdded(child)
		if UserInputService.TouchEnabled and child:IsA("Tool") then
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
		if UserInputService.TouchEnabled and tool:IsA("Tool") then
			tool.ManualActivationOnly = false
		end
	end)

	for _, child in pairs(instance:GetChildren()) do
		OnCharacterChildAdded(child)
	end
end

function object:Start()
	self:Enable(true)
end

function object:Stop()
	self:Enable(false)
end

function object.CleanupPath(_)
	CleanupPath() -- equivalent call inferred; original call site unknown
end

function object:Enable(enabled, p, touchJumpController)
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

		self.touchJumpController = touchJumpController

		if self.touchJumpController then
			self.touchJumpController:Enable(self.jumpEnabled)
		end
	else
		if self.running then
			self:DisconnectEvents()
			CleanupPath() -- equivalent call inferred; original call site unknown

			if UserInputService.TouchEnabled then
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

		if self.touchJumpController and not self.jumpEnabled then
			self.touchJumpController:Enable(true)
		end

		self.touchJumpController = nil
	end

	if UserInputService.KeyboardEnabled and enabled ~= self.enabled then
		self.forwardValue = 0
		self.backwardValue = 0
		self.leftValue = 0
		self.rightValue = 0
		self.moveVector = createVector(0, 0, 0)

		if enabled then
			self:BindContextActions()
			self:ConnectFocusEventListeners()
		else
			self:UnbindContextActions()
			self:DisconnectFocusEventListeners()
		end
	end

	self.wasdEnabled = enabled and p or false
	self.enabled = enabled
end

function object:OnRenderStepped(p)
	self.isJumping = false

	if v11 then
		v11:OnRenderStepped(p)

		if v11 then
			self.moveVector = v11.NextActionMoveDirection
			self.moveVectorIsCameraRelative = false

			if v11.NextActionJump then
				self.isJumping = true
			end
		else
			self.moveVector = self.keyboardMoveVector
			self.moveVectorIsCameraRelative = true
		end
	else
		self.moveVector = self.keyboardMoveVector
		self.moveVectorIsCameraRelative = true
	end

	if self.jumpRequested then
		self.isJumping = true
	end
end

function object:UpdateMovement(p)
	if p == Enum.UserInputState.Cancel then
		self.keyboardMoveVector = createVector(0, 0, 0)
	elseif self.wasdEnabled then
		self.keyboardMoveVector = Vector3.new(
			self.leftValue + self.rightValue,
			0,
			self.forwardValue + self.backwardValue
		)
	end
end

function object.UpdateJump(_) end

function object.SetShowPath(_, p)
	v = p
end

function object.GetShowPath(_)
	return v
end

function object.SetWaypointTexture(_, p)
	ClickToMoveDisplay.SetWaypointTexture(p)
end

function object.GetWaypointTexture(_)
	return ClickToMoveDisplay.GetWaypointTexture()
end

function object.SetWaypointRadius(_, p)
	ClickToMoveDisplay.SetWaypointRadius(p)
end

function object.GetWaypointRadius(_)
	return ClickToMoveDisplay.GetWaypointRadius()
end

function object.SetEndWaypointTexture(_, p)
	ClickToMoveDisplay.SetEndWaypointTexture(p)
end

function object.GetEndWaypointTexture(_)
	return ClickToMoveDisplay.GetEndWaypointTexture()
end

function object.SetWaypointsAlwaysOnTop(_, p)
	ClickToMoveDisplay.SetWaypointsAlwaysOnTop(p)
end

function object.GetWaypointsAlwaysOnTop(_)
	return ClickToMoveDisplay.GetWaypointsAlwaysOnTop()
end

function object.SetFailureAnimationEnabled(_, p)
	v2 = p
end

function object.GetFailureAnimationEnabled(_)
	return v2
end

function object.SetIgnoredPartsTag(_, p)
	UpdateIgnoreTag(p)
end

function object.GetIgnoredPartsTag(_)
	return v10
end

function object.SetUseDirectPath(_, p)
	v3 = p
end

function object.GetUseDirectPath(_)
	return v3
end

function object.SetAgentSizeIncreaseFactor(_, p)
	v4 = 1 + p / 100
end

function object.GetAgentSizeIncreaseFactor(_)
	return (v4 - 1) * 100
end

function object.SetUnreachableWaypointTimeout(_, p)
	v5 = p
end

function object.GetUnreachableWaypointTimeout(_)
	return v5
end

function object:SetUserJumpEnabled(jumpEnabled)
	self.jumpEnabled = jumpEnabled

	if self.touchJumpController then
		self.touchJumpController:Enable(jumpEnabled)
	end
end

function object.GetUserJumpEnabled(p)
	return p.jumpEnabled
end

function object:MoveTo(p, p2, p3)
	local character = localPlayer.Character

	if character == nil then
		return false
	end

	local pather = Pather(p, createVector(0, 1, 0), p3)

	if pather and pather:IsValidPath() then
		HandleMoveTo(pather, p, nil, character, p2)
		return true
	else
		return false
	end
end

return object