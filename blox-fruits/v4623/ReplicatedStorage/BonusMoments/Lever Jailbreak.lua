local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local localPlayer = Players.LocalPlayer
local _ = {
	MAP_FOLDER = "Prison",
	LOCATIONS = "BonusMoment_Locations",
	LEVERS = "Levers",
	ARM = "Lever",
	GATES = "Gates",
	BOSS_GATES = "BossGates"
}
local _ = {
	ANGLE = 1.0122909661567112,
	PULL_TIME = 0.26,
	PULL_BACK = 2.4,
	SLAM_TIME = 0.16,
	SPRING_TIME = 0.44,
	SPRING_BACK = 1.9,
	SPRING_STAGGER = 0.06,
	RESET_HOLD = 0.34,
	NUDGE = 0.10471975511965978,
	NUDGE_TIME = 0.12,
	STUCK = 0.3490658503988659,
	STUCK_TIME = 0.18,
	STUCK_HOLD = 0.24,
	STUCK_BACK = 0.34
}
local _ = {
	RANGE = 11,
	BRIGHTNESS = 2.4,
	IDLE_SPEED = 2.1,
	IDLE_DEPTH = 0.3,
	FLASH_TIME = 0.55,
	SPENT = 0.35
}
local _ = {
	RANGE = 14,
	HOLD = 0.15,
	ACTION = "Pull"
}
local v = {
	RISE = 14,
	RISE_TIME = 0.95,
	STAGGER = 0.075,
	CHAIN_VOICES = 6,
	RELEASE_AT = 0.7,
	SOUND_FADE = 0.4
}
local v2 = {
	FOV = 72,
	FOV_WIDE = 82,
	FADE = 0.35,
	OPEN_HOLD = 0.2,
	CLOSE_HOLD = 0.5,
	SHOT = 1.8,
	SHOT_WIDE = 2.1,
	SEAL_SHOT = 2.6,
	SEAL_BACK_START = 62,
	SEAL_BACK_END = 48,
	SEAL_UP_START = 14,
	SEAL_UP_END = 6,
	SEAL_DROP = 8,
	BACK_START = 68,
	BACK_END = 46,
	UP_START = 17,
	UP_END = 9,
	SIDE = 30,
	WIDE_BACK = 118,
	WIDE_BACK_END = 96,
	WIDE_UP = 28,
	WIDE_UP_END = 14,
	LOOK_UP = 3,
	GROUP_RADIUS = 70
}
local v3 = {
	Red = Color3.fromRGB(255, 92, 84),
	Blue = Color3.fromRGB(96, 155, 255),
	Green = Color3.fromRGB(96, 232, 132)
}
local color = Color3.fromRGB(255, 64, 48)
local color2 = Color3.fromRGB(255, 236, 190)
local v4 = nil
local v5 = {}
local v6 = {}
local v7 = nil
local v8 = nil
local heartbeatConnection = nil
local flag = false
local v9 = false
local v10 = false
local v11 = false
local v12 = false
local flag2 = false
local flag3 = false

local function getLocationsFolder()
	local map = workspace:FindFirstChild("Map")
	local prison = map and map:FindFirstChild("Prison")
	local bonusMoment_Locations = prison and prison:FindFirstChild("BonusMoment_Locations", true)

	if bonusMoment_Locations then
		return bonusMoment_Locations
	end

	if map then
		return (map:FindFirstChild("BonusMoment_Locations", true))
	end

	return nil
end

local function sortByPosition(vector2: Vector3, vector3: Vector3)
	if math.abs(vector2.X - vector3.X) > 0.001 then
		return vector2.X < vector3.X
	end

	return vector2.Z < vector3.Z
end

local function targetsValid()
	if #v5 == 0 then
		return false
	end

	for _, v13 in v5 do
		if not v13.arm:IsDescendantOf(workspace) then
			return false
		end
	end

	return true
end

local object = setmetatable({}, {
	__mode = "k"
})

local function restPose(p)
	local cFrame = object[p]

	if not cFrame then
		cFrame = p.CFrame
		object[p] = cFrame
	end

	return cFrame
end

local function describeArm(cframe: CFrame, vector2: Vector3)
	return cframe.Position - cframe.LookVector * (vector2.Z * 0.5), cframe.RightVector
end

local function resolveTargets()
	if targetsValid() then
		return true
	end

	table.clear(v5)
	local locationsFolder = getLocationsFolder()
	local levers

	if locationsFolder then
		levers = locationsFolder:FindFirstChild("Levers")
	end

	if not levers then
		return false
	end

	for _, model in levers:GetChildren() do
		local lever

		if model:IsA("Model") then
			lever = model:FindFirstChild("Lever")
		end

		if not (lever and lever:IsA("BasePart")) then
			continue
		end

		local cFrame = object[lever]

		if not cFrame then
			cFrame = lever.CFrame
			object[lever] = cFrame
		end

		local size = lever.Size
		local pivot = cFrame.Position - cFrame.LookVector * (size.Z * 0.5)
		local rightVector = cFrame.RightVector
		table.insert(v5, {
			arm = lever,
			rest = cFrame,
			pivot = pivot,
			axis = rightVector,
			colour = v3[model.Name] or lever.Color,
			name = model.Name,
			phase = 0,
			angle = 0,
			swing = nil,
			flash = nil,
			hinge = nil,
			lamp = nil,
			handle = nil,
			prompt = nil,
			sparks = nil,
			pulled = false
		})
	end

	table.sort(v5, function(a, b)
		local position = a.rest.Position
		local position2 = b.rest.Position

		if math.abs(position.X - position2.X) > 0.001 then
			return position.X < position2.X
		end

		return position.Z < position2.Z
	end)

	for k, v13 in v5 do
		v13.phase = k * 1.37
	end

	return #v5 > 0
end

local function resolveSealCentre()
	if v8 then
		return v8
	end

	local locationsFolder = getLocationsFolder()
	local bossGates

	if locationsFolder then
		bossGates = locationsFolder:FindFirstChild("BossGates")
	end

	if not bossGates then
		return nil
	end

	local v13 = createVector(0, 0, 0)
	local count = 0

	for _, part in bossGates:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local cFrame = object[part]

		if not cFrame then
			cFrame = part.CFrame
			object[part] = cFrame
		end

		v13 += cFrame.Position
		count += 1
	end

	if count == 0 then
		return nil
	end

	v8 = v13 / count
	return v8
end

local function gatesValid()
	if #v6 == 0 then
		return false
	end

	for _, v13 in v6 do
		for _, part in v13.parts do
			if not part.part:IsDescendantOf(workspace) then
				return false
			end
		end
	end

	return true
end

local function resolveGates()
	if gatesValid() then
		return true
	end

	table.clear(v6)
	local locationsFolder = getLocationsFolder()
	local gates

	if locationsFolder then
		gates = locationsFolder:FindFirstChild("Gates")
	end

	if not gates then
		return false
	end

	for _, part in gates:GetChildren() do
		local parts = {}
		local v14 = createVector(0, 0, 0)

		if part:IsA("BasePart") then
			local cFrame = object[part]

			if not cFrame then
				cFrame = part.CFrame
				object[part] = cFrame
			end

			table.insert(parts, {
				part = part,
				rest = cFrame
			})
			v14 += cFrame.Position
		end

		for _, part2 in part:GetDescendants() do
			if not part2:IsA("BasePart") then
				continue
			end

			local cFrame = object[part2]

			if not cFrame then
				cFrame = part2.CFrame
				object[part2] = cFrame
			end

			table.insert(parts, {
				part = part2,
				rest = cFrame
			})
			v14 += cFrame.Position
		end

		if not (#parts > 0) then
			continue
		end

		local v15 = parts[1]
		local offset = v15.part.CFrame.Position.Y - v15.rest.Position.Y
		table.insert(v6, {
			index = 0,
			parts = parts,
			centre = v14 / #parts,
			offset = offset,
			swing = nil,
			raised = offset > 0.001
		})
	end

	table.sort(v6, function(a, b)
		local position = a.parts[1].rest.Position
		local position2 = b.parts[1].rest.Position

		if math.abs(position.X - position2.X) > 0.001 then
			return position.X < position2.X
		end

		return position.Z < position2.Z
	end)

	for k, v13 in v6 do
		v13.index = k
	end

	return #v6 > 0
end

local function easeOutBack(p: number, p2: number)
	local v13 = p - 1
	return v13 * v13 * ((p2 + 1) * v13 + p2) + 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function easeInOut(p: number)
	return -(math.cos(3.141592653589793 * p) - 1) / 2
end

local function applyAngle(data)
	local arm = data.arm

	if not arm.Parent then
		return
	end

	if math.abs(data.angle) < 0.0001 then
		arm.CFrame = data.rest
		return
	end

	local cframe = CFrame.fromAxisAngle(data.axis, data.angle)
	arm.CFrame = CFrame.new(data.pivot) * cframe * CFrame.new(-data.pivot) * data.rest
end

-- equivalent calls inferred from this helper; original call sites unknown
local function swingTo(p, to: number, duration: number, back: number, value: number?)
	p.swing = {
		from = p.angle,
		to = to,
		start = os.clock() + (value or 0),
		duration = duration,
		back = back
	}
end

local function applyGate(p)
	local vector2 = Vector3.new(0, p.offset, 0)

	for _, part in p.parts do
		if part.part.Parent then
			part.part.CFrame = part.rest + vector2
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fadeGateSound(p)
	local sound = p.sound

	if not sound then
		return
	end

	p.sound = nil
	pcall(function()
		Sound:FadeOut(sound, 0.4)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fadeBreachSound()
	local v13 = v7

	if not v13 then
		return
	end

	v7 = nil
	pcall(function()
		Sound:FadeOut(v13, 0.4)
	end)
end

local function gateSettled(p, p2: number)
	local swing = p.swing
	return swing == nil or swing.duration - (p2 - swing.start) <= 0.4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function liftGate(p, to: number, duration: number, p4: number)
	fadeGateSound(p) -- equivalent call inferred; original call site unknown
	p.swing = {
		from = p.offset,
		to = to,
		start = os.clock() + p4,
		duration = duration,
		back = 0
	}
end

local function stepGate(state, now: number)
	local swing = state.swing

	if not swing then
		return
	end

	local swing2 = state.swing
	local sound = (swing2 == nil or swing2.duration - (now - swing2.start) <= v.SOUND_FADE) and state.sound

	if sound then
		state.sound = nil
		pcall(function()
			Sound:FadeOut(sound, 0.4)
		end)
	end

	local v13 = (now - swing.start) / swing.duration

	if v13 >= 1 then
		state.offset = swing.to
		state.swing = nil
	elseif v13 >= 0 then
		state.offset = swing.from + (swing.to - swing.from) * easeInOut(v13)
	else
		return
	end

	applyGate(state)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setLampColour(p, color3: Color3, duration: number)
	p.flash = {
		colour = color3,
		start = os.clock(),
		duration = duration
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function emitSparks(p, p2: number)
	local sparks = p.sparks

	if sparks then
		sparks:Emit(p2)
	end
end

local function getCharacterRoot()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function flatUnit(vector2: Vector3, vector3: Vector3)
	local vector4 = Vector3.new(vector2.X, 0, vector2.Z)

	if vector4.Magnitude > 0.001 then
		return vector4.Unit
	end

	return vector3
end

local function yardCentre()
	local v13 = createVector(0, 0, 0)

	for _, v14 in v6 do
		v13 += v14.centre
	end

	return v13 / math.max(#v6, 1)
end

local function shotAnchor()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	if humanoidRootPart then
		return humanoidRootPart.Position
	end

	if #v5 > 0 then
		return v5[1].rest.Position
	end

	local v13 = createVector(0, 0, 0)

	for _, v14 in v6 do
		v13 += v14.centre
	end

	return v13 / math.max(#v6, 1)
end

local function clusterCentre(list)
	local v13 = createVector(0, 0, 0)

	for _, v14 in list do
		v13 += v14.centre
	end

	return v13 / math.max(#list, 1)
end

local function clusterGates(vector2: Vector3)
	local clone = table.clone(v6)
	local result = {}

	while #clone > 0 do
		local v13 = 1e999
		local v14 = 1

		for k, v15 in clone do
			local magnitude = (v15.centre - vector2).Magnitude

			if not (magnitude < v13) then
				continue
			end

			v14 = k
			v13 = magnitude
		end

		local centre = clone[v14].centre
		local v15 = {}

		for i = #clone, 1, -1 do
			if not ((clone[i].centre - centre).Magnitude <= 70) then
				continue
			end

			table.insert(v15, clone[i])
			table.remove(clone, i)
		end

		table.insert(result, v15)
	end

	table.sort(result, function(a, b)
		local v13 = createVector(0, 0, 0)

		for _, v14 in a do
			v13 += v14.centre
		end

		local magnitude = (v13 / math.max(#a, 1) - vector2).Magnitude
		local v14 = createVector(0, 0, 0)

		for _, v15 in b do
			v14 += v15.centre
		end

		return magnitude < (v14 / math.max(#b, 1) - vector2).Magnitude
	end)
	return result
end

local function raiseCluster(p, vector2: Vector3)
	local clone = table.clone(p)
	table.sort(clone, function(a, b)
		return (a.centre - vector2).Magnitude < (b.centre - vector2).Magnitude
	end)
	local indexes = {}
	local count = 0

	for k, v13 in clone do
		if v13.raised then
			continue
		end

		v13.raised = true
		table.insert(indexes, v13.index)
		local v14 = (k - 1) * 0.075
		liftGate(v13, 14, 0.95, v14) -- equivalent call inferred; original call site unknown

		if not (count < 6) then
			continue
		end

		count += 1
		local v15 = v13
		task.delay(v14, function()
			if not (v15.raised and v15.swing) then
				return
			end

			fadeGateSound(v15) -- equivalent call inferred; original call site unknown
			v15.sound = Sound:Play("ChainDragging", v15.centre, nil, 0.9, 0.7)
		end)
	end

	if #indexes == 0 then
		return
	end

	local v13 = v4
	local v14 = (#indexes - 1) * 0.075 + 0.6649999999999999
	task.delay(v14, function()
		if v13 and v4 == v13 then
			pcall(function()
				v13:InvokeServer("Release", indexes)
			end)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function raiseGates()
	if #v6 == 0 then
		return
	end

	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	local position

	if humanoidRootPart then
		position = humanoidRootPart.Position
	elseif #v5 > 0 then
		position = v5[1].rest.Position
	else
		local v15 = createVector(0, 0, 0)

		for _, v16 in v6 do
			v15 += v16.centre
		end

		position = v15 / math.max(#v6, 1)
	end

	raiseCluster(v6, position)
end

local function makeFade()
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil, nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LeverJailbreakCinematic"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 60
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	return frame, screenGui
end

local function fade(fade2, backgroundTransparency: number, duration: number)
	if not fade2 then
		task.wait(duration)
		return
	end

	local tween = TweenService:Create(fade2, TweenInfo.new(duration), {
		BackgroundTransparency = backgroundTransparency
	})
	tween:Play()
	tween.Completed:Wait()
end

local function playShot(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number, fieldOfView: number)
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.FieldOfView = fieldOfView
		currentCamera.CFrame = CFrame.lookAt(vector2, vector4)
	end

	local cframe = CFrame.lookAt(vector2, vector4)
	local cframe2 = CFrame.lookAt(vector3, vector4)
	local lastTime = os.clock()

	while true do
		local v13 = math.clamp((os.clock() - lastTime) / p, 0, 1)
		local currentCamera2 = workspace.CurrentCamera

		if not currentCamera2 then
			break
		end

		currentCamera2.CameraType = Enum.CameraType.Scriptable
		currentCamera2.FieldOfView = fieldOfView
		currentCamera2.CFrame = cframe:Lerp(cframe2, easeInOut(v13))

		if v13 >= 1 then
			break
		else
			RunService.RenderStepped:Wait()
		end
	end
end

local function closeShot(list, vector2: Vector3, flag4: boolean)
	local v13 = createVector(0, 0, 0)

	for _, v14 in list do
		v13 += v14.centre
	end

	local v14 = v13 / math.max(#list, 1)
	local v15 = v14 + createVector(0, 3, 0)
	local v16 = v14 - vector2
	local vector3 = Vector3.new(v16.X, 0, v16.Z)
	local v17 = not (vector3.Magnitude > 0.001) and createVector(0, 0, 1) or vector3.Unit
	local vector4 = Vector3.new(-v17.Z, 0, v17.X)
	local v18 = v15 - v17 * 68 + createVector(0, 17, 0)
	local v19 = v15 - v17 * 46 + createVector(0, 9, 0)

	if flag4 then
		v18 += vector4 * 30
		v19 -= vector4 * 30
	end

	return v18, v19, v15
end

local function sealShot(vector2: Vector3, vector3: Vector3)
	local v13 = vector2 - createVector(0, 8, 0)
	local v14 = vector2 - vector3
	local vector4 = Vector3.new(v14.X, 0, v14.Z)
	local v15 = not (vector4.Magnitude > 0.001) and createVector(0, 0, 1) or vector4.Unit
	return v13 - v15 * 62 + createVector(0, 14, 0), v13 - v15 * 48 + createVector(0, 6, 0), v13
end

local function wideShot(items, vector2: Vector3)
	local v13 = createVector(0, 0, 0)
	local count = 0

	for _, item in items do
		local v14 = createVector(0, 0, 0)

		for _, v15 in item do
			v14 += v15.centre
		end

		v13 += v14 / math.max(#item, 1)
		count += 1
	end

	local v14 = v13 / math.max(count, 1)
	local v15 = v14 + createVector(0, 3, 0)
	local v16 = v14 - vector2
	local vector3 = Vector3.new(v16.X, 0, v16.Z)
	local v17 = not (vector3.Magnitude > 0.001) and createVector(0, 0, 1) or vector3.Unit
	return v15 - v17 * 118 + createVector(0, 28, 0), v15 - v17 * 96 + createVector(0, 14, 0), v15
end

local function getControls()
	local success, result = pcall(function()
		local playerScripts = localPlayer:WaitForChild("PlayerScripts", 5)
		local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 5)

		if not playerModule then
			return nil
		end

		local module = require(playerModule)
		return (module:GetControls())
	end)

	if success then
		return result
	end

	return nil
end

local function runGateCutscene()
	if flag3 then
		return
	end

	flag3 = true
	local v13 = createVector(0, 0, 0)

	for _, v14 in v6 do
		v13 += v14.centre
	end

	local v14 = v13 / math.max(#v6, 1)
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		humanoidRootPart = nil
	end

	local position

	if humanoidRootPart then
		position = humanoidRootPart.Position
	elseif #v5 > 0 then
		position = v5[1].rest.Position
	else
		local v16 = createVector(0, 0, 0)

		for _, v17 in v6 do
			v16 += v17.centre
		end

		position = v16 / math.max(#v6, 1)
	end

	local v16 = clusterGates(position)
	local fade2, v17 = makeFade()
	local currentCamera = workspace.CurrentCamera
	local cameraType

	if currentCamera then
		cameraType = currentCamera.CameraType
	else
		cameraType = Enum.CameraType.Custom
	end

	local fieldOfView = not currentCamera and 70 or currentCamera.FieldOfView
	local success, result = pcall(function()
		local playerScripts = localPlayer:WaitForChild("PlayerScripts", 5)
		local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 5)

		if not playerModule then
			return nil
		end

		local module = require(playerModule)
		return (module:GetControls())
	end)

	if not success then
		result = nil
	end

	if result then
		pcall(function()
			result:Disable()
		end)
	end

	local success2, result2 = pcall(function()
		local DISTANCE_EPSILON = 0.001

		if #v16 == 0 then
			return true
		end

		fade(fade2, 0, 0.35)
		local v19 = v16[1]
		local v21 = createVector(0, 0, 0)

		for _, v22 in v19 do
			v21 += v22.centre
		end

		local v22 = v21 / math.max(#v19, 1)
		local v23 = v22 + createVector(0, 1, 0) * v2.LOOK_UP
		local v24 = v22 - v14
		local vector2 = Vector3.new(v24.X, 0, v24.Z)
		local v25 = not (vector2.Magnitude > DISTANCE_EPSILON) and createVector(0, 0, 1) or vector2.Unit
		Vector3.new(-v25.Z, 0, v25.X)
		local v26 = v23 - v25 * v2.BACK_START + createVector(0, 1, 0) * v2.UP_START
		local v27 = v23 - v25 * v2.BACK_END + createVector(0, 1, 0) * v2.UP_END
		local sealCentre = resolveSealCentre()
		local v28, v29, v30

		if sealCentre then
			v28 = sealCentre - createVector(0, 1, 0) * v2.SEAL_DROP
			local v32 = sealCentre - v14
			local vector3 = Vector3.new(v32.X, 0, v32.Z)
			local v33 = not (vector3.Magnitude > DISTANCE_EPSILON) and createVector(0, 0, 1) or vector3.Unit
			v29 = v28 - v33 * v2.SEAL_BACK_START + createVector(0, 1, 0) * v2.SEAL_UP_START
			v30 = v28 - v33 * v2.SEAL_BACK_END + createVector(0, 1, 0) * v2.SEAL_UP_END
		else
			v30 = v27
			v28 = v23
			v29 = v26
		end

		local currentCamera2 = workspace.CurrentCamera

		if currentCamera2 then
			currentCamera2.CameraType = Enum.CameraType.Scriptable
			currentCamera2.FieldOfView = 72
			currentCamera2.CFrame = CFrame.lookAt(v29, v28)
		end

		fade(fade2, 1, 0.35)
		task.wait(0.2)

		if sealCentre then
			playShot(v29, v30, v28, 2.6, 72)
		end

		raiseCluster(v19, v23)
		playShot(v26, v27, v23, 1.8, 72)

		if v16[2] then
			local v31 = v16[2]
			local v33 = createVector(0, 0, 0)

			for _, v34 in v31 do
				v33 += v34.centre
			end

			local v34 = v33 / math.max(#v31, 1)
			local v35 = v34 + createVector(0, 1, 0) * v2.LOOK_UP
			local v36 = v34 - v14
			local vector3 = Vector3.new(v36.X, 0, v36.Z)
			local v37 = not (vector3.Magnitude > DISTANCE_EPSILON) and createVector(0, 0, 1) or vector3.Unit
			local vector4 = Vector3.new(-v37.Z, 0, v37.X)
			local v38 = v35 - v37 * v2.BACK_START + createVector(0, 1, 0) * v2.UP_START
			local v39 = v35 - v37 * v2.BACK_END + createVector(0, 1, 0) * v2.UP_END
			local v40 = v38 + vector4 * v2.SIDE
			local v41 = v39 - vector4 * v2.SIDE
			raiseCluster(v31, v35)
			playShot(v40, v41, v35, 1.8, 72)
		end

		local v31 = {}

		for i = 3, #v16 do
			table.insert(v31, v16[i])
		end

		if #v31 > 0 then
			local v32, v33, v34 = wideShot(v31, v14)

			for _, v35 in v31 do
				raiseCluster(v35, v34)
			end

			playShot(v32, v33, v34, 2.1, 82)
		end

		task.wait(0.5)
		fade(fade2, 0, 0.35)
		return true
	end)

	if not success2 then
		warn("[Lever Jailbreak] gate cutscene error:", result2)
	end

	local currentCamera2 = workspace.CurrentCamera

	if currentCamera2 then
		currentCamera2.FieldOfView = fieldOfView

		if cameraType == Enum.CameraType.Scriptable then
			cameraType = Enum.CameraType.Custom
		end

		currentCamera2.CameraType = cameraType
	end

	if result then
		pcall(function()
			result:Enable()
		end)
	end

	fade(fade2, 1, 0.35)

	if v17 then
		v17:Destroy()
	end

	flag3 = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function teardownLever(state)
	if state.prompt then
		state.prompt:Destroy()
		state.prompt = nil
	end

	if state.handle then
		state.handle:Destroy()
		state.handle = nil
	end

	if state.hinge then
		state.hinge:Destroy()
		state.hinge = nil
	end

	state.lamp = nil
	state.sparks = nil
	state.flash = nil
end

local function requestPull(p: number)
	local v13 = v4

	if not v13 or v12 or v11 or not v10 or v13.Completed then
		return
	end

	v12 = true
	local success, result = pcall(function()
		return v13:InvokeServer("Pull", p)
	end)
	v12 = false

	if not success or typeof(result) ~= "table" or v4 ~= v13 then
		return
	end

	local v14 = v5[p]

	if not v14 then
		return
	end

	if result.Result == "Accepted" or result.Result == "Solved" then
		v14.pulled = true
		swingTo(v14, 1.0122909661567112, 0.26, 2.4) -- equivalent call inferred; original call site unknown
		setLampColour(v14, v14.colour, 0.55) -- equivalent call inferred; original call site unknown
		emitSparks(v14, 14) -- equivalent call inferred; original call site unknown
		Sound:Play("LeverSFX", v14.rest.Position, nil, 1, 0.85)

		if result.Result == "Solved" then
			v11 = true
		end
	elseif result.Result == "Stuck" then
		v11 = true
		swingTo(v14, 0.3490658503988659, 0.18, 0) -- equivalent call inferred; original call site unknown
		Sound:Play("LeverSFX", v14.rest.Position, nil, 0.42, 0.8)
		task.delay(0.42, function()
			if v4 ~= v13 then
				return
			end

			swingTo(v14, 0, 0.34, 1.9) -- equivalent call inferred; original call site unknown
			v11 = false
		end)
	elseif result.Result == "Reset" then
		v11 = true
		v14.pulled = false
		swingTo(v14, 1.0122909661567112, 0.16, 0) -- equivalent call inferred; original call site unknown
		setLampColour(v14, color, 0.78) -- equivalent call inferred; original call site unknown
		emitSparks(v14, 8) -- equivalent call inferred; original call site unknown
		Sound:Play("LeverSFX", v14.rest.Position, nil, 0.62, 0.9)
		local total = 0.06

		for _, v15 in v5 do
			if not (v15 ~= v14 and v15.pulled) then
				continue
			end

			v15.pulled = false
			swingTo(v15, 0, 0.44, 1.9, 0.34 + total) -- equivalent call inferred; original call site unknown
			setLampColour(v15, color, 0.78) -- equivalent call inferred; original call site unknown
			total += 0.06
		end

		task.delay(0.34, function()
			if v4 ~= v13 then
				return
			end

			swingTo(v14, 0, 0.44, 1.9) -- equivalent call inferred; original call site unknown
			Sound:Play("ChainDragging", v14.rest.Position, nil, 1.15, 0.6)
			v11 = false
		end)
	else
		swingTo(v14, 0.10471975511965978, 0.12, 0) -- equivalent call inferred; original call site unknown
		task.delay(0.12, function()
			if v4 == v13 and not v14.pulled then
				swingTo(v14, 0, 0.12, 0) -- equivalent call inferred; original call site unknown
			end
		end)
	end
end

local function buildLever(state, k: number)
	if state.hinge then
		return
	end

	for _, attachment in state.arm:GetChildren() do
		if attachment:IsA("Attachment") and (attachment.Name == "LeverLamp" or attachment.Name == "LeverGrip") then
			attachment:Destroy()
		end
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "LeverLamp"
	attachment.Position = Vector3.new(0, 0, -state.arm.Size.Z * 0.5)
	attachment.Parent = state.arm
	local pointLight = Instance.new("PointLight")
	pointLight.Color = state.colour
	pointLight.Range = 11
	pointLight.Brightness = 2.4
	pointLight.Shadows = false
	pointLight.Parent = attachment
	local attachment2 = Instance.new("Attachment")
	attachment2.Name = "LeverGrip"
	attachment2.Position = Vector3.new(0, 0, state.arm.Size.Z * 0.45)
	attachment2.Parent = state.arm
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Enabled = false
	particleEmitter.Rate = 0
	particleEmitter.Lifetime = NumberRange.new(0.2, 0.45)
	particleEmitter.Speed = NumberRange.new(6, 16)
	particleEmitter.SpreadAngle = Vector2.new(180, 180)
	particleEmitter.Size = NumberSequence.new(0.35, 0)
	particleEmitter.Color = ColorSequence.new(state.colour)
	particleEmitter.LightEmission = 1
	particleEmitter.Brightness = 4
	particleEmitter.Acceleration = createVector(0, -55, 0)
	particleEmitter.Parent = attachment2
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt:AddTag("ProximityPrompt")
	proximityPrompt.ActionText = "Pull"
	proximityPrompt.ObjectText = `{state.name} Lever`
	proximityPrompt.MaxActivationDistance = 14
	proximityPrompt.HoldDuration = 0.15
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Parent = attachment2
	proximityPrompt.Triggered:Connect(function()
		requestPull(k)
	end)
	state.hinge = attachment
	state.lamp = pointLight
	state.handle = attachment2
	state.sparks = particleEmitter
	state.prompt = proximityPrompt
end

local function stepLever(state, now: number)
	local swing = state.swing

	if swing then
		local v13 = (now - swing.start) / swing.duration

		if v13 >= 1 then
			state.angle = swing.to
			state.swing = nil
		elseif v13 >= 0 then
			local v14

			if swing.back > 0 then
				local back = swing.back
				local v15 = v13 - 1
				v14 = v15 * v15 * ((back + 1) * v15 + back) + 1
			else
				v14 = v13 * v13
			end

			state.angle = swing.from + (swing.to - swing.from) * v14
		end

		applyAngle(state)
	end

	local lamp = state.lamp

	if not lamp then
		return
	end

	local flash = state.flash

	if flash then
		local v13 = (now - flash.start) / flash.duration

		if v13 >= 1 then
			state.flash = nil
		else
			lamp.Color = flash.colour
			lamp.Brightness = 2.4 * (1 + 2.5 * (1 - v13))
			return
		end
	end

	lamp.Color = state.colour

	if not v10 then
		lamp.Brightness = 0
	elseif state.pulled then
		lamp.Brightness = 0.35
	else
		lamp.Brightness = 2.4 * (0.7 + 0.3 * (math.sin(now * 2.1 + state.phase) * 0.5 + 0.5))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopStepping()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startStepping()
	if heartbeatConnection then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local now = os.clock()

		for _, v13 in v5 do
			stepLever(v13, now)
		end

		local v13

		if v7 == nil then
			v13 = false
		else
			v13 = #v6 > 0
		end

		for _, v14 in v6 do
			stepGate(v14, now)

			if not v13 then
				continue
			end

			if v14.raised then
				local swing = v14.swing

				if swing == nil or swing.duration - (now - swing.start) <= v.SOUND_FADE then
					continue
				end
			end

			v13 = false
		end

		if v13 then
			fadeBreachSound() -- equivalent call inferred; original call site unknown
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setPromptsEnabled(enabled: boolean)
	for _, v13 in v5 do
		local prompt = v13.prompt

		if prompt then
			prompt.Enabled = enabled
		end
	end
end

local function finishSwings(list, list2)
	if #list == 0 and #list2 == 0 then
		return
	end

	task.spawn(function()
		while true do
			local now = os.clock()
			local v13 = false

			for _, v14 in list do
				stepLever(v14, now)
				v13 = v13 or v14.swing ~= nil
			end

			for _, v14 in list2 do
				stepGate(v14, now)
				v13 = v13 or v14.swing ~= nil
			end

			if not v13 then
				break
			end

			task.wait()
		end
	end)
end

local function teardown()
	stopStepping() -- equivalent call inferred; original call site unknown
	local v13 = {}
	local v14 = {}

	for _, v15 in v5 do
		teardownLever(v15) -- equivalent call inferred; original call site unknown
		v15.pulled = false
		local swing = v15.swing

		if flag2 then
			v15.swing = nil
		elseif swing and swing.to == 0 then
			table.insert(v13, v15)
		else
			v15.swing = nil
			v15.angle = 0
			applyAngle(v15)
		end
	end

	fadeBreachSound() -- equivalent call inferred; original call site unknown

	for _, v15 in v6 do
		fadeGateSound(v15) -- equivalent call inferred; original call site unknown
		local swing = v15.swing

		if flag2 then
			v15.swing = nil
		elseif swing and swing.to == 0 then
			v15.raised = false
			table.insert(v14, v15)
		else
			v15.swing = nil
			v15.offset = 0
			v15.raised = false
			applyGate(v15)
		end
	end

	if #v13 ~= 0 or #v14 ~= 0 then
		task.spawn(function()
			while true do
				local now = os.clock()
				local v15 = false

				for _, v16 in v13 do
					stepLever(v16, now)
					v15 = v15 or v16.swing ~= nil
				end

				for _, v16 in v14 do
					stepGate(v16, now)
					v15 = v15 or v16.swing ~= nil
				end

				if not v15 then
					break
				end

				task.wait()
			end
		end)
	end

	table.clear(v5)
	table.clear(v6)
	v9 = false
	v10 = false
	v11 = false
	flag2 = false
end

local function lowerGates()
	fadeBreachSound() -- equivalent call inferred; original call site unknown
	local total = 0

	for _, v13 in v6 do
		if not (v13.raised or not (math.abs(v13.offset) < 0.001)) then
			continue
		end

		v13.raised = false
		liftGate(v13, 0, 0.95, total) -- equivalent call inferred; original call site unknown
		total += 0.075
	end
end

local function springAll(flag4: boolean)
	local total = 0
	local v13 = false

	for _, v14 in v5 do
		if not (v14.pulled or not (math.abs(v14.angle) < 0.0001)) then
			continue
		end

		v14.pulled = false
		swingTo(v14, 0, 0.44, 1.9, total) -- equivalent call inferred; original call site unknown
		total += 0.06
		v13 = true
	end

	if v13 and flag4 and v5[1] then
		Sound:Play("ChainDragging", v5[1].rest.Position, nil, 1.15, 0.5)
	end
end

local function wire(p, p2)
	if not resolveTargets() then
		return false
	end

	for k, v13 in v5 do
		buildLever(v13, k)
	end

	if not v9 then
		v9 = true
		p.Trove:Add(teardown)
		startStepping() -- equivalent call inferred; original call site unknown
	end

	resolveGates()
	resolveSealCentre()

	if p2 then
		for k, v13 in v5 do
			local pulled = p2[k] == true
			v13.pulled = pulled
			v13.swing = nil
			v13.angle = pulled and 1.0122909661567112 or 0
			applyAngle(v13)
		end
	end

	setPromptsEnabled(v10 and not p.Completed) -- equivalent call inferred; original call site unknown
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function waitForTargets(p, p2)
	if wire(p, p2) then
		return
	end

	task.spawn(function()
		local v13 = os.clock() + 30

		while v4 == p and os.clock() < v13 do
			task.wait(1)

			if wire(p, p2) then
				break
			end
		end
	end)
end

local LeverJailbreak = {}
LeverJailbreak.DataName = script.Name
LeverJailbreak.Repeatable = true

function LeverJailbreak.OnLoad(object2)
	v4 = object2
	flag = false
	v11 = false
	v12 = false
	flag2 = false
	object2:FireServer("Init")
	task.delay(4, function()
		if v4 == object2 and not (object2.Completed or flag) then
			object2:FireServer("Init")
		end
	end)
end

function LeverJailbreak.OnActive(p, p2)
	v10 = p2

	if v4 ~= p then
		return
	end

	if p2 then
		if not wire(p, nil) then
			local v13 = nil
			task.spawn(function()
				local v14 = os.clock() + 30

				while v4 == p and os.clock() < v14 do
					task.wait(1)

					if wire(p, v13) then
						break
					end
				end
			end)
		end
	elseif not flag2 then
		springAll(false)
	end

	setPromptsEnabled(p2 and not p.Completed) -- equivalent call inferred; original call site unknown
end

function LeverJailbreak.OnComplete(p)
	if v4 == p then
		v11 = false
		flag2 = false
		springAll(false)

		if resolveGates() then
			lowerGates()
		end
	end

	setPromptsEnabled(false) -- equivalent call inferred; original call site unknown
end

LeverJailbreak.RemoteEvents = {
	Setup = function(p, p2, _)
		if flag then
			return
		end

		flag = true

		if typeof(p2) ~= "table" then
			p2 = nil
		end

		waitForTargets(p, p2) -- equivalent call inferred; original call site unknown
	end,
	Reset = function(p, p2)
		if v4 ~= p then
			return
		end

		v11 = false
		flag2 = false
		springAll(p2 == true)

		if resolveGates() then
			lowerGates()
		end

		setPromptsEnabled(v10 and not p.Completed) -- equivalent call inferred; original call site unknown
	end,
	Breach = function(p)
		if v4 ~= p then
			return
		end

		v11 = true
		flag2 = true
		setPromptsEnabled(false) -- equivalent call inferred; original call site unknown

		for _, v13 in v5 do
			setLampColour(v13, color2, 1.6) -- equivalent call inferred; original call site unknown
			emitSparks(v13, 10) -- equivalent call inferred; original call site unknown
		end

		local position

		if v5[1] then
			position = v5[1].rest.Position
		end

		if position then
			fadeBreachSound() -- equivalent call inferred; original call site unknown
			v7 = Sound:Play("Other.StoneDoor", position, nil, 0.8, 0.9)
		end

		if not resolveGates() then
			warn("[Lever Jailbreak] no \"Gates\" folder found under BonusMoment_Locations")
			return
		end

		task.delay(9.2, function()
			if v4 == p then
				raiseGates() -- equivalent call inferred; original call site unknown
			end
		end)
		task.spawn(runGateCutscene)
	end,
	BossAwakening = function(p)
		if v4 ~= p then
			return
		end

		v11 = true
		setPromptsEnabled(false) -- equivalent call inferred; original call site unknown
	end
}
return LeverJailbreak