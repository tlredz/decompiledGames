local createVector = vector.create
local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local AxisLinks = require(script.Parent.AxisLinks)
local Particles = require(script.Parent.Particles)
local Flipbook = require(script.Parent.Flipbook)
require(script.Parent.Events)
local PartConstants = require(script.Parent.PartConstants)
local Pool = require(script.Parent.Pool)
local NestedEmit = require(script.Parent.NestedEmit)
local StaticPass = require(script.Parent.StaticPass)
local Turbulence = require(script.Parent.Turbulence)
local directionVectors = PartConstants.DirectionVectors
local shapeFunctions = PartConstants.shapeFunctions

local function _findBasePartAncestor(p)
	local parent = p.Parent

	while parent do
		if parent:IsA("BasePart") then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

return function(p)
	function p:EmitPart(sourceItem, p2, data)
		if not (sourceItem and sourceItem.Parent) then
			return
		end

		local data2 = self:GetData(sourceItem)

		if not (data2 and data2.RenderTemplate) then
			return
		end

		local link

		if not (data and data.IgnoreLink) then
			link = p2 or data2.Link
		end

		local randomValueFromRange = Range.RandomValueFromRange(data2.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local cFrame = nil

		if data then
			if data.EventOriginResolver then
				cFrame = data.EventOriginResolver()
			end

			cFrame = cFrame or data.EventOriginCF
		end

		if cFrame then
			if not (data and data.UseFullOrigin) then
				cFrame = CFrame.new(cFrame.Position) * sourceItem.CFrame.Rotation
			end
		elseif link then
			local linkCFrame = PartConstants.resolveLinkCFrame(link)
			local position = linkCFrame.Position

			if data2.LinkMode == "Follow" then
				cFrame = CFrame.new(position) * sourceItem.CFrame.Rotation
			elseif link == sourceItem then
				cFrame = sourceItem.CFrame
			else
				cFrame = CFrame.new(position) * linkCFrame.Rotation * sourceItem.CFrame.Rotation
			end
		else
			cFrame = sourceItem.CFrame
		end

		local v3 = directionVectors[data2.EmissionDirection] or directionVectors[Enum.NormalId.Top]
		local v4 = cFrame[v3.vector] * v3.multiplier
		local vector2 = Vector3.new()
		local v5 = nil
		local v6

		if data2.UseShape then
			local shapeFunction = shapeFunctions[data2.ParticleData.Shape]

			if shapeFunction then
				local shapePart = data2.ShapePart or sourceItem
				local cFrame2

				if data2.ShapePart then
					cFrame2 = data2.ShapePart.CFrame or cFrame
				else
					cFrame2 = cFrame
				end

				local v7, v8, v9 = shapeFunction(shapePart, data2.ParticleData)
				local shapeInOut = data2.ParticleData.ShapeInOut

				if shapeInOut == Enum.ParticleEmitterShapeInOut.Inward then
					v9 = -v9
				elseif shapeInOut == Enum.ParticleEmitterShapeInOut.InAndOut and math.random() < 0.5 then
					v9 = -v9
				end

				v5 = (cFrame2 - cFrame2.Position):VectorToWorldSpace(v9)

				if data2.ParticleData.LookAtInitially then
					local eulerAnglesXYZ, v10, v11 = cFrame:ToEulerAnglesXYZ()
					v6 = CFrame.new((cFrame2 * CFrame.new(v7)).Position) * v8 * CFrame.Angles(eulerAnglesXYZ, v10, v11)
				else
					v6 = CFrame.new((cFrame2 * CFrame.new(v7)).Position) * cFrame.Rotation
				end
			else
				v6 = CFrame.new((cFrame * CFrame.new(vector2)).Position) * cFrame.Rotation
			end
		else
			v6 = CFrame.new((cFrame * CFrame.new(vector2)).Position) * cFrame.Rotation
		end

		local dirMode = data2.DirMode or "RigidLocal"
		local rangeAxes = AxisLinks.sampleRangeAxes(data2, data2.AxisLinks, { "RotX", "RotY", "RotZ" }, Range, data)
		local rotX = rangeAxes.RotX
		local rotY = rangeAxes.RotY
		local rotZ = rangeAxes.RotZ
		local cframe = PartConstants.composeRotation(data2.RotOrder or "Global", rotX, rotY, rotZ)
		local v7 = v6 * cframe
		local v8 = self._parentScaleMap and self._parentScaleMap[sourceItem]
		local v9 = (not v8 or v8.ScaleMotion == false) and 1 or PartConstants.getParentScaleFactor(
			v8,
			os.clock(),
			Graph
		)
		local v10 = PartConstants.applyPositionOffset(v7, data2, link, sourceItem, Range, AxisLinks, data, nil, v9)

		if dirMode == "Global" then
			v10 = CFrame.new(v10.Position) * cframe
		end

		if v5 then
			v4 = v5
		elseif dirMode == "Local" then
			v4 = v10[v3.vector] * v3.multiplier
		elseif dirMode == "Global" then
			v4 = CFrame.new()[v3.vector] * v3.multiplier
		end

		local v11, v12

		if data2.ParticleData.SpreadAngle.X > 0 or data2.ParticleData.SpreadAngle.Y > 0 then
			v11 = (math.random() * 2 - 1) * data2.ParticleData.SpreadAngle.X
			v12 = (math.random() * 2 - 1) * data2.ParticleData.SpreadAngle.Y
		else
			v11 = 0
			v12 = 0
		end

		local cframe2 = CFrame.Angles(math.rad(v11), math.rad(v12), 0)
		local lookVector = (CFrame.lookAt(Vector3.new(), v4) * cframe2).LookVector
		local seeds = {
			SizeX = Graph.GenerateSeed(data2.SizeX),
			SizeY = Graph.GenerateSeed(data2.SizeY),
			SizeZ = Graph.GenerateSeed(data2.SizeZ),
			RotSpeedX = Graph.GenerateSeed(data2.RotSpeedX),
			RotSpeedY = Graph.GenerateSeed(data2.RotSpeedY),
			RotSpeedZ = Graph.GenerateSeed(data2.RotSpeedZ),
			PosOffsetX = Graph.GenerateSeed(data2.PosOffsetX),
			PosOffsetY = Graph.GenerateSeed(data2.PosOffsetY),
			PosOffsetZ = Graph.GenerateSeed(data2.PosOffsetZ),
			Speed = Graph.GenerateSeed(data2.Speed),
			Brightness = Graph.GenerateSeed(data2.Brightness),
			Transparency = Graph.GenerateSeed(data2.Transparency),
			AccelStrength = Graph.GenerateSeed(data2.AccelStrength),
			Timescale = Graph.GenerateSeed(data2.Timescale)
		}
		AxisLinks.applyGraphAxisAliases(data2, seeds, data2.AxisLinks)
		local invertMotion = data2.InvertMotion
		local simLocalCFrames, v15

		if invertMotion then
			simLocalCFrames, v15 = self:PreSimulateForward(
				data2,
				seeds,
				v10,
				lookVector,
				cframe2,
				link,
				lifeTime,
				nil,
				v10.Rotation * cframe:Inverse()
			)
		end

		local part = Pool.acquireOrCopyBare(data2.RenderTemplate, "Part", data2.Pool)
		part.Archivable = false
		local cframe3

		if link then
			cframe3 = PartConstants.resolveLinkCFrame(link)

			if data2.LinkMode == "Follow" or data2.LinkMode == "Pivot" then
				cframe3 = CFrame.new(cframe3.Position) or cframe3
			end
		else
			cframe3 = CFrame.new()
		end

		if invertMotion and simLocalCFrames then
			v10 = simLocalCFrames[v15 or data2.TotalKeyFrames] or simLocalCFrames[0]
		elseif link then
			v10 = cframe3:ToObjectSpace(v10) or v10
		end

		part.CFrame = cframe3 * v10
		local v16 = {
			Type = "Part",
			VisualPart = part,
			Link = link,
			LinkMode = data2.LinkMode
		}

		if data2.LinkMode ~= "RigidLocal" or not (link and cframe3) then
			cframe3 = nil
		end

		v16._rigidLocalParentCF = cframe3
		v16.Events = data2.Events
		v16.SpecialMesh = part:FindFirstChildOfClass("SpecialMesh")
		v16.Decal = part:FindFirstChildOfClass("Decal")
		v16.SurfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")
		v16.StartTime = os.clock()
		v16.TotalKeyFrames = invertMotion and v15 or math.max(1, data2.TotalKeyFrames)
		v16.CurrentStep = 0
		v16.AccumulatedDT = 0
		v16.LifeTime = lifeTime
		v16.PartLife = data2.PartLife
		v16.CurrentPosition = part.Position
		v16.LocalCF = v10
		v16.BaseDirection = lookVector
		v16._accelVel = createVector(0, 0, 0)
		v16.SpeedMultiplier = 1
		v16._spinRate = createVector(0, 0, 0)
		v16._spinAccumX = 0
		v16._spinAccumY = 0
		v16._spinAccumZ = 0
		v16.EmissionDirection = data2.EmissionDirection
		v16.SpreadRotation = cframe2
		v16.Acceleration = data2.ParticleData.Acceleration
		v16.Drag = data2.ParticleData.Drag
		v16.VelocityVectored = data2.VelocityVectored
		v16.InvertMotion = invertMotion
		v16.SimLocalCFrames = simLocalCFrames
		v16.RotMode = data2.RotMode or "OverLife"
		v16.RotOrder = data2.RotOrder or "Global"
		v16.AccRotX = 0
		v16.AccRotY = 0
		v16.AccRotZ = 0
		v16.Orientation = data2.Orientation
		v16.ZOffset = data2.ZOffset
		v16._localWorldCF = v10
		v16.SpawnRotation = v10.Rotation
		v16.SpawnEmitterRotation = v10.Rotation * cframe:Inverse()
		v16.DisplacementMode = data2.DisplacementMode
		v16._sleepRadius = not (part and part:IsA("BasePart")) and 1 or part.Size.Magnitude * 0.5 or 1
		v16._prevWorldOff = createVector(0, 0, 0)
		v16.HasPosOffsetGraphs = data2.PosOffsetX ~= nil or data2.PosOffsetY ~= nil or data2.PosOffsetZ ~= nil
		local hasTargetAccel

		if data2.AccelerationTowardsInstance == true and data2.AccelTarget ~= nil and data2.AccelStrength ~= nil then
			hasTargetAccel = not data2.InvertMotion
		else
			hasTargetAccel = false
		end

		v16.HasTargetAccel = hasTargetAccel
		v16.AccelTarget = data2.AccelTarget
		v16.TargetVel = createVector(0, 0, 0)
		v16.NeedsFullIteration = data2.VelocityVectored
		local needsRotAccum

		if data2.RotMode == "Speed" then
			needsRotAccum = not data2.VelocityVectored
		else
			needsRotAccum = false
		end

		v16.NeedsRotAccum = needsRotAccum
		v16.HasDrag = data2.ParticleData.Drag ~= 0
		v16.HasAccel = data2.ParticleData.Acceleration.Magnitude > 0
		v16.HasDecal = part:FindFirstChildOfClass("Decal") ~= nil
		v16.Graphs = {
			SizeX = data2.SizeX,
			SizeY = data2.SizeY,
			SizeZ = data2.SizeZ,
			RotSpeedX = data2.RotSpeedX,
			RotSpeedY = data2.RotSpeedY,
			RotSpeedZ = data2.RotSpeedZ,
			PosOffsetX = data2.PosOffsetX,
			PosOffsetY = data2.PosOffsetY,
			PosOffsetZ = data2.PosOffsetZ,
			Speed = data2.Speed,
			Brightness = data2.Brightness,
			Transparency = data2.Transparency,
			Color = data2.Color,
			AccelStrength = data2.AccelStrength,
			Timescale = data2.Timescale
		}
		v16.Seeds = seeds
		v16._effectiveElapsed = Graph.InitialEffectiveElapsed(data2.Timescale, seeds.Timescale, lifeTime)

		if v16.HasPosOffsetGraphs then
			local v19 = not v16.Graphs.PosOffsetX and 0 or Graph.QueryPointsWithTime(
				0,
				v16.Graphs.PosOffsetX,
				v16.Seeds.PosOffsetX
			) or 0
			local v20 = not v16.Graphs.PosOffsetY and 0 or Graph.QueryPointsWithTime(
				0,
				v16.Graphs.PosOffsetY,
				v16.Seeds.PosOffsetY
			) or 0
			local v21 = not v16.Graphs.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
				0,
				v16.Graphs.PosOffsetZ,
				v16.Seeds.PosOffsetZ
			) or 0
			local displacement = PartConstants.resolveDisplacement(
				Vector3.new(v19, v20, v21),
				data2.DisplacementMode or "Global",
				v16.SpawnRotation,
				v16.SpawnEmitterRotation
			)
			v16._prevWorldOff = displacement

			if v19 ~= 0 or v20 ~= 0 or v21 ~= 0 then
				v16.LocalCF += displacement
				v16.VisualPart.CFrame = v16.VisualPart.CFrame + displacement
			end
		end

		Turbulence.buildInto(v16, data2)
		local vector3 = Vector3.new(
			Graph.QueryPointsWithTime(0, v16.Graphs.SizeX, v16.Seeds.SizeX),
			Graph.QueryPointsWithTime(0, v16.Graphs.SizeY, v16.Seeds.SizeY),
			Graph.QueryPointsWithTime(0, v16.Graphs.SizeZ, v16.Seeds.SizeZ)
		)
		local pointsWithTime = Graph.QueryPointsWithTime(0, v16.Graphs.Transparency, v16.Seeds.Transparency)
		local colorPointWithTime = Graph.QueryColorPointWithTime(0, v16.Graphs.Color)
		local pointsWithTime2 = Graph.QueryPointsWithTime(0, v16.Graphs.Brightness, v16.Seeds.Brightness)

		if v16.SpecialMesh then
			v16.SpecialMesh.Scale = vector3
		else
			v16.VisualPart.Size = vector3
		end

		if v16.SurfaceAppearance then
			v16.VisualPart.Transparency = pointsWithTime
			v16.VisualPart.Color = Color3.fromRGB(
				colorPointWithTime.R * 255,
				colorPointWithTime.G * 255,
				colorPointWithTime.B * 255
			)
			v16.SurfaceAppearance.Color = Color3.fromRGB(
				colorPointWithTime.R * 255,
				colorPointWithTime.G * 255,
				colorPointWithTime.B * 255
			)
			pcall(function()
				v16.SurfaceAppearance.EmissiveTint = Color3.new(
					colorPointWithTime.R * pointsWithTime2,
					colorPointWithTime.G * pointsWithTime2,
					colorPointWithTime.B * pointsWithTime2
				)
			end)
		elseif v16.Decal then
			v16.Decal.Transparency = pointsWithTime
			v16.Decal.Color3 = Color3.fromRGB(
				colorPointWithTime.R * 255 * pointsWithTime2,
				colorPointWithTime.G * 255 * pointsWithTime2,
				colorPointWithTime.B * 255 * pointsWithTime2
			)
		else
			v16.VisualPart.Transparency = pointsWithTime
			v16.VisualPart.Color = Color3.fromRGB(
				colorPointWithTime.R * 255,
				colorPointWithTime.G * 255,
				colorPointWithTime.B * 255
			)
		end

		for _, emitter in part:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		part.Parent = data2.EmitParent or self:GetFolder()

		for _, trail in part:GetDescendants() do
			if not trail:IsA("Trail") or trail:GetAttribute("Transformed") then
				continue
			end

			local parent = trail.Parent
			local v19 = false

			while parent and parent ~= part do
				if parent:GetAttribute("Transformed") then
					v19 = true
					break
				else
					parent = parent.Parent
				end
			end

			if v19 or trail:GetAttribute("EmitDuration") == nil then
				continue
			end

			if trail.Enabled ~= true then
				trail.Enabled = true
			end

			if trail:GetAttribute("_pooledTrailEnabled") ~= nil then
				trail:SetAttribute("_pooledTrailEnabled", true)
			end
		end

		Pool.restoreTrails(part, "Part")
		local _makeAliveCheck = self:_makeAliveCheck()

		for _, attachment in part:GetChildren() do
			if attachment:IsA("Attachment") then
				Particles.EnableEmitChildrenAndRepeatForAttachments(attachment, _makeAliveCheck)
			end

			Particles.EnableEmitSingle(attachment, _makeAliveCheck)
		end

		if self._parentScaleMap and self._parentScaleMap[sourceItem] then
			v16.ParentScale = self._parentScaleMap[sourceItem]
		end

		v16._sourceItem = sourceItem
		p._seedTsOverride(v16, sourceItem)

		if data2.Pool ~= false then
			v16._sourceRT = data2.RenderTemplate
			v16._poolKind = "Part"
		end

		StaticPass.apply(v16)
		self:_applyEmitVisualPasses(v16)
		self:_registerEmit(v16, data)

		if data2.CachedMeshTextures and #data2.CachedMeshTextures > 0 then
			local surfaceAppearance = v16.SurfaceAppearance or v16.Decal

			if not surfaceAppearance and part:IsA("MeshPart") then
				surfaceAppearance = part
			end

			if surfaceAppearance then
				Flipbook.Flip(v16, data2.ParticleData, data2.CachedMeshTextures, surfaceAppearance, lifeTime)
			end
		end

		v16._nestedAlive = { true }
		NestedEmit.walkWithScale(self, data2.RenderTemplate, part, v16._nestedAlive, data, v16.ParentScale, v16)
	end

	function p:EmitAttachment(sourceItem, p2, data)
		if not (sourceItem and sourceItem.Parent) then
			return
		end

		local data2 = self:GetData(sourceItem)

		if not (data2 and data2.RenderTemplate) then
			return
		end

		local link

		if not (data and data.IgnoreLink) then
			link = p2 or data2.Link
		end

		local randomValueFromRange = Range.RandomValueFromRange(data2.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local worldCFrame = sourceItem.WorldCFrame
		local v3 = nil

		if data then
			if data.EventOriginResolver then
				v3 = data.EventOriginResolver()
			end

			v3 = v3 or data.EventOriginCF
		end

		if v3 then
			if not (data and data.UseFullOrigin) then
				v3 = CFrame.new(v3.Position) * worldCFrame.Rotation
			end
		elseif link then
			local linkCFrame = PartConstants.resolveLinkCFrame(link)

			if data2.LinkMode == "Follow" then
				v3 = CFrame.new(linkCFrame.Position) * worldCFrame.Rotation
			elseif link == sourceItem then
				v3 = worldCFrame
			else
				v3 = CFrame.new(linkCFrame.Position) * linkCFrame.Rotation * worldCFrame.Rotation
			end
		else
			v3 = worldCFrame
		end

		local emitParent = data2.EmitParent

		if not emitParent then
			emitParent = sourceItem.Parent

			while true do
				if not emitParent then
					emitParent = nil
					break
				end

				if emitParent:IsA("BasePart") then
					break
				else
					emitParent = emitParent.Parent
				end
			end

			if not emitParent then
				emitParent = self:GetFolder()
			end
		end

		local cFrame = emitParent and emitParent:IsA("BasePart") and emitParent.CFrame or CFrame.new()
		local objectSpace = cFrame:ToObjectSpace(v3)
		local v4 = directionVectors[data2.EmissionDirection] or directionVectors[Enum.NormalId.Top]
		local dirMode = data2.DirMode or "RigidLocal"
		local rangeAxes = AxisLinks.sampleRangeAxes(data2, data2.AxisLinks, { "RotX", "RotY", "RotZ" }, Range, data)
		local rotX = rangeAxes.RotX
		local rotY = rangeAxes.RotY
		local rotZ = rangeAxes.RotZ
		local cframe = PartConstants.composeRotation(data2.RotOrder or "Global", rotX, rotY, rotZ)
		local v5 = objectSpace * cframe
		local v6

		if dirMode == "Local" then
			v6 = v5[v4.vector] * v4.multiplier
		elseif dirMode == "Global" then
			v6 = CFrame.new()[v4.vector] * v4.multiplier

			if emitParent and emitParent:IsA("BasePart") then
				v6 = emitParent.CFrame:VectorToObjectSpace(v6)
			end
		else
			v6 = objectSpace[v4.vector] * v4.multiplier
		end

		local v7 = self._parentScaleMap and self._parentScaleMap[sourceItem]
		local v8 = (not v7 or v7.ScaleMotion == false) and 1 or PartConstants.getParentScaleFactor(
			v7,
			os.clock(),
			Graph
		)
		local v9 = PartConstants.applyPositionOffset(v5, data2, link, sourceItem, Range, AxisLinks, data, cFrame, v8)

		if dirMode == "Global" then
			if emitParent and emitParent:IsA("BasePart") then
				v9 = CFrame.new(v9.Position) * emitParent.CFrame.Rotation:Inverse() * cframe
			else
				v9 = CFrame.new(v9.Position) * cframe
			end
		end

		local v10, v11

		if data2.ParticleData.SpreadAngle.X > 0 or data2.ParticleData.SpreadAngle.Y > 0 then
			v10 = (math.random() * 2 - 1) * data2.ParticleData.SpreadAngle.X
			v11 = (math.random() * 2 - 1) * data2.ParticleData.SpreadAngle.Y
		else
			v10 = 0
			v11 = 0
		end

		local cframe2 = CFrame.Angles(math.rad(v10), math.rad(v11), 0)
		local lookVector = (CFrame.lookAt(Vector3.new(), v6) * cframe2).LookVector
		local seeds = {
			Speed = Graph.GenerateSeed(data2.Speed),
			RotSpeedX = Graph.GenerateSeed(data2.RotSpeedX),
			RotSpeedY = Graph.GenerateSeed(data2.RotSpeedY),
			RotSpeedZ = Graph.GenerateSeed(data2.RotSpeedZ),
			PosOffsetX = Graph.GenerateSeed(data2.PosOffsetX),
			PosOffsetY = Graph.GenerateSeed(data2.PosOffsetY),
			PosOffsetZ = Graph.GenerateSeed(data2.PosOffsetZ),
			Timescale = Graph.GenerateSeed(data2.Timescale)
		}
		AxisLinks.applyGraphAxisAliases(data2, seeds, data2.AxisLinks)
		local invertMotion = data2.InvertMotion
		local simLocalCFrames, v14

		if invertMotion then
			simLocalCFrames, v14 = self:PreSimulateAttachmentForward(
				data2,
				seeds,
				v9,
				lookVector,
				cframe2,
				lifeTime,
				nil,
				v9.Rotation * cframe:Inverse()
			)
		end

		local folder = Pool.acquireOrCopyBare(data2.RenderTemplate, "Attachment", data2.Pool)
		folder.Archivable = false

		if invertMotion and simLocalCFrames then
			v9 = simLocalCFrames[v14 or data2.TotalKeyFrames] or simLocalCFrames[0]
		end

		folder.CFrame = v9
		folder.Parent = emitParent
		Pool.restoreTrails(folder, "Attachment")

		if link then
			local linkCFrame = PartConstants.resolveLinkCFrame(link)
			local cframe3 = (emitParent and emitParent:IsA("BasePart") and emitParent.CFrame or CFrame.new()):ToObjectSpace(linkCFrame)

			if data2.LinkMode == "Follow" or data2.LinkMode == "Pivot" then
				cframe3 = CFrame.new(cframe3.Position)
			end

			v9 = cframe3:ToObjectSpace(v9)
		end

		local rigidLocalParentCF

		if data2.LinkMode == "RigidLocal" and link then
			rigidLocalParentCF = PartConstants.resolveLinkCFrame(link)
		end

		local v16 = {
			Type = "Attachment",
			VisualPart = folder,
			Link = link,
			LinkMode = data2.LinkMode,
			_rigidLocalParentCF = rigidLocalParentCF,
			Events = data2.Events,
			StartTime = os.clock(),
			TotalKeyFrames = invertMotion and v14 or math.max(1, data2.TotalKeyFrames),
			CurrentStep = 0,
			AccumulatedDT = 0,
			LifeTime = lifeTime,
			PartLife = data2.PartLife,
			LocalCF = v9,
			_localWorldCF = v9,
			BaseDirection = lookVector,
			_accelVel = createVector(0, 0, 0),
			SpeedMultiplier = 1,
			_spinRate = createVector(0, 0, 0),
			_spinAccumX = 0,
			_spinAccumY = 0,
			_spinAccumZ = 0,
			EmissionDirection = data2.EmissionDirection,
			SpreadRotation = cframe2,
			Acceleration = data2.ParticleData.Acceleration,
			Drag = data2.ParticleData.Drag,
			VelocityVectored = data2.VelocityVectored,
			InvertMotion = invertMotion,
			SimLocalCFrames = simLocalCFrames,
			RotMode = data2.RotMode or "OverLife",
			RotOrder = data2.RotOrder or "Global",
			AccRotX = 0,
			AccRotY = 0,
			AccRotZ = 0,
			Orientation = data2.Orientation,
			ZOffset = data2.ZOffset,
			SpawnRotation = v9.Rotation,
			SpawnEmitterRotation = v9.Rotation * cframe:Inverse(),
			DisplacementMode = data2.DisplacementMode,
			_sleepRadius = 1,
			_prevWorldOff = createVector(0, 0, 0),
			HasPosOffsetGraphs = data2.PosOffsetX ~= nil or data2.PosOffsetY ~= nil or data2.PosOffsetZ ~= nil,
			NeedsFullIteration = data2.VelocityVectored,
			NeedsRotAccum = data2.RotMode == "Speed" and not data2.VelocityVectored,
			HasDrag = data2.ParticleData.Drag ~= 0,
			HasAccel = data2.ParticleData.Acceleration.Magnitude > 0,
			Graphs = {
				Speed = data2.Speed,
				RotSpeedX = data2.RotSpeedX,
				RotSpeedY = data2.RotSpeedY,
				RotSpeedZ = data2.RotSpeedZ,
				PosOffsetX = data2.PosOffsetX,
				PosOffsetY = data2.PosOffsetY,
				PosOffsetZ = data2.PosOffsetZ,
				Timescale = data2.Timescale
			},
			Seeds = seeds,
			_effectiveElapsed = Graph.InitialEffectiveElapsed(data2.Timescale, seeds.Timescale, lifeTime)
		}

		if v16.HasPosOffsetGraphs then
			local v18 = not v16.Graphs.PosOffsetX and 0 or Graph.QueryPointsWithTime(
				0,
				v16.Graphs.PosOffsetX,
				v16.Seeds.PosOffsetX
			) or 0
			local v19 = not v16.Graphs.PosOffsetY and 0 or Graph.QueryPointsWithTime(
				0,
				v16.Graphs.PosOffsetY,
				v16.Seeds.PosOffsetY
			) or 0
			local v20 = not v16.Graphs.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
				0,
				v16.Graphs.PosOffsetZ,
				v16.Seeds.PosOffsetZ
			) or 0
			local displacement = PartConstants.resolveDisplacement(
				Vector3.new(v18, v19, v20),
				data2.DisplacementMode or "Global",
				v16.SpawnRotation,
				v16.SpawnEmitterRotation
			)
			v16._prevWorldOff = displacement

			if v18 ~= 0 or v19 ~= 0 or v20 ~= 0 then
				v16.LocalCF += displacement
				v16.VisualPart.CFrame = v16.VisualPart.CFrame + displacement
			end
		end

		Turbulence.buildInto(v16, data2)
		v16._sourceItem = sourceItem
		p._seedTsOverride(v16, sourceItem)

		if self._parentScaleMap and self._parentScaleMap[sourceItem] then
			v16.ParentScale = self._parentScaleMap[sourceItem]
		end

		if data2.Pool ~= false then
			v16._sourceRT = data2.RenderTemplate
			v16._poolKind = "Attachment"
		end

		StaticPass.apply(v16)
		self:_applyEmitVisualPasses(v16)
		self:_registerEmit(v16, data)

		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local _makeAliveCheck = self:_makeAliveCheck()

		for _, attachment in folder:GetChildren() do
			if attachment:IsA("Attachment") then
				Particles.EnableEmitChildrenAndRepeatForAttachments(attachment, _makeAliveCheck)
			end

			Particles.EnableEmitSingle(attachment, _makeAliveCheck)
		end

		v16._nestedAlive = { true }
		NestedEmit.walkWithScale(self, data2.RenderTemplate, folder, v16._nestedAlive, data, v16.ParentScale, v16)
	end

	function p:EmitBeam(sourceItem, link, p3)
		if not (sourceItem and sourceItem.Parent) then
			return
		end

		local data = self:GetData(sourceItem)

		if not (data and data.RenderTemplate) then
			return
		end

		local visualPart = Pool.acquireOrClone(data.RenderTemplate, "Beam", data.Pool)
		visualPart.Archivable = false
		visualPart.Enabled = true

		if data.FaceCamera ~= nil then
			visualPart.FaceCamera = data.FaceCamera
		end

		if data.ZOffset ~= nil then
			visualPart.ZOffset = data.ZOffset
		end

		if data.TextureMode ~= nil then
			visualPart.TextureMode = data.TextureMode
		end

		if p3 and p3._parentCloneMap then
			local _parentCloneMap = p3._parentCloneMap

			if visualPart.Attachment0 and _parentCloneMap[visualPart.Attachment0] then
				visualPart.Attachment0 = _parentCloneMap[visualPart.Attachment0]
			end

			if visualPart.Attachment1 and _parentCloneMap[visualPart.Attachment1] then
				visualPart.Attachment1 = _parentCloneMap[visualPart.Attachment1]
			end
		end

		local animatedProps = {}

		for k, beamProp in pairs(data.BeamProps) do
			if not beamProp then
				continue
			end

			if Graph.IsStatic(beamProp) then
				visualPart[k] = Graph.GetStaticValue(beamProp, visualPart[k])
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

					visualPart[k] = pointsWithTime
				end
			end
		end

		if animatedProps.TextureSpeed then
			visualPart.TextureSpeed = 0
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
			visualPart.Transparency = graphStates[1].Graph
		end

		if #colorStates > 0 then
			visualPart.Color = colorStates[1].Graph
		end

		visualPart.Parent = data.EmitParent or self:GetFolder()
		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local seed = Graph.GenerateSeed(data.BeamTimescale)
		local v7 = {
			Type = "Beam",
			VisualPart = visualPart,
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
			Graphs = {
				Timescale = data.BeamTimescale
			},
			Seeds = {
				Timescale = seed
			},
			_effectiveElapsed = Graph.InitialEffectiveElapsed(data.BeamTimescale, seed, lifeTime)
		}

		if self._parentScaleMap and self._parentScaleMap[sourceItem] then
			v7.ParentScale = self._parentScaleMap[sourceItem]
			v7._baseWidth0 = visualPart.Width0
			v7._baseWidth1 = visualPart.Width1
			v7._baseCurveSize0 = visualPart.CurveSize0
			v7._baseCurveSize1 = visualPart.CurveSize1
			v7._baseTextureLength = visualPart.TextureLength
			v7._baseSegments = visualPart.Segments
		end

		v7._sourceItem = sourceItem
		p._seedTsOverride(v7, sourceItem)

		if data.Pool ~= false then
			v7._sourceRT = data.RenderTemplate
			v7._poolKind = "Beam"
		end

		self:_registerEmit(v7, p3)

		if data.CachedBeamTextures and #data.CachedBeamTextures > 0 and data.FlipbookParticle then
			Flipbook.FlipBeam(v7, data.FlipbookParticle, data.CachedBeamTextures, visualPart, lifeTime)
		end
	end
end