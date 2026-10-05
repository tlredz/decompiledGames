local createVector = vector.create
local GuiService = game:GetService("GuiService")
local HapticService = game:GetService("HapticService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PlatformController = require(ReplicatedStorage:WaitForChild("Client").PlatformController)
local Player = require(ReplicatedStorage.Shared.Player)
local v = Enum.RenderPriority.Camera.Value + 1
local v2 = { 3.7, 41.2, 88.9 }
local gamepad1 = Enum.UserInputType.Gamepad1
local v3 = {
	[Enum.VibrationMotor.Large] = 1,
	[Enum.VibrationMotor.Small] = 0.5
}
local v4 = {
	Fade = {
		1,
		0.9952,
		0.9808,
		0.9569,
		0.9239,
		0.8819,
		0.8315,
		0.773,
		0.7071,
		0.6344,
		0.5556,
		0.4714,
		0.3827,
		0.2903,
		0.1951,
		0.098,
		0
	},
	Pulse = {
		0,
		0.1951,
		0.3827,
		0.5556,
		0.7071,
		0.8315,
		0.9239,
		0.9808,
		1,
		0.9808,
		0.9239,
		0.8315,
		0.7071,
		0.5556,
		0.3827,
		0.1951,
		0
	}
}
local random = Random.new()
local v5 = nil

local function canShake()
	local currentCamera = Workspace.CurrentCamera
	return currentCamera ~= nil and currentCamera.CameraType ~= Enum.CameraType.Scriptable and not GuiService.ReducedMotionEnabled
end

-- equivalent calls inferred from this helper; original call sites unknown
local function smoothstep(near: number, far: number, magnitude: number)
	local v7 = math.clamp((magnitude - near) / (far - near), 0, 1)
	return v7 * v7 * (3 - v7 * 2)
end

local function anchorPosition(center)
	if typeof(center) == "Vector3" then
		return center
	end

	if center:IsA("Player") then
		local rootPart = Player.FindRootPart(center)

		if rootPart == nil then
			return nil
		end

		return rootPart.Position
	else
		if center:IsA("PVInstance") then
			return center:GetPivot().Position
		end

		if center:IsA("Attachment") then
			return center.WorldPosition
		end

		return nil
	end
end

local function rangeGain(range)
	local rootPart = Player.FindRootPart()
	local v7 = anchorPosition(range.Center)

	if rootPart == nil or v7 == nil then
		return 1
	end

	local magnitude = (v7 - rootPart.Position).Magnitude

	if range.Far < magnitude then
		return nil
	end

	if range.Far <= range.Near then
		return 1
	end

	local v8 = 1 - smoothstep(range.Near, range.Far, magnitude)

	if v8 > 0 then
		return v8
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function envelopeAt(value: number, shape: string)
	local v7 = v4[shape]
	local v8 = math.clamp(value, 0, 1) * (#v7 - 1)
	local v9 = math.floor(v8) + 1
	local v10 = math.min(v9 + 1, #v7)
	return (math.lerp(v7[v9], v7[v10], v8 - (v9 - 1)))
end

local function sampleOffset(p, p2: number)
	local v7 = p.elapsed * 21 + p.seed
	local v8 = table.create(#v2)

	for k, v9 in v2 do
		v8[k] = math.noise(v7, v9, p.seed) * 2.2 * p2
	end

	return (Vector3.new(v8[1], v8[2], v8[3]))
end

local function rumblePad(p)
	if not p.rumble then
		return nil
	end

	if (PlatformController.IsConsole() or PlatformController.IsMobile()) and HapticService:IsVibrationSupported(gamepad1) then
		return gamepad1
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function driveMotors(p, p2: number)
	for k, v7 in v3 do
		HapticService:SetMotor(p, k, p2 * v7)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rumble(p, p2: number)
	local v7

	if p.rumble and (PlatformController.IsConsole() or PlatformController.IsMobile()) and HapticService:IsVibrationSupported(gamepad1) then
		v7 = gamepad1
	end

	if v7 ~= nil then
		driveMotors(v7, math.sqrt((math.clamp(p.reach, 0, 1))) * p2) -- equivalent call inferred; original call site unknown
	end
end

local function untouchedSinceLastWrite(p, p2)
	local lastWritten = p.lastWritten
	return lastWritten ~= nil and p2.CFrame:FuzzyEq(lastWritten, 0.0001)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeOffset(state, currentCamera, offset: Vector3)
	local cFrame = currentCamera.CFrame
	local lastWritten = state.lastWritten
	local v7

	if lastWritten == nil then
		v7 = false
	else
		v7 = currentCamera.CFrame:FuzzyEq(lastWritten, 0.0001)
	end

	if v7 then
		cFrame *= CFrame.new(-state.appliedOffset)
	end

	local v8 = cFrame * CFrame.new(offset)
	currentCamera.CFrame = v8
	state.lastWritten = v8
	state.appliedOffset = offset
end

local function stopLive()
	local v7 = v5

	if v7 == nil then
		return
	end

	v5 = nil
	RunService:UnbindFromRenderStep("CameraShake.Offset")
	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		local lastWritten = v7.lastWritten
		local v8

		if lastWritten == nil then
			v8 = false
		else
			v8 = currentCamera.CFrame:FuzzyEq(lastWritten, 0.0001)
		end

		if v8 then
			currentCamera.CFrame *= CFrame.new(-v7.appliedOffset)
		end
	end

	local v8

	if v7.rumble and (PlatformController.IsConsole() or PlatformController.IsMobile()) and HapticService:IsVibrationSupported(gamepad1) then
		v8 = gamepad1
	end

	if v8 ~= nil then
		for k, v9 in v3 do
			HapticService:SetMotor(v8, k, v9 * 0)
		end
	end
end

local function stepLive(p: number)
	local v7 = v5
	local currentCamera = Workspace.CurrentCamera

	if v7 == nil or currentCamera == nil then
		stopLive()
		return
	end

	v7.elapsed += p

	if v7.elapsed >= v7.span then
		stopLive()
		return
	end

	local v9 = envelopeAt(v7.elapsed / v7.span, v7.shape) -- equivalent call inferred; original call site unknown
	v7.sinceSample += p
	local offset = v7.offset

	if offset == nil or v7.hold <= 0 or v7.sinceSample >= v7.hold then
		v7.sinceSample = 0
		offset = sampleOffset(v7, v9 * v7.reach)
		v7.offset = offset
		rumble(v7, v9) -- equivalent call inferred; original call site unknown
	end

	writeOffset(v7, currentCamera, offset) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function begin(p)
	v5 = p
	RunService:BindToRenderStep("CameraShake.Offset", v, stepLive)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function holdFor(samplesPerSecond: number?)
	if samplesPerSecond == nil or samplesPerSecond <= 0 then
		return 0
	end

	return 1 / samplesPerSecond
end

local v6 = {
	Play = function(options)
		local currentCamera = Workspace.CurrentCamera
		local v7

		if currentCamera == nil or currentCamera.CameraType == Enum.CameraType.Scriptable then
			v7 = false
		else
			v7 = not GuiService.ReducedMotionEnabled
		end

		if not v7 then
			return
		end

		stopLive()
		local v8 = options or {}
		local v9 = not v8.Range and 1 or rangeGain(v8.Range)

		if v9 == nil then
			return
		end

		begin({
			span = v8.Seconds or 1,
			reach = (v8.Magnitude or 1) * v9,
			hold = holdFor(v8.SamplesPerSecond),
			shape = v8.Shape == "Pulse" and "Pulse" or "Fade",
			rumble = v8.Rumble ~= false,
			seed = random:NextNumber(0, 1000),
			elapsed = 0,
			sinceSample = 0,
			offset = nil,
			appliedOffset = createVector(0, 0, 0),
			lastWritten = nil
		}) -- equivalent call inferred; original call site unknown
	end,
	Stop = function()
		stopLive()
	end
}
return table.freeze(v6)