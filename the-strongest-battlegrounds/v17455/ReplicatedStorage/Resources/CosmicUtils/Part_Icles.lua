local createVector = vector.create
local Graph = require(script.Graph)
local Range = require(script.Range)
local Particles = require(script.Particles)
local Flipbook = require(script.Flipbook)
local parent = script.Parent.Parent
local RunService = game:GetService("RunService")
local PartIcles = {
	Beam = {},
	EnabledParts = {}
}
_G.Part_Icles = _G.Part_Icles or {}
_G.Part_Icles.EnableAllowed = _G.Part_Icles.EnableAllowed or true
local beam = PartIcles.Beam

-- equivalent calls inferred from this helper; original call sites unknown
local function is_alive(instance)
	return instance and instance.Parent and instance:IsDescendantOf(game)
end

local v = {
	[Enum.NormalId.Top] = {
		vector = "UpVector",
		multiplier = 1
	},
	[Enum.NormalId.Bottom] = {
		vector = "UpVector",
		multiplier = -1
	},
	[Enum.NormalId.Front] = {
		vector = "LookVector",
		multiplier = 1
	},
	[Enum.NormalId.Back] = {
		vector = "LookVector",
		multiplier = -1
	},
	[Enum.NormalId.Left] = {
		vector = "RightVector",
		multiplier = -1
	},
	[Enum.NormalId.Right] = {
		vector = "RightVector",
		multiplier = 1
	}
}
local v2 = {
	[Enum.ParticleEmitterShape.Box] = function(p, _)
		return (Vector3.new(
			(math.random() * 2 - 1) * p.Size.X / 2,
			(math.random() * 2 - 1) * p.Size.Y / 2,
			(math.random() * 2 - 1) * p.Size.Z / 2
		))
	end,
	[Enum.ParticleEmitterShape.Sphere] = function(p, p2)
		local v3 = p.Size.X / 2
		local v4 = v3 * p2.ShapePartial
		local v5 = (math.random() * (v3 ^ 3 - v4 ^ 3) + v4 ^ 3) ^ 0.3333333333333333
		local v6 = math.random() * 2 * 3.141592653589793
		local v7 = math.acos(math.random() * 2 - 1)
		local vector2 = Vector3.new(math.sin(v7) * math.cos(v6), math.sin(v7) * math.sin(v6), (math.cos(v7)))
		return vector2 * v5, (CFrame.lookAt(Vector3.new(), -vector2))
	end,
	[Enum.ParticleEmitterShape.Cylinder] = function(p, p2)
		local v3 = p.Size.X / 2
		local Y = p.Size.Y
		local shapePartial = p2.ShapePartial
		local v4 = math.sqrt((math.random())) * (1 - shapePartial) + shapePartial
		local v5 = math.random() * 2 * 3.141592653589793
		local v6 = v4 * v3 * math.cos(v5)
		local v7 = (math.random() * 2 - 1) * (Y / 2)
		local v8 = v4 * v3 * math.sin(v5)
		local vector2 = Vector3.new(v6, v7, v8)
		local v9 = math.abs(v7)
		local v10

		if Y / 2 - 0.01 < v9 then
			v10 = Vector3.new(0, math.sign(v7), 0)
		else
			v10 = Vector3.new(v6, 0, v8).Unit
		end

		return vector2, (CFrame.lookAt(Vector3.new(), -v10))
	end,
	[Enum.ParticleEmitterShape.Disc] = function(p, p2)
		local v3 = p.Size.X / 2
		local shapePartial = p2.ShapePartial
		local v4 = math.sqrt((math.random())) * (1 - shapePartial) + shapePartial
		local v5 = math.random() * 2 * 3.141592653589793
		local vector2 = Vector3.new(v4 * v3 * math.cos(v5), 0, v4 * v3 * math.sin(v5))
		local unit = vector2.Unit
		return vector2, (CFrame.lookAt(Vector3.new(), -unit))
	end
}

function PartIcles:GetFolder()
	if workspace.Terrain:FindFirstChild("EmittedPartsUsingPart_icle") then
		return workspace.Terrain.EmittedPartsUsingPart_icle
	end

	local folder = Instance.new("Folder")
	folder.Name = "EmittedPartsUsingPart_icle"
	folder.Parent = workspace.Terrain
	return folder
end

function beam:Emit(beam2)
	if beam2:IsA("Beam") and beam2:GetAttribute("Transformed") then
		local factors = beam2:FindFirstChild("Factors")

		if not factors then
			return
		end

		local function isStatic(sequence)
			return not sequence or #sequence.Keypoints <= 1
		end

		local function getStaticValue(sequence, p)
			if sequence and #sequence.Keypoints ~= 0 then
				return sequence.Keypoints[1].Value
			end

			return p
		end

		local parent2

		if workspace.Terrain:FindFirstChild("EmittedPartsUsingPart_icle") then
			parent2 = workspace.Terrain.EmittedPartsUsingPart_icle
		else
			parent2 = Instance.new("Folder")
			parent2.Name = "EmittedPartsUsingPart_icle"
			parent2.Parent = workspace.Terrain
		end

		local properties = factors:FindFirstChild("Properties")
		local graphBlender = factors:FindFirstChild("GraphBlender")
		local totalKeyFrames = factors:FindFirstChild("TotalKeyFrames")
		local lifeTime = factors:FindFirstChild("LifeTime")
		local clone = beam2:Clone()
		local v4 = {
			Brightness = properties:FindFirstChild("Brightness"),
			CurveSize0 = properties:FindFirstChild("CurveSize0"),
			CurveSize1 = properties:FindFirstChild("CurveSize1"),
			Width0 = properties:FindFirstChild("Width0"),
			Width1 = properties:FindFirstChild("Width1"),
			LightEmission = properties:FindFirstChild("LightEmission"),
			Segments = properties:FindFirstChild("Segments"),
			TextureLength = properties:FindFirstChild("TextureLength"),
			TextureSpeed = properties:FindFirstChild("TextureSpeed")
		}
		local v5 = {}

		for k, v6 in pairs(v4) do
			if not v6 then
				continue
			end

			local size = v6.Size

			if not size or #size.Keypoints <= 1 then
				local value = clone[k]

				if size and #size.Keypoints ~= 0 then
					value = size.Keypoints[1].Value
				end

				clone[k] = value
				print(k, ": is now", clone[k], "or", value)
			else
				v5[k] = {
					Sequence = size,
					Seed = Graph.GenerateSeeds(size, 20)[math.random(1, 20)]
				}
			end
		end

		local colorGraphs = graphBlender:FindFirstChild("ColorGraphs")
		local transparencyGraphs = graphBlender:FindFirstChild("TransparencyGraphs")
		local randomValueFromRange = Range.RandomValueFromRange(lifeTime.Lifetime)
		local children = {}
		local children2 = {}

		for _, child in pairs(transparencyGraphs:GetChildren()) do
			table.insert(children, child)
		end

		for _, child in pairs(colorGraphs:GetChildren()) do
			table.insert(children2, child)
		end

		table.sort(children, function(a, b)
			return a.Name < b.Name
		end)
		table.sort(children2, function(a, b)
			return a.Name < b.Name
		end)
		local v6 = 1
		local v7 = children2[v6]
		local v8 = 1
		local v9 = children[v8]
		clone.Enabled = true
		clone.Parent = parent2
		task.spawn(function()
			local lastTime = tick()
			local v10 = 0
			local value = 100
			local total = 0
			local total2 = 0

			if totalKeyFrames and totalKeyFrames.Value > 0 then
				value = totalKeyFrames.Value
			end

			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				local v11 = tick() - lastTime
				local v12 = v11 / randomValueFromRange

				if v12 > 1 or not (clone.Parent and clone:IsDescendantOf(workspace)) then
					heartbeatConnection:Disconnect()

					if clone and clone.Parent then
						clone:Destroy()
					end
				else
					local v13 = math.floor(v12 * value)

					if v10 < v13 then
						v10 = v13
						local v14 = v10 / value
						local durationOfBlend = v9 and v9:FindFirstChild("DurationOfBlend")
						local durationOfBlend2 = v7 and v7:FindFirstChild("DurationOfBlend")

						if durationOfBlend and durationOfBlend2 then
							local value2 = durationOfBlend.Value

							if total2 + value2 < v11 and children[v8 + 1] then
								total2 += value2
								v8 += 1
								v9 = children[v8]
							end

							local value3 = durationOfBlend2.Value

							if total + value3 < v11 and children2[v6 + 1] then
								total += value3
								v6 += 1
								v7 = children2[v6]
							end

							local transparency = v9:FindFirstChild("Transparency")
							local blendSpeed = v9:FindFirstChild("BlendSpeed")
							local color = v7:FindFirstChild("Color")
							local blendSpeed2 = v7:FindFirstChild("BlendSpeed")

							if transparency and blendSpeed then
								clone.Transparency = Graph.BlendGraphWithTime(
									clone.Transparency,
									transparency.Transparency,
									blendSpeed.Transparency,
									v14
								)
							end

							if color and blendSpeed2 then
								clone.Color = Graph.BlendColorGraphWithTime(
									clone.Color,
									color.Color,
									blendSpeed2.Transparency,
									v14
								)
							end
						end

						for k, v15 in pairs(v5) do
							clone[k] = Graph.QueryPointsWithTime(v14, v15.Sequence, v15.Seed)
						end
					end
				end
			end)
		end)
	end
end

function beam.EnableEmit(_, beam2)
	if beam2:IsA("Beam") and beam2:GetAttribute("EmitDelay") then
		task.delay(beam2:GetAttribute("EmitDelay"), function()
			beam:Emit(beam2)
		end)
	end
end

function PartIcles.Transform(_, instance)
	if instance:IsA("Beam") then
		local clone = parent.Layouts.Beam.Factors:Clone()
		clone.Parent = instance
		instance:SetAttribute("Transformed", true)
		instance:SetAttribute("EmitCount", 1)
		instance:SetAttribute("EmitDuration", 0)
		instance:SetAttribute("EmitDelay", 0)
		instance:SetAttribute("IsEmitter", true)
	elseif instance:IsA("Part") or instance:IsA("MeshPart") then
		local clone_2 = parent.Layouts.Part.Factors:Clone()
		clone_2.Parent = instance
		instance:SetAttribute("Transformed", true)
		instance:SetAttribute("EmitCount", 0)
		instance:SetAttribute("EmitDuration", 0)
		instance:SetAttribute("EmitDelay", 0)
		instance:SetAttribute("IsEmitter", true)
	end
end

function PartIcles:Emit(folder, p)
	if folder:FindFirstChild("Factors") then
		local v3 = {
			[Enum.NormalId.Top] = folder.CFrame.UpVector,
			[Enum.NormalId.Bottom] = -folder.CFrame.UpVector,
			[Enum.NormalId.Front] = folder.CFrame.LookVector,
			[Enum.NormalId.Back] = -folder.CFrame.LookVector,
			[Enum.NormalId.Left] = -folder.CFrame.RightVector,
			[Enum.NormalId.Right] = folder.CFrame.RightVector
		}
		local specialMesh = folder:FindFirstChildOfClass("SpecialMesh")
		local decal = folder:FindFirstChildOfClass("Decal")
		local factors = folder:FindFirstChild("Factors")
		local totalKeyFrames = factors:FindFirstChild("TotalKeyFrames")
		local meshFlipbooks = factors:FindFirstChild("MeshFlipbooks")
		local main = factors:FindFirstChild("Main")
		local velocityVectored = factors:FindFirstChild("VelocityVectored")
		local main2 = factors:FindFirstChild("Main")
		local size = factors:FindFirstChild("Size")
		local X = size:FindFirstChild("X")
		local Y = size:FindFirstChild("Y")
		local Z = size:FindFirstChild("Z")
		local rotation = factors:FindFirstChild("Rotation")
		local X2 = rotation:FindFirstChild("X")
		local Y2 = rotation:FindFirstChild("Y")
		local Z2 = rotation:FindFirstChild("Z")
		local rotationSpeed = factors:FindFirstChild("RotationSpeed")
		local X3 = rotationSpeed:FindFirstChild("X")
		local Y3 = rotationSpeed:FindFirstChild("Y")
		local Z3 = rotationSpeed:FindFirstChild("Z")
		local main3 = factors:FindFirstChild("Main")
		local seeds = Graph.GenerateSeeds(main2.Size, 20)
		local seeds2 = Graph.GenerateSeeds(X.Size, 20)
		local seeds3 = Graph.GenerateSeeds(Y.Size, 20)
		local seeds4 = Graph.GenerateSeeds(Z.Size, 20)
		local seeds5 = Graph.GenerateSeeds(X3.Squash, 20)
		local seeds6 = Graph.GenerateSeeds(Y3.Squash, 20)
		local seeds7 = Graph.GenerateSeeds(Z3.Squash, 20)
		local seeds8 = Graph.GenerateSeeds(main3.Squash, 20)
		local seeds9 = Graph.GenerateSeeds(main.Transparency, 20)
		local v4 = math.random(1, 20)
		local seed = seeds[v4]
		local seed2 = seeds2[v4]
		local seed3 = seeds3[v4]
		local seed4 = seeds4[v4]
		local seed5 = seeds5[v4]
		local seed6 = seeds6[v4]
		local seed7 = seeds7[v4]
		local seed8 = seeds8[v4]
		local seed9 = seeds9[v4]
		local randomValueFromRange = Range.RandomValueFromRange(main.Lifetime)
		local randomValueFromRange2 = Range.RandomValueFromRange(X2.Rotation)
		local randomValueFromRange3 = Range.RandomValueFromRange(Y2.Rotation)
		local randomValueFromRange4 = Range.RandomValueFromRange(Z2.Rotation)
		folder.Locked = true
		folder:SetAttribute("IsEmitter", false)

		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		for _, attachment in folder:GetChildren() do
			if attachment:IsA("Attachment") then
				Particles.EnableEmitChildrenAndRepeatForAttachments(attachment)
			end

			Particles.EnableEmitSingle(attachment)
		end

		if decal then
			Flipbook.Flip(main, meshFlipbooks, decal, randomValueFromRange)
		end

		local v5 = main.ShapeInOut == Enum.ParticleEmitterShapeInOut.InAndOut and v2[main.Shape]

		if v5 then
			local v6, v7 = v5(folder, main)

			if typeof(v7) == "CFrame" and main.ShapeStyle == Enum.ParticleEmitterShapeStyle.Surface then
				local eulerAnglesXYZ, v8, v9 = folder.CFrame:ToEulerAnglesXYZ()
				folder:PivotTo(CFrame.new((folder.CFrame * CFrame.new(v6)).Position) * v7 * CFrame.Angles(
					eulerAnglesXYZ,
					v8,
					v9
				))
			else
				folder:PivotTo(CFrame.new((folder.CFrame * CFrame.new(v6)).Position) * folder.CFrame.Rotation)
			end
		end

		if specialMesh then
			specialMesh.Scale = createVector(0, 0, 0)
		else
			folder.Size = createVector(0, 0, 0)
		end

		folder.CFrame *= CFrame.Angles(
			math.rad(randomValueFromRange2),
			math.rad(randomValueFromRange3),
			(math.rad(randomValueFromRange4))
		)
		local position = folder.Position
		local emissionDirection = main.EmissionDirection
		local lookVector

		if velocityVectored.Value == false then
			lookVector = v3[emissionDirection]
		else
			local v6 = v[emissionDirection] or v[Enum.NormalId.Top]
			lookVector = folder.CFrame[v6.vector] * v6.multiplier
		end

		local spreadAngle = main.SpreadAngle
		local v6, v7

		if spreadAngle.X > 0 or spreadAngle.Y > 0 then
			v6 = (math.random() * 2 - 1) * spreadAngle.X
			v7 = (math.random() * 2 - 1) * spreadAngle.Y
			lookVector = (CFrame.lookAt(Vector3.new(), lookVector) * CFrame.Angles(math.rad(v6), math.rad(v7), 0)).LookVector
		else
			v6 = 0
			v7 = 0
		end

		local cframe = CFrame.Angles(math.rad(v6), math.rad(v7), 0)
		local _ = lookVector * Graph.QueryPointsWithTime(0.1, main3.Squash, seed8)
		local acceleration = main.Acceleration
		local cFrame = p and p.CFrame or CFrame.new()
		local v8 = p and cFrame:ToObjectSpace(folder.CFrame) or folder.CFrame
		task.spawn(function()
			local lastTime = tick()
			local v9 = 0
			local v10 = not (totalKeyFrames and totalKeyFrames.Value and totalKeyFrames.Value > 0) and 100 or totalKeyFrames.Value
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(_)
				local v11 = (tick() - lastTime) / randomValueFromRange

				if not (folder.Parent and folder:IsDescendantOf(workspace)) then
					heartbeatConnection:Disconnect()
				elseif v11 >= 1 or v10 <= v9 then
					local partLife = factors:FindFirstChild("PartLife")

					if partLife == nil then
						folder:Destroy()
					else
						task.delay(partLife.Value or 0, function()
							if folder and folder.Parent then
								folder:Destroy()
							end
						end)
					end

					heartbeatConnection:Disconnect()
				else
					local v12 = math.floor(v11 * v10)

					if v9 < v12 then
						v9 = v12
						task.spawn(function()
							local pointsWithTime = Graph.QueryPointsWithTime(v11, main2.Size, seed)
							local pointsWithTime2 = Graph.QueryPointsWithTime(v11, X.Size, seed2)
							local pointsWithTime3 = Graph.QueryPointsWithTime(v11, Y.Size, seed3)
							local pointsWithTime4 = Graph.QueryPointsWithTime(v11, Z.Size, seed4)
							local pointsWithTime5 = Graph.QueryPointsWithTime(v11, X3.Squash, seed5)
							local pointsWithTime6 = Graph.QueryPointsWithTime(v11, Y3.Squash, seed6)
							local pointsWithTime7 = Graph.QueryPointsWithTime(v11, Z3.Squash, seed7)
							local pointsWithTime8 = Graph.QueryPointsWithTime(v11, main3.Squash, seed8)
							local pointsWithTime9 = Graph.QueryPointsWithTime(v11, main.Transparency, seed9)
							local colorPointWithTime = Graph.QueryColorPointWithTime(v11, main.Color)
							local v13 = v11
							local v14 = acceleration * v13
							local v15 = pointsWithTime8 * math.exp(-main.Drag * v13)
							local v16 = position + lookVector * v15 * randomValueFromRange / 10 + v14 * randomValueFromRange / 10
							local cframe2 = CFrame.Angles(
								math.rad(pointsWithTime5),
								math.rad(pointsWithTime6),
								(math.rad(pointsWithTime7))
							)
							local v17 = v16 - position
							local cFrame2 = p and p.CFrame or CFrame.new()
							local vectorToObjectSpace = cFrame2:VectorToObjectSpace(v17)
							v8 = CFrame.new(vectorToObjectSpace) * v8
							folder.CFrame = cFrame2 * v8
							folder.CFrame *= cframe2
							position = folder.Position

							if specialMesh then
								specialMesh.Scale = Vector3.new(pointsWithTime2, pointsWithTime3, pointsWithTime4)
							else
								folder.Size = Vector3.new(pointsWithTime2, pointsWithTime3, pointsWithTime4)
							end

							if decal then
								decal.Transparency = pointsWithTime9
								decal.Color3 = Color3.fromRGB(
									colorPointWithTime.R * 255 * pointsWithTime,
									colorPointWithTime.G * 255 * pointsWithTime,
									colorPointWithTime.B * 255 * pointsWithTime
								)
							else
								folder.Transparency = pointsWithTime9
								folder.Color = colorPointWithTime
							end

							if velocityVectored.Value == true then
								local v18 = folder.CFrame * cframe
								local v19 = v[emissionDirection] or v[Enum.NormalId.Top]
								lookVector = v18[v19.vector] * v19.multiplier
							end
						end)
					end
				end
			end)
		end)
	end
end

function PartIcles:Enable(instance, p)
	if not instance:FindFirstChild("Factors") then
		warn(instance.Name .. "- is not Transformed")
		return
	end

	_G.Part_Icles.EnableAllowed = false
	local factors = instance:FindFirstChild("Factors")
	local factorsMain = factors and factors:FindFirstChild("Main")
	local enabled = factors and factors:FindFirstChild("Enabled")

	if not (factorsMain and enabled) then
		_G.Part_Icles.EnableAllowed = true
		return
	end

	local folder = PartIcles:GetFolder()

	if self.EnabledParts[instance] then
		task.cancel(self.EnabledParts[instance])
		self.EnabledParts[instance] = nil
	end

	self.EnabledParts[instance] = task.spawn(function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function cleanup()
			_G.Part_Icles.EnableAllowed = true
			self.EnabledParts[instance] = nil
		end

		while enabled.Value == true do
			if not is_alive(instance) then
				break
			end

			local clone = instance:Clone()
			self:Emit(clone, p)
			clone.Parent = folder
			task.wait(1 / math.max(factorsMain.Rate, 0.001))
		end

		cleanup() -- equivalent call inferred; original call site unknown
	end)
end

function PartIcles:EnableEmitChildren(instance)
	if not instance then
		return
	end

	task.spawn(function()
		if not instance then
			return
		end

		for _, beam2 in instance:GetChildren() do
			if not beam2:GetAttribute("Transformed") then
				continue
			end

			local factors = beam2:FindFirstChild("Factors")

			if not factors then
				continue
			end

			if beam2:IsA("Beam") then
				beam:EnableEmit(beam2)
			else
				local emitCount = beam2:GetAttribute("EmitCount") or 0
				local emitDelay = beam2:GetAttribute("EmitDelay") or 0
				local emitDuration = beam2:GetAttribute("EmitDuration") or 0
				local enabled = factors:FindFirstChild("Enabled")
				local folder = self:GetFolder()
				local clones = {}

				for i = 1, emitCount do
					clones[i] = beam2:Clone()
				end

				local v3 = beam2
				local v5 = beam2
				task.delay(emitDelay, function()
					if is_alive(v3) then
						for k, v10 in clones do
							self:Emit(v10, instance)
							self:EnableEmitChildren(v10, v3)
							v10.Parent = folder
						end

						if emitDuration > 0 and enabled then
							enabled.Value = true
							self:Enable(v3, instance)
							task.wait(emitDuration)

							if enabled.Parent then
								enabled.Value = false
							end
						end
					else
						for k, v10 in clones do
							v10:Destroy()
						end
					end
				end)
			end
		end
	end)
end

function PartIcles:EnableEmit(beam2, _)
	local factors = beam2:FindFirstChild("Factors")

	if factors then
		if beam2:IsA("Beam") then
			beam:EnableEmit(beam2)
			return
		end

		local emitCount = beam2:GetAttribute("EmitCount") or 0
		local emitDelay = beam2:GetAttribute("EmitDelay") or 0
		local emitDuration = beam2:GetAttribute("EmitDuration") or 0
		local enabled = factors:FindFirstChild("Enabled")
		local folder = self:GetFolder()
		local clones = {}

		for i = 1, emitCount do
			clones[i] = beam2:Clone()
		end

		task.delay(emitDelay, function()
			if is_alive(beam2) then
				for _, v4 in clones do
					self:Emit(v4)
					v4.Parent = folder
					self:EnableEmitChildren(v4)
				end

				if emitDuration > 0 and enabled then
					enabled.Value = true
					self:Enable(beam2)
					task.wait(emitDuration)

					if enabled.Parent then
						enabled.Value = false
					end
				end
			else
				for _, v4 in clones do
					v4:Destroy()
				end
			end
		end)
	end
end

function PartIcles:_emitAny(instance)
	if not instance:GetAttribute("Transformed") then
		return
	end

	self:EnableEmit(instance, true)

	for _, part in instance:GetChildren() do
		if part:GetAttribute("Transformed") then
			self:EnableEmit(part, true)
		elseif part:IsA("BasePart") then
			Particles.EnableEmit(part)
		end
	end
end

function PartIcles:_RecurCheck(instance)
	for _, child in instance:GetChildren() do
		if child:GetAttribute("Transformed") then
			self:EnableEmit(child, true)
		else
			self:_RecurCheck(child)
		end
	end
end

function PartIcles:AbsoluteEmit(instance)
	if instance:GetAttribute("Transformed") then
		self:_emitAny(instance)
	else
		self:_RecurCheck(instance)
	end
end

return PartIcles