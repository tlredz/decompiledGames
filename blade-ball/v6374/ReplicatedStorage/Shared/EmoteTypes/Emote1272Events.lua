local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local v = require3(script.Parent.Emote1272Particles)
local Emote1272Events = {}
local class = {}
class.__index = class
local v2 = {}
local heartbeatConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function unregisterSession(object)
	v2[object] = nil

	if heartbeatConnection and next(v2) == nil then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function registerSession(object)
	v2[object] = true

	if heartbeatConnection then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		for k in v2 do
			k:_update(dt)
		end
	end)
end

local _ = {
	BeamRoad = "2. Beam Squares (Enable)",
	CodedCubes = "3. Coded Cubes (Emit)",
	BigBackdrop = "4. BigBackDrop (Emit)",
	DiscoFloor = "6. Disco Floor (Emit)",
	Lightning = "7. Lightning Strike (Emit)"
}
local v3 = {
	Idle = 4,
	Low = 8,
	Mid = 14,
	High = 22
}
local v4 = {
	StartFrames = { 298, 809 },
	Beats = 6,
	RippleSpeed = 7.5,
	PopTime = 0.16,
	FadeTime = 0.45,
	RedColor = Color3.fromRGB(150, 26, 26),
	BlackColor = Color3.fromRGB(5, 0, 0),
	RedTransparency = 0.22,
	BlackTransparency = 0.4
}
local v5 = {
	{
		Frame = 231,
		Holder = "3. Coded Cubes (Emit)"
	},
	{
		Frame = 253,
		Holder = "3. Coded Cubes (Emit)"
	},
	{
		Frame = 280,
		Holder = "4. BigBackDrop (Emit)"
	},
	{
		Frame = 413,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Left"
	},
	{
		Frame = 435,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Right"
	},
	{
		Frame = 451,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Left"
	},
	{
		Frame = 473,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Right"
	},
	{
		Frame = 692,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Left"
	},
	{
		Frame = 714,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Right"
	},
	{
		Frame = 730,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Left"
	},
	{
		Frame = 752,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Right"
	},
	{
		Frame = 791,
		Holder = "4. BigBackDrop (Emit)"
	},
	{
		Frame = 840,
		Holder = "3. Coded Cubes (Emit)"
	},
	{
		Frame = 854,
		Holder = "3. Coded Cubes (Emit)"
	},
	{
		Frame = 889,
		Holder = "3. Coded Cubes (Emit)"
	},
	{
		Frame = 906,
		Holder = "3. Coded Cubes (Emit)"
	},
	{
		Frame = 1032,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Left"
	},
	{
		Frame = 1054,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Right"
	},
	{
		Frame = 1070,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Left"
	},
	{
		Frame = 1092,
		Holder = "7. Lightning Strike (Emit)",
		Emitter = "Strike_Right"
	}
}
local v6 = { "3. Coded Cubes (Emit)", "4. BigBackDrop (Emit)", "7. Lightning Strike (Emit)" }
local v7 = { "Left", "Middle", "Right" }

local function getBeamTargets(p)
	if p % 4 == 0 then
		return 22, 22, 22
	end

	if p % 2 == 0 then
		return 8, 22, 8
	end

	return 14, 8, 14
end

local function getFrame(p)
	local v8 = not (p.FrameRate > 0) and 60 or p.FrameRate or 60
	return math.clamp(p.TimePosition * v8, 0, 1109), v8
end

function Emote1272Events.new(instance, storage)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		warn("[Emote1272Events] missing HumanoidRootPart")
		return nil
	end

	local object = setmetatable({
		_rootPart = humanoidRootPart,
		_storage = storage,
		_emittersByHolder = {},
		_beamLanes = {},
		_beamsEnabled = nil,
		_floorEntries = {},
		_floorMaxRing = 0,
		_floorVisible = false,
		_visualUpdateElapsed = 0,
		_particles = v.new(storage),
		_lastFrame = nil,
		_track = nil,
		_destroyed = false
	}, class)
	object:_collectEmitters()
	object:_collectBeamLanes()
	object:_collectFloorTiles()
	return object
end

function class:_collectEmitters()
	for _, childName in v6 do
		local child = self._storage:FindFirstChild(childName)
		local parts = {}

		if child then
			for _, part in child:GetChildren() do
				local renderTemplate = part:FindFirstChild("RenderTemplate")

				if not (part:IsA("BasePart") and part:GetAttribute("Transformed") and renderTemplate) then
					continue
				end

				if renderTemplate:IsA("BasePart") then
					renderTemplate.Anchored = true
					renderTemplate.CanCollide = false
					renderTemplate.CanQuery = false
					renderTemplate.CanTouch = false
				end

				for _, effect in renderTemplate:GetDescendants() do
					if effect:IsA("Trail") then
						effect.Enabled = false
						effect:Clear()
					elseif effect:IsA("ParticleEmitter") then
						effect.Enabled = false
					end
				end

				table.insert(parts, part)
			end
		end

		self._emittersByHolder[childName] = parts
	end
end

function class:_collectBeamLanes()
	local _2BeamSquaresEnable = self._storage:FindFirstChild("2. Beam Squares (Enable)")
	local floorAmbient = _2BeamSquaresEnable and _2BeamSquaresEnable:FindFirstChild("FloorAmbient")
	local floor = floorAmbient and floorAmbient:FindFirstChild("Floor")
	local ROADBEAMS = floor and floor:FindFirstChild("ROAD.BEAMS")
	local groupA = ROADBEAMS and ROADBEAMS:FindFirstChild("GroupA")

	if not groupA then
		return
	end

	for _, childName in v7 do
		local child = groupA:FindFirstChild(childName)
		local arrow_Front = child and child:FindFirstChild("Arrow_Front")

		if not (arrow_Front and arrow_Front:IsA("Attachment")) then
			continue
		end

		local beams = {}

		for _, beam in child:GetChildren() do
			if beam:IsA("Beam") then
				table.insert(beams, beam)
			end
		end

		self._beamLanes[childName] = {
			Arrow = arrow_Front,
			Beams = beams
		}
	end

	self:_setBeamsEnabled(false)
	self:_setBeamHeights(0, 0, 0)
	task.defer(function()
		if not self._destroyed then
			self:_refreshBeamConfiguration()
		end
	end)
end

function class:_collectFloorTiles()
	local _6DiscoFloorEmit = self._storage:FindFirstChild("6. Disco Floor (Emit)")
	local tiles = _6DiscoFloorEmit and _6DiscoFloorEmit:FindFirstChild("Tiles")
	local floorOrigin = _6DiscoFloorEmit and _6DiscoFloorEmit:FindFirstChild("FloorOrigin")

	if not (tiles and floorOrigin and floorOrigin:IsA("BasePart")) then
		return
	end

	local parts = {}

	for _, part in tiles:GetChildren() do
		if part:IsA("BasePart") then
			table.insert(parts, part)
		end
	end

	if #parts == 0 then
		return
	end

	local position = parts[1].Position
	local v8 = 1e999

	for i = 2, #parts do
		local v9 = parts[i].Position - position
		local magnitude = Vector2.new(v9.X, v9.Z).Magnitude

		if magnitude > 0.01 and magnitude < v8 then
			v8 = magnitude
		end
	end

	local v9 = v8 == 1e999 and 1 or v8

	for _, part in parts do
		local v11 = part.Position - floorOrigin.Position
		local v12 = v11.X / v9
		local v13 = v11.Z / v9
		local v14 = {
			Part = part,
			Ring = math.sqrt(v12 * v12 + v13 * v13),
			Parity = (math.floor(v12 + 0.5) + math.floor(v13 + 0.5)) % 2,
			Shown = false,
			LastLit = nil
		}
		self._floorMaxRing = math.max(self._floorMaxRing, v14.Ring)
		table.insert(self._floorEntries, v14)
	end

	self:_hideFloor()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreBeamWidth(beam)
	beam:RemoveTag("BeamTweenWidth")
	local targetWidth0 = beam:GetAttribute("TargetWidth0")
	local targetWidth1 = beam:GetAttribute("TargetWidth1")

	if type(targetWidth0) == "number" then
		beam.Width0 = targetWidth0
	end

	if type(targetWidth1) == "number" then
		beam.Width1 = targetWidth1
	end
end

function class:_refreshBeamConfiguration()
	for _, _beamLane in self._beamLanes do
		for _, beam in _beamLane.Beams do
			restoreBeamWidth(beam) -- equivalent call inferred; original call site unknown
			beam.Enabled = self._beamsEnabled
		end
	end
end

function class:_setBeamsEnabled(p)
	if self._beamsEnabled == p then
		return
	end

	self._beamsEnabled = p

	for _, _beamLane in self._beamLanes do
		for _, beam in _beamLane.Beams do
			restoreBeamWidth(beam) -- equivalent call inferred; original call site unknown
			beam.Enabled = p
		end
	end
end

function class:_setBeamHeights(p2, p3, p4)
	local left = self._beamLanes.Left
	local middle = self._beamLanes.Middle
	local right = self._beamLanes.Right

	if left then
		left.Arrow.Position = Vector3.new(0, p2, 0)
	end

	if middle then
		middle.Arrow.Position = Vector3.new(0, p3, 0)
	end

	if right then
		right.Arrow.Position = Vector3.new(0, p4, 0)
	end
end

function class:_updateBeam(p, p2)
	if next(self._beamLanes) == nil then
		return
	end

	if p >= 1106 then
		self:_setBeamsEnabled(false)
		self:_setBeamHeights(0, 0, 0)
	else
		local v8 = p / p2
		local v9 = math.floor(v8 / 0.4643962848297214)
		local v10 = -(math.cos(3.141592653589793 * math.clamp((v8 - v9 * 0.4643962848297214) / 0.4643962848297214, 0, 1)) - 1) / 2
		local high, high2, high3

		if v9 % 4 == 0 then
			high = v3.High
			high2 = v3.High
			high3 = v3.High
		elseif v9 % 2 == 0 then
			high = v3.Low
			high2 = v3.High
			high3 = v3.Low
		else
			high = v3.Mid
			high2 = v3.Low
			high3 = v3.Mid
		end

		local high4, high5, high6

		if v9 > 0 then
			local v11 = v9 - 1

			if v11 % 4 == 0 then
				high4 = v3.High
				high5 = v3.High
				high6 = v3.High
			elseif v11 % 2 == 0 then
				high4 = v3.Low
				high5 = v3.High
				high6 = v3.Low
			else
				high4 = v3.Mid
				high5 = v3.Low
				high6 = v3.Mid
			end
		else
			high4 = 4
			high5 = 4
			high6 = 4
		end

		self:_setBeamsEnabled(true)
		self:_setBeamHeights(math.lerp(high4, high, v10), math.lerp(high5, high2, v10), (math.lerp(high6, high3, v10)))
	end
end

function class:_hideFloor()
	for _, _floorEntry in self._floorEntries do
		_floorEntry.Part.Transparency = 1
		_floorEntry.Part.Color = v4.BlackColor
		_floorEntry.Shown = false
		_floorEntry.LastLit = nil
	end

	self._floorVisible = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getActiveFloorStartFrame(p)
	for i = #v4.StartFrames, 1, -1 do
		if v4.StartFrames[i] <= p then
			return v4.StartFrames[i]
		end
	end

	return nil
end

function class:_updateFloor(p, p2)
	if #self._floorEntries == 0 then
		return
	end

	local activeFloorStartFrame = getActiveFloorStartFrame(p) -- equivalent call inferred; original call site unknown

	if activeFloorStartFrame then
		local v8 = (p - activeFloorStartFrame) / p2
		local v9 = self._floorMaxRing / v4.RippleSpeed + v4.PopTime + v4.Beats * 0.4643962848297214

		if not (v8 < 0 or v9 + v4.FadeTime <= v8) then
			local v10 = not (v9 <= v8) and 1 or 1 - math.clamp((v8 - v9) / v4.FadeTime, 0, 1)
			local v11 = math.floor(v8 / 0.4643962848297214)

			for _, _floorEntry in self._floorEntries do
				local v12 = v8 - _floorEntry.Ring / v4.RippleSpeed

				if v12 <= 0 then
					if _floorEntry.Shown then
						_floorEntry.Part.Transparency = 1
						_floorEntry.Shown = false
					end
				else
					local lastLit = (_floorEntry.Parity + v11) % 2 == 0

					if _floorEntry.LastLit ~= lastLit then
						_floorEntry.Part.Color = lastLit and v4.RedColor or v4.BlackColor
						_floorEntry.LastLit = lastLit
					end

					local redTransparency = lastLit and v4.RedTransparency or v4.BlackTransparency
					_floorEntry.Part.Transparency = 1 - (1 - redTransparency) * math.clamp(v12 / v4.PopTime, 0, 1) * v10
					_floorEntry.Shown = true
				end
			end

			self._floorVisible = true
			return
		end
	end

	if self._floorVisible then
		self:_hideFloor()
	end
end

function class:_emit(p2, p3)
	for _, v8 in self._emittersByHolder[p2] or {} do
		if not p3 or v8.Name == p3 then
			self._particles:Emit(v8, v8.CFrame)
		end
	end
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function crossedFrame(_lastFrame, lastFrame, frame)
	if lastFrame < _lastFrame then
		return _lastFrame < frame or frame <= lastFrame
	end

	return _lastFrame < frame and frame <= lastFrame
end

function class:_fireCrossedEvents(lastFrame)
	local _lastFrame = self._lastFrame

	if _lastFrame == nil then
		self._lastFrame = lastFrame
		return
	end

	for _, v8 in v5 do
		if crossedFrame(_lastFrame, lastFrame, v8.Frame) then
			self:_emit(v8.Holder, v8.Emitter)
		end
	end

	self._lastFrame = lastFrame
end

function class:_update(p)
	if self._destroyed then
		return
	end

	if not self._rootPart.Parent then
		self:Destroy()
		return
	end

	local _track = self._track

	if not _track then
		return
	end

	local v8 = not (_track.FrameRate > 0) and 60 or _track.FrameRate or 60
	local v9 = math.clamp(_track.TimePosition * v8, 0, 1109)
	self:_fireCrossedEvents(v9)
	self._visualUpdateElapsed += p

	if self._visualUpdateElapsed >= 0.03333333333333333 then
		self._visualUpdateElapsed %= 0.03333333333333333
		self:_updateBeam(v9, v8)
		self:_updateFloor(v9, v8)
	end

	self._particles:Update()
end

function class:Start(track)
	if self._destroyed or self._track then
		return
	end

	self._track = track
	local v8 = not (track.FrameRate > 0) and 60 or track.FrameRate or 60
	local lastFrame = math.clamp(track.TimePosition * v8, 0, 1109)
	self._lastFrame = lastFrame
	self:_updateBeam(lastFrame, v8)
	self:_updateFloor(lastFrame, v8)
	registerSession(self) -- equivalent call inferred; original call site unknown
end

function class:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	unregisterSession(self) -- equivalent call inferred; original call site unknown
	self._track = nil
	self:_setBeamsEnabled(false)
	self:_setBeamHeights(0, 0, 0)
	self:_hideFloor()
	self._particles:Destroy()
end

return Emote1272Events