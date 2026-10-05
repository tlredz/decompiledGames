local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local domain = FX:WaitForChild("ControlRework").Domain
local v = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
local insert = table.insert
local v2 = {}
game.Players.PlayerAdded:Connect(function(player)
	local character = player.Character

	-- equivalent calls inferred from this helper; original call sites unknown
	local function forgetLastCharacter()
		if character then
			v2[character] = nil
		end
	end

	local characterAddedConnection = player.CharacterAdded:Connect(function(character2)
		forgetLastCharacter() -- equivalent call inferred; original call site unknown
		character = character2
	end)
	local ancestryChangedConnection = nil
	ancestryChangedConnection = player.AncestryChanged:Connect(function(_, parent)
		if parent then
			return
		end

		characterAddedConnection:Disconnect()
		ancestryChangedConnection:Disconnect()
		forgetLastCharacter() -- equivalent call inferred; original call site unknown
	end)
end)

local function characterOf(instance)
	if typeof(instance) == "Instance" then
		if instance:IsA("Player") then
			return instance.Character
		end

		if instance:IsA("Model") then
			return instance
		end
	elseif type(instance) == "table" and typeof(instance.Character) == "Instance" then
		return instance.Character
	end

	return nil
end

local _ = os.clock()

local function RecolorControlColor(player, color: Color3)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	return color
end

local function RecolorControlColorSequence(player, p)
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		return Util.WrapColorSequenceConstructor(p, player, "ControlFruitVFXColor")
	end

	return p
end

local function addClusterHumanoid(parent)
	local humanoid = Instance.new("Humanoid")
	humanoid.BreakJointsOnDeath = false
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.EvaluateStateMachine = false
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.RequiresNeck = false
	humanoid.Parent = parent
	return humanoid
end

local function LerpColorSequence(sequence, sequence2, p)
	local colorSequenceKeypoints = {}

	for i, keypoint in ipairs(sequence.Keypoints) do
		local keypoint2 = sequence2.Keypoints[i]
		local time = keypoint.Time
		local lerped = keypoint.Value:Lerp(keypoint2.Value, p)
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(time, lerped))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local function TweenColorSequence(p, p2, p3, p4, p5)
	local total = 0
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total += dt
		local v3 = math.clamp(total / p5, 0, 1)
		p[p2] = LerpColorSequence(p3, p4, v3)

		if v3 >= 1 then
			heartbeatConnection:Disconnect()
		end
	end)
end

local function calculateCircleRadiusFromY(p: number, p2: number, p3: number)
	local v3 = math.abs(p2 - p3)

	if p < v3 then
		return 0
	end

	return (math.sqrt(p * p - v3 * v3))
end

local function fadeBeamTransparency(p, duration: number)
	local v3 = {}

	for i, keypoint in ipairs(p.Transparency.Keypoints) do
		v3[i] = {
			t = keypoint.Time,
			v = keypoint.Value
		}
	end

	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 0
	local changedConnection = numberValue.Changed:Connect(function()
		local value = numberValue.Value
		local numberSequenceKeypoints = table.create(#v3)

		for i, v4 in ipairs(v3) do
			local v5 = v4.v + (1 - v4.v) * value
			numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(v4.t, v5)
		end

		p.Transparency = NumberSequence.new(numberSequenceKeypoints)
	end)
	local tween = TweenService:Create(
		numberValue,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Value = 1
		}
	)
	tween:Play()
	tween.Completed:Connect(function()
		if changedConnection then
			changedConnection:Disconnect()
		end

		numberValue:Destroy()
	end)
end

local function scaleEmitterOpacity(state, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in state.Transparency.Keypoints do
		local v3 = math.clamp(1 - keypoint.Value, 0, 1)
		local v4

		if state.LightEmission >= 0.5 then
			v4 = math.min(1, v3 * p)
		else
			v4 = 1 - (1 - v3) ^ p
		end

		local v5 = 1 - v4
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, v5, (math.min(keypoint.Envelope, v5, 1 - v5)))
		)
	end

	state.Transparency = NumberSequence.new(numberSequenceKeypoints)
end

local v3 = {
	Bubble = {
		["AmbienceSmoke|rbxassetid://11871320339"] = {
			targetAlive = 6,
			comp = "opacity"
		},
		["Particle_3|rbxassetid://73010006738592"] = {
			targetAlive = 3,
			comp = "opacity"
		},
		["Particle_4|rbxassetid://76459755203500"] = {
			targetAlive = 3,
			comp = "opacity"
		},
		["Particle_7|rbxassetid://74353605190041"] = {
			targetAlive = 2,
			comp = "opacity"
		}
	},
	GroundAura = {
		["Particle_1|rbxassetid://13395479051"] = {
			targetAlive = 4,
			comp = "none"
		},
		["Particle_8|rbxassetid://13398555541"] = {
			targetAlive = 4,
			comp = "none"
		},
		["Particle_4|rbxassetid://13395481373"] = {
			targetAlive = 3,
			comp = "none"
		}
	},
	WindModel = {
		["Particle_3|rbxassetid://14898208074"] = {
			targetAlive = 8,
			comp = "brightness"
		}
	}
}

local function applyEmitterThinning(folder, p)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v4 = p[emitter.Name .. "|" .. emitter.Texture]

		if not v4 then
			continue
		end

		local midpoint = (emitter.Lifetime.Min + emitter.Lifetime.Max) / 2
		local v6 = emitter.Rate * midpoint

		if midpoint <= 0 or v6 <= v4.targetAlive then
			continue
		end

		emitter.Rate = v4.targetAlive / midpoint

		if v4.comp == "opacity" then
			scaleEmitterOpacity(emitter, v6 / v4.targetAlive)
		elseif v4.comp == "brightness" then
			emitter.Brightness *= v6 / v4.targetAlive
		end
	end
end

local v4 = {
	GetDomeFromPlayer = function(self, character)
		if typeof(character) == "Instance" then
			if character:IsA("Player") then
				character = character.Character
			elseif not character:IsA("Model") then
				character = nil
			end
		elseif type(character) == "table" and typeof(character.Character) == "Instance" then
			character = character.Character
		else
			character = nil
		end

		return character and v2[character]
	end
}

function v4.new(instance, getSize, getCFrame, getGlobe, character)
	local maid = Util.Maid.new()
	local object = setmetatable({
		Reference = instance,
		GetSize = getSize,
		GetCFrame = getCFrame,
		GetGlobe = getGlobe,
		Player = character,
		Maid = maid
	}, {
		__index = v4
	})
	local raycastResult = workspace:Raycast(
		object.Reference:GetAttribute("CFrame").Position,
		Vector3.new(0, -instance:GetAttribute("Radius"), 0),
		raycastParams
	)
	local Y

	if raycastResult then
		Y = raycastResult.Position.Y
	else
		Y = instance:GetAttribute("CFrame").Position.Y
	end

	local v5 = os.clock() + 5
	local now = 0
	local v6 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function SyncRoomMeshSize()
		now = os.clock()
		local hexBubble = object.Mesh and object.Mesh:FindFirstChild("Hex Bubble")
		local hexBubble2 = object.Object and object.Object:FindFirstChild("HexBubble")

		if hexBubble and hexBubble2 then
			hexBubble.Size = hexBubble2.Size
		end
	end

	local function UpdateSize()
		if v5 < os.clock() then
			return
		end

		if os.clock() - now >= 0.06666666666666667 then
			SyncRoomMeshSize() -- equivalent call inferred; original call site unknown
		elseif not v6 then
			v6 = true
			task.delay(0.06666666666666667, function()
				v6 = false
				SyncRoomMeshSize() -- equivalent call inferred; original call site unknown
			end)
		end

		local hexBubble = object.Object.HexBubble
		local v7 = hexBubble.Size.X / 2
		local children = object.Object.Outside:GetChildren()
		local count = #children
		local v8 = 6.283185307179586 * v7 / count
		local cframe = CFrame.new(0, 0, -v7)
		local vector2 = Vector3.new(v8, 1, 10)

		for k, v9 in children do
			v9.CFrame = CFrame.new(hexBubble.Position) * CFrame.Angles(0, 6.283185307179586 / count * k, 0) * cframe
			v9.Size = vector2
			v9.Rock.Acceleration = v9.CFrame.RightVector * 500
		end

		local v9 = math.abs(object.Reference:GetAttribute("CFrame").Position.Y - Y)
		local v10 = v7 < v9 and 0 or math.sqrt(v7 * v7 - v9 * v9) or 0
		local particle_7 = hexBubble.Ground.Particle_7
		hexBubble.Ground.CFrame = CFrame.new(0, (Y or 0) - hexBubble.CFrame.Position.Y, 0)
		particle_7.Size = NumberSequence.new(0.6666666666666666 * v10 * 2)
		particle_7.Enabled = true
		local v11 = hexBubble.Size.X / 2 + 2
		hexBubble.Attachment1.CFrame = CFrame.new(-v11, 0, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		hexBubble.Attachment2.CFrame = CFrame.new(v11, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0)

		for _, beam in pairs(hexBubble:GetChildren()) do
			if not beam:IsA("Beam") then
				continue
			end

			if not beam:GetAttribute("_Width0") then
				beam:SetAttribute("_Width0", beam.Width0)
			end

			if not beam:GetAttribute("_Width1") then
				beam:SetAttribute("_Width1", beam.Width1)
			end

			beam.CurveSize0 = v11 * 4 / 3
			beam.CurveSize1 = v11 * 4 / 3
			beam.Width0 = beam:GetAttribute("_Width0") * v11 / 100
			beam.Width1 = beam:GetAttribute("_Width1") * v11 / 100
		end
	end

	object.Object = object.Maid:GiveTask(domain.Bubble:Clone())
	applyEmitterThinning(object.Object, v3.Bubble)
	local ground = object.Object.HexBubble:FindFirstChild("Ground")

	if ground then
		local particle_1 = ground:FindFirstChild("Particle_1")
		local particle_2 = ground:FindFirstChild("Particle_2")

		if particle_1 and particle_2 and particle_1:IsA("ParticleEmitter") and particle_2:IsA("ParticleEmitter") then
			particle_2:Destroy()
			scaleEmitterOpacity(particle_1, 2)
		end
	end

	for _, beam in object.Object.HexBubble:GetChildren() do
		if beam:IsA("Beam") then
			beam.Segments = 60
		end
	end

	object.Object.HexBubble.CFrame = object.GetCFrame()
	object.Object.HexBubble.Transparency = 1
	object.Object.HexBubble.Color = Color3.fromRGB(255, 255, 255)
	Util.SetParentOverrideWithColor(object.Object, workspace._WorldOrigin, character, "ControlFruitVFXColor", true)
	object.Mesh = domain.Room:Clone()
	local mesh = object.Mesh
	local humanoid = Instance.new("Humanoid")
	humanoid.BreakJointsOnDeath = false
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.EvaluateStateMachine = false
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.RequiresNeck = false
	humanoid.Parent = mesh
	object.Mesh["Hex Bubble"].CFrame = object.GetCFrame()
	Util.SetParentOverrideWithColor(object.Mesh, object.Object, character, "ControlFruitVFXColor", true)
	local sizeChangedConnection = object.Object.HexBubble:GetPropertyChangedSignal("Size"):Connect(UpdateSize)
	maid:GiveTask(function()
		if sizeChangedConnection then
			pcall(sizeChangedConnection.Disconnect, sizeChangedConnection)
			sizeChangedConnection = nil
		end
	end)
	object.Maid:GiveTask(object.Object.HexBubble:GetPropertyChangedSignal("CFrame"):Connect(function()
		object.Mesh["Hex Bubble"].CFrame = object.Object.HexBubble.CFrame
	end))
	object.PulseAnim = Util.Anims:Get(object.Object, "RoomPulse")
	task.spawn(object.Start, object)

	if typeof(character) == "Instance" then
		if character:IsA("Player") then
			character = character.Character
		elseif not character:IsA("Model") then
			character = nil
		end
	elseif type(character) == "table" and typeof(character.Character) == "Instance" then
		character = character.Character
	else
		character = nil
	end

	if character then
		v2[character] = object

		if not game.Players:GetPlayerFromCharacter(character) then
			character.Destroying:Once(function()
				if v2[character] == object then
					v2[character] = nil
				end
			end)
		end
	end

	return object
end

function v4:_SnapshotShapesForRebind()
	local shapeSnapshot = {}

	for _, editableShape in pairs(self.EditableShapes) do
		local positions = table.create(#editableShape.Vertices)

		for i, v6 in ipairs(editableShape.Vertices) do
			positions[i] = v6.OriginalPosition.Position
		end

		table.insert(shapeSnapshot, {
			center = editableShape.CFrame.Position,
			normal = editableShape.CFrame.LookVector,
			vertices = positions,
			color = editableShape.Color,
			transparency = editableShape.Transparency
		})
	end

	self._ShapeSnapshot = shapeSnapshot
end

function v4:_RebindShapesFromFixedMesh(editableMesh, data)
	local _ShapeSnapshot = self._ShapeSnapshot
	assert(_ShapeSnapshot, "No shape snapshot")
	local rawset2 = rawset
	local v5 = {
		GetAttribute = function(self, p3)
			return self.__attributes[p3]
		end,
		SetAttribute = function(self, p3, p4)
			self.__attributes[p3] = p4
		end,
		GetOriginalCFrame = function(p2)
			return data.NewMesh.CFrame * p2.OriginalCFrame
		end,
		GetCFrame = function(p2)
			return data.NewMesh.CFrame * p2.CFrame
		end,
		UpdateWorldCFrame = function(self)
			local v6 = data.NewMesh.Size.X / data.OriginalMeshScale

			for _, v7 in pairs(self.Vertices) do
				local position = v7.OriginalPosition.Position
				local pointToWorldSpace = (self.CFrame - self.CFrame.Position + self.CFrame.Position / v6):PointToWorldSpace(position)
				editableMesh:SetPosition(v7.ID, pointToWorldSpace)
			end
		end,
		SetCFrame = function(self, p2, p3)
			local objectSpace = data.NewMesh.CFrame:ToObjectSpace(p2)
			local v6 = objectSpace - objectSpace.Position
			local position = objectSpace.Position
			local cFrame = CFrame.new(position) * v6
			self.CFrame = cFrame
			self.Position = cFrame.Position

			if p3 then
				data.WorldCFrames[self] = nil
			else
				data.WorldCFrames[self] = true
			end

			self:UpdateWorldCFrame()
		end,
		SetTransparency = function(self, transparency)
			if self.Transparency == transparency or math.abs(self.Transparency - transparency) < 0.01 then
				return
			end

			for _, color in pairs(self.Colors) do
				editableMesh:SetColorAlpha(color, 1 - transparency)
			end

			self.Transparency = transparency
		end,
		SetColor = function(self, color)
			if self.Color == color then
				return
			end

			for _, color2 in pairs(self.Colors) do
				editableMesh:SetColor(color2, color)
			end

			self.Color = color
		end
	}
	local editableShapes = {}

	for i, v7 in ipairs(_ShapeSnapshot) do
		editableShapes[i] = setmetatable({
			Colors = {},
			Vertices = {},
			CFrame = CFrame.new(v7.center),
			OriginalCFrame = CFrame.new(v7.center),
			Color = v7.color,
			Transparency = v7.transparency,
			__attributes = {}
		}, {
			__index = v5
		})
	end

	local clock = os.clock
	local ipairs2 = ipairs
	local now = clock()
	local lastTime = os.clock()
	local v7 = table.create(#_ShapeSnapshot)

	for _, v8 in _ShapeSnapshot do
		local v9 = v8.center // 6
		local v10 = v7[v9]

		if v10 == nil then
			v10 = {}
			v7[v9] = v10
		end

		table.insert(v10, v8)
	end

	local function findNearestShape(p2)
		local v8 = p2 // 6
		local v9 = 1e999
		local v10 = nil

		for i = -1, 1 do
			for i2 = -1, 1 do
				for i3 = -1, 1 do
					if not (i ~= 0 or i3 ~= 0 or i2 ~= 0) then
						continue
					end

					local v12 = v7[v8 + Vector3.new(i3, i, i2)]

					if not v12 then
						continue
					end

					for k, v13 in v12 do
						local magnitude = (p2 - v13.center).Magnitude

						if not (magnitude < v9) then
							continue
						end

						v10 = k
						v9 = magnitude
					end
				end
			end
		end

		return v10
	end

	for _, v8 in ipairs2((editableMesh:GetFaces())) do
		if clock() - now > 0.006666666666666667 then
			task.wait()
			now = clock()
		end

		local faceVertices = editableMesh:GetFaceVertices(v8)
		local v9 = createVector(0, 0, 0)

		for _, v10 in ipairs2(faceVertices) do
			if clock() - now > 0.006666666666666667 then
				task.wait()
				now = clock()
			end

			v9 += editableMesh:GetPosition(v10)
		end

		local nearestShape = findNearestShape(v9 / #faceVertices)

		if not nearestShape then
			continue
		end

		if clock() - now > 0.006666666666666667 then
			task.wait()
			now = clock()
		end

		local colors = editableShapes[nearestShape].Colors

		for _, v10 in editableMesh:GetFaceColors(v8) do
			insert(colors, v10)
		end
	end

	local v8 = os.clock() - lastTime
	print(string.format("calced in %.4fms", v8 * 1000))

	for _, v9 in ipairs2(editableShapes) do
		local color = v9.Color
		local transparency = v9.Transparency
		local colors = v9.Colors
		local abs = math.abs

		function v9:SetColor(color2)
			if color == color2 then
				return
			end

			for k, v11 in colors do
				editableMesh:SetColor(v11, color2)
			end

			color = color2
			self.Color = color2
		end

		local colors2 = colors

		function v9:SetTransparency(p3: number)
			if transparency == p3 or abs(transparency - p3) < 0.01 then
				return
			end

			for k, v14 in colors2 do
				editableMesh:SetColorAlpha(v14, 1 - p3)
			end

			transparency = p3
			rawset2(self, "Transparency", p3)
		end
	end

	self.EditableMesh = editableMesh
	self.EditableShapes = editableShapes
	self._ShapeSnapshot = nil
end

function v4:_BuildPulseCache()
	if self._PulseCache then
		return
	end

	local cFrame = self.NewMesh.CFrame
	local v5 = self.NewMesh.Size.X * 0.5
	local pulseCache = {}

	for _, editableShape in pairs(self.EditableShapes) do
		local objectSpace = cFrame:ToObjectSpace((editableShape:GetCFrame()))
		local position = objectSpace.Position
		local height = math.clamp((position.Y / v5 + 1) * 0.5, 0, 1)
		pulseCache[#pulseCache + 1] = {
			shape = editableShape,
			height01 = height,
			normal = position.Unit,
			localCF = objectSpace,
			color = editableShape.Color,
			transparency = editableShape.Transparency or 0,
			active = false
		}
	end

	table.sort(pulseCache, function(a, b)
		return a.height01 > b.height01
	end)
	self._PulseCache = pulseCache
end

function v4.Pulse(p, _, ...)
	p.PulseAnim.Priority = Enum.AnimationPriority.Action
	p.PulseAnim:Play()
end

function v4:_UpdatePulses()
	if self._PulseConn then
		return
	end

	self:_BuildPulseCache()
	local _ = self.Fresnel
	self._PulseConn = task.spawn(function()
		while task.wait(0.022222222222222223) do
			if self._ActivePulses and #self._ActivePulses ~= 0 then
				local now = os.clock()
				local cFrame = self.NewMesh.CFrame

				for i = #self._ActivePulses, 1, -1 do
					local _ActivePuls = self._ActivePulses[i]

					if (now - _ActivePuls.start) / _ActivePuls.duration >= 1 then
						table.remove(self._ActivePulses, i)
					end
				end

				for _, v5 in ipairs(self._PulseCache) do
					local color = v5.color
					local transparency = v5.transparency
					local v6 = createVector(0, 0, 0)
					local flag = false

					for _, _ActivePuls in ipairs(self._ActivePulses) do
						local v7 = (now - _ActivePuls.start) / _ActivePuls.duration

						if v7 < 0 or v7 > 1 then
							continue
						end

						local v8 = 1 - v7
						local v9 = math.abs(v5.height01 - v8)

						if _ActivePuls.band < v9 then
							continue
						end

						local v10 = 1 - v9 / _ActivePuls.band
						local v11 = v10 * v10
						flag = true
						v6 += v5.normal * (v11 * _ActivePuls.strength)
						color = color:Lerp(_ActivePuls.color, v11)

						if _ActivePuls.affectTransparency then
							transparency = math.min(transparency, 1 - v11)
						end
					end

					if flag then
						v5.shape.Pulsing = true
						local v7 = v5.localCF * CFrame.new(v6)
						v5.shape:SetCFrame(cFrame * v7, true)
						v5.shape:SetColor(color)
						v5.shape:SetTransparency(transparency)
					else
						v5.shape.Pulsing = nil
						v5.shape:SetCFrame(cFrame * v5.localCF, true)
						v5.shape:SetColor(v5.color)
						v5.shape:SetTransparency(v5.transparency)
					end
				end
			else
				self._PulseConn = nil
				local _ = self.Fresnel
				break
			end
		end
	end)
end

function v4.UpdateColor(object, color, p, value)
	local v5 = value or 1

	if color == nil then
		color = Color3.fromRGB(54, 78, 216)
	end

	local player = object.Player

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		color = Util.WrapColor3Constructor(color, player, "ControlFruitVFXColor")
	end

	local v6 = p == nil and createVector(0, 0.55, 1) or p
	local player2 = object.Player
	local color2 = Color3.new(v6.X, v6.Y, v6.Z)

	if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
		color2 = Util.WrapColor3Constructor(color2, player2, "ControlFruitVFXColor")
	end

	local vector2 = Vector3.new(color2.R, color2.G, color2.B)
	local v7 = {}
	local hexBubble = object.Object:FindFirstChild("HexBubble")

	if hexBubble then
		for _, beam in pairs(hexBubble:GetChildren()) do
			if not beam:IsA("Beam") then
				continue
			end

			if not beam:GetAttribute("OriginalColor") then
				beam:SetAttribute("OriginalColor", beam.Color)
			end

			table.insert(v7, {
				obj = beam,
				start = beam.Color,
				goal = color == nil and beam:GetAttribute("OriginalColor") or ColorSequence.new(color)
			})
		end
	end

	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(object.Mesh["Hex Bubble"], TweenInfo.new(v5 or 0.01), {
		Color = color
	}):Play()
	local globe = object:GetGlobe()
	local vertexColor = globe and globe.Mesh.VertexColor
	task.spawn(function()
		local total = 0

		while total < v5 do
			local v8 = task.wait()

			if object.Destroyed then
				break
			end

			total += v8
			local v9 = math.clamp(total / v5, 0, 1)
			local v10 = v9 * v9

			if globe then
				globe.Mesh.VertexColor = vertexColor:Lerp(vector2, v10)
			end

			for _, v11 in v7 do
				v11.obj.Color = LerpColorSequence(v11.start, v11.goal, v10)
			end
		end
	end)
end

function v4.SetMaxTransparency(_, _) end

function v4.Start(data)
	for _ = 2, 6 do
		local clone = data.Object.Outside.Edge:Clone()
		clone.Parent = data.Object.Outside
	end

	local rotation = data.Object.HexBubble.CFrame.Rotation
	Util.Anims:Get(data.Object, "RoomBreathing"):Play(0.5, 1, 0.4)
	local total = 0
	local v5 = -1

	while true do
		local v6 = task.wait()

		if data.Destroyed then
			break
		end

		local size = data.GetSize()
		local hexBubble = data.Object.HexBubble
		total += v6
		local v7 = total / 1
		local v8 = not (v7 <= 0.35) and 1 or TweenService:GetValue(
			(v7 - 0) / 0.35,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		)
		rotation *= CFrame.Angles(0, -0.1308996938995747 * v8 * v6, 0)
		hexBubble.CFrame = CFrame.new(data.GetCFrame().Position) * rotation

		if not (math.abs(size - v5) > math.max(v5, 1) * 0.0015) then
			continue
		end

		hexBubble.Size = createVector(1, 1, 1) * size
		v5 = size
	end
end

function v4.Retract(_) end

function v4:Destroy()
	if self.Destroyed then
		return
	end

	self.Destroyed = true
	task.spawn(function()
		TweenService:Create(self.Mesh["Hex Bubble"], TweenInfo.new(0.5), {
			Transparency = 1
		}):Play()

		for _, effect in self.Object.HexBubble:GetDescendants() do
			if effect:IsA("ParticleEmitter") then
				effect.Enabled = false
			elseif effect:IsA("Beam") then
				TweenService:Create(effect, TweenInfo.new(0.5), {
					Width0 = effect.Width0 * 0.333,
					Width1 = effect.Width1 * 0.333
				}):Play()
				fadeBeamTransparency(effect, 0.5)
			end
		end
	end)
	task.delay(1, function()
		self.Maid:DoCleaning()
	end)
	task.delay(1, function()
		pcall(function()
			self.EditableMesh:Destroy()
		end)
		pcall(function()
			self.Mesh:Destroy()
		end)
	end)
end

local model = Instance.new("Model")
model.Name = "DomeRocks"
model.Parent = workspace._WorldOrigin
local class = {}
class.__index = class

function class.new(template, p: number, parent)
	local object = setmetatable({}, class)
	object._template = template
	object._pool = table.create(p)
	object._inUse = {}
	object._parent = parent

	for _ = 1, p do
		local clone = template:Clone()
		clone.Parent = parent
		clone.Size = createVector(0, 0, 0)
		clone.Transparency = 1
		clone.CanCollide = false
		table.insert(object._pool, clone)
	end

	return object
end

function class:GetPart()
	local clone = table.remove(self._pool)

	if not clone then
		clone = self._template:Clone()
		clone.Parent = self._parent
	end

	self._inUse[clone] = true
	clone.Parent = self._parent
	clone.Transparency = 0
	clone.CanCollide = true
	return clone
end

function class:ReturnPart(p2)
	if not (p2 and p2.Parent and self._inUse[p2]) then
		return
	end

	self._inUse[p2] = nil
	p2.Size = createVector(0, 0, 0)
	p2.Transparency = 1
	p2.CanCollide = false
	p2.CFrame = CFrame.new(0, -1000000, 0)
	table.insert(self._pool, p2)
end

function class:ReturnAll(list)
	for i = 1, #list do
		self:ReturnPart(list[i])
	end
end

local neon = Enum.Material.Neon
local color = Color3.fromRGB(146, 175, 221)
local clone = domain:WaitForChild("Cube"):WaitForChild("Inner"):Clone()
clone.Name = "RockTemplate"
clone:ClearAllChildren()
clone.Anchored = true
clone.CanCollide = true
clone.CanTouch = true
clone.CastShadow = false
clone.CanQuery = false
clone.Material = neon
clone.Color = color
clone.Size = createVector(2, 2, 2)
local v5 = class.new(clone, 70, model)
local lightningBoltShafi = Util.LightningBoltShafi

local function NewBolt(attachment, attachment2, value: number?, player)
	local v6 = lightningBoltShafi.new(attachment, attachment2, value or 35, 0.7, workspace.Terrain)
	local curveSize = math.random(-15, 25)
	local curveSize2 = math.random(-15, 25)
	v6.CurveSize0 = curveSize
	v6.CurveSize1 = curveSize2
	local maxRadius = math.random(20, 35)
	v6.MinRadius = 5
	v6.MaxRadius = maxRadius
	v6.Frequency = 0.5
	v6.AnimationSpeed = math.random(5, 9)
	local maxThicknessMultiplier = 0.5 + math.random() * 5.75
	v6.MinThicknessMultiplier = 0.3
	v6.MaxThicknessMultiplier = maxThicknessMultiplier
	v6.MinTransparency = 0
	v6.MaxTransparency = 1
	v6.PulseSpeed = 35
	v6.PulseLength = 1000000
	v6.FadeLength = 0.2
	v6.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(177, 153, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(203, 158, 255))
	})
	local color2 = v6.Color

	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent then
		color2 = Util.WrapColorSequenceConstructor(color2, player, "ControlFruitVFXColor")
	end

	v6.Color = color2
	v6.ContractFrom = 0.5
	v6.ColorOffsetSpeed = 3
	return v6
end

return function(player)
	if player.Stage == "Fetch" then
		local __Room = player.Character:FindFirstChild("__Room")

		if __Room then
			return v[__Room]
		end

		warn("roomTag not found")
	else
		if player.Stage == "FromPlayer" then
			return v4:GetDomeFromPlayer(player.Player)
		end

		if player.Stage == "Start" and not v[player.Domain] then
			local v6 = v4.new(player.Domain, player.GetSize, player.GetCFrame, player.GetGlobe, player.Player)
			v[player.Domain] = v6
			local v7 = true
			player.Domain.Destroying:Once(function()
				v7 = false
				v[player.Domain]:Destroy()
				v[player.Domain] = nil
			end)
			task.spawn(function()
				local clones = {}
				local v8 = {}
				local v9 = nil
				local v10 = nil
				task.delay(1.4, function()
					if not v7 then
						return
					end

					for i = 1, 7 do
						local scale = domain.Cube:GetScale()
						local clone2 = domain.Cube:Clone()

						if i > 2 then
							scale = scale - 0.1 + math.random() * 0.15 or scale
						end

						clone2:ScaleTo(scale)
						Util.SetParentOverrideWithColor(
							clone2,
							workspace._WorldOrigin,
							player.Player,
							"ControlFruitVFXColor"
						)

						for _, child in clone2.Trails:GetChildren() do
							child.Enabled = false
						end

						for _, part in clone2:GetChildren() do
							if not part:IsA("BasePart") then
								continue
							end

							local size = part.Size
							part.Size = createVector(0, 0, 0)
							TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Size = size
							}):Play()
						end

						for _, child in clone2.Trails:GetChildren() do
							local v11 = child
							task.delay(0.5, function()
								v11.Enabled = true
							end)
						end

						table.insert(clones, clone2)
					end

					local mesh = v6:GetGlobe().Mesh
					local v11 = false
					tick()

					local function updCol()
						local color2 = Color3.new(mesh.VertexColor.X, mesh.VertexColor.Y, mesh.VertexColor.Z)

						for _, v12 in clones do
							v12.Outline.Color = color2:Lerp(Color3.new(1, 1, 1), 0.3)
							v12.Inner.Color = color2:Lerp(Color3.new(1, 1, 1), 0.6)
							v12.Trails.TrailSub.Color = ColorSequence.new(color2)
							v12.Trails.Trail.Color = ColorSequence.new(color2:Lerp(Color3.new(1, 1, 1), 0.3), color2)
							v12.Trails.Trail1.Color = ColorSequence.new(color2:Lerp(Color3.new(1, 1, 1), 0.3), color2)
						end
					end

					updCol()
					local vertexColorChangedConnection = mesh:GetPropertyChangedSignal("VertexColor"):Connect(updCol)

					local function EndCubes()
						if vertexColorChangedConnection then
							vertexColorChangedConnection:Disconnect()
							vertexColorChangedConnection = nil
						end
					end

					v10 = EndCubes

					local function UpdateCubes(p)
						if v6.Object:GetAttribute("Ult") == nil or v6.Object:GetAttribute("Ult") == false then
							if v11 == true then
								v11 = false

								for _, v12 in pairs(v8) do
									v12:Destroy()
								end
							end
						elseif v6.Object:GetAttribute("Ult") == true and v11 == false then
							task.spawn(function()
								v11 = true

								local function pickRandomClosestCube(clones2, position: Vector3, value: number?, p2)
									local v12 = {}

									for k, item in pairs(clones2) do
										if not (item and item ~= p2) then
											continue
										end

										local magnitude = (item.PrimaryPart.Position - position).Magnitude
										v12[#v12 + 1] = {
											Key = k,
											Cube = item,
											Distance = magnitude
										}
									end

									if #v12 == 0 then
										return nil, nil
									end

									table.sort(v12, function(a, b)
										return a.Distance < b.Distance
									end)
									local v14 = math.max(1, (math.floor(#v12 * (value or 0.35))))
									local v15 = v12[math.random(1, v14)]
									return v15.Key, v15.Cube
								end

								for _, v12 in pairs(clones) do
									local _, v13 = pickRandomClosestCube(clones, v12.Inner.Position, 0.25, v12)
									local newBolt = NewBolt(
										v13.Inner.Attachment,
										v12.Inner.Attachment,
										math.random(10, 15),
										player.Player
									)
									v8[newBolt] = newBolt
								end
							end)
						end

						local hexBubble = v[player.Domain].Object.HexBubble
						local v12 = hexBubble.Size.X / 2
						local v13 = v12 / 2
						local v14 = v13 / 2

						for k, v15 in clones do
							local v16 = not (k > 2) and 0 or k - 1.5707963267948966 or 0
							local v17 = math.noise(k, p)
							local v18 = k % 2 == 0 and 1 or -1
							v15:PivotTo(CFrame.new(hexBubble.Position) * CFrame.Angles(0, v16 + math.rad(p * 40), 0) * CFrame.new(
								0,
								v13 + math.sin(p) * (v14 + v17 * v16) * v18,
								(v12 + 5) * v18
							))
						end
					end

					v9 = UpdateCubes
				end)
				local clone2 = domain.SphereModel:Clone()
				clone2:PivotTo(player.GetCFrame())
				clone2:ScaleTo(0.01)
				Util.SetParentOverrideWithColor(clone2, workspace._WorldOrigin, player.Player, "ControlFruitVFXColor")
				local specialMeshes = {}

				for _, specialMesh in pairs(clone2:GetDescendants()) do
					if specialMesh:IsA("SpecialMesh") and specialMesh.VertexColor.Z > 1 then
						table.insert(specialMeshes, specialMesh)
					end
				end

				local clone3 = domain.GroundAura:Clone()
				applyEmitterThinning(clone3, v3.GroundAura)
				clone3:PivotTo(player.GetCFrame() * CFrame.new(0, 3, 0))
				clone3:ScaleTo(0.01)
				Util.SetParentOverrideWithColor(clone3, workspace._WorldOrigin, player.Player, "ControlFruitVFXColor")
				task.spawn(function()
					for _, emitter in pairs(clone3:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = true
						local v11 = emitter
						task.delay(1.3, function()
							v11.Enabled = false
						end)
					end
				end)
				local ringBeam = clone2.RingBeam
				ringBeam.CFrame = clone2.PrimaryPart.CFrame
				ringBeam.AlignPosition.Position = ringBeam.Position
				ringBeam.AlignPosition.Enabled = true
				ringBeam.Anchored = false
				ringBeam.Massless = true
				ringBeam.AngularVelocity.Enabled = true
				ringBeam.AngularVelocity.AngularVelocity = createVector(0, 10, 0)

				for _, effect in pairs(ringBeam:GetDescendants()) do
					if effect:IsA("ParticleEmitter") then
						effect:Emit(effect:GetAttribute("EmitCount"))
					elseif effect:IsA("Beam") then
						local v11 = effect
						task.delay(1.25, function()
							TweenService:Create(v11, TweenInfo.new(0.5), {
								Width0 = v11.Width0 * 0.333,
								Width1 = v11.Width1 * 0.333
							}):Play()
							fadeBeamTransparency(v11, 0.5)
						end)
					end
				end

				local flag = true
				task.delay(5, function()
					flag = false
					clone2:Destroy()
					clone3:Destroy()
				end)
				task.spawn(function()
					if _G.FastMode then
						return
					end

					local cFrame = v[player.Domain].Object.HexBubble.CFrame
					local raycastParams2 = RaycastParams.new()
					raycastParams2.FilterDescendantsInstances = { workspace.Map }
					raycastParams2.FilterType = Enum.RaycastFilterType.Include
					raycastParams2.IgnoreWater = false
					local v11 = table.create(70)

					for i = 1, 70 do
						local v12 = i / 70 * 3.141592653589793 * 2
						local angleCos = math.cos(v12)
						local angleSin = math.sin(v12)
						local part = v5:GetPart()
						local player2 = player.Player
						local color2 = color

						if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
							color2 = Util.WrapColor3Constructor(color2, player2, "ControlFruitVFXColor")
						end

						part.Color = color2
						local vector2 = Vector3.new(math.random(2, 3), math.random(2, 3), math.random(2, 3))
						part.Size = vector2
						local v16 = math.random() * 1.8 + 1.2
						local vector3 = Vector3.new(v16, v16 * (0.6 + math.random() * 0.8), v16)
						part.Size *= vector3
						v11[i] = {
							part = part,
							baseScale = vector2,
							angleCos = angleCos,
							angleSin = angleSin,
							initScale = vector3,
							growthMul = 0.6 + math.random() * 1.4,
							spawnTime = tick(),
							alive = true
						}
					end

					local position = cFrame.Position

					for i = 1, 70 do
						local v12 = v11[i]

						if not (v12 and v12.alive) then
							continue
						end

						local v13 = position + Vector3.new(v12.angleCos * 30, 2, v12.angleSin * 30) + createVector(
							0,
							2,
							0
						)
						local raycastResult = workspace:Raycast(v13, createVector(0, -100, 0), raycastParams2)

						if raycastResult then
							v12.part.CFrame = CFrame.new(raycastResult.Position)
							local size = v12.part.Size
							v12.part.Size = createVector(0, 0, 0)
							TweenService:Create(v12.part, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
								Size = size
							}):Play()
						else
							v12.alive = false
							v5:ReturnPart(v12.part)
						end
					end

					local flag2 = true
					local v12 = true
					task.delay(0.6, function()
						v12 = false
					end)
					task.delay(1.6, function()
						v12 = true

						for i = 1, 70 do
							local v13 = v11[i]

							if v13 and v13.alive then
								TweenService:Create(
									v13.part,
									TweenInfo.new(
										math.random(30, 90) / 100,
										Enum.EasingStyle.Back,
										Enum.EasingDirection.InOut
									),
									{
										Size = createVector(0, 0, 0)
									}
								):Play()
							end
						end

						task.wait(0.9)
						flag2 = false

						for i = 1, 70 do
							local v13 = v11[i]

							if not (v13 and v13.alive) then
								continue
							end

							v13.alive = false
							v5:ReturnPart(v13.part)
						end
					end)
					local parts = table.create(70)
					local v13 = table.create(70)
					local v14 = 0

					while flag2 do
						local v15 = math.max(player.GetSize() / 2 - 15, 30)
						local position2 = cFrame.Position
						local now = tick()
						local v16 = not v12 and now - v14 >= 0.1

						if v16 then
							v14 = now
						end

						local count = 0

						for i = 1, 70 do
							local v17 = v11[i]

							if not (v17 and v17.alive and v17.part.Parent) then
								continue
							end

							local v18 = position2 + Vector3.new(v17.angleCos * v15, 2, v17.angleSin * v15)
							local v19 = math.random(-v17.baseScale.Y, v17.baseScale.Y) * 2
							local v20 = CFrame.new(v18, position2) * CFrame.new(0, v19, 0)

							if v16 then
								local v21 = math.max(0, now - v17.spawnTime)
								local v22 = v17.growthMul * 3 * v21
								local initScale = v17.initScale
								v17.part.Size = v17.baseScale * Vector3.new(
									initScale.X + v22,
									initScale.Y + v22,
									initScale.Z + v22
								)
							end

							count += 1
							parts[count] = v17.part
							v13[count] = v20
						end

						if count > 0 then
							workspace:BulkMoveTo(parts, v13)
						end

						task.wait(0.016666666666666666)
					end
				end)
				local model2 = Instance.new("Model")
				model2.Parent = workspace._WorldOrigin
				task.spawn(function()
					local RunService2 = game:GetService("RunService")
					local v11 = {
						Center = clone2.PrimaryPart.Position,
						ringRadii = { 23, 21, 19 },
						ringHeights = { 0, 5, 10 },
						pointsPerRing = 10,
						beamThickness = 1.5,
						beamColor = 0,
						beamTransparency = 0,
						beamBrightness = 5,
						beamFaceCamera = true,
						radiusExpansion = 0,
						heightExpansion = 0,
						rotation = 0,
						drift = 0,
						startAnchored = true
					}
					local player2 = player.Player
					local colorSequence = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(51, 95, 255)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(58, 88, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 95, 255))
					})

					if typeof(player2) == "Instance" and player2:IsA("Player") and player2.Parent then
						colorSequence = Util.WrapColorSequenceConstructor(
							colorSequence,
							player2,
							"ControlFruitVFXColor"
						)
					end

					v11.beamColor = colorSequence
					v11.radiusExpansion = {
						enabled = true,
						rate = 8,
						maxScale = 12,
						minScale = 1,
						phaseOffset = 125.35,
						pulse = false
					}
					v11.heightExpansion = {
						enabled = true,
						rate = 5,
						maxScale = 50,
						minScale = 1,
						phaseOffset = 15,
						pulse = false
					}
					v11.rotation = {
						enabled = true,
						degreesPerSecond = 350,
						clockwise = true
					}
					v11.drift = {
						xAmt = 10.5,
						yAmt = 25,
						zAmt = 10.5
					}
					local center = v11.Center
					local ringRadii = v11.ringRadii
					local ringHeights = v11.ringHeights
					local pointsPerRing = v11.pointsPerRing
					local beamThickness = v11.beamThickness
					local beamColor = v11.beamColor
					local v12 = {}
					local v13 = {}

					for i, baseRadius in ipairs(ringRadii) do
						local baseHeight = ringHeights[i] or 0
						v12[i] = {}

						for i2 = 1, pointsPerRing do
							local v16 = (i2 - 1) / pointsPerRing * 3.141592653589793 * 2
							local vector2 = Vector3.new(math.cos(v16), 0, (math.sin(v16)))
							local v17 = center + vector2 * baseRadius + Vector3.new(0, baseHeight, 0)
							local part = Instance.new("Part")
							part.Transparency = 1
							part.CanCollide = false
							part.Anchored = v11.startAnchored
							part.CFrame = CFrame.new(v17)
							part.Parent = model2
							v12[i][i2] = {
								part = part,
								baseRadius = baseRadius,
								baseHeight = baseHeight,
								radialDir = vector2,
								randomOffset1 = math.random() * 3.141592653589793 * 2,
								randomOffset2 = math.random() * 3.141592653589793 * 2,
								randomOffset3 = math.random() * 3.141592653589793 * 2,
								randomSpeed1 = v11.drift.xAmt > 0 and 0.3 + math.random() / 5 or 0.3,
								randomSpeed2 = v11.drift.yAmt > 0 and 0.2 + math.random() / 5 or 0.2
							}
						end
					end

					local function makeBeam(part, part2)
						local beam = Instance.new("Beam")
						local attachment = Instance.new("Attachment")
						local attachment2 = Instance.new("Attachment")
						attachment.Parent = part
						attachment2.Parent = part2
						beam.Attachment0 = attachment
						beam.Attachment1 = attachment2
						beam.Width0 = 0
						beam.Width1 = 0
						beam.Color = beamColor
						beam.Transparency = NumberSequence.new(v11.beamTransparency)
						beam.FaceCamera = v11.beamFaceCamera
						beam.Brightness = v11.beamBrightness
						beam.Texture = "rbxassetid://17130908144"
						beam.LightEmission = 0.7
						beam.Parent = model2
						return beam
					end

					for i = 1, #ringRadii do
						for i2 = 1, pointsPerRing do
							local v14 = i2 % pointsPerRing + 1
							table.insert(v13, (makeBeam(v12[i][i2].part, v12[i][v14].part)))
						end

						if i < #ringRadii then
							for i2 = 1, pointsPerRing do
								table.insert(v13, (makeBeam(v12[i][i2].part, v12[i + 1][i2].part)))
							end
						end

						if not (i < #ringRadii) then
							continue
						end

						for i2 = 1, pointsPerRing do
							local v14 = i2 % pointsPerRing + 1
							table.insert(v13, (makeBeam(v12[i][i2].part, v12[i + 1][v14].part)))
						end
					end

					local heartbeatConnection = nil
					task.spawn(function()
						for _, v14 in pairs(v13) do
							TweenService:Create(v14, TweenInfo.new(0.25 + math.random() * 0.5), {
								Width0 = beamThickness,
								Width1 = beamThickness
							}):Play()
							local v15 = v14
							task.delay(1.25, function()
								TweenService:Create(v15, TweenInfo.new(0.25 + math.random() * 0.25), {
									Width0 = 0,
									Width1 = 0
								}):Play()
								task.wait(0.5)
								v15:Destroy()
							end)
						end

						task.wait(2)

						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end

						model2:Destroy()
					end)
					local v14 = {}
					local v15 = {}

					for i = 1, #ringRadii do
						v14[i] = v11.radiusExpansion.minScale
						v15[i] = v11.heightExpansion.minScale
					end

					local total = 0
					local total2 = 0
					heartbeatConnection = RunService2.Heartbeat:Connect(function(dt)
						total += dt

						if v11.rotation.enabled then
							local v16 = v11.rotation.clockwise and -1 or 1
							total2 += v16 * math.rad(v11.rotation.degreesPerSecond) * dt
						end

						if v11.radiusExpansion.enabled then
							for i = 1, #ringRadii do
								local radiusExpansion = v11.radiusExpansion

								if radiusExpansion.pulse then
									local midpoint = (math.sin(total * radiusExpansion.rate + (i - 1) * radiusExpansion.phaseOffset) + 1) / 2
									v14[i] = radiusExpansion.minScale + midpoint * (radiusExpansion.maxScale - radiusExpansion.minScale)
								else
									local v16 = v14[i] + radiusExpansion.rate * dt
									v14[i] = math.clamp(v16, radiusExpansion.minScale, radiusExpansion.maxScale)
								end
							end
						end

						if v11.heightExpansion.enabled then
							for i = 1, #ringRadii do
								local heightExpansion = v11.heightExpansion

								if heightExpansion.pulse then
									local midpoint = (math.sin(total * heightExpansion.rate + (i - 1) * heightExpansion.phaseOffset) + 1) / 2
									v15[i] = heightExpansion.minScale + midpoint * (heightExpansion.maxScale - heightExpansion.minScale)
								else
									local v16 = v15[i] + heightExpansion.rate * dt
									v15[i] = math.clamp(v16, heightExpansion.minScale, heightExpansion.maxScale)
								end
							end
						end

						local cframe = CFrame.Angles(0, total2, 0)

						for i, list in ipairs(v12) do
							local v16 = v14[i] or 1
							local v17 = v15[i] or 1

							for _, v18 in ipairs(list) do
								local v19 = total
								local randomOffset1 = v18.randomOffset1
								local randomOffset2 = v18.randomOffset2
								local randomOffset3 = v18.randomOffset3
								local randomSpeed1 = v18.randomSpeed1
								local randomSpeed2 = v18.randomSpeed2
								local v20 = math.sin(v19 * randomSpeed1 + randomOffset1) * v11.drift.xAmt
								local v21 = math.cos(v19 * randomSpeed2 + randomOffset2) * v11.drift.yAmt
								local v22 = math.sin(v19 * randomSpeed1 * 0.7 + randomOffset3) * v11.drift.zAmt
								local v23 = center + cframe:VectorToWorldSpace(v18.radialDir) * (v18.baseRadius * v16) + Vector3.new(
									0,
									v18.baseHeight * v17,
									0
								) + Vector3.new(v20, v21, v22)
								v18.part.CFrame = CFrame.new(v23)
							end
						end
					end)
				end)
				task.delay(1.4, function()
					for _, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v11 = emitter
						task.spawn(function()
							v11.Enabled = false
						end)
					end
				end)
				task.spawn(function()
					local numberValue = Instance.new("NumberValue")
					numberValue.Parent = workspace._WorldOrigin
					numberValue.Value = 0.2
					task.delay(5, function()
						numberValue:Destroy()
					end)
					local clonesByClone = {}
					task.spawn(function()
						local modelsFolder = domain.ModelsFolder
						local raycastParams2 = RaycastParams.new()
						raycastParams2.FilterDescendantsInstances = { workspace.Map }
						raycastParams2.FilterType = Enum.RaycastFilterType.Include
						raycastParams2.IgnoreWater = true
						local v11 = clone2.PrimaryPart.Position + createVector(0, 2, 0)
						local raycastResult = workspace:Raycast(v11, createVector(0, -50, 0), raycastParams2)

						if raycastResult then
							for i = 1, 4 do
								local clone4 = modelsFolder["CloudModel" .. i]:Clone()
								clone4:PivotTo(clone2.PrimaryPart.CFrame)
								clone4:ScaleTo(numberValue.Value)
								local HSV, v12, v13 = raycastResult.Instance.Color:ToHSV()
								local v14 = math.clamp(v13 * 0.9, 0, 1)
								clone4.PrimaryPart.Color = Color3.fromHSV(HSV, v12, v14)
								clone4.Parent = workspace._WorldOrigin
								clone4:SetAttribute("Rot", math.random(10, 25) / 5 * (math.random(0, 1) * 2 - 1))
								clone4:SetAttribute("ScaleN", math.random(9, 10) / 10)
								task.spawn(function()
									clone4:SetAttribute("Size", math.random(1, 2) / 10)
									task.wait(0.15)
									clone4:SetAttribute("Size", math.random(2, 4) / 10)
									task.delay(0.1 + math.random() * 0.1, function()
										local WAIT_INTERVAL = 0.15
										clone4:SetAttribute("Size", -clone4:GetAttribute("Size"))
										task.wait(WAIT_INTERVAL)
										clone4:SetAttribute("Size", math.random(3, 7) / 5)
										clone4:SetAttribute(
											"Rot",
											math.random(10, 25) / 20 * (math.random(0, 1) * 2 - 1)
										)
										task.wait(WAIT_INTERVAL)
										clone4:SetAttribute("Size", -clone4:GetAttribute("Size") * 1.2)
										task.wait(WAIT_INTERVAL)
										clone4:SetAttribute("Size", math.random(3, 7) / 5)
									end)
								end)
								clone4.PrimaryPart.Transparency = 1
								TweenService:Create(clone4.PrimaryPart, TweenInfo.new(0.35 + math.random() * 0.35), {
									Transparency = 0
								}):Play()
								local v16 = clone4
								task.delay(0.5 - i * 0.05, function()
									task.wait(0.5 * math.random() + 0.125)
									TweenService:Create(v16.PrimaryPart, TweenInfo.new(0.1 + math.random() * 0.25), {
										Transparency = 1
									}):Play()
								end)
								clonesByClone[clone4] = clone4
								task.wait(0.125)
							end
						end
					end)
					task.spawn(function()
						local clone4 = domain.WindModel:Clone()
						applyEmitterThinning(clone4, v3.WindModel)
						clone4:PivotTo(clone2.PrimaryPart.CFrame * CFrame.new(0, 5, 0))
						clone4.Parent = workspace._WorldOrigin
						task.spawn(function()
							local numberValue2 = Instance.new("NumberValue")
							numberValue2.Parent = clone4
							numberValue2.Value = 1
							TweenService:Create(
								numberValue2,
								TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									Value = 10
								}
							):Play()
							task.delay(1, function()
								TweenService:Create(clone4.PrimaryPart, TweenInfo.new(0.25), {
									Transparency = 1
								}):Play()

								for _, emitter in pairs(clone4:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							local v11 = tick() + 1.6

							repeat
								clone4:ScaleTo(numberValue2.Value)
								clone4:PivotTo(clone4.PrimaryPart.CFrame * CFrame.Angles(0, 0.17453292519943295, 0))
								task.wait()
							until v11 - tick() <= 0

							clone4:Destroy()
						end)
					end)
					TweenService:Create(
						numberValue,
						TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Value = 3.8
						}
					):Play()
					task.delay(1, function()
						TweenService:Create(
							numberValue,
							TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Value = numberValue.Value + 1
							}
						):Play()
					end)
					local v11 = tick() + 2

					while true do
						for _, v12 in pairs(clonesByClone) do
							v12:ScaleTo(numberValue.Value * v12:GetAttribute("ScaleN"))
							v12.PrimaryPart.Size = v12.PrimaryPart.Size + Vector3.new(0, v12:GetAttribute("Size"), 0)
							v12:PivotTo(v12.PrimaryPart.CFrame * CFrame.Angles(
								0,
								math.rad((v12:GetAttribute("Rot"))),
								0
							))
						end

						task.wait()

						if not (v11 - tick() <= 0) then
							continue
						end

						task.wait(0.5)

						for _, v12 in pairs(clonesByClone) do
							TweenService:Create(v12.PrimaryPart, TweenInfo.new(0.25), {
								Transparency = 1
							}):Play()
							local v13 = v12
							task.delay(1, function()
								v13:Destroy()
							end)
						end

						break
					end
				end)
				local mesh = player.GetGlobe().Mesh
				local scale = clone2:GetScale()
				local total = 0
				local v11 = nil
				local v12 = nil

				while true do
					total += task.wait(0.016666666666666666)
					local v13 = player.GetSize() / 404.71385936898844

					if flag then
						local v14 = math.abs(v13 - scale)

						if scale * 0.005 < v14 then
							clone2:ScaleTo(v13)
							clone3:ScaleTo(v13)
							scale = v13
						end
					end

					local cFrame = player.GetCFrame()

					if flag and cFrame ~= v11 then
						clone2:PivotTo(cFrame)
						clone3:PivotTo(cFrame * CFrame.new(0, 3, 0))
						v11 = cFrame
					end

					local vertexColor = mesh.VertexColor

					if flag and vertexColor ~= v12 then
						for _, v14 in specialMeshes do
							v14.VertexColor = vertexColor
						end

						v12 = vertexColor
					end

					if v9 and v[player.Domain] ~= nil then
						v9(total)
					end

					if not (v7 == false or v[player.Domain] == nil) then
						continue
					end

					if v10 then
						v10()
					end

					for _, v14 in clones do
						local clone4 = domain.EndImpact:Clone()
						clone4.CFrame = v14.PrimaryPart.CFrame * CFrame.new(0, 5, -15)
						clone4.Parent = workspace._WorldOrigin

						for _, emitter in pairs(clone4:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v15 = emitter
							task.spawn(function()
								if v15:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v15:GetAttribute("EmitDelay"))
								end

								v15:Emit(v15:GetAttribute("EmitCount"))
							end)
						end

						for _, child in pairs(v14:GetChildren()) do
							if child:IsA("Trail") or child:IsA("ParticleEmitter") or child:IsA("Beam") then
								child.Enabled = false
							elseif child:IsA("BasePart") then
								child.Transparency = 1
							end
						end

						local v16 = v14
						task.delay(3, function()
							clone4:Destroy()
							v16:Destroy()
						end)
					end

					clone2:Destroy()
					clone3:Destroy()
					break
				end
			end)
		end
	end
end