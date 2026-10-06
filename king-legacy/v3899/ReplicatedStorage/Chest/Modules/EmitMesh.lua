local createVector = vector.create
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
local Graph = require(script.Graph)
local Range = require(script.Range)
local Particles = require(script.Particles)
local Flipbook = require(script.Flipbook)
local parent = script.Parent.Parent
game:GetService("RunService")
local EmitMesh = {
	Beam = {},
	EnabledParts = {}
}
_G.Part_Icles = _G.Part_Icles or {}
_G.Part_Icles.EnableAllowed = _G.Part_Icles.EnableAllowed or true
local beam = EmitMesh.Beam
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

function EmitMesh:GetFolder()
	if workspace.Terrain:FindFirstChild("EmittedParts_InGame") then
		local _ = workspace.Terrain.EmittedParts_InGame
	else
		local folder = Instance.new("Folder")
		folder.Name = "EmittedParts_InGame"
		folder.Parent = workspace.Terrain
	end

	return workspace.Effects
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

			task.spawn(function()
				PeodizService.new({
					Time = 10
				}, function()
					local v11 = tick() - lastTime
					local v12 = v11 / randomValueFromRange

					if v12 > 1 or not clone.Parent then
						if clone and clone.Parent then
							clone:Destroy()
						end

						return true
					else
						local v13 = math.floor(v12 * value)

						if v10 < v13 then
							v10 = v13
							local v14 = v10 / value

							if v9 and v9.DurationOfBlend then
								local value2 = v9.DurationOfBlend.Value

								if total2 + value2 < v11 and children[v8 + 1] then
									total2 += value2
									v8 += 1
									v9 = children[v8]
								end

								local value3 = v7.DurationOfBlend.Value

								if total + value3 < v11 and children2[v6 + 1] then
									total += value3
									v6 += 1
									v7 = children2[v6]
								end

								local transparency = v9.Transparency.Transparency
								local transparency2 = v9.BlendSpeed.Transparency
								clone.Transparency = Graph.BlendGraphWithTime(
									clone.Transparency,
									transparency,
									transparency2,
									v14
								)
								local color = v7.Color.Color
								local transparency3 = v7.BlendSpeed.Transparency
								clone.Color = Graph.BlendColorGraphWithTime(clone.Color, color, transparency3, v14)
							end

							for k, v15 in pairs(v5) do
								clone[k] = Graph.QueryPointsWithTime(v14, v15.Sequence, v15.Seed)
							end
						end
					end
				end)
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

function EmitMesh.Transform(_, instance)
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

function EmitMesh:Emit(folder, _, p)
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
		local lockedToPart = main3.LockedToPart
		local seeds = Graph.GenerateSeeds(main2.Size, 1)
		local seeds2 = Graph.GenerateSeeds(X.Size, 1)
		local seeds3 = Graph.GenerateSeeds(Y.Size, 1)
		local seeds4 = Graph.GenerateSeeds(Z.Size, 1)
		local seeds5 = Graph.GenerateSeeds(X3.Squash, 1)
		local seeds6 = Graph.GenerateSeeds(Y3.Squash, 1)
		local seeds7 = Graph.GenerateSeeds(Z3.Squash, 1)
		local seeds8 = Graph.GenerateSeeds(main3.Squash, 1)
		local seeds9 = Graph.GenerateSeeds(main.Transparency, 1)
		local seed = seeds[1]
		local seed2 = seeds2[1]
		local seed3 = seeds3[1]
		local seed4 = seeds4[1]
		local seed5 = seeds5[1]
		local seed6 = seeds6[1]
		local seed7 = seeds7[1]
		local seed8 = seeds8[1]
		local seed9 = seeds9[1]
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

		local cFrame = folder.CFrame

		if main.ShapeInOut == Enum.ParticleEmitterShapeInOut.InAndOut then
			local v4 = v2[main.Shape]

			if v4 then
				local v5, v6 = v4(folder, main)

				if typeof(v6) == "CFrame" and main.ShapeStyle == Enum.ParticleEmitterShapeStyle.Surface then
					local eulerAnglesXYZ, v7, v8 = cFrame:ToEulerAnglesXYZ()
					cFrame = CFrame.new((cFrame * CFrame.new(v5)).Position) * v6 * CFrame.Angles(eulerAnglesXYZ, v7, v8)
				else
					cFrame = CFrame.new((cFrame * CFrame.new(v5)).Position) * cFrame.Rotation
				end
			end
		end

		local cframe = cFrame * CFrame.Angles(
			math.rad(randomValueFromRange2),
			math.rad(randomValueFromRange3),
			(math.rad(randomValueFromRange4))
		)
		folder:PivotTo(cframe)

		if specialMesh then
			specialMesh.Scale = createVector(0, 0, 0)
		else
			folder.Size = createVector(0, 0, 0)
		end

		local emissionDirection = main.EmissionDirection
		local lookVector

		if velocityVectored.Value == false then
			lookVector = v3[emissionDirection]
		else
			local v4 = v[emissionDirection] or v[Enum.NormalId.Top]
			lookVector = folder.CFrame[v4.vector] * v4.multiplier
		end

		local spreadAngle = main.SpreadAngle

		if spreadAngle.X > 0 or spreadAngle.Y > 0 then
			local v4 = (math.random() * 2 - 1) * spreadAngle.X
			local v5 = (math.random() * 2 - 1) * spreadAngle.Y
			lookVector = (CFrame.lookAt(Vector3.new(), lookVector) * CFrame.Angles(math.rad(v4), math.rad(v5), 0)).LookVector
		end

		local acceleration = main.Acceleration
		local identity = CFrame.identity

		if lockedToPart and p then
			identity = p.CFrame:ToObjectSpace(cframe)

			if velocityVectored.Value == true then
				lookVector = cframe:VectorToObjectSpace(lookVector)
				acceleration = cframe:VectorToObjectSpace(acceleration)
			end
		end

		task.spawn(function()
			local lastTime = tick()
			local v4 = 0
			local value = 100
			local v5 = createVector(0, 0, 0)

			if totalKeyFrames and totalKeyFrames.Value and totalKeyFrames.Value > 0 then
				value = totalKeyFrames.Value
			end

			task.spawn(function()
				PeodizService.new({
					Time = 10
				}, function(p2)
					local v6 = (tick() - lastTime) / randomValueFromRange

					if v6 >= 1 or value <= v4 then
						if factors:FindFirstChild("PartLife") == nil then
							folder:Destroy()
						else
							task.delay(factors.PartLife.Value or 0, function()
								folder:Destroy()
							end)
						end

						return true
					else
						local v7 = math.floor(v6 * value)

						if v4 < v7 then
							v4 = v7
							task.spawn(function()
								local pointsWithTime = Graph.QueryPointsWithTime(v6, main2.Size, seed)
								local pointsWithTime2 = Graph.QueryPointsWithTime(v6, X.Size, seed2)
								local pointsWithTime3 = Graph.QueryPointsWithTime(v6, Y.Size, seed3)
								local pointsWithTime4 = Graph.QueryPointsWithTime(v6, Z.Size, seed4)
								local pointsWithTime5 = Graph.QueryPointsWithTime(v6, X3.Squash, seed5)
								local pointsWithTime6 = Graph.QueryPointsWithTime(v6, Y3.Squash, seed6)
								local pointsWithTime7 = Graph.QueryPointsWithTime(v6, Z3.Squash, seed7)
								local pointsWithTime8 = Graph.QueryPointsWithTime(v6, main3.Squash, seed8)
								local pointsWithTime9 = Graph.QueryPointsWithTime(v6, main.Transparency, seed9)
								local colorPointWithTime = Graph.QueryColorPointWithTime(v6, main.Color)
								local v8 = v6
								local v10 = lookVector * (pointsWithTime8 * math.exp(-main.Drag * v8)) * (p2 * 10) + acceleration * v8 * (p2 * 10)
								v5 += v10
								local cframe2 = CFrame.Angles(
									math.rad(pointsWithTime5),
									math.rad(pointsWithTime6),
									(math.rad(pointsWithTime7))
								)
								local v11

								if lockedToPart and p then
									local cframe3 = CFrame.new(v5)
									v11 = p.CFrame * identity * cframe3 * cframe2
								else
									v11 = cframe * CFrame.new(v5) * cframe2
								end

								folder:PivotTo(v11)

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
							end)
						end
					end
				end)
			end)
		end)
	end
end

function EmitMesh:EnableVFX(instance, enabled: boolean)
	if instance:FindFirstChild("Factors") and _G.Part_Icles.EnableAllowed == true then
		local function enabledVFX(_)
			local factors = instance:FindFirstChild("Factors")

			if not factors then
				return
			end

			local main = factors:FindFirstChild("Main")
			local enabled2 = factors:FindFirstChild("Enabled")
			local enableWithRespectToEnable = factors:FindFirstChild("EnableWithRespectToEnable")

			if enableWithRespectToEnable then
				enableWithRespectToEnable.Value = enabled
			end

			if enabled2 then
				main:SetAttribute("Enabled", enabled)
			end

			if enabled then
				self:Enable(instance)
			end
		end

		enabledVFX(instance)

		for _, part in ipairs(instance:GetChildren()) do
			if part:IsA("BasePart") then
				enabledVFX(part)
			end
		end
	end
end

function EmitMesh:Enable(instance)
	if not instance:FindFirstChild("Factors") or _G.Part_Icles.EnableAllowed ~= true then
		warn(instance.Name .. "- is not Transformed")
		return
	end

	local factors = instance:FindFirstChild("Factors")
	local main = factors:FindFirstChild("Main")
	local enabled = factors:FindFirstChild("Enabled")
	local enableWithRespectToEnable = factors:FindFirstChild("EnableWithRespectToEnable")
	print(self)
	local folder = self:GetFolder()

	if self.EnabledParts[instance] then
		task.cancel(self.EnabledParts[instance])
		self.EnabledParts[instance] = nil
	end

	self.EnabledParts[instance] = task.spawn(function()
		PeodizService.new({
			Time = 10,
			WaitTime = 1 / main.Rate
		}, function(_)
			if not (instance.Parent and enabled.Value and main:GetAttribute("Enabled")) then
				return true
			end

			if not enableWithRespectToEnable or enableWithRespectToEnable.Value ~= false then
				local clone = instance:Clone()
				self:Emit(clone, clone.Parent, instance)
				clone.Parent = folder
			end
		end)
	end)
end

function EmitMesh:EmitVFX(p, p2)
	self:EnableEmit(p, p2)
	self:EnableEmitChildren(p)
end

function EmitMesh:EnableEmit(beam2)
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
			for _, v3 in clones do
				v3.Parent = folder
				self:Emit(v3)
				self:EnableEmitChildren(v3)
			end

			if emitDuration > 0 then
				enabled.Value = true
				self:Enable(beam2)
				task.wait(emitDuration)
				enabled.Value = false
			end
		end)
	end
end

function EmitMesh:EnableEmitChildren(instance)
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

			local v5 = beam2
			local v8 = beam2
			task.delay(emitDelay, function()
				for k, v9 in clones do
					v9.Parent = folder
					self:Emit(v9)
					self:EnableEmitChildren(v9, v5)
				end

				if emitDuration > 0 then
					enabled.Value = true
					self:Enable(v5, instance)
					task.wait(emitDuration)
					enabled.Value = false
				end
			end)
		end
	end
end

function EmitMesh:_RecurCheck(instance)
	for _, child in instance:GetChildren() do
		if child:GetAttribute("Transformed") then
			self:EnableEmit(child)
		else
			self:_RecurCheck(child)
		end
	end
end

function EmitMesh:AbsoluteEmit(instance)
	if instance:GetAttribute("Transformed") then
		self:EnableEmit(instance)
		return
	end

	self:_RecurCheck(instance)

	for _, part in instance:GetChildren() do
		if part:IsA("BasePart") and part:GetAttribute("Transformed") == nil then
			Particles.EnableEmit(part)
		end
	end
end

return EmitMesh