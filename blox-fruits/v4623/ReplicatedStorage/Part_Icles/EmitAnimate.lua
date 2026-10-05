local createVector = vector.create
local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local Particles = require(script.Parent.Particles)
local PartConstants = require(script.Parent.PartConstants)
local AxisLinks = require(script.Parent.AxisLinks)
local Events = require(script.Parent.Events)
local StaticPass = require(script.Parent.StaticPass)
local Turbulence = require(script.Parent.Turbulence)
local directionVectors = PartConstants.DirectionVectors
local shapeFunctions = PartConstants.shapeFunctions
return function(p)
	function p:EmitPartAnimate(instance, p2, p3)
		if not (instance and instance.Parent) then
			return
		end

		local data = self:GetData(instance)

		if not (data and data.RenderTemplate) then
			return
		end

		local link = p2 or data.Link
		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local renderTemplate = data.RenderTemplate
		local cFrame = renderTemplate.CFrame
		local cFrame2

		if link then
			local linkCFrame = PartConstants.resolveLinkCFrame(link)
			local position = linkCFrame.Position

			if data.LinkMode == "Follow" then
				cFrame2 = CFrame.new(position) * instance.CFrame.Rotation
			elseif link == instance then
				cFrame2 = instance.CFrame
			else
				cFrame2 = CFrame.new(position) * linkCFrame.Rotation * instance.CFrame.Rotation
			end
		else
			cFrame2 = instance.CFrame
		end

		local v3 = directionVectors[data.EmissionDirection] or directionVectors[Enum.NormalId.Top]
		local v4 = cFrame2[v3.vector] * v3.multiplier
		local vector2 = Vector3.new()
		local v5 = nil
		local v6

		if data.UseShape then
			local shapeFunction = shapeFunctions[data.ParticleData.Shape]

			if shapeFunction then
				local shapePart = data.ShapePart or instance
				local cFrame3

				if data.ShapePart then
					cFrame3 = data.ShapePart.CFrame or cFrame2
				else
					cFrame3 = cFrame2
				end

				local v7, v8, v9 = shapeFunction(shapePart, data.ParticleData)
				local shapeInOut = data.ParticleData.ShapeInOut

				if shapeInOut == Enum.ParticleEmitterShapeInOut.Inward then
					v9 = -v9
				elseif shapeInOut == Enum.ParticleEmitterShapeInOut.InAndOut and math.random() < 0.5 then
					v9 = -v9
				end

				v5 = (cFrame3 - cFrame3.Position):VectorToWorldSpace(v9)

				if data.ParticleData.LookAtInitially then
					local eulerAnglesXYZ, v10, v11 = cFrame2:ToEulerAnglesXYZ()
					v6 = CFrame.new((cFrame3 * CFrame.new(v7)).Position) * v8 * CFrame.Angles(eulerAnglesXYZ, v10, v11)
				else
					v6 = CFrame.new((cFrame3 * CFrame.new(v7)).Position) * cFrame2.Rotation
				end
			else
				v6 = CFrame.new((cFrame2 * CFrame.new(vector2)).Position) * cFrame2.Rotation
			end
		else
			v6 = CFrame.new((cFrame2 * CFrame.new(vector2)).Position) * cFrame2.Rotation
		end

		local dirMode = data.DirMode or "RigidLocal"
		local rangeAxes = AxisLinks.sampleRangeAxes(data, data.AxisLinks, { "RotX", "RotY", "RotZ" }, Range, p3)
		local rotX = rangeAxes.RotX
		local rotY = rangeAxes.RotY
		local rotZ = rangeAxes.RotZ
		local cframe = PartConstants.composeRotation(data.RotOrder or "Global", rotX, rotY, rotZ)
		local v7 = v6 * cframe
		local v8 = PartConstants.applyPositionOffset(v7, data, link, instance, Range, AxisLinks, p3)

		if dirMode == "Global" then
			v8 = CFrame.new(v8.Position) * cframe
		end

		if v5 then
			v4 = v5
		elseif dirMode == "Local" then
			v4 = v8[v3.vector] * v3.multiplier
		elseif dirMode == "Global" then
			v4 = CFrame.new()[v3.vector] * v3.multiplier
		end

		local v9, v10

		if data.ParticleData.SpreadAngle.X > 0 or data.ParticleData.SpreadAngle.Y > 0 then
			v9 = (math.random() * 2 - 1) * data.ParticleData.SpreadAngle.X
			v10 = (math.random() * 2 - 1) * data.ParticleData.SpreadAngle.Y
		else
			v9 = 0
			v10 = 0
		end

		local cframe2 = CFrame.Angles(math.rad(v9), math.rad(v10), 0)
		local lookVector = (CFrame.lookAt(Vector3.new(), v4) * cframe2).LookVector
		local seeds = {
			SizeX = Graph.GenerateSeed(data.SizeX),
			SizeY = Graph.GenerateSeed(data.SizeY),
			SizeZ = Graph.GenerateSeed(data.SizeZ),
			RotSpeedX = Graph.GenerateSeed(data.RotSpeedX),
			RotSpeedY = Graph.GenerateSeed(data.RotSpeedY),
			RotSpeedZ = Graph.GenerateSeed(data.RotSpeedZ),
			PosOffsetX = Graph.GenerateSeed(data.PosOffsetX),
			PosOffsetY = Graph.GenerateSeed(data.PosOffsetY),
			PosOffsetZ = Graph.GenerateSeed(data.PosOffsetZ),
			Speed = Graph.GenerateSeed(data.Speed),
			Brightness = Graph.GenerateSeed(data.Brightness),
			Transparency = Graph.GenerateSeed(data.Transparency),
			AccelStrength = Graph.GenerateSeed(data.AccelStrength),
			Timescale = Graph.GenerateSeed(data.Timescale)
		}
		AxisLinks.applyGraphAxisAliases(data, seeds, data.AxisLinks)
		local invertMotion = data.InvertMotion
		local simLocalCFrames, v13

		if invertMotion then
			simLocalCFrames, v13 = self:PreSimulateForward(
				data,
				seeds,
				v8,
				lookVector,
				cframe2,
				link,
				lifeTime,
				nil,
				v8.Rotation * cframe:Inverse()
			)
		end

		local cframe3

		if link then
			cframe3 = PartConstants.resolveLinkCFrame(link)

			if data.LinkMode == "Follow" or data.LinkMode == "Pivot" then
				cframe3 = CFrame.new(cframe3.Position) or cframe3
			end
		else
			cframe3 = CFrame.new()
		end

		if invertMotion and simLocalCFrames then
			v8 = simLocalCFrames[v13 or data.TotalKeyFrames] or simLocalCFrames[0]
		elseif link then
			v8 = cframe3:ToObjectSpace(v8) or v8
		end

		renderTemplate.CFrame = cframe3 * v8
		local v14 = {
			Type = "Part",
			VisualPart = renderTemplate,
			Link = link,
			LinkMode = data.LinkMode
		}

		if data.LinkMode ~= "RigidLocal" or not (link and cframe3) then
			cframe3 = nil
		end

		v14._rigidLocalParentCF = cframe3
		v14.Events = data.Events
		v14.SpecialMesh = renderTemplate:FindFirstChildOfClass("SpecialMesh")
		v14.Decal = renderTemplate:FindFirstChildOfClass("Decal")
		v14.SurfaceAppearance = renderTemplate:FindFirstChildOfClass("SurfaceAppearance")
		local surfaceAppearance = renderTemplate:FindFirstChildOfClass("SurfaceAppearance")
		v14._initialSAColor = surfaceAppearance and surfaceAppearance.Color or nil
		local initialPartColor

		if renderTemplate:IsA("BasePart") then
			initialPartColor = renderTemplate.Color or nil
		end

		v14._initialPartColor = initialPartColor
		v14.StartTime = os.clock()
		v14.TotalKeyFrames = invertMotion and v13 or math.max(1, data.TotalKeyFrames)
		v14.CurrentStep = 0
		v14.AccumulatedDT = 0
		v14.LifeTime = lifeTime
		v14.PartLife = data.PartLife or 0
		v14.CurrentPosition = renderTemplate.Position
		v14.LocalCF = v8
		v14.BaseDirection = lookVector
		v14._initialBaseDirection = lookVector
		v14.EmissionDirection = data.EmissionDirection
		v14.SpreadRotation = cframe2
		v14.Acceleration = data.ParticleData.Acceleration
		v14.Drag = data.ParticleData.Drag
		v14.VelocityVectored = data.VelocityVectored
		v14.InvertMotion = invertMotion
		v14.SimLocalCFrames = simLocalCFrames
		v14.RotMode = data.RotMode or "OverLife"
		v14.RotOrder = data.RotOrder or "Global"
		v14.AccRotX = 0
		v14.AccRotY = 0
		v14.AccRotZ = 0
		v14.Orientation = data.Orientation
		v14.ZOffset = data.ZOffset
		v14._localWorldCF = v8
		v14.SpawnRotation = v8.Rotation
		v14.SpawnEmitterRotation = v8.Rotation * cframe:Inverse()
		v14.DisplacementMode = data.DisplacementMode
		v14._sleepRadius = not (renderTemplate and renderTemplate:IsA("BasePart")) and 1 or renderTemplate.Size.Magnitude * 0.5 or 1
		v14._prevWorldOff = createVector(0, 0, 0)
		v14.HasPosOffsetGraphs = data.PosOffsetX ~= nil or data.PosOffsetY ~= nil or data.PosOffsetZ ~= nil
		v14.NeedsFullIteration = data.VelocityVectored
		local needsRotAccum

		if data.RotMode == "Speed" then
			needsRotAccum = not data.VelocityVectored
		else
			needsRotAccum = false
		end

		v14.NeedsRotAccum = needsRotAccum
		v14.HasDrag = data.ParticleData.Drag ~= 0
		v14.HasAccel = data.ParticleData.Acceleration.Magnitude > 0
		v14.HasDecal = renderTemplate:FindFirstChildOfClass("Decal") ~= nil
		local hasTargetAccel

		if data.AccelerationTowardsInstance == true and data.AccelTarget ~= nil and data.AccelStrength ~= nil then
			hasTargetAccel = not data.InvertMotion
		else
			hasTargetAccel = false
		end

		v14.HasTargetAccel = hasTargetAccel
		v14.AccelTarget = data.AccelTarget
		v14.TargetVel = createVector(0, 0, 0)
		v14.Graphs = {
			SizeX = data.SizeX,
			SizeY = data.SizeY,
			SizeZ = data.SizeZ,
			RotSpeedX = data.RotSpeedX,
			RotSpeedY = data.RotSpeedY,
			RotSpeedZ = data.RotSpeedZ,
			PosOffsetX = data.PosOffsetX,
			PosOffsetY = data.PosOffsetY,
			PosOffsetZ = data.PosOffsetZ,
			Speed = data.Speed,
			Brightness = data.Brightness,
			Transparency = data.Transparency,
			Color = data.Color,
			AccelStrength = data.AccelStrength,
			Timescale = data.Timescale
		}
		v14.Seeds = seeds
		v14._effectiveElapsed = Graph.InitialEffectiveElapsed(data.Timescale, seeds.Timescale, lifeTime)
		v14.IsAnimate = true
		v14.AnimateItem = instance
		v14.InitialAnchorCF = cFrame
		v14.InitialLocalCF = v8

		if v14.HasPosOffsetGraphs then
			local v18 = not v14.Graphs.PosOffsetX and 0 or Graph.QueryPointsWithTime(
				0,
				v14.Graphs.PosOffsetX,
				v14.Seeds.PosOffsetX
			) or 0
			local v19 = not v14.Graphs.PosOffsetY and 0 or Graph.QueryPointsWithTime(
				0,
				v14.Graphs.PosOffsetY,
				v14.Seeds.PosOffsetY
			) or 0
			local v20 = not v14.Graphs.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
				0,
				v14.Graphs.PosOffsetZ,
				v14.Seeds.PosOffsetZ
			) or 0
			local displacement = PartConstants.resolveDisplacement(
				Vector3.new(v18, v19, v20),
				data.DisplacementMode or "Global",
				v14.SpawnRotation,
				v14.SpawnEmitterRotation
			)
			v14._prevWorldOff = displacement

			if v18 ~= 0 or v19 ~= 0 or v20 ~= 0 then
				v14.LocalCF += displacement
				v14.VisualPart.CFrame = v14.VisualPart.CFrame + displacement
			end
		end

		Turbulence.buildInto(v14, data)
		local vector3 = Vector3.new(
			Graph.QueryPointsWithTime(0, v14.Graphs.SizeX, v14.Seeds.SizeX),
			Graph.QueryPointsWithTime(0, v14.Graphs.SizeY, v14.Seeds.SizeY),
			Graph.QueryPointsWithTime(0, v14.Graphs.SizeZ, v14.Seeds.SizeZ)
		)
		local pointsWithTime = Graph.QueryPointsWithTime(0, v14.Graphs.Transparency, v14.Seeds.Transparency)
		local colorPointWithTime = Graph.QueryColorPointWithTime(0, v14.Graphs.Color)
		local pointsWithTime2 = Graph.QueryPointsWithTime(0, v14.Graphs.Brightness, v14.Seeds.Brightness)

		if v14.SpecialMesh then
			v14.SpecialMesh.Scale = vector3
		else
			v14.VisualPart.Size = vector3
		end

		if v14.SurfaceAppearance then
			v14.VisualPart.Transparency = pointsWithTime
			v14.VisualPart.Color = Color3.fromRGB(
				colorPointWithTime.R * 255,
				colorPointWithTime.G * 255,
				colorPointWithTime.B * 255
			)
			v14.SurfaceAppearance.Color = Color3.fromRGB(
				colorPointWithTime.R * 255,
				colorPointWithTime.G * 255,
				colorPointWithTime.B * 255
			)
			pcall(function()
				v14.SurfaceAppearance.EmissiveTint = Color3.new(
					colorPointWithTime.R * pointsWithTime2,
					colorPointWithTime.G * pointsWithTime2,
					colorPointWithTime.B * pointsWithTime2
				)
			end)
		elseif v14.Decal then
			v14.Decal.Transparency = pointsWithTime
			v14.Decal.Color3 = Color3.fromRGB(
				colorPointWithTime.R * 255 * pointsWithTime2,
				colorPointWithTime.G * 255 * pointsWithTime2,
				colorPointWithTime.B * 255 * pointsWithTime2
			)
		else
			v14.VisualPart.Transparency = pointsWithTime
			v14.VisualPart.Color = Color3.fromRGB(
				colorPointWithTime.R * 255,
				colorPointWithTime.G * 255,
				colorPointWithTime.B * 255
			)
		end

		local _makeAliveCheck = self:_makeAliveCheck()

		for _, attachment in renderTemplate:GetChildren() do
			if attachment:IsA("Attachment") then
				Particles.EnableEmitChildrenAndRepeatForAttachments(attachment, _makeAliveCheck)
			end

			Particles.EnableEmitSingle(attachment, _makeAliveCheck)
		end

		if self._parentScaleMap and self._parentScaleMap[instance] then
			v14.ParentScale = self._parentScaleMap[instance]
		end

		v14._sourceItem = instance
		p._seedTsOverride(v14, instance)
		StaticPass.apply(v14)
		self.ActiveAnimates[instance] = v14
		self:_applyEmitVisualPasses(v14)
		self:_registerEmit(v14, p3)

		for _, descendant in renderTemplate:GetDescendants() do
			if descendant:GetAttribute("Transformed") then
				self:EnableEmit(descendant, descendant.Parent, Events.descendCtx(p3))
			end
		end
	end

	function p.EmitAttachmentAnimate(object, p2, p3, p4)
		if not (p2 and p2.Parent) then
			return
		end

		local data = object:GetData(p2)

		if not (data and data.RenderTemplate) then
			return
		end

		local link = p3 or data.Link
		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local renderTemplate = data.RenderTemplate
		local cFrame = renderTemplate.CFrame
		local cframe = CFrame.new()
		local v3 = directionVectors[data.EmissionDirection] or directionVectors[Enum.NormalId.Top]
		local dirMode = data.DirMode or "RigidLocal"
		local rangeAxes = AxisLinks.sampleRangeAxes(data, data.AxisLinks, { "RotX", "RotY", "RotZ" }, Range, p4)
		local rotX = rangeAxes.RotX
		local rotY = rangeAxes.RotY
		local rotZ = rangeAxes.RotZ
		local cframe2 = PartConstants.composeRotation(data.RotOrder or "Global", rotX, rotY, rotZ)
		local v4 = cframe * cframe2
		local v5

		if dirMode == "Local" then
			v5 = v4[v3.vector] * v3.multiplier
		elseif dirMode == "Global" then
			local v6 = CFrame.new()[v3.vector] * v3.multiplier
			v5 = p2.WorldCFrame:VectorToObjectSpace(v6)
		else
			v5 = cframe[v3.vector] * v3.multiplier
		end

		local v6 = PartConstants.applyPositionOffset(v4, data, link, p2, Range, AxisLinks, p4, p2.WorldCFrame)

		if dirMode == "Global" then
			v6 = CFrame.new(v6.Position) * p2.WorldCFrame.Rotation:Inverse() * cframe2
		end

		local v7, v8

		if data.ParticleData.SpreadAngle.X > 0 or data.ParticleData.SpreadAngle.Y > 0 then
			v7 = (math.random() * 2 - 1) * data.ParticleData.SpreadAngle.X
			v8 = (math.random() * 2 - 1) * data.ParticleData.SpreadAngle.Y
		else
			v7 = 0
			v8 = 0
		end

		local cframe3 = CFrame.Angles(math.rad(v7), math.rad(v8), 0)
		local lookVector = (CFrame.lookAt(Vector3.new(), v5) * cframe3).LookVector
		local seeds = {
			Speed = Graph.GenerateSeed(data.Speed),
			RotSpeedX = Graph.GenerateSeed(data.RotSpeedX),
			RotSpeedY = Graph.GenerateSeed(data.RotSpeedY),
			RotSpeedZ = Graph.GenerateSeed(data.RotSpeedZ),
			PosOffsetX = Graph.GenerateSeed(data.PosOffsetX),
			PosOffsetY = Graph.GenerateSeed(data.PosOffsetY),
			PosOffsetZ = Graph.GenerateSeed(data.PosOffsetZ),
			Timescale = Graph.GenerateSeed(data.Timescale)
		}
		AxisLinks.applyGraphAxisAliases(data, seeds, data.AxisLinks)
		local invertMotion = data.InvertMotion
		local simLocalCFrames, v11

		if invertMotion then
			simLocalCFrames, v11 = object:PreSimulateAttachmentForward(
				data,
				seeds,
				v6,
				lookVector,
				cframe3,
				lifeTime,
				nil,
				v6.Rotation * cframe2:Inverse()
			)
		end

		if invertMotion and simLocalCFrames then
			v6 = simLocalCFrames[v11 or data.TotalKeyFrames] or simLocalCFrames[0]
		end

		renderTemplate.CFrame = v6
		local v12 = {
			Type = "Attachment",
			VisualPart = renderTemplate,
			Link = link,
			LinkMode = data.LinkMode
		}
		local rigidLocalParentCF

		if data.LinkMode == "RigidLocal" and link then
			rigidLocalParentCF = PartConstants.resolveLinkCFrame(link) or nil
		end

		v12._rigidLocalParentCF = rigidLocalParentCF
		v12.Events = data.Events
		v12.StartTime = os.clock()
		v12.TotalKeyFrames = invertMotion and v11 or math.max(1, data.TotalKeyFrames)
		v12.CurrentStep = 0
		v12.AccumulatedDT = 0
		v12.LifeTime = lifeTime
		v12.PartLife = data.PartLife or 0
		v12.LocalCF = v6
		v12._localWorldCF = v6
		v12.BaseDirection = lookVector
		v12._initialBaseDirection = lookVector
		v12.EmissionDirection = data.EmissionDirection
		v12.SpreadRotation = cframe3
		v12.Acceleration = data.ParticleData.Acceleration
		v12.Drag = data.ParticleData.Drag
		v12.VelocityVectored = data.VelocityVectored
		v12.InvertMotion = invertMotion
		v12.SimLocalCFrames = simLocalCFrames
		v12.RotMode = data.RotMode or "OverLife"
		v12.RotOrder = data.RotOrder or "Global"
		v12.AccRotX = 0
		v12.AccRotY = 0
		v12.AccRotZ = 0
		v12.Orientation = data.Orientation
		v12.ZOffset = data.ZOffset
		v12.NeedsFullIteration = data.VelocityVectored
		v12.NeedsRotAccum = data.RotMode == "Speed" and not data.VelocityVectored
		v12.HasDrag = data.ParticleData.Drag ~= 0
		v12.HasAccel = data.ParticleData.Acceleration.Magnitude > 0
		v12.SpawnRotation = v6.Rotation
		v12.SpawnEmitterRotation = v6.Rotation * cframe2:Inverse()
		v12.DisplacementMode = data.DisplacementMode
		v12._sleepRadius = visualPart and visualPart:IsA("BasePart") and visualPart.Size.Magnitude * 0.5 or 1
		v12._prevWorldOff = createVector(0, 0, 0)
		v12.HasPosOffsetGraphs = data.PosOffsetX ~= nil or data.PosOffsetY ~= nil or data.PosOffsetZ ~= nil
		v12.Graphs = {
			Speed = data.Speed,
			RotSpeedX = data.RotSpeedX,
			RotSpeedY = data.RotSpeedY,
			RotSpeedZ = data.RotSpeedZ,
			PosOffsetX = data.PosOffsetX,
			PosOffsetY = data.PosOffsetY,
			PosOffsetZ = data.PosOffsetZ,
			Timescale = data.Timescale
		}
		v12.Seeds = seeds
		v12._effectiveElapsed = Graph.InitialEffectiveElapsed(data.Timescale, seeds.Timescale, lifeTime)
		v12.IsAnimate = true
		v12.AnimateItem = p2
		v12.InitialAnchorCF = cFrame
		v12.InitialLocalCF = v6

		if v12.HasPosOffsetGraphs then
			local v15 = not v12.Graphs.PosOffsetX and 0 or Graph.QueryPointsWithTime(
				0,
				v12.Graphs.PosOffsetX,
				v12.Seeds.PosOffsetX
			) or 0
			local v16 = not v12.Graphs.PosOffsetY and 0 or Graph.QueryPointsWithTime(
				0,
				v12.Graphs.PosOffsetY,
				v12.Seeds.PosOffsetY
			) or 0
			local v17 = not v12.Graphs.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
				0,
				v12.Graphs.PosOffsetZ,
				v12.Seeds.PosOffsetZ
			) or 0
			local displacement = PartConstants.resolveDisplacement(
				Vector3.new(v15, v16, v17),
				data.DisplacementMode or "Global",
				v12.SpawnRotation,
				v12.SpawnEmitterRotation
			)
			v12._prevWorldOff = displacement

			if v15 ~= 0 or v16 ~= 0 or v17 ~= 0 then
				v12.LocalCF += displacement
				v12.VisualPart.CFrame = v12.VisualPart.CFrame + displacement
			end
		end

		Turbulence.buildInto(v12, data)
		v12._sourceItem = p2
		p._seedTsOverride(v12, p2)
		StaticPass.apply(v12)
		object.ActiveAnimates[p2] = v12
		object:_applyEmitVisualPasses(v12)
		object:_registerEmit(v12, p4)
		local _makeAliveCheck = object:_makeAliveCheck()

		for _, attachment in renderTemplate:GetChildren() do
			if attachment:IsA("Attachment") then
				Particles.EnableEmitChildrenAndRepeatForAttachments(attachment, _makeAliveCheck)
			end

			Particles.EnableEmitSingle(attachment, _makeAliveCheck)
		end

		for _, descendant in renderTemplate:GetDescendants() do
			if descendant:GetAttribute("Transformed") then
				object:EnableEmit(descendant, descendant.Parent, Events.descendCtx(p4))
			end
		end
	end

	function p:EmitBeamAnimate(sourceItem, link, p3)
		if not (sourceItem and sourceItem.Parent) then
			return
		end

		local data = self:GetData(sourceItem)

		if not (data and data.RenderTemplate) then
			return
		end

		local renderTemplate = data.RenderTemplate
		local beamSnapshot = {
			Brightness = renderTemplate.Brightness,
			CurveSize0 = renderTemplate.CurveSize0,
			CurveSize1 = renderTemplate.CurveSize1,
			Width0 = renderTemplate.Width0,
			Width1 = renderTemplate.Width1,
			LightEmission = renderTemplate.LightEmission,
			LightInfluence = renderTemplate.LightInfluence,
			Segments = renderTemplate.Segments,
			TextureLength = renderTemplate.TextureLength,
			TextureSpeed = renderTemplate.TextureSpeed,
			Transparency = renderTemplate.Transparency,
			Color = renderTemplate.Color,
			FaceCamera = renderTemplate.FaceCamera,
			Enabled = renderTemplate.Enabled
		}

		if data.FaceCamera ~= nil then
			renderTemplate.FaceCamera = data.FaceCamera
		end

		local animatedProps = {}

		for k, beamProp in pairs(data.BeamProps) do
			if not beamProp then
				continue
			end

			if Graph.IsStatic(beamProp) then
				renderTemplate[k] = Graph.GetStaticValue(beamProp, renderTemplate[k])
			else
				local seed = Graph.GenerateSeed(beamProp)
				animatedProps[k] = {
					Sequence = beamProp,
					Seed = seed
				}

				if k ~= "TextureSpeed" then
					local pointsWithTime = Graph.QueryPointsWithTime(0, beamProp, seed)

					if k == "Segments" then
						pointsWithTime = math.max(20, (math.round(pointsWithTime)))
					end

					renderTemplate[k] = pointsWithTime
				end
			end
		end

		if animatedProps.TextureSpeed then
			renderTemplate.TextureSpeed = 0
		end

		local graphStates, colorStates = Graph.CollectGraphStates(data.GraphBlender)
		local transMergedTimes = {}

		for i = 1, #graphStates - 1 do
			transMergedTimes[i] = Graph.PrecomputeMergedTimes(graphStates[i].Graph, graphStates[i + 1].Graph)
		end

		local colorMergedTimes = {}

		for i = 1, #colorStates - 1 do
			colorMergedTimes[i] = Graph.PrecomputeMergedColorTimes(colorStates[i].Graph, colorStates[i + 1].Graph)
		end

		if #graphStates > 0 then
			renderTemplate.Transparency = graphStates[1].Graph
		end

		if #colorStates > 0 then
			renderTemplate.Color = colorStates[1].Graph
		end

		renderTemplate.Enabled = true
		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local seed = Graph.GenerateSeed(data.BeamTimescale)
		local v7 = {
			Type = "Beam",
			VisualPart = renderTemplate,
			Link = link,
			Events = data.Events,
			StartTime = os.clock(),
			TotalKeyFrames = math.max(1, data.TotalKeyFrames),
			CurrentStep = 0,
			LifeTime = lifeTime,
			PartLife = data.PartLife or 0,
			AnimatedProps = animatedProps,
			TransStates = graphStates,
			ColorStates = colorStates,
			TransMergedTimes = transMergedTimes,
			ColorMergedTimes = colorMergedTimes,
			BeamSnapshot = beamSnapshot,
			Graphs = {
				Timescale = data.BeamTimescale
			},
			Seeds = {
				Timescale = seed
			},
			_effectiveElapsed = Graph.InitialEffectiveElapsed(data.BeamTimescale, seed, lifeTime),
			IsAnimate = true,
			AnimateItem = sourceItem
		}

		if self._parentScaleMap and self._parentScaleMap[sourceItem] then
			v7.ParentScale = self._parentScaleMap[sourceItem]
			v7._baseWidth0 = renderTemplate.Width0
			v7._baseWidth1 = renderTemplate.Width1
			v7._baseCurveSize0 = renderTemplate.CurveSize0
			v7._baseCurveSize1 = renderTemplate.CurveSize1
			v7._baseTextureLength = renderTemplate.TextureLength
			v7._baseSegments = renderTemplate.Segments
		end

		v7._sourceItem = sourceItem
		p._seedTsOverride(v7, sourceItem)
		self.ActiveAnimates[sourceItem] = v7
		self:_registerEmit(v7, p3)
	end

	function p._refreshAnimateNonSpatial(_, state, data)
		if not data then
			return
		end

		if data.EmissionDirection then
			state.EmissionDirection = data.EmissionDirection
		end

		if data.Orientation then
			state.Orientation = data.Orientation
		end

		if data.ZOffset ~= nil then
			state.ZOffset = data.ZOffset
		end

		if data.RotOrder then
			state.RotOrder = data.RotOrder
		end

		if data.PartLife ~= nil then
			state.PartLife = data.PartLife
		end

		local timescale = data.Timescale or data.BeamTimescale or data.AtmTimescale or data.PLTimescale

		if timescale and state.Graphs then
			state.Graphs.Timescale = timescale
			state.Seeds.Timescale = Graph.GenerateSeed(timescale)
		end

		if data.ParticleData and data.ParticleData.SpreadAngle then
			local spreadAngle = data.ParticleData.SpreadAngle
			local v, v2

			if spreadAngle.X > 0 or spreadAngle.Y > 0 then
				v = (math.random() * 2 - 1) * spreadAngle.X
				v2 = (math.random() * 2 - 1) * spreadAngle.Y
			else
				v = 0
				v2 = 0
			end

			state.SpreadRotation = CFrame.Angles(math.rad(v), math.rad(v2), 0)
		end
	end
end