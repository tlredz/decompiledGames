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
local _ = os.clock()

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

local v3 = {
	GetDomeFromPlayer = function(self, player)
		return v2[player.Character]
	end
}

function v3.new(instance, getSize, getCFrame, getGlobe, p4)
	local maid = Util.Maid.new()
	local object = setmetatable({
		Reference = instance,
		GetSize = getSize,
		GetCFrame = getCFrame,
		GetGlobe = getGlobe,
		Maid = maid
	}, {
		__index = v3
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

	local v4 = os.clock() + 5

	local function UpdateSize()
		if v4 < os.clock() then
			return
		end

		object.Mesh["Hex Bubble"].Size = object.Object.HexBubble.Size
		local hexBubble = object.Object.HexBubble
		local v5 = hexBubble.Size.X / 2
		local children = object.Object.Outside:GetChildren()
		local count = #children
		local v6 = 6.283185307179586 * v5 / count
		local cframe = CFrame.new(0, 0, -v5)
		local vector2 = Vector3.new(v6, 1, 10)

		for k, v7 in children do
			v7.CFrame = CFrame.new(hexBubble.Position) * CFrame.Angles(0, 6.283185307179586 / count * k, 0) * cframe
			v7.Size = vector2
			v7.Rock.Acceleration = v7.CFrame.RightVector * 500
		end

		local v7 = math.abs(object.Reference:GetAttribute("CFrame").Position.Y - Y)
		local v8 = v5 < v7 and 0 or math.sqrt(v5 * v5 - v7 * v7) or 0
		local particle_7 = hexBubble.Ground.Particle_7
		hexBubble.Ground.CFrame = CFrame.new(0, (Y or 0) - hexBubble.CFrame.Position.Y, 0)
		particle_7.Size = NumberSequence.new(0.6666666666666666 * v8 * 2)
		particle_7.Enabled = true
		local v9 = hexBubble.Size.X / 2 + 2
		hexBubble.Attachment1.CFrame = CFrame.new(-v9, 0, 0) * CFrame.Angles(0, -1.5707963267948966, 0)
		hexBubble.Attachment2.CFrame = CFrame.new(v9, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0)

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

			beam.CurveSize0 = v9 * 4 / 3
			beam.CurveSize1 = v9 * 4 / 3
			beam.Width0 = beam:GetAttribute("_Width0") * v9 / 100
			beam.Width1 = beam:GetAttribute("_Width1") * v9 / 100
		end
	end

	object.Object = object.Maid:GiveTask(domain.Bubble:Clone())
	object.Object.HexBubble.CFrame = object.GetCFrame()
	object.Object.HexBubble.Transparency = 1
	object.Object.HexBubble.Color = Color3.fromRGB(255, 255, 255)
	object.Object.Parent = workspace._WorldOrigin
	object.Mesh = domain.Room:Clone()
	object.Mesh["Hex Bubble"].CFrame = object.GetCFrame()
	object.Mesh.Parent = object.Object
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
	v2[p4] = object
	return object
end

function v3:_SnapshotShapesForRebind()
	local shapeSnapshot = {}

	for _, editableShape in pairs(self.EditableShapes) do
		local positions = table.create(#editableShape.Vertices)

		for i, v5 in ipairs(editableShape.Vertices) do
			positions[i] = v5.OriginalPosition.Position
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

function v3:_RebindShapesFromFixedMesh(editableMesh, data)
	local _ShapeSnapshot = self._ShapeSnapshot
	assert(_ShapeSnapshot, "No shape snapshot")
	local rawset2 = rawset
	local v4 = {
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
			local v5 = data.NewMesh.Size.X / data.OriginalMeshScale

			for _, v6 in pairs(self.Vertices) do
				local position = v6.OriginalPosition.Position
				local pointToWorldSpace = (self.CFrame - self.CFrame.Position + self.CFrame.Position / v5):PointToWorldSpace(position)
				editableMesh:SetPosition(v6.ID, pointToWorldSpace)
			end
		end,
		SetCFrame = function(self, p2, p3)
			local objectSpace = data.NewMesh.CFrame:ToObjectSpace(p2)
			local v5 = objectSpace - objectSpace.Position
			local position = objectSpace.Position
			local cFrame = CFrame.new(position) * v5
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

	for i, v6 in ipairs(_ShapeSnapshot) do
		editableShapes[i] = setmetatable({
			Colors = {},
			Vertices = {},
			CFrame = CFrame.new(v6.center),
			OriginalCFrame = CFrame.new(v6.center),
			Color = v6.color,
			Transparency = v6.transparency,
			__attributes = {}
		}, {
			__index = v4
		})
	end

	local clock = os.clock
	local ipairs2 = ipairs
	local now = clock()
	local lastTime = os.clock()
	local v6 = table.create(#_ShapeSnapshot)

	for _, v7 in _ShapeSnapshot do
		local v8 = v7.center // 6
		local v9 = v6[v8]

		if v9 == nil then
			v9 = {}
			v6[v8] = v9
		end

		table.insert(v9, v7)
	end

	local function findNearestShape(p2)
		local v7 = p2 // 6
		local v8 = 1e999
		local v9 = nil

		for i = -1, 1 do
			for i2 = -1, 1 do
				for i3 = -1, 1 do
					if not (i ~= 0 or i3 ~= 0 or i2 ~= 0) then
						continue
					end

					local v11 = v6[v7 + Vector3.new(i3, i, i2)]

					if not v11 then
						continue
					end

					for k, v12 in v11 do
						local magnitude = (p2 - v12.center).Magnitude

						if not (magnitude < v8) then
							continue
						end

						v9 = k
						v8 = magnitude
					end
				end
			end
		end

		return v9
	end

	for _, v7 in ipairs2((editableMesh:GetFaces())) do
		if clock() - now > 0.006666666666666667 then
			task.wait()
			now = clock()
		end

		local faceVertices = editableMesh:GetFaceVertices(v7)
		local v8 = createVector(0, 0, 0)

		for _, v9 in ipairs2(faceVertices) do
			if clock() - now > 0.006666666666666667 then
				task.wait()
				now = clock()
			end

			v8 += editableMesh:GetPosition(v9)
		end

		local nearestShape = findNearestShape(v8 / #faceVertices)

		if not nearestShape then
			continue
		end

		if clock() - now > 0.006666666666666667 then
			task.wait()
			now = clock()
		end

		local colors = editableShapes[nearestShape].Colors

		for _, v9 in editableMesh:GetFaceColors(v7) do
			insert(colors, v9)
		end
	end

	local v7 = os.clock() - lastTime
	print(string.format("calced in %.4fms", v7 * 1000))

	for _, v8 in ipairs2(editableShapes) do
		local color = v8.Color
		local transparency = v8.Transparency
		local colors = v8.Colors
		local abs = math.abs

		function v8:SetColor(color2)
			if color == color2 then
				return
			end

			for k, v10 in colors do
				editableMesh:SetColor(v10, color2)
			end

			color = color2
			self.Color = color2
		end

		local colors2 = colors

		function v8:SetTransparency(p3: number)
			if transparency == p3 or abs(transparency - p3) < 0.01 then
				return
			end

			for k, v13 in colors2 do
				editableMesh:SetColorAlpha(v13, 1 - p3)
			end

			transparency = p3
			rawset2(self, "Transparency", p3)
		end
	end

	self.EditableMesh = editableMesh
	self.EditableShapes = editableShapes
	self._ShapeSnapshot = nil
end

function v3:_BuildPulseCache()
	if self._PulseCache then
		return
	end

	local cFrame = self.NewMesh.CFrame
	local v4 = self.NewMesh.Size.X * 0.5
	local pulseCache = {}

	for _, editableShape in pairs(self.EditableShapes) do
		local objectSpace = cFrame:ToObjectSpace((editableShape:GetCFrame()))
		local position = objectSpace.Position
		local height = math.clamp((position.Y / v4 + 1) * 0.5, 0, 1)
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

function v3.Pulse(p, _, ...)
	p.PulseAnim.Priority = Enum.AnimationPriority.Action
	p.PulseAnim:Play()
end

function v3:_UpdatePulses()
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

				for _, v4 in ipairs(self._PulseCache) do
					local color = v4.color
					local transparency = v4.transparency
					local v5 = createVector(0, 0, 0)
					local flag = false

					for _, _ActivePuls in ipairs(self._ActivePulses) do
						local v6 = (now - _ActivePuls.start) / _ActivePuls.duration

						if v6 < 0 or v6 > 1 then
							continue
						end

						local v7 = 1 - v6
						local v8 = math.abs(v4.height01 - v7)

						if _ActivePuls.band < v8 then
							continue
						end

						local v9 = 1 - v8 / _ActivePuls.band
						local v10 = v9 * v9
						flag = true
						v5 += v4.normal * (v10 * _ActivePuls.strength)
						color = color:Lerp(_ActivePuls.color, v10)

						if _ActivePuls.affectTransparency then
							transparency = math.min(transparency, 1 - v10)
						end
					end

					if flag then
						v4.shape.Pulsing = true
						local v6 = v4.localCF * CFrame.new(v5)
						v4.shape:SetCFrame(cFrame * v6, true)
						v4.shape:SetColor(color)
						v4.shape:SetTransparency(transparency)
					else
						v4.shape.Pulsing = nil
						v4.shape:SetCFrame(cFrame * v4.localCF, true)
						v4.shape:SetColor(v4.color)
						v4.shape:SetTransparency(v4.transparency)
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

function v3.UpdateColor(p, color2, _, value)
	local TweenService2 = game:GetService("TweenService")
	TweenService2:Create(p.Mesh["Hex Bubble"], TweenInfo.new(value or 0.01), {
		Color = color2
	})
end

function v3.SetMaxTransparency(_, _) end

function v3.Start(data)
	for _ = 2, 6 do
		local clone = data.Object.Outside.Edge:Clone()
		clone.Parent = data.Object.Outside
	end

	local rotation = data.Object.HexBubble.CFrame.Rotation
	Util.Anims:Get(data.Object, "RoomBreathing"):Play(0.5, 1, 0.4)
	local total = 0
	local v4 = createVector(0, 0, 0)

	while true do
		local v5 = task.wait()

		if data.Destroyed then
			break
		end

		local size = data.GetSize()
		local hexBubble = data.Object.HexBubble
		total += v5
		local v6 = total / 1
		local v7 = not (v6 <= 0.35) and 1 or TweenService:GetValue(
			(v6 - 0) / 0.35,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		)
		rotation *= CFrame.Angles(0, -0.1308996938995747 * v7 * v5, 0)
		hexBubble.CFrame = CFrame.new(data.GetCFrame().Position) * rotation

		if v4 == size then
			continue
		end

		hexBubble.Size = createVector(1, 1, 1) * size
		v4 = size
	end
end

function v3.Retract(_) end

function v3:Destroy()
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
local part = Instance.new("Part")
part.Name = "RockTemplate"
part.Anchored = true
part.CanCollide = true
part.CastShadow = false
part.CanQuery = false
part.Material = neon
part.Color = color
part.Size = createVector(2, 2, 2)
local v4 = class.new(part, 70, model)
local lightningBoltShafi = Util.LightningBoltShafi

local function NewBolt(attachment, attachment2, value: number?)
	local v5 = lightningBoltShafi.new(attachment, attachment2, value or 35, 0.7, workspace.Terrain)
	local curveSize = math.random(-15, 25)
	local curveSize2 = math.random(-15, 25)
	v5.CurveSize0 = curveSize
	v5.CurveSize1 = curveSize2
	local maxRadius = math.random(20, 35)
	v5.MinRadius = 5
	v5.MaxRadius = maxRadius
	v5.Frequency = 0.5
	v5.AnimationSpeed = math.random(5, 9)
	local maxThicknessMultiplier = 0.5 + math.random() * 5.75
	v5.MinThicknessMultiplier = 0.3
	v5.MaxThicknessMultiplier = maxThicknessMultiplier
	v5.MinTransparency = 0
	v5.MaxTransparency = 1
	v5.PulseSpeed = 35
	v5.PulseLength = 1000000
	v5.FadeLength = 0.2
	v5.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(177, 153, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(203, 158, 255))
	})
	v5.ContractFrom = 0.5
	v5.ColorOffsetSpeed = 3
	return v5
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
			return v3:GetDomeFromPlayer(player.Player)
		end

		if player.Stage == "Start" and not v[player.Domain] then
			local v5 = v3.new(player.Domain, player.GetSize, player.GetCFrame, player.GetGlobe, player.Player)
			v[player.Domain] = v5
			local v6 = true
			player.Domain.Destroying:Once(function()
				v6 = false
				v[player.Domain]:Destroy()
				v[player.Domain] = nil
			end)
			task.spawn(function()
				local clones = {}
				local v7 = {}
				local v8 = nil
				local v9 = nil
				task.delay(1.4, function()
					if not v6 then
						return
					end

					for i = 1, 7 do
						local scale = domain.Cube:GetScale()
						local clone = domain.Cube:Clone()

						if i > 2 then
							scale = scale - 0.1 + math.random() * 0.15 or scale
						end

						clone:ScaleTo(scale)
						clone.Parent = workspace._WorldOrigin

						for _, child in clone.Trails:GetChildren() do
							child.Enabled = false
						end

						for _, part2 in clone:GetChildren() do
							if not part2:IsA("BasePart") then
								continue
							end

							local size = part2.Size
							part2.Size = createVector(0, 0, 0)
							TweenService:Create(part2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Size = size
							}):Play()
						end

						for _, child in clone.Trails:GetChildren() do
							local v10 = child
							task.delay(0.5, function()
								v10.Enabled = true
							end)
						end

						table.insert(clones, clone)
					end

					local mesh = v5:GetGlobe().Mesh
					local v10 = false
					tick()

					local function updCol()
						local color2 = Color3.new(mesh.VertexColor.X, mesh.VertexColor.Y, mesh.VertexColor.Z)

						for _, v11 in clones do
							v11.Outline.Color = color2:Lerp(Color3.new(1, 1, 1), 0.3)
							v11.Inner.Color = color2:Lerp(Color3.new(1, 1, 1), 0.6)
							v11.Trails.TrailSub.Color = ColorSequence.new(color2)
							v11.Trails.Trail.Color = ColorSequence.new(color2:Lerp(Color3.new(1, 1, 1), 0.3), color2)
							v11.Trails.Trail1.Color = ColorSequence.new(color2:Lerp(Color3.new(1, 1, 1), 0.3), color2)
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

					v9 = EndCubes

					local function UpdateCubes(p)
						if v5.Object:GetAttribute("Ult") == nil or v5.Object:GetAttribute("Ult") == false then
							if v10 == true then
								v10 = false

								for _, v11 in pairs(v7) do
									v11:Destroy()
								end
							end
						elseif v5.Object:GetAttribute("Ult") == true and v10 == false then
							task.spawn(function()
								v10 = true

								local function pickRandomClosestCube(clones2, position: Vector3, value: number?, p2)
									local v11 = {}

									for k, item in pairs(clones2) do
										if not (item and item ~= p2) then
											continue
										end

										local magnitude = (item.PrimaryPart.Position - position).Magnitude
										v11[#v11 + 1] = {
											Key = k,
											Cube = item,
											Distance = magnitude
										}
									end

									if #v11 == 0 then
										return nil, nil
									end

									table.sort(v11, function(a, b)
										return a.Distance < b.Distance
									end)
									local v13 = math.max(1, (math.floor(#v11 * (value or 0.35))))
									local v14 = v11[math.random(1, v13)]
									return v14.Key, v14.Cube
								end

								for _, v11 in pairs(clones) do
									local _, v12 = pickRandomClosestCube(clones, v11.Inner.Position, 0.25, v11)
									local newBolt = NewBolt(
										v12.Inner.Attachment,
										v11.Inner.Attachment,
										math.random(10, 15)
									)
									v7[newBolt] = newBolt
								end
							end)
						end

						local hexBubble = v[player.Domain].Object.HexBubble
						local v11 = hexBubble.Size.X / 2
						local v12 = v11 / 2
						local v13 = v12 / 2

						for k, v14 in clones do
							local v15 = not (k > 2) and 0 or k - 1.5707963267948966 or 0
							local v16 = math.noise(k, p)
							local v17 = k % 2 == 0 and 1 or -1
							v14:PivotTo(CFrame.new(hexBubble.Position) * CFrame.Angles(0, v15 + math.rad(p * 40), 0) * CFrame.new(
								0,
								v12 + math.sin(p) * (v13 + v16 * v15) * v17,
								(v11 + 5) * v17
							))
						end
					end

					v8 = UpdateCubes
				end)
				local clone = domain.SphereModel:Clone()
				clone:PivotTo(player.GetCFrame())
				clone:ScaleTo(0.01)
				clone.Parent = workspace._WorldOrigin
				local specialMeshes = {}

				for _, specialMesh in pairs(clone:GetDescendants()) do
					if specialMesh:IsA("SpecialMesh") and specialMesh.VertexColor.Z > 1 then
						table.insert(specialMeshes, specialMesh)
					end
				end

				local clone2 = domain.GroundAura:Clone()
				clone2:PivotTo(player.GetCFrame() * CFrame.new(0, 3, 0))
				clone2:ScaleTo(0.01)
				clone2.Parent = workspace._WorldOrigin
				task.spawn(function()
					for _, emitter in pairs(clone2:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						emitter.Enabled = true
						local v10 = emitter
						task.delay(1.3, function()
							v10.Enabled = false
						end)
					end
				end)
				local ringBeam = clone.RingBeam
				ringBeam.CFrame = clone.PrimaryPart.CFrame
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
						local v10 = effect
						task.delay(1.25, function()
							TweenService:Create(v10, TweenInfo.new(0.5), {
								Width0 = v10.Width0 * 0.333,
								Width1 = v10.Width1 * 0.333
							}):Play()
							fadeBeamTransparency(v10, 0.5)
						end)
					end
				end

				task.spawn(function()
					if _G.FastMode then
						return
					end

					local cFrame = v[player.Domain].Object.HexBubble.CFrame
					local raycastParams2 = RaycastParams.new()
					raycastParams2.FilterDescendantsInstances = { workspace.Map }
					raycastParams2.FilterType = Enum.RaycastFilterType.Include
					raycastParams2.IgnoreWater = false
					local v10 = table.create(70)

					for i = 1, 70 do
						local v11 = i / 70 * 3.141592653589793 * 2
						local angleCos = math.cos(v11)
						local angleSin = math.sin(v11)
						local part2 = v4:GetPart()
						local vector2 = Vector3.new(math.random(2, 3), math.random(2, 3), math.random(2, 3))
						part2.Size = vector2
						local v14 = math.random() * 1.8 + 1.2
						local vector3 = Vector3.new(v14, v14 * (0.6 + math.random() * 0.8), v14)
						part2.Size *= vector3
						v10[i] = {
							part = part2,
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
						local v11 = v10[i]

						if not (v11 and v11.alive) then
							continue
						end

						local v12 = position + Vector3.new(v11.angleCos * 30, 2, v11.angleSin * 30) + createVector(
							0,
							2,
							0
						)
						local raycastResult = workspace:Raycast(v12, createVector(0, -100, 0), raycastParams2)

						if raycastResult then
							v11.part.CFrame = CFrame.new(raycastResult.Position)
							local size = v11.part.Size
							v11.part.Size = createVector(0, 0, 0)
							TweenService:Create(v11.part, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
								Size = size
							}):Play()
						else
							v11.alive = false
							v4:ReturnPart(v11.part)
						end
					end

					local flag = true
					local v11 = true
					task.delay(0.6, function()
						v11 = false
					end)
					task.delay(1.6, function()
						v11 = true

						for i = 1, 70 do
							local v12 = v10[i]

							if v12 and v12.alive then
								TweenService:Create(
									v12.part,
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
						flag = false

						for i = 1, 70 do
							local v12 = v10[i]

							if not (v12 and v12.alive) then
								continue
							end

							v12.alive = false
							v4:ReturnPart(v12.part)
						end
					end)
					local parts = table.create(70)
					local v12 = table.create(70)

					while flag do
						local v13 = math.max(player.GetSize() / 2 - 15, 30)
						local position2 = cFrame.Position
						local now = tick()
						local count = 0

						for i = 1, 70 do
							local v14 = v10[i]

							if not (v14 and v14.alive and v14.part.Parent) then
								continue
							end

							local v15 = position2 + Vector3.new(v14.angleCos * v13, 2, v14.angleSin * v13)
							local v16 = math.random(-v14.baseScale.Y, v14.baseScale.Y) * 2
							local v17 = CFrame.new(v15, position2) * CFrame.new(0, v16, 0)

							if not v11 then
								local v18 = math.max(0, now - v14.spawnTime)
								local v19 = v14.growthMul * 3 * v18
								local initScale = v14.initScale
								v14.part.Size = v14.baseScale * Vector3.new(
									initScale.X + v19,
									initScale.Y + v19,
									initScale.Z + v19
								)
							end

							count += 1
							parts[count] = v14.part
							v12[count] = v17
						end

						if count > 0 then
							workspace:BulkMoveTo(parts, v12)
						end

						task.wait(0.016666666666666666)
					end
				end)
				local model2 = Instance.new("Model")
				model2.Parent = workspace._WorldOrigin
				task.spawn(function()
					local RunService2 = game:GetService("RunService")
					local v10 = {
						Center = clone.PrimaryPart.Position,
						ringRadii = { 23, 21, 19 },
						ringHeights = { 0, 5, 10 },
						pointsPerRing = 10,
						beamThickness = 1.5,
						beamColor = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(51, 95, 255)),
							ColorSequenceKeypoint.new(0.5, Color3.fromRGB(58, 88, 255)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(51, 95, 255))
						}),
						beamTransparency = 0,
						beamBrightness = 5,
						beamFaceCamera = true,
						radiusExpansion = {
							enabled = true,
							rate = 8,
							maxScale = 12,
							minScale = 1,
							phaseOffset = 125.35,
							pulse = false
						},
						heightExpansion = {
							enabled = true,
							rate = 5,
							maxScale = 50,
							minScale = 1,
							phaseOffset = 15,
							pulse = false
						},
						rotation = {
							enabled = true,
							degreesPerSecond = 350,
							clockwise = true
						},
						drift = {
							xAmt = 10.5,
							yAmt = 25,
							zAmt = 10.5
						},
						startAnchored = true
					}
					local center = v10.Center
					local ringRadii = v10.ringRadii
					local ringHeights = v10.ringHeights
					local pointsPerRing = v10.pointsPerRing
					local beamThickness = v10.beamThickness
					local beamColor = v10.beamColor
					local v11 = {}
					local v12 = {}

					for i, baseRadius in ipairs(ringRadii) do
						local baseHeight = ringHeights[i] or 0
						v11[i] = {}

						for i2 = 1, pointsPerRing do
							local v15 = (i2 - 1) / pointsPerRing * 3.141592653589793 * 2
							local vector2 = Vector3.new(math.cos(v15), 0, (math.sin(v15)))
							local v16 = center + vector2 * baseRadius + Vector3.new(0, baseHeight, 0)
							local part2 = Instance.new("Part")
							part2.Transparency = 1
							part2.CanCollide = false
							part2.Anchored = v10.startAnchored
							part2.CFrame = CFrame.new(v16)
							part2.Parent = model2
							v11[i][i2] = {
								part = part2,
								baseRadius = baseRadius,
								baseHeight = baseHeight,
								radialDir = vector2,
								randomOffset1 = math.random() * 3.141592653589793 * 2,
								randomOffset2 = math.random() * 3.141592653589793 * 2,
								randomOffset3 = math.random() * 3.141592653589793 * 2,
								randomSpeed1 = v10.drift.xAmt > 0 and 0.3 + math.random() / 5 or 0.3,
								randomSpeed2 = v10.drift.yAmt > 0 and 0.2 + math.random() / 5 or 0.2
							}
						end
					end

					local function makeBeam(part2, part3)
						local beam = Instance.new("Beam")
						local attachment = Instance.new("Attachment")
						local attachment2 = Instance.new("Attachment")
						attachment.Parent = part2
						attachment2.Parent = part3
						beam.Attachment0 = attachment
						beam.Attachment1 = attachment2
						beam.Width0 = 0
						beam.Width1 = 0
						beam.Color = beamColor
						beam.Transparency = NumberSequence.new(v10.beamTransparency)
						beam.FaceCamera = v10.beamFaceCamera
						beam.Brightness = v10.beamBrightness
						beam.Texture = "rbxassetid://17130908144"
						beam.LightEmission = 0.7
						beam.Parent = model2
						return beam
					end

					for i = 1, #ringRadii do
						for i2 = 1, pointsPerRing do
							local v13 = i2 % pointsPerRing + 1
							table.insert(v12, (makeBeam(v11[i][i2].part, v11[i][v13].part)))
						end

						if i < #ringRadii then
							for i2 = 1, pointsPerRing do
								table.insert(v12, (makeBeam(v11[i][i2].part, v11[i + 1][i2].part)))
							end
						end

						if not (i < #ringRadii) then
							continue
						end

						for i2 = 1, pointsPerRing do
							local v13 = i2 % pointsPerRing + 1
							table.insert(v12, (makeBeam(v11[i][i2].part, v11[i + 1][v13].part)))
						end
					end

					task.spawn(function()
						for _, v13 in pairs(v12) do
							TweenService:Create(v13, TweenInfo.new(0.25 + math.random() * 0.5), {
								Width0 = beamThickness,
								Width1 = beamThickness
							}):Play()
							local v14 = v13
							task.delay(1.25, function()
								TweenService:Create(v14, TweenInfo.new(0.25 + math.random() * 0.25), {
									Width0 = 0,
									Width1 = 0
								}):Play()
								task.wait(0.5)
								v14:Destroy()
							end)
						end

						task.wait(2)
						model2:Destroy()
					end)
					local v13 = {}
					local v14 = {}

					for i = 1, #ringRadii do
						v13[i] = v10.radiusExpansion.minScale
						v14[i] = v10.heightExpansion.minScale
					end

					local total = 0
					local total2 = 0
					RunService2.Heartbeat:Connect(function(dt)
						total += dt

						if v10.rotation.enabled then
							local v15 = v10.rotation.clockwise and -1 or 1
							total2 += v15 * math.rad(v10.rotation.degreesPerSecond) * dt
						end

						if v10.radiusExpansion.enabled then
							for i = 1, #ringRadii do
								local radiusExpansion = v10.radiusExpansion

								if radiusExpansion.pulse then
									local midpoint = (math.sin(total * radiusExpansion.rate + (i - 1) * radiusExpansion.phaseOffset) + 1) / 2
									v13[i] = radiusExpansion.minScale + midpoint * (radiusExpansion.maxScale - radiusExpansion.minScale)
								else
									local v15 = v13[i] + radiusExpansion.rate * dt
									v13[i] = math.clamp(v15, radiusExpansion.minScale, radiusExpansion.maxScale)
								end
							end
						end

						if v10.heightExpansion.enabled then
							for i = 1, #ringRadii do
								local heightExpansion = v10.heightExpansion

								if heightExpansion.pulse then
									local midpoint = (math.sin(total * heightExpansion.rate + (i - 1) * heightExpansion.phaseOffset) + 1) / 2
									v14[i] = heightExpansion.minScale + midpoint * (heightExpansion.maxScale - heightExpansion.minScale)
								else
									local v15 = v14[i] + heightExpansion.rate * dt
									v14[i] = math.clamp(v15, heightExpansion.minScale, heightExpansion.maxScale)
								end
							end
						end

						local cframe = CFrame.Angles(0, total2, 0)

						for i, list in ipairs(v11) do
							local v15 = v13[i] or 1
							local v16 = v14[i] or 1

							for _, v17 in ipairs(list) do
								local v18 = total
								local randomOffset1 = v17.randomOffset1
								local randomOffset2 = v17.randomOffset2
								local randomOffset3 = v17.randomOffset3
								local randomSpeed1 = v17.randomSpeed1
								local randomSpeed2 = v17.randomSpeed2
								local v19 = math.sin(v18 * randomSpeed1 + randomOffset1) * v10.drift.xAmt
								local v20 = math.cos(v18 * randomSpeed2 + randomOffset2) * v10.drift.yAmt
								local v21 = math.sin(v18 * randomSpeed1 * 0.7 + randomOffset3) * v10.drift.zAmt
								local v22 = center + cframe:VectorToWorldSpace(v17.radialDir) * (v17.baseRadius * v15) + Vector3.new(
									0,
									v17.baseHeight * v16,
									0
								) + Vector3.new(v19, v20, v21)
								v17.part.CFrame = CFrame.new(v22)
							end
						end
					end)
				end)
				task.delay(1.4, function()
					for _, emitter in pairs(clone:GetDescendants()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v10 = emitter
						task.spawn(function()
							v10.Enabled = false
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
						local v10 = clone.PrimaryPart.Position + createVector(0, 2, 0)
						local raycastResult = workspace:Raycast(v10, createVector(0, -50, 0), raycastParams2)

						if raycastResult then
							for i = 1, 4 do
								local clone3 = modelsFolder["CloudModel" .. i]:Clone()
								clone3:PivotTo(clone.PrimaryPart.CFrame)
								clone3:ScaleTo(numberValue.Value)
								local HSV, v11, v12 = raycastResult.Instance.Color:ToHSV()
								local v13 = math.clamp(v12 * 0.9, 0, 1)
								clone3.PrimaryPart.Color = Color3.fromHSV(HSV, v11, v13)
								clone3.Parent = workspace._WorldOrigin
								clone3:SetAttribute("Rot", math.random(10, 25) / 5 * (math.random(0, 1) * 2 - 1))
								clone3:SetAttribute("ScaleN", math.random(9, 10) / 10)
								task.spawn(function()
									clone3:SetAttribute("Size", math.random(1, 2) / 10)
									task.wait(0.15)
									clone3:SetAttribute("Size", math.random(2, 4) / 10)
									task.delay(0.1 + math.random() * 0.1, function()
										local WAIT_INTERVAL = 0.15
										clone3:SetAttribute("Size", -clone3:GetAttribute("Size"))
										task.wait(WAIT_INTERVAL)
										clone3:SetAttribute("Size", math.random(3, 7) / 5)
										clone3:SetAttribute(
											"Rot",
											math.random(10, 25) / 20 * (math.random(0, 1) * 2 - 1)
										)
										task.wait(WAIT_INTERVAL)
										clone3:SetAttribute("Size", -clone3:GetAttribute("Size") * 1.2)
										task.wait(WAIT_INTERVAL)
										clone3:SetAttribute("Size", math.random(3, 7) / 5)
									end)
								end)
								clone3.PrimaryPart.Transparency = 1
								TweenService:Create(clone3.PrimaryPart, TweenInfo.new(0.35 + math.random() * 0.35), {
									Transparency = 0
								}):Play()
								local v15 = clone3
								task.delay(0.5 - i * 0.05, function()
									task.wait(0.5 * math.random() + 0.125)
									TweenService:Create(v15.PrimaryPart, TweenInfo.new(0.1 + math.random() * 0.25), {
										Transparency = 1
									}):Play()
								end)
								clonesByClone[clone3] = clone3
								task.wait(0.125)
							end
						end
					end)
					task.spawn(function()
						local clone3 = domain.WindModel:Clone()
						clone3:PivotTo(clone.PrimaryPart.CFrame * CFrame.new(0, 5, 0))
						clone3.Parent = workspace._WorldOrigin
						task.spawn(function()
							local numberValue2 = Instance.new("NumberValue")
							numberValue2.Parent = clone3
							numberValue2.Value = 1
							TweenService:Create(
								numberValue2,
								TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
								{
									Value = 10
								}
							):Play()
							task.delay(1, function()
								TweenService:Create(clone3.PrimaryPart, TweenInfo.new(0.25), {
									Transparency = 1
								}):Play()

								for _, emitter in pairs(clone3:GetDescendants()) do
									if emitter:IsA("ParticleEmitter") then
										emitter.Enabled = false
									end
								end
							end)
							local v10 = tick() + 1.6

							repeat
								clone3:ScaleTo(numberValue2.Value)
								clone3:PivotTo(clone3.PrimaryPart.CFrame * CFrame.Angles(0, 0.17453292519943295, 0))
								task.wait()
							until v10 - tick() <= 0

							clone3:Destroy()
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
					local v10 = tick() + 2

					while true do
						for _, v11 in pairs(clonesByClone) do
							v11:ScaleTo(numberValue.Value * v11:GetAttribute("ScaleN"))
							v11.PrimaryPart.Size = v11.PrimaryPart.Size + Vector3.new(0, v11:GetAttribute("Size"), 0)
							v11:PivotTo(v11.PrimaryPart.CFrame * CFrame.Angles(
								0,
								math.rad((v11:GetAttribute("Rot"))),
								0
							))
						end

						task.wait()

						if not (v10 - tick() <= 0) then
							continue
						end

						task.wait(0.5)

						for _, v11 in pairs(clonesByClone) do
							TweenService:Create(v11.PrimaryPart, TweenInfo.new(0.25), {
								Transparency = 1
							}):Play()
							local v12 = v11
							task.delay(1, function()
								v12:Destroy()
							end)
						end

						break
					end
				end)
				local mesh = player.GetGlobe().Mesh
				local total = 0
				local v10 = nil

				while true do
					total += task.wait(0.016666666666666666)
					local v11 = player.GetSize() / 404.71385936898844

					if clone:GetScale() ~= v11 then
						clone:ScaleTo(v11)
						clone2:ScaleTo(v11)
					end

					local cFrame = player.GetCFrame()

					if cFrame ~= v10 then
						clone:PivotTo(cFrame)
						clone2:PivotTo(cFrame * CFrame.new(0, 3, 0))
						v10 = cFrame
					end

					for _, v12 in specialMeshes do
						v12.VertexColor = mesh.VertexColor
					end

					if v8 and v[player.Domain] ~= nil then
						v8(total)
					end

					if not (v6 == false or v[player.Domain] == nil) then
						continue
					end

					if v9 then
						v9()
					end

					for _, v12 in clones do
						local clone3 = domain.EndImpact:Clone()
						clone3.CFrame = v12.PrimaryPart.CFrame * CFrame.new(0, 5, -15)
						clone3.Parent = workspace._WorldOrigin

						for _, emitter in pairs(clone3:GetDescendants()) do
							if not emitter:IsA("ParticleEmitter") then
								continue
							end

							local v13 = emitter
							task.spawn(function()
								if v13:GetAttribute("EmitDelay") ~= 0 then
									task.wait(v13:GetAttribute("EmitDelay"))
								end

								v13:Emit(v13:GetAttribute("EmitCount"))
							end)
						end

						for _, child in pairs(v12:GetChildren()) do
							if child:IsA("Trail") or child:IsA("ParticleEmitter") or child:IsA("Beam") then
								child.Enabled = false
							elseif child:IsA("BasePart") then
								child.Transparency = 1
							end
						end

						local v14 = v12
						task.delay(3, function()
							clone3:Destroy()
							v14:Destroy()
						end)
					end

					clone:Destroy()
					clone2:Destroy()
					break
				end
			end)
		end
	end
end