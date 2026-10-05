local createVector = vector.create
local Graph = require(script.Graph)
local Range = require(script.Range)
local Particles = require(script.Particles)
local Flipbook = require(script.Flipbook)
local parent = script.Parent.Parent
local RunService = game:GetService("RunService")
local Part = {
	Beam = {}
}
local beam = Part.Beam
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
	[Enum.NormalId.Top] = createVector(0, 1, 0),
	[Enum.NormalId.Bottom] = createVector(0, -1, 0),
	[Enum.NormalId.Front] = createVector(0, 0, -1),
	[Enum.NormalId.Back] = createVector(0, 0, 1),
	[Enum.NormalId.Left] = createVector(-1, 0, 0),
	[Enum.NormalId.Right] = createVector(1, 0, 0)
}

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

				print(k .. " is static. Setting value to: " .. tostring(value))
				clone[k] = value
			else
				print(k .. " is a graph. Preparing for animation.")
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

				if v12 > 1 or not clone.Parent then
					heartbeatConnection:Disconnect()

					if clone and clone.Parent then
						clone:Destroy()
					end
				else
					local v13 = math.floor(v12 * value)

					if v10 < v13 then
						v10 = v13
						local v14 = v10 / value
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

						for k, v15 in pairs(v5) do
							clone[k] = Graph.QueryPointsWithTime(v14, v15.Sequence, v15.Seed)
						end
					end
				end
			end)
		end)
	end
end

function Part.Transform(_, instance)
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

function Part:Emit(clone, flag: boolean)
	if clone:FindFirstChild("Factors") then
		if clone:FindFirstChildOfClass("SpecialMesh") and clone:FindFirstChildOfClass("Decal") then
			local parent2

			if workspace.Terrain:FindFirstChild("EmittedPartsUsingPart_icle") then
				parent2 = workspace.Terrain.EmittedPartsUsingPart_icle
			else
				parent2 = Instance.new("Folder")
				parent2.Name = "EmittedPartsUsingPart_icle"
				parent2.Parent = workspace.Terrain
			end

			local factors = clone:FindFirstChild("Factors")
			local totalKeyFrames = factors:FindFirstChild("TotalKeyFrames")
			local meshFlipbooks = factors:FindFirstChild("MeshFlipbooks")
			local main = factors:FindFirstChild("Main")
			local velocityVectored = factors:FindFirstChild("VelocityVectored")
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
			local main2 = factors:FindFirstChild("Main")
			local seeds = Graph.GenerateSeeds(X.Size, 20)
			local seeds2 = Graph.GenerateSeeds(Y.Size, 20)
			local seeds3 = Graph.GenerateSeeds(Z.Size, 20)
			local seeds4 = Graph.GenerateSeeds(X3.Squash, 20)
			local seeds5 = Graph.GenerateSeeds(Y3.Squash, 20)
			local seeds6 = Graph.GenerateSeeds(Z3.Squash, 20)
			local seeds7 = Graph.GenerateSeeds(main2.Squash, 20)
			local seeds8 = Graph.GenerateSeeds(main.Transparency, 20)
			local brightness = main.Brightness
			local v4 = math.random(1, 20)
			local seed = seeds[v4]
			local seed2 = seeds2[v4]
			local seed3 = seeds3[v4]
			local seed4 = seeds4[v4]
			local seed5 = seeds5[v4]
			local seed6 = seeds6[v4]
			local seed7 = seeds7[v4]
			local seed8 = seeds8[v4]
			local randomValueFromRange = Range.RandomValueFromRange(main.Lifetime)
			local randomValueFromRange2 = Range.RandomValueFromRange(X2.Rotation)
			local randomValueFromRange3 = Range.RandomValueFromRange(Y2.Rotation)
			local randomValueFromRange4 = Range.RandomValueFromRange(Z2.Rotation)

			if flag == true then
				clone = clone:Clone()
				clone.Parent = parent2
			end

			clone.Locked = true
			clone:SetAttribute("IsEmitter", false)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, child in clone:GetChildren() do
				if child:IsA("Attachment") then
					Particles.EnableEmitChildrenAndRepeatForAttachments(child)
				end

				if child:IsA("ParticleEmitter") then
					Particles.EnableEmitSingle(child)
				end
			end

			local decal = clone:FindFirstChildOfClass("Decal")
			Flipbook.Flip(main, meshFlipbooks, decal, randomValueFromRange)
			local specialMesh = clone:FindFirstChildOfClass("SpecialMesh")
			clone.Rotation = Vector3.new(randomValueFromRange2, randomValueFromRange3, randomValueFromRange4)
			local position = clone.Position
			local emissionDirection = main.EmissionDirection
			local lookVector

			if velocityVectored.Value == false then
				lookVector = v2[emissionDirection]
			else
				local v5 = v[emissionDirection] or v[Enum.NormalId.Top]
				lookVector = clone.CFrame[v5.vector] * v5.multiplier
			end

			local spreadAngle = main.SpreadAngle
			local v5, v6

			if spreadAngle.X > 0 or spreadAngle.Y > 0 then
				v5 = (math.random() * 2 - 1) * spreadAngle.X
				v6 = (math.random() * 2 - 1) * spreadAngle.Y
				lookVector = (CFrame.lookAt(Vector3.new(), lookVector) * CFrame.Angles(v5, v6, 0)).LookVector
			else
				v5 = 0
				v6 = 0
			end

			local cframe = CFrame.Angles(math.rad(v5), math.rad(v6), 0)
			local _ = lookVector * Graph.QueryPointsWithTime(0.1, main2.Squash, seed7)
			local acceleration = main.Acceleration
			task.spawn(function()
				local lastTime = tick()
				local v7 = 0
				local v8 = not (totalKeyFrames and totalKeyFrames.Value and totalKeyFrames.Value > 0) and 100 or totalKeyFrames.Value
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					local v9 = (tick() - lastTime) / randomValueFromRange

					if v9 >= 1 or v8 <= v7 then
						heartbeatConnection:Disconnect()
						task.delay(factors.PartLife.Value or 0, function()
							clone:Destroy()
						end)
					else
						local v10 = math.floor(v9 * v8)

						if v7 < v10 then
							v7 = v10
							task.spawn(function()
								local pointsWithTime = Graph.QueryPointsWithTime(v9, X.Size, seed)
								local pointsWithTime2 = Graph.QueryPointsWithTime(v9, Y.Size, seed2)
								local pointsWithTime3 = Graph.QueryPointsWithTime(v9, Z.Size, seed3)
								local pointsWithTime4 = Graph.QueryPointsWithTime(v9, X3.Squash, seed4)
								local pointsWithTime5 = Graph.QueryPointsWithTime(v9, Y3.Squash, seed5)
								local pointsWithTime6 = Graph.QueryPointsWithTime(v9, Z3.Squash, seed6)
								local pointsWithTime7 = Graph.QueryPointsWithTime(v9, main2.Squash, seed7)
								local pointsWithTime8 = Graph.QueryPointsWithTime(v9, main.Transparency, seed8)
								local colorPointWithTime = Graph.QueryColorPointWithTime(v9, main.Color)
								local v11 = v9 * randomValueFromRange
								local v12 = randomValueFromRange / v8
								local _ = lookVector * pointsWithTime7
								local v13 = acceleration * v11
								local v14 = pointsWithTime7 * math.exp(-main.Drag * v11)
								local position2 = position + lookVector * v14 * randomValueFromRange / 10 + v13 * randomValueFromRange / 10
								specialMesh.Scale = Vector3.new(pointsWithTime, pointsWithTime2, pointsWithTime3)
								clone.Position = position2
								position = clone.Position
								local cframe2 = CFrame.Angles(
									math.rad(pointsWithTime4 * v12),
									math.rad(pointsWithTime5 * v12),
									(math.rad(pointsWithTime6 * v12))
								)
								clone.CFrame *= cframe2
								decal.Transparency = pointsWithTime8
								decal.Color3 = Color3.fromRGB(
									colorPointWithTime.R * 255 * brightness,
									colorPointWithTime.G * 255 * brightness,
									colorPointWithTime.B * 255 * brightness
								)

								if velocityVectored.Value == true then
									local v16 = clone.CFrame * cframe
									local v17 = v[emissionDirection] or v[Enum.NormalId.Top]
									lookVector = v16[v17.vector] * v17.multiplier
								end
							end)
						end
					end
				end)
			end)

			if flag == true then
				return clone
			end
		else
			local parent2

			if workspace.Terrain:FindFirstChild("EmittedPartsUsingPart_icle") then
				parent2 = workspace.Terrain.EmittedPartsUsingPart_icle
			else
				parent2 = Instance.new("Folder")
				parent2.Name = "EmittedPartsUsingPart_icle"
				parent2.Parent = workspace.Terrain
			end

			local factors = clone:FindFirstChild("Factors")
			local totalKeyFrames = factors:FindFirstChild("TotalKeyFrames")
			local main = factors:FindFirstChild("Main")
			clone:FindFirstChildOfClass("Decal")
			clone:FindFirstChildOfClass("SpecialMesh")
			local velocityVectored = factors:FindFirstChild("VelocityVectored")
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
			local main2 = factors:FindFirstChild("Main")
			local seeds = Graph.GenerateSeeds(X.Size, 20)
			local seeds2 = Graph.GenerateSeeds(Y.Size, 20)
			local seeds3 = Graph.GenerateSeeds(Z.Size, 20)
			local seeds4 = Graph.GenerateSeeds(X3.Squash, 20)
			local seeds5 = Graph.GenerateSeeds(Y3.Squash, 20)
			local seeds6 = Graph.GenerateSeeds(Z3.Squash, 20)
			local seeds7 = Graph.GenerateSeeds(main2.Squash, 20)
			local seeds8 = Graph.GenerateSeeds(main.Transparency, 20)
			local v4 = math.random(1, 20)
			local seed = seeds[v4]
			local seed2 = seeds2[v4]
			local seed3 = seeds3[v4]
			local seed4 = seeds4[v4]
			local seed5 = seeds5[v4]
			local seed6 = seeds6[v4]
			local seed7 = seeds7[v4]
			local seed8 = seeds8[v4]
			local randomValueFromRange = Range.RandomValueFromRange(main.Lifetime)
			local randomValueFromRange2 = Range.RandomValueFromRange(X2.Rotation)
			local randomValueFromRange3 = Range.RandomValueFromRange(Y2.Rotation)
			local randomValueFromRange4 = Range.RandomValueFromRange(Z2.Rotation)

			if flag == true then
				clone = clone:Clone()
				clone.Parent = parent2
			end

			clone.Locked = true
			clone:SetAttribute("IsEmitter", false)
			clone.Anchored = true

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			for _, child in clone:GetChildren() do
				if child:IsA("Attachment") then
					Particles.EnableEmitChildrenAndRepeatForAttachments(child)
				end

				if child:IsA("ParticleEmitter") then
					Particles.EnableEmitSingle(child)
				end
			end

			clone.Rotation = Vector3.new(randomValueFromRange2, randomValueFromRange3, randomValueFromRange4)
			local position = clone.Position
			local emissionDirection = main.EmissionDirection
			local lookVector

			if velocityVectored.Value == false then
				lookVector = v2[emissionDirection]
			else
				local v5 = v[emissionDirection] or v[Enum.NormalId.Top]
				lookVector = clone.CFrame[v5.vector] * v5.multiplier
			end

			local spreadAngle = main.SpreadAngle
			local v5, v6

			if spreadAngle.X > 0 or spreadAngle.Y > 0 then
				v5 = (math.random() * 2 - 1) * spreadAngle.X
				v6 = (math.random() * 2 - 1) * spreadAngle.Y
				lookVector = (CFrame.lookAt(Vector3.new(), lookVector) * CFrame.Angles(v5, v6, 0)).LookVector
			else
				v5 = 0
				v6 = 0
			end

			local cframe = CFrame.Angles(math.rad(v5), math.rad(v6), 0)
			local _ = lookVector * Graph.QueryPointsWithTime(0, main2.Squash, seed7)
			local acceleration = main.Acceleration
			task.spawn(function()
				local lastTime = tick()
				local v7 = 0
				local v8 = not (totalKeyFrames and totalKeyFrames.Value and totalKeyFrames.Value > 0) and 100 or totalKeyFrames.Value
				local heartbeatConnection = nil
				heartbeatConnection = RunService.Heartbeat:Connect(function()
					local v9 = (tick() - lastTime) / randomValueFromRange

					if v9 >= 1 or v8 <= v7 then
						heartbeatConnection:Disconnect()

						if factors:FindFirstChild("PartLife") then
							task.delay(factors.PartLife.Value or 0, function()
								clone:Destroy()
							end)
						else
							clone:Destroy()
						end
					else
						local v10 = math.floor(v9 * v8)

						if v7 < v10 then
							v7 = v10
							local v11 = v7 / v8
							task.spawn(function()
								local pointsWithTime = Graph.QueryPointsWithTime(v11, X.Size, seed)
								local pointsWithTime2 = Graph.QueryPointsWithTime(v11, Y.Size, seed2)
								local pointsWithTime3 = Graph.QueryPointsWithTime(v11, Z.Size, seed3)
								local pointsWithTime4 = Graph.QueryPointsWithTime(v11, X3.Squash, seed4)
								local pointsWithTime5 = Graph.QueryPointsWithTime(v11, Y3.Squash, seed5)
								local pointsWithTime6 = Graph.QueryPointsWithTime(v11, Z3.Squash, seed6)
								local pointsWithTime7 = Graph.QueryPointsWithTime(v11, main2.Squash, seed7)
								local pointsWithTime8 = Graph.QueryPointsWithTime(v11, main.Transparency, seed8)
								local colorPointWithTime = Graph.QueryColorPointWithTime(v11, main.Color)
								local v12 = v11 * randomValueFromRange
								local v13 = randomValueFromRange / v8
								local _ = lookVector * pointsWithTime7
								local v14 = acceleration * v12
								local v15 = pointsWithTime7 * math.exp(-main.Drag * v12)
								local position2 = position + lookVector * v15 * randomValueFromRange / 10 + v14 * randomValueFromRange / 10
								clone.Size = Vector3.new(pointsWithTime, pointsWithTime2, pointsWithTime3)
								clone.Position = position2
								position = clone.Position
								local cframe2 = CFrame.Angles(
									math.rad(pointsWithTime4 * v13),
									math.rad(pointsWithTime5 * v13),
									(math.rad(pointsWithTime6 * v13))
								)
								clone.CFrame *= cframe2
								clone.Transparency = pointsWithTime8
								clone.Color = colorPointWithTime

								if velocityVectored.Value == true then
									local v17 = clone.CFrame * cframe
									local v18 = v[emissionDirection] or v[Enum.NormalId.Top]
									lookVector = v17[v18.vector] * v18.multiplier
								end
							end)
						end
					end
				end)
			end)

			if flag == true then
				return clone
			end
		end
	end
end

function Part:Enable(instance)
	if not instance:FindFirstChild("Factors") then
		warn(instance.Name .. "- is not Transformed")
		return
	end

	local factors = instance:FindFirstChild("Factors")
	local main = factors:FindFirstChild("Main")
	local enabled = factors:FindFirstChild("Enabled")
	task.spawn(function()
		while enabled.Value == true do
			Part:Emit(instance, true)
			task.wait(1 / main.Rate)
		end
	end)
end

function Part:EnableEmit(instance)
	task.spawn(function()
		task.wait(instance:GetAttribute("EmitDelay"))
		local emitCount = instance:GetAttribute("EmitCount")
		task.spawn(function()
			for _ = 1, emitCount do
				Part:Emit(instance, false)
			end
		end)
		task.spawn(function()
			if instance:GetAttribute("EmitDuration") > 0 then
				local enabled = instance:FindFirstChild("Factors").Enabled
				enabled.Value = true
				Part:Enable(instance)
				task.wait(instance:GetAttribute("EmitDuration"))
				enabled.Value = false
			end
		end)
	end)
end

function Part:EnableEmitAll(instance)
	print(instance.Name)
	task.spawn(function()
		task.wait(instance:GetAttribute("EmitDelay"))

		for _ = 1, instance:GetAttribute("EmitCount") do
			local folder = Part:Emit(instance, true)
			task.spawn(function()
				for i, beam2 in folder:GetDescendants() do
					if not (beam2:GetAttribute("Transformed") and beam2:GetAttribute("IsEmitter") == true) then
						continue
					end

					if beam2:IsA("Beam") then
						beam:Emit(beam2)
					else
						Part:EnableEmit(beam2)
					end
				end
			end)
		end
	end)
end

function Part.AbsoluteEmit(_, beam2)
	task.spawn(function()
		if beam2:GetAttribute("Transformed") and beam2:GetAttribute("IsEmitter") == true then
			if beam2:IsA("Beam") then
				beam:Emit(beam2)
			else
				Part:EnableEmitAll(beam2)
			end
		end
	end)
end

return Part