local createVector = vector.create
local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local AxisLinks = require(script.Parent.AxisLinks)
local Particles = require(script.Parent.Particles)
require(script.Parent.TypeRegistry)
local Events = require(script.Parent.Events)
local PartConstants = require(script.Parent.PartConstants)
local Pool = require(script.Parent.Pool)
local NestedEmit = require(script.Parent.NestedEmit)
local StaticPass = require(script.Parent.StaticPass)
local Turbulence = require(script.Parent.Turbulence)
local directionVectors = PartConstants.DirectionVectors
return function(p)
	function p:EmitModel(sourceItem, p2, data)
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
		local pivot = sourceItem:GetPivot()
		local v3 = nil

		if data then
			if data.EventOriginResolver then
				v3 = data.EventOriginResolver()
			end

			v3 = v3 or data.EventOriginCF
		end

		if v3 then
			if not (data and data.UseFullOrigin) then
				v3 = CFrame.new(v3.Position) * pivot.Rotation
			end
		else
			v3 = pivot
		end

		local v4 = directionVectors[data2.EmissionDirection] or directionVectors[Enum.NormalId.Top]
		local v5 = v3[v4.vector] * v4.multiplier
		local dirMode = data2.DirMode or "RigidLocal"
		local rangeAxes = AxisLinks.sampleRangeAxes(data2, data2.AxisLinks, { "RotX", "RotY", "RotZ" }, Range, data)
		local rotX = rangeAxes.RotX
		local rotY = rangeAxes.RotY
		local rotZ = rangeAxes.RotZ
		local cframe = PartConstants.composeRotation(data2.RotOrder or "Global", rotX, rotY, rotZ)
		local v6 = v3 * cframe
		local v7 = PartConstants.applyPositionOffset(v6, data2, link, sourceItem, Range, AxisLinks, data)

		if dirMode == "Global" then
			v7 = CFrame.new(v7.Position) * cframe
		end

		if dirMode == "Local" then
			v5 = v7[v4.vector] * v4.multiplier
		elseif dirMode == "Global" then
			v5 = CFrame.new()[v4.vector] * v4.multiplier
		end

		local v8, v9

		if data2.ParticleData.SpreadAngle.X > 0 or data2.ParticleData.SpreadAngle.Y > 0 then
			v8 = (math.random() * 2 - 1) * data2.ParticleData.SpreadAngle.X
			v9 = (math.random() * 2 - 1) * data2.ParticleData.SpreadAngle.Y
		else
			v8 = 0
			v9 = 0
		end

		local cframe2 = CFrame.Angles(math.rad(v8), math.rad(v9), 0)
		local lookVector = (CFrame.lookAt(Vector3.new(), v5) * cframe2).LookVector
		local seeds = {
			RotSpeedX = Graph.GenerateSeed(data2.RotSpeedX),
			RotSpeedY = Graph.GenerateSeed(data2.RotSpeedY),
			RotSpeedZ = Graph.GenerateSeed(data2.RotSpeedZ),
			PosOffsetX = Graph.GenerateSeed(data2.PosOffsetX),
			PosOffsetY = Graph.GenerateSeed(data2.PosOffsetY),
			PosOffsetZ = Graph.GenerateSeed(data2.PosOffsetZ),
			Speed = Graph.GenerateSeed(data2.Speed),
			Scale = Graph.GenerateSeed(data2.Scale),
			Timescale = Graph.GenerateSeed(data2.Timescale)
		}
		AxisLinks.applyGraphAxisAliases(data2, seeds, data2.AxisLinks)
		local invertMotion = data2.InvertMotion
		local simLocalCFrames, v12

		if invertMotion then
			simLocalCFrames, v12 = self:PreSimulateForward(
				data2,
				seeds,
				v7,
				lookVector,
				cframe2,
				link,
				lifeTime,
				nil,
				v7.Rotation * cframe:Inverse()
			)
		end

		local folder = Pool.acquireOrCopyBare(data2.RenderTemplate, "Model", data2.Pool)
		folder.Archivable = false
		local renderTemplate = data2.RenderTemplate

		if renderTemplate and folder:GetAttribute("_pooledModelScale") == nil then
			local success, result = pcall(function()
				return renderTemplate:GetScale()
			end)

			if success and result then
				folder:SetAttribute("_pooledModelScale", result)
			end
		end

		local _pooledModelScale = folder:GetAttribute("_pooledModelScale")

		if _pooledModelScale then
			pcall(function()
				folder:ScaleTo(_pooledModelScale)
			end)
		end

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
			v7 = simLocalCFrames[v12 or data2.TotalKeyFrames] or simLocalCFrames[0]
		elseif link then
			v7 = cframe3:ToObjectSpace(v7) or v7
		end

		folder:PivotTo(cframe3 * v7)
		local v13 = {
			Type = "Model",
			VisualPart = folder,
			Link = link,
			LinkMode = data2.LinkMode
		}

		if data2.LinkMode ~= "RigidLocal" or not (link and cframe3) then
			cframe3 = nil
		end

		v13._rigidLocalParentCF = cframe3
		v13.Events = data2.Events
		v13.StartTime = os.clock()
		v13.TotalKeyFrames = invertMotion and v12 or math.max(1, data2.TotalKeyFrames)
		v13.CurrentStep = 0
		v13.AccumulatedDT = 0
		v13.LifeTime = lifeTime
		v13.PartLife = data2.PartLife
		v13.CurrentPosition = folder:GetPivot().Position
		v13.LocalCF = v7
		v13.BaseDirection = lookVector
		v13._accelVel = createVector(0, 0, 0)
		v13.SpeedMultiplier = 1
		v13._spinRate = createVector(0, 0, 0)
		v13._spinAccumX = 0
		v13._spinAccumY = 0
		v13._spinAccumZ = 0
		v13.EmissionDirection = data2.EmissionDirection
		v13.SpreadRotation = cframe2
		v13.Acceleration = data2.ParticleData.Acceleration
		v13.Drag = data2.ParticleData.Drag
		v13.VelocityVectored = data2.VelocityVectored
		v13.InvertMotion = invertMotion
		v13.SimLocalCFrames = simLocalCFrames
		v13.RotMode = data2.RotMode or "OverLife"
		v13.RotOrder = data2.RotOrder or "Global"
		v13.AccRotX = 0
		v13.AccRotY = 0
		v13.AccRotZ = 0
		v13.Orientation = data2.Orientation
		v13.ZOffset = data2.ZOffset
		v13._localWorldCF = v7
		v13.SpawnRotation = v7.Rotation
		v13.SpawnEmitterRotation = v7.Rotation * cframe:Inverse()
		v13.DisplacementMode = data2.DisplacementMode
		v13._sleepRadius = 1
		v13._prevWorldOff = createVector(0, 0, 0)
		v13.HasPosOffsetGraphs = data2.PosOffsetX ~= nil or data2.PosOffsetY ~= nil or data2.PosOffsetZ ~= nil
		v13.NeedsFullIteration = data2.VelocityVectored
		v13.NeedsRotAccum = data2.RotMode == "Speed" and not data2.VelocityVectored
		v13.HasDrag = data2.ParticleData.Drag ~= 0
		v13.HasAccel = data2.ParticleData.Acceleration.Magnitude > 0
		v13.Graphs = {
			RotSpeedX = data2.RotSpeedX,
			RotSpeedY = data2.RotSpeedY,
			RotSpeedZ = data2.RotSpeedZ,
			PosOffsetX = data2.PosOffsetX,
			PosOffsetY = data2.PosOffsetY,
			PosOffsetZ = data2.PosOffsetZ,
			Speed = data2.Speed,
			Scale = data2.Scale,
			Timescale = data2.Timescale
		}
		v13.Seeds = seeds
		v13._effectiveElapsed = Graph.InitialEffectiveElapsed(data2.Timescale, seeds.Timescale, lifeTime)

		if v13.HasPosOffsetGraphs then
			local v15 = not v13.Graphs.PosOffsetX and 0 or Graph.QueryPointsWithTime(
				0,
				v13.Graphs.PosOffsetX,
				v13.Seeds.PosOffsetX
			) or 0
			local v16 = not v13.Graphs.PosOffsetY and 0 or Graph.QueryPointsWithTime(
				0,
				v13.Graphs.PosOffsetY,
				v13.Seeds.PosOffsetY
			) or 0
			local v17 = not v13.Graphs.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
				0,
				v13.Graphs.PosOffsetZ,
				v13.Seeds.PosOffsetZ
			) or 0
			local displacement = PartConstants.resolveDisplacement(
				Vector3.new(v15, v16, v17),
				data2.DisplacementMode or "Global",
				v13.SpawnRotation,
				v13.SpawnEmitterRotation
			)
			v13._prevWorldOff = displacement

			if v15 ~= 0 or v16 ~= 0 or v17 ~= 0 then
				v13.LocalCF += displacement
				v13.VisualPart:PivotTo(v13.VisualPart:GetPivot() + displacement)
			end
		end

		Turbulence.buildInto(v13, data2)
		local beams = {}

		for _, beam in folder:GetDescendants() do
			if not beam:IsA("Beam") or beam:GetAttribute("Transformed") then
				continue
			end

			table.insert(beams, beam)
		end

		if #beams > 0 then
			v13._visualBeams = beams
		end

		if self._parentScaleMap and self._parentScaleMap[sourceItem] then
			v13.ParentScale = self._parentScaleMap[sourceItem]
		end

		folder:ScaleTo(math.max(0.001, Graph.QueryPointsWithTime(0, v13.Graphs.Scale, v13.Seeds.Scale)) * PartConstants.getParentScaleFactor(
			v13.ParentScale,
			v13.StartTime,
			Graph
		))

		for _, v15 in ipairs(beams) do
			if v15.Segments < 20 then
				v15.Segments = 20
			end
		end

		folder.Parent = data2.EmitParent or self:GetFolder()
		Pool.restoreTrails(folder, "Model")

		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		local _makeAliveCheck = self:_makeAliveCheck()

		for _, descendant in folder:GetDescendants() do
			Particles.EnableEmitSingle(descendant, _makeAliveCheck)
		end

		v13._sourceItem = sourceItem
		p._seedTsOverride(v13, sourceItem)

		if data2.Pool ~= false then
			v13._sourceRT = data2.RenderTemplate
			v13._poolKind = "Model"
		end

		StaticPass.apply(v13)
		self:_applyEmitVisualPasses(v13)
		self:_registerEmit(v13, data)
		v13._nestedAlive = { true }
		self._parentScaleMap = self._parentScaleMap or {}
		local v15 = {
			Graph = v13.Graphs.Scale,
			Seed = v13.Seeds.Scale,
			StaticValue = v13._staticScale or v13.Graphs.Scale == nil and 1 or nil,
			TotalKeyFrames = v13.TotalKeyFrames,
			StartTime = v13.StartTime,
			LifeTime = v13.LifeTime,
			ScaleTextureLength = data2.ScaleTextureLength ~= false,
			ScaleMotion = data2.ScaleMotion ~= false,
			ScaleRotation = data2.ScaleRotation == true,
			Parent = v13.ParentScale
		}
		local scaleMapKeys = {}
		NestedEmit.walk(self, data2.RenderTemplate, folder, v13._nestedAlive, data, function(p3)
			self._parentScaleMap[p3] = v15
			scaleMapKeys[#scaleMapKeys + 1] = p3
		end)
		v13._scaleMapKeys = scaleMapKeys
	end

	function p:EmitModelAnimate(instance, p2, p3)
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
		local pivot = renderTemplate:GetPivot()
		local pivot2 = instance:GetPivot()
		local v3 = directionVectors[data.EmissionDirection] or directionVectors[Enum.NormalId.Top]
		local v4 = pivot2[v3.vector] * v3.multiplier
		local dirMode = data.DirMode or "RigidLocal"
		local rangeAxes = AxisLinks.sampleRangeAxes(data, data.AxisLinks, { "RotX", "RotY", "RotZ" }, Range, p3)
		local rotX = rangeAxes.RotX
		local rotY = rangeAxes.RotY
		local rotZ = rangeAxes.RotZ
		local cframe = PartConstants.composeRotation(data.RotOrder or "Global", rotX, rotY, rotZ)
		local v5 = pivot2 * cframe
		local v6 = PartConstants.applyPositionOffset(v5, data, link, instance, Range, AxisLinks, p3)

		if dirMode == "Global" then
			v6 = CFrame.new(v6.Position) * cframe
		end

		if dirMode == "Local" then
			v4 = v6[v3.vector] * v3.multiplier
		elseif dirMode == "Global" then
			v4 = CFrame.new()[v3.vector] * v3.multiplier
		end

		local v7, v8

		if data.ParticleData.SpreadAngle.X > 0 or data.ParticleData.SpreadAngle.Y > 0 then
			v7 = (math.random() * 2 - 1) * data.ParticleData.SpreadAngle.X
			v8 = (math.random() * 2 - 1) * data.ParticleData.SpreadAngle.Y
		else
			v7 = 0
			v8 = 0
		end

		local cframe2 = CFrame.Angles(math.rad(v7), math.rad(v8), 0)
		local lookVector = (CFrame.lookAt(Vector3.new(), v4) * cframe2).LookVector
		local seeds = {
			RotSpeedX = Graph.GenerateSeed(data.RotSpeedX),
			RotSpeedY = Graph.GenerateSeed(data.RotSpeedY),
			RotSpeedZ = Graph.GenerateSeed(data.RotSpeedZ),
			PosOffsetX = Graph.GenerateSeed(data.PosOffsetX),
			PosOffsetY = Graph.GenerateSeed(data.PosOffsetY),
			PosOffsetZ = Graph.GenerateSeed(data.PosOffsetZ),
			Speed = Graph.GenerateSeed(data.Speed),
			Scale = Graph.GenerateSeed(data.Scale),
			Timescale = Graph.GenerateSeed(data.Timescale)
		}
		AxisLinks.applyGraphAxisAliases(data, seeds, data.AxisLinks)
		local invertMotion = data.InvertMotion
		local simLocalCFrames, v11

		if invertMotion then
			simLocalCFrames, v11 = self:PreSimulateForward(
				data,
				seeds,
				v6,
				lookVector,
				cframe2,
				link,
				lifeTime,
				nil,
				v6.Rotation * cframe:Inverse()
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
			v6 = simLocalCFrames[v11 or data.TotalKeyFrames] or simLocalCFrames[0]
		elseif link then
			v6 = cframe3:ToObjectSpace(v6) or v6
		end

		renderTemplate:PivotTo(cframe3 * v6)
		local v12 = {
			Type = "Model",
			VisualPart = renderTemplate,
			Link = link,
			LinkMode = data.LinkMode
		}

		if data.LinkMode ~= "RigidLocal" or not (link and cframe3) then
			cframe3 = nil
		end

		v12._rigidLocalParentCF = cframe3
		v12.Events = data.Events
		v12.StartTime = os.clock()
		v12.TotalKeyFrames = invertMotion and v11 or math.max(1, data.TotalKeyFrames)
		v12.CurrentStep = 0
		v12.AccumulatedDT = 0
		v12.LifeTime = lifeTime
		v12.PartLife = data.PartLife or 0
		v12.CurrentPosition = renderTemplate:GetPivot().Position
		v12.LocalCF = v6
		v12.BaseDirection = lookVector
		v12._accelVel = createVector(0, 0, 0)
		v12.SpeedMultiplier = 1
		v12._spinRate = createVector(0, 0, 0)
		v12._spinAccumX = 0
		v12._spinAccumY = 0
		v12._spinAccumZ = 0
		v12.EmissionDirection = data.EmissionDirection
		v12.SpreadRotation = cframe2
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
		v12._localWorldCF = v6
		v12.SpawnRotation = v6.Rotation
		v12.SpawnEmitterRotation = v6.Rotation * cframe:Inverse()
		v12.DisplacementMode = data.DisplacementMode
		v12._sleepRadius = 1
		v12._prevWorldOff = createVector(0, 0, 0)
		v12.HasPosOffsetGraphs = data.PosOffsetX ~= nil or data.PosOffsetY ~= nil or data.PosOffsetZ ~= nil
		v12.NeedsFullIteration = data.VelocityVectored
		v12.NeedsRotAccum = data.RotMode == "Speed" and not data.VelocityVectored
		v12.HasDrag = data.ParticleData.Drag ~= 0
		v12.HasAccel = data.ParticleData.Acceleration.Magnitude > 0
		v12.Graphs = {
			RotSpeedX = data.RotSpeedX,
			RotSpeedY = data.RotSpeedY,
			RotSpeedZ = data.RotSpeedZ,
			PosOffsetX = data.PosOffsetX,
			PosOffsetY = data.PosOffsetY,
			PosOffsetZ = data.PosOffsetZ,
			Speed = data.Speed,
			Scale = data.Scale,
			Timescale = data.Timescale
		}
		v12.Seeds = seeds
		v12._effectiveElapsed = Graph.InitialEffectiveElapsed(data.Timescale, seeds.Timescale, lifeTime)
		v12.IsAnimate = true
		v12.AnimateItem = instance
		v12.InitialAnchorCF = pivot
		v12.InitialLocalCF = v6
		local success, result = pcall(function()
			return instance:GetScale()
		end)
		v12.InitialScale = success and result or 1

		if v12.HasPosOffsetGraphs then
			local v14 = not v12.Graphs.PosOffsetX and 0 or Graph.QueryPointsWithTime(
				0,
				v12.Graphs.PosOffsetX,
				v12.Seeds.PosOffsetX
			) or 0
			local v15 = not v12.Graphs.PosOffsetY and 0 or Graph.QueryPointsWithTime(
				0,
				v12.Graphs.PosOffsetY,
				v12.Seeds.PosOffsetY
			) or 0
			local v16 = not v12.Graphs.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
				0,
				v12.Graphs.PosOffsetZ,
				v12.Seeds.PosOffsetZ
			) or 0
			local displacement = PartConstants.resolveDisplacement(
				Vector3.new(v14, v15, v16),
				data.DisplacementMode or "Global",
				v12.SpawnRotation,
				v12.SpawnEmitterRotation
			)
			v12._prevWorldOff = displacement

			if v14 ~= 0 or v15 ~= 0 or v16 ~= 0 then
				v12.LocalCF += displacement
				v12.VisualPart:PivotTo(v12.VisualPart:GetPivot() + displacement)
			end
		end

		Turbulence.buildInto(v12, data)
		local beams = {}

		for _, beam in renderTemplate:GetDescendants() do
			if not beam:IsA("Beam") or beam:GetAttribute("Transformed") then
				continue
			end

			table.insert(beams, beam)
		end

		if #beams > 0 then
			v12._visualBeams = beams
		end

		if self._parentScaleMap and self._parentScaleMap[instance] then
			v12.ParentScale = self._parentScaleMap[instance]
		end

		renderTemplate:ScaleTo(math.max(0.001, Graph.QueryPointsWithTime(0, v12.Graphs.Scale, v12.Seeds.Scale)) * PartConstants.getParentScaleFactor(
			v12.ParentScale,
			v12.StartTime,
			Graph
		))

		for _, v14 in ipairs(beams) do
			if v14.Segments < 20 then
				v14.Segments = 20
			end
		end

		local _makeAliveCheck = self:_makeAliveCheck()

		for _, descendant in renderTemplate:GetDescendants() do
			Particles.EnableEmitSingle(descendant, _makeAliveCheck)
		end

		v12._sourceItem = instance
		p._seedTsOverride(v12, instance)
		StaticPass.apply(v12)
		self.ActiveAnimates[instance] = v12
		self:_applyEmitVisualPasses(v12)
		self:_registerEmit(v12, p3)
		self._parentScaleMap = self._parentScaleMap or {}
		local v14 = {
			Graph = v12.Graphs.Scale,
			Seed = v12.Seeds.Scale,
			StaticValue = v12._staticScale or v12.Graphs.Scale == nil and 1 or nil,
			TotalKeyFrames = v12.TotalKeyFrames,
			StartTime = v12.StartTime,
			LifeTime = v12.LifeTime,
			ScaleTextureLength = data.ScaleTextureLength ~= false,
			ScaleMotion = data.ScaleMotion ~= false,
			ScaleRotation = data.ScaleRotation == true,
			Parent = v12.ParentScale
		}
		local descendants = {}

		for _, descendant in renderTemplate:GetDescendants() do
			if not descendant:GetAttribute("Transformed") then
				continue
			end

			self._parentScaleMap[descendant] = v14
			descendants[#descendants + 1] = descendant
			self:EnableEmit(descendant, descendant.Parent, Events.descendCtx(p3))
		end

		v12._scaleMapKeys = descendants
	end
end