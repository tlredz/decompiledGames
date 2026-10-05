local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(ReplicatedStorage.Controllers.CameraController.Types)
local SewerSystem = require(ReplicatedStorage.Modules.World.SewerSystem)
local WallEffects = require(script.Parent.WallEffects)
local v = {
	BLACK_FADE_FROM_TIME = 0.55,
	BLACK_FADE_TO_TIME = 0.42,
	BLACK_HOLD_TIME = 0.12,
	BOSS_FIELD_OF_VIEW = 10,
	BOSS_HOLD_TIME = 0.8,
	CAMERA_RELEASE_DISTANCE = 12,
	CAMERA_RELEASE_FOCUS_DISTANCE = 4,
	CAMERA_RELEASE_FOCUS_HEIGHT = 2.5,
	CAMERA_RELEASE_HEIGHT = 5,
	CAMERA_CORNER_LIFT = 2,
	CAMERA_CORNER_RADIUS = 38,
	CAMERA_CORNER_RADIUS_RATIO = 0.42,
	CAMERA_CURVE_CONTROL_RATIO = 0.5523,
	CAMERA_SPEED_MULTIPLIER = 1.8,
	CAMERA_TURN_BANK = 0.07853981633974483,
	CAMERA_TURN_LEAD_DISTANCE = 24,
	DISPLAY_ORDER = 10000,
	FIELD_OF_VIEW_RESTORE_FREQUENCY = 5,
	FIELD_OF_VIEW_RESTORE_TIMEOUT = 0.85,
	POSITION_EASE_WINDOW_ALPHA = 0.14,
	READY_TIMEOUT = 8,
	SEGMENTS = {
		{
			duration = 2.5,
			easeIn = true,
			repairAt = 0.04,
			wallIndex = 2
		},
		{
			duration = 2.8,
			repairAt = 0.05,
			wallIndex = 1
		},
		{
			duration = 2.1
		},
		{
			duration = 1.7,
			easeOut = true
		}
	},
	WALL_REPAIR_DURATIONS = { 0.5, 0.48 }
}
local DungeonCameraController = {}
DungeonCameraController.__index = DungeonCameraController
local v2 = {}

local function findSewerMap()
	local map = workspace:FindFirstChild("Map")
	local model

	if map then
		model = map:FindFirstChild(SewerSystem.MAP_NAME)
	end

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

local function isPreviewReady(instance)
	if not (instance and instance.Parent) then
		return false
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	return humanoid ~= nil and humanoid.Health > 0 and humanoidRootPart ~= nil and humanoidRootPart:IsA("BasePart")
end

local function areEnemyPreviewsReady(items)
	if not items then
		return false
	end

	for _, item in items do
		local v3

		if item and item.Parent then
			local humanoid = item:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = item:FindFirstChild("HumanoidRootPart")

			if humanoid == nil or not (humanoid.Health > 0) or humanoidRootPart == nil then
				v3 = false
			else
				v3 = humanoidRootPart:IsA("BasePart")
			end
		else
			v3 = false
		end

		if not v3 then
			return false
		end
	end

	return true
end

local function isWallVisual(instance)
	return instance:GetAttribute(SewerSystem.WALL_SCRAP_ATTRIBUTE) == true or instance.Name:sub(
		1,
		#SewerSystem.BREAKABLE_WALL_NAME_PREFIX
	) == SewerSystem.BREAKABLE_WALL_NAME_PREFIX
end

-- equivalent calls inferred from this helper; original call sites unknown
local function smoothTurn(value: number)
	local v3 = math.clamp(value, 0, 1)
	return 0.5 - math.cos(3.141592653589793 * v3) * 0.5
end

function v2.getPositionAlpha(p: number, p2)
	local POSITION_EASE_WINDOW_ALPHA = v.POSITION_EASE_WINDOW_ALPHA

	if p2.easeIn and p < POSITION_EASE_WINDOW_ALPHA then
		local v3 = p / POSITION_EASE_WINDOW_ALPHA
		return POSITION_EASE_WINDOW_ALPHA * v3 * v3 * (2 - v3)
	end

	if p2.easeOut and 1 - POSITION_EASE_WINDOW_ALPHA < p then
		local v3 = (1 - p) / POSITION_EASE_WINDOW_ALPHA
		return 1 - POSITION_EASE_WINDOW_ALPHA * v3 * v3 * (2 - v3)
	else
		return p
	end
end

function v2.getCornerRadius(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local v3 = vector3 - vector2
	local v4 = vector4 - vector3

	if v3.Magnitude < 0.001 or v4.Magnitude < 0.001 or math.abs((v3.Unit:Dot(v4.Unit))) > 0.98 then
		return 0
	end

	return (math.min(
		v.CAMERA_CORNER_RADIUS,
		v3.Magnitude * v.CAMERA_CORNER_RADIUS_RATIO,
		v4.Magnitude * v.CAMERA_CORNER_RADIUS_RATIO
	))
end

function v2.getRoundedPosition(vector2: Vector3?, vector3: Vector3, vector4: Vector3, vector5: Vector3?, p: number)
	local v3

	if vector2 then
		local cornerRadius = v2.getCornerRadius(vector2, vector3, vector4)
		local v4 = vector4 - vector3

		if cornerRadius > 0 and v4.Magnitude > 0.001 then
			v3 = vector3 + v4.Unit * cornerRadius
		else
			v3 = vector3
		end
	else
		v3 = vector3
	end

	if not vector5 then
		return v3:Lerp(vector4, p), nil
	end

	local cornerRadius = v2.getCornerRadius(vector3, vector4, vector5)

	if cornerRadius <= 0 then
		return v3:Lerp(vector4, p), nil
	end

	local v4 = vector4 - (vector4 - vector3).Unit * cornerRadius
	local v5 = vector4 + (vector5 - vector4).Unit * cornerRadius
	local magnitude = (v4 - v3).Magnitude
	local v6 = magnitude + cornerRadius * 2
	local v7 = magnitude / v6
	local v8 = math.max(0, v7 - v.CAMERA_TURN_LEAD_DISTANCE / v6)
	local selected

	if v8 <= p then
		selected = (p - v8) / (1 - v8)
	end

	if p < v7 then
		return v3:Lerp(v4, p / v7), selected
	end

	local v10 = (p - v7) / (1 - v7)
	local v11 = 1 - v10
	local unit = (vector4 - vector3).Unit
	local unit2 = (vector5 - vector4).Unit
	local v12 = cornerRadius * v.CAMERA_CURVE_CONTROL_RATIO
	local v13 = v4 + unit * v12
	local v14 = v5 - unit2 * v12
	return
		v4 * v11 ^ 3 + v13 * 3 * v11 ^ 2 * v10 + v14 * 3 * v11 * v10 ^ 2 + v5 * v10 ^ 3 + createVector(0, 1, 0) * math.sin(3.141592653589793 * v10) * v.CAMERA_CORNER_LIFT,
		selected
end

function v2.getFlightRotation(cframe: CFrame, cframe2: CFrame, cframe3: CFrame?, value: number?)
	if not (value and cframe3) then
		return cframe2.Rotation
	end

	local v3 = smoothTurn(value) -- equivalent call inferred; original call site unknown
	local v4 = -math.sign((cframe2.Position - cframe.Position):Cross(cframe3.Position - cframe2.Position).Y) * math.sin(3.141592653589793 * v3) * v.CAMERA_TURN_BANK
	return cframe2.Rotation:Lerp(cframe3.Rotation, v3) * CFrame.Angles(0, 0, v4)
end

function DungeonCameraController.new(cameraController)
	local map = workspace:FindFirstChild("Map")
	local model

	if map then
		model = map:FindFirstChild(SewerSystem.MAP_NAME)
	end

	if not (model and model:IsA("Model")) then
		model = nil
	end

	local self = setmetatable({
		_boss = nil,
		_cameraController = cameraController,
		_destroyed = false,
		_enemyPreviews = nil,
		_fadeFrame = nil,
		_fadeGui = nil,
		_fadeTween = nil,
		_hiddenWalls = {},
		_repairFolders = {},
		_repairStarted = {},
		_sewerMap = model,
		_wallConnection = nil
	}, DungeonCameraController)
	self:bindWalls()
	return self
end

function DungeonCameraController:setBoss(boss)
	if not self._destroyed then
		self._boss = boss
	end
end

function DungeonCameraController:setEnemyPreviews(p2)
	if not self._destroyed then
		self._enemyPreviews = table.clone(p2)
	end
end

function DungeonCameraController:hideWall(p2)
	if self._hiddenWalls[p2] == nil then
		self._hiddenWalls[p2] = p2.LocalTransparencyModifier
	end

	p2.LocalTransparencyModifier = 1
end

function DungeonCameraController:hideWalls()
	local _sewerMap = self._sewerMap

	if not _sewerMap then
		local map = workspace:FindFirstChild("Map")

		if map then
			_sewerMap = map:FindFirstChild(SewerSystem.MAP_NAME)
		else
			_sewerMap = nil
		end

		if not (_sewerMap and _sewerMap:IsA("Model")) then
			_sewerMap = nil
		end
	end

	if not _sewerMap then
		return
	end

	self._sewerMap = _sewerMap
	local folder = _sewerMap:FindFirstChild(SewerSystem.BREAKABLE_WALLS_NAME)

	if not folder then
		return
	end

	for _, part in folder:GetDescendants() do
		if not (part:IsA("BasePart") and (part:GetAttribute(SewerSystem.WALL_SCRAP_ATTRIBUTE) == true or part.Name:sub(
			1,
			#SewerSystem.BREAKABLE_WALL_NAME_PREFIX
		) == SewerSystem.BREAKABLE_WALL_NAME_PREFIX)) then
			continue
		end

		self:hideWall(part)
	end
end

function DungeonCameraController:bindWalls()
	local _sewerMap = self._sewerMap

	if not _sewerMap then
		return
	end

	self:hideWalls()
	self._wallConnection = _sewerMap.DescendantAdded:Connect(function(part)
		if not self._destroyed and part:IsA("BasePart") and (part:GetAttribute(SewerSystem.WALL_SCRAP_ATTRIBUTE) == true or part.Name:sub(
			1,
			#SewerSystem.BREAKABLE_WALL_NAME_PREFIX
		) == SewerSystem.BREAKABLE_WALL_NAME_PREFIX) then
			self:hideWall(part)
		end
	end)
end

function DungeonCameraController:getWaypoints()
	local _sewerMap = self._sewerMap

	if not _sewerMap then
		local map = workspace:FindFirstChild("Map")

		if map then
			_sewerMap = map:FindFirstChild(SewerSystem.MAP_NAME)
		else
			_sewerMap = nil
		end

		if not (_sewerMap and _sewerMap:IsA("Model")) then
			_sewerMap = nil
		end
	end

	if not _sewerMap then
		return nil
	end

	self._sewerMap = _sewerMap
	local child = _sewerMap:FindFirstChild(SewerSystem.TRACKERS_FOLDER_NAME)

	if not child then
		return nil
	end

	local v3 = { SewerSystem.BOSS_ROOM_ENTRANCE_CAMERA_NAME }

	for _, v4 in SewerSystem.HALLWAY_CAMERA_NAMES do
		table.insert(v3, v4)
	end

	local parts = {}

	for _, childName in v3 do
		local part = child:FindFirstChild(childName)

		if part and part:IsA("BasePart") then
			table.insert(parts, part)
		else
			return nil
		end
	end

	return parts
end

function DungeonCameraController:waitForScene()
	local v3 = os.clock() + v.READY_TIMEOUT

	while not self._destroyed and os.clock() < v3 do
		if not self._sewerMap then
			local map = workspace:FindFirstChild("Map")
			local model

			if map then
				model = map:FindFirstChild(SewerSystem.MAP_NAME)
			end

			if not (model and model:IsA("Model")) then
				model = nil
			end

			self._sewerMap = model

			if self._sewerMap and not self._wallConnection then
				self:bindWalls()
			end
		end

		self:hideWalls()
		local waypoints = self:getWaypoints()
		local child

		if self._sewerMap then
			child = self._sewerMap:FindFirstChild(SewerSystem.BREAKABLE_WALLS_NAME)
		end

		local _boss = self._boss
		local v4

		if _boss and _boss.Parent then
			local humanoid = _boss:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = _boss:FindFirstChild("HumanoidRootPart")

			if humanoid == nil or not (humanoid.Health > 0) or humanoidRootPart == nil then
				v4 = false
			else
				v4 = humanoidRootPart:IsA("BasePart")
			end
		else
			v4 = false
		end

		if v4 then
			local _enemyPreviews = self._enemyPreviews
			local v5

			if _enemyPreviews then
				local flag = true

				for _, _enemyPreview in _enemyPreviews do
					local v6

					if _enemyPreview and _enemyPreview.Parent then
						local humanoid = _enemyPreview:FindFirstChildOfClass("Humanoid")
						local humanoidRootPart = _enemyPreview:FindFirstChild("HumanoidRootPart")

						if humanoid == nil or not (humanoid.Health > 0) or humanoidRootPart == nil then
							v6 = false
						else
							v6 = humanoidRootPart:IsA("BasePart")
						end
					else
						v6 = false
					end

					if v6 then
						continue
					end

					v5 = false
					flag = false
					break
				end

				if flag then
					v5 = true
				end
			else
				v5 = false
			end

			if v5 and waypoints and child then
				return waypoints
			end
		end

		RunService.Heartbeat:Wait()
	end

	return nil
end

function DungeonCameraController:createFade()
	if self._fadeFrame and self._fadeFrame.Parent then
		return self._fadeFrame
	end

	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui") or Players.LocalPlayer:WaitForChild(
		"PlayerGui",
		5
	)

	if not (playerGui and playerGui:IsA("PlayerGui")) then
		return nil
	end

	local sewerDungeonPreviewTransition = playerGui:FindFirstChild("SewerDungeonPreviewTransition")

	if sewerDungeonPreviewTransition then
		sewerDungeonPreviewTransition:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SewerDungeonPreviewTransition"
	screenGui.DisplayOrder = v.DISPLAY_ORDER
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Name = "Black"
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = screenGui
	self._fadeGui = screenGui
	self._fadeFrame = frame
	return frame
end

function DungeonCameraController:fade(backgroundTransparency: number, duration: number)
	local fade = self:createFade()

	if self._destroyed or not fade then
		return false
	end

	if self._fadeTween then
		self._fadeTween:Cancel()
	end

	local tween = TweenService:Create(
		fade,
		TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			BackgroundTransparency = backgroundTransparency
		}
	)
	self._fadeTween = tween
	tween:Play()
	tween.Completed:Wait()

	if self._destroyed or self._fadeTween ~= tween or not fade.Parent then
		return false
	end

	fade.BackgroundTransparency = backgroundTransparency
	self._fadeTween = nil
	return true
end

function DungeonCameraController:wait(p2: number)
	local v3 = os.clock() + p2

	while not self._destroyed and os.clock() < v3 do
		RunService.Heartbeat:Wait()
	end

	return not self._destroyed
end

function DungeonCameraController:waitForCameraAnimations()
	local v3 = os.clock() + v.FIELD_OF_VIEW_RESTORE_TIMEOUT

	while not self._destroyed and self._cameraController.Animations:IsAnimating() and os.clock() < v3 do
		RunService.Heartbeat:Wait()
	end

	if self._cameraController.Animations:IsAnimating() then
		self._cameraController.Animations:SkipToGoal()
	end

	return not self._destroyed
end

function DungeonCameraController:findWall(p2: number)
	local _sewerMap = self._sewerMap
	local child

	if _sewerMap then
		child = _sewerMap:FindFirstChild(SewerSystem.BREAKABLE_WALLS_NAME)
	end

	local part

	if child then
		part = child:FindFirstChild(`{SewerSystem.BREAKABLE_WALL_NAME_PREFIX}{p2}`, true)
	end

	if part and part:IsA("BasePart") then
		return part
	end

	return nil
end

function DungeonCameraController:beginRepair(p: number)
	if self._destroyed or self._repairStarted[p] then
		return nil
	end

	local wall = self:findWall(p)
	local _sewerMap = self._sewerMap
	local v3 = v.WALL_REPAIR_DURATIONS[p]

	if not (wall and _sewerMap and v3) then
		return nil
	end

	self._repairStarted[p] = true
	local v4 = self._hiddenWalls[wall] or 0
	local repairWall = WallEffects.repairWall(wall, _sewerMap, v3, v4)
	table.insert(self._repairFolders, repairWall)
	return v3
end

function DungeonCameraController:getReleaseCFrame()
	local character = Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return nil
	end

	local v3 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
	local v4 = not (v3.Magnitude > 0.01) and createVector(0, 0, 1) or v3.Unit
	local v5 = humanoidRootPart.Position - v4 * v.CAMERA_RELEASE_DISTANCE + createVector(0, 1, 0) * v.CAMERA_RELEASE_HEIGHT
	local v6 = humanoidRootPart.Position + v4 * v.CAMERA_RELEASE_FOCUS_DISTANCE + createVector(0, 1, 0) * v.CAMERA_RELEASE_FOCUS_HEIGHT
	return CFrame.lookAt(v5, v6)
end

function DungeonCameraController:tweenTo(cframe: CFrame?, cframe2: CFrame, cframe3: CFrame, cframe4: CFrame?, data)
	local v3 = data.duration / v.CAMERA_SPEED_MULTIPLIER
	local v4 = false
	local total = 0

	while not self._destroyed and total < v3 do
		total += RunService.RenderStepped:Wait()
		local v5 = math.clamp(total / v3, 0, 1)
		local positionAlpha = v2.getPositionAlpha(v5, data)
		local getRoundedPosition = v2.getRoundedPosition
		local position

		if cframe then
			position = cframe.Position
		end

		local position2 = cframe2.Position
		local position3 = cframe3.Position
		local v6

		if cframe4 then
			v6 = cframe4.Position
		end

		local roundedPosition, v7 = getRoundedPosition(position, position2, position3, v6, positionAlpha)
		local flightRotation = v2.getFlightRotation(cframe2, cframe3, cframe4, v7)
		self._cameraController:SetCFrame(CFrame.new(roundedPosition) * flightRotation.Rotation)

		if not data.wallIndex or not data.repairAt or v4 or not (data.repairAt <= v5) then
			continue
		end

		if not self:beginRepair(data.wallIndex) then
			return false
		end

		v4 = true
	end

	if self._destroyed then
		return false
	end

	local getRoundedPosition = v2.getRoundedPosition
	local position

	if cframe then
		position = cframe.Position
	end

	local position2 = cframe2.Position
	local position3 = cframe3.Position
	local v5

	if cframe4 then
		v5 = cframe4.Position
	end

	local roundedPosition, v6 = getRoundedPosition(position, position2, position3, v5, 1)
	local flightRotation = v2.getFlightRotation(cframe2, cframe3, cframe4, v6)
	self._cameraController:SetCFrame(CFrame.new(roundedPosition) * flightRotation.Rotation)
	return not (data.wallIndex and not (v4 or self:beginRepair(data.wallIndex)))
end

function DungeonCameraController:play()
	local v3 = self:waitForScene()

	if not v3 then
		warn("[SewerDungeonCameraController] Enemy previews, walls, or camera trackers were unavailable")
		return false
	end

	if not self:fade(0, v.BLACK_FADE_TO_TIME) then
		return false
	end

	local fieldOfView = self._cameraController._camera.FieldOfView
	local _areAnimationsInstant = self._cameraController._areAnimationsInstant
	self._cameraController:SetAreAnimationsInstant(true)
	self._cameraController:TeleportTo(v3[1].CFrame)
	self._cameraController.Animations:AnimateFieldOfView(v.BOSS_FIELD_OF_VIEW)
	self._cameraController:SetAreAnimationsInstant(_areAnimationsInstant)

	if not (self:wait(v.BLACK_HOLD_TIME) and self:fade(1, v.BLACK_FADE_FROM_TIME) and self:wait(v.BOSS_HOLD_TIME)) then
		return false
	end

	self._cameraController.Animations:AnimateFieldOfView(fieldOfView, 1, v.FIELD_OF_VIEW_RESTORE_FREQUENCY)

	if not self:waitForCameraAnimations() then
		return false
	end

	local releaseCFrame = self:getReleaseCFrame()

	if not releaseCFrame then
		return false
	end

	local v4 = {
		v3[1].CFrame,
		v3[2].CFrame,
		v3[3].CFrame,
		v3[4].CFrame,
		releaseCFrame
	}

	for k, v5 in v.SEGMENTS do
		local v6

		if k > 1 then
			v6 = v4[k - 1]
		end

		if not self:tweenTo(v6, v4[k], v4[k + 1], v4[k + 2], v5) then
			return false
		end
	end

	return true
end

function DungeonCameraController:destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	if self._wallConnection then
		self._wallConnection:Disconnect()
		self._wallConnection = nil
	end

	if self._fadeTween then
		self._fadeTween:Cancel()
		self._fadeTween = nil
	end

	if self._fadeGui then
		self._fadeGui:Destroy()
		self._fadeGui = nil
		self._fadeFrame = nil
	end

	self._enemyPreviews = nil

	for _, _repairFolder in self._repairFolders do
		_repairFolder:Destroy()
	end

	table.clear(self._repairFolders)

	for k, _hiddenWall in self._hiddenWalls do
		if k.Parent then
			k.LocalTransparencyModifier = _hiddenWall
		end
	end

	table.clear(self._hiddenWalls)
end

return DungeonCameraController