local createVector = vector.create
local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local PartConstants = require(script.Parent.PartConstants)
local StaticPass = require(script.Parent.StaticPass)
local AxisLinks = require(script.Parent.AxisLinks)
local NestedEmit = require(script.Parent.NestedEmit)
local Turbulence = require(script.Parent.Turbulence)
return function(p)
	function p._replayAnimateCycle(object, state, startTime)
		state.StartTime = startTime
		state.CurrentStep = 0

		if state.AccumulatedDT then
			state.AccumulatedDT = 0
		end

		if state.InitialLocalCF then
			state.LocalCF = state.InitialLocalCF
		end

		if state.AccRotX then
			state.AccRotX = 0
			state.AccRotY = 0
			state.AccRotZ = 0
		end

		if state.TargetVel then
			state.TargetVel = createVector(0, 0, 0)
		end

		state._collisionStopped = false
		state._spinRate = createVector(0, 0, 0)
		state._spinAccumX = 0
		state._spinAccumY = 0
		state._spinAccumZ = 0
		state.SpeedMultiplier = 1

		if state._accelVel then
			state._accelVel = createVector(0, 0, 0)
		end

		if state._prevWorldOff then
			state._prevWorldOff = createVector(0, 0, 0)
			state._displacementMirrorX = nil
			state._displacementMirrorY = nil
			state._displacementMirrorZ = nil

			if state.HasPosOffsetGraphs and state.Graphs and state.SpawnRotation then
				local v = not state.Graphs.PosOffsetX and 0 or Graph.QueryPointsWithTime(
					0,
					state.Graphs.PosOffsetX,
					state.Seeds.PosOffsetX
				) or 0
				local v2 = not state.Graphs.PosOffsetY and 0 or Graph.QueryPointsWithTime(
					0,
					state.Graphs.PosOffsetY,
					state.Seeds.PosOffsetY
				) or 0
				local v3 = not state.Graphs.PosOffsetZ and 0 or Graph.QueryPointsWithTime(
					0,
					state.Graphs.PosOffsetZ,
					state.Seeds.PosOffsetZ
				) or 0

				if v ~= 0 or v2 ~= 0 or v3 ~= 0 then
					local displacement = PartConstants.resolveDisplacement(
						Vector3.new(v, v2, v3),
						state.DisplacementMode or "Global",
						state.SpawnRotation,
						state.SpawnEmitterRotation
					)
					state._prevWorldOff = displacement
					state.LocalCF += displacement

					if state.VisualPart and state.VisualPart.Parent then
						if state.Type == "Model" then
							pcall(function()
								state.VisualPart:PivotTo(state.VisualPart:GetPivot() + displacement)
							end)
						else
							state.VisualPart.CFrame = state.VisualPart.CFrame + displacement
						end
					end
				end
			end
		end

		Turbulence.reprime(state)

		if state._initialBaseDirection then
			state.BaseDirection = state._initialBaseDirection
		end

		state._lastOrientPos = nil
		local initialLocalCF = state.InitialLocalCF
		local initialLocalCF2 = state.InitialLocalCF
		state._localWorldCF = initialLocalCF
		state._postUpdateCF = initialLocalCF2
		state._lastTransIdx = nil
		state._lastColorIdx = nil
		state._effectiveElapsed = Graph.InitialEffectiveElapsed(
			state.Graphs and state.Graphs.Timescale,
			state.Seeds and state.Seeds.Timescale,
			state.LifeTime
		)
		state._hitHistory = nil

		if state.Type == "ImageLabel" then
			state.PosX = 0
			state.PosY = 0
			state.EnvVelX = 0
			state.EnvVelY = 0
			state.AccRot = 0
		end

		local data = object:GetData(state.AnimateItem)

		if data then
			state.Events = data.Events
			state._killedManually = false
			state._fireOnDeathOverride = false
			state._hitFired = false
			state.LifeTime = Range.RandomValueFromRange(data.Lifetime)

			if state.LifeTime <= 0 then
				state.LifeTime = 0.001
			end

			state.TotalKeyFrames = math.max(1, data.TotalKeyFrames)

			if data.ParticleData then
				state.Acceleration = data.ParticleData.Acceleration
				state.Drag = data.ParticleData.Drag
				state.HasDrag = data.ParticleData.Drag ~= 0
				state.HasAccel = data.ParticleData.Acceleration.Magnitude > 0
			end

			state.InvertMotion = data.InvertMotion or false
			state.AccelTarget = data.AccelTarget
			local hasTargetAccel

			if data.AccelerationTowardsInstance == true and data.AccelTarget ~= nil and data.AccelStrength ~= nil then
				hasTargetAccel = not state.InvertMotion
			else
				hasTargetAccel = false
			end

			state.HasTargetAccel = hasTargetAccel
			state.TargetVel = createVector(0, 0, 0)

			if data.VelocityVectored ~= nil then
				state.VelocityVectored = data.VelocityVectored
			end

			state.NeedsFullIteration = state.VelocityVectored or false

			if data.RotMode then
				state.RotMode = data.RotMode
				state.NeedsRotAccum = data.RotMode == "Speed" and not state.VelocityVectored
			end

			state.Link = data.Link
			state.LinkMode = data.LinkMode

			if state.LinkMode == "RigidLocal" and state.Link and state.Link.Parent then
				state._rigidLocalParentCF = PartConstants.resolveLinkCFrame(state.Link)
			end

			if state.Type == "ImageLabel" then
				object:_refreshImageLabelAnimateNonSpatial(state, data)
			elseif state.Type == "Lightning" then
				object:_refreshLightningAnimate(state, data)
			elseif state.Type == "CameraShake" then
				object:_refreshCameraShakeAnimate(state, data)
			elseif state.Type == "Rocks" then
				object:_refreshRocksAnimate(state, data)
			elseif state.Type == "Rope" then
				object:_refreshRopeAnimate(state, data)
			else
				object:_refreshAnimateNonSpatial(state, data)
			end

			StaticPass.restoreFromFreshData(state, data)
			AxisLinks.refreshLoopGraphsAndSeeds(state, data, Graph)

			if state.Type == "Part" or state.Type == "Attachment" or state.Type == "Model" then
				Turbulence.buildInto(state, data)
			end

			StaticPass.apply(state)

			if state.Type == "ImageLabel" and state._staticSizeScaleX and state._staticSizeScaleY then
				state._staticSizeScaleX = nil
				state._staticSizeScaleY = nil
			end

			state._effectiveElapsed = Graph.InitialEffectiveElapsed(
				state.Graphs and state.Graphs.Timescale,
				state.Seeds and state.Seeds.Timescale,
				state.LifeTime
			)

			if state.Type == "ImageLabel" then
				state.InvertMotion = data.ImgInvertMotion or false

				if state.InvertMotion then
					local _computeImageLabelEndState, posY, envVelX, envVelY = object:_computeImageLabelEndState(
						data,
						state.DirX or 0,
						state.DirY or 0,
						state.LifeTime,
						state.Seeds
					)
					state.PosX = _computeImageLabelEndState
					state.PosY = posY
					state.EnvVelX = envVelX
					state.EnvVelY = envVelY
					state._effectiveElapsed = state.LifeTime
					state._invertDtSign = -1
				else
					state._invertDtSign = nil
				end
			end

			if state.InvertMotion and state.AnimateItem and state.AnimateItem.Parent then
				local cFrame = nil
				local v2 = state.Type == "Attachment"

				if state.Type == "Model" then
					local success, result = pcall(function()
						return state.AnimateItem:GetPivot()
					end)

					if success then
						cFrame = result
					end
				elseif v2 then
					cFrame = state.AnimateItem.CFrame
				elseif state.AnimateItem:IsA("BasePart") then
					cFrame = state.AnimateItem.CFrame
				end

				if cFrame then
					local success, result, totalKeyFrames = pcall(function()
						if v2 then
							return object:PreSimulateAttachmentForward(
								data,
								state.Seeds,
								cFrame,
								state.BaseDirection,
								state.SpreadRotation,
								state.LifeTime,
								nil,
								state.SpawnEmitterRotation
							)
						end

						return object:PreSimulateForward(
							data,
							state.Seeds,
							cFrame,
							state.BaseDirection,
							state.SpreadRotation,
							state.Link,
							state.LifeTime,
							nil,
							state.SpawnEmitterRotation
						)
					end)

					if success then
						state.SimLocalCFrames = result

						if totalKeyFrames then
							state.TotalKeyFrames = totalKeyFrames
						end
					end
				end
			elseif not state.InvertMotion then
				state.SimLocalCFrames = nil
			end

			if state.Type == "Beam" and data.BeamProps then
				local visualPart = state.VisualPart
				local animatedProps = {}

				for k, beamProp in pairs(data.BeamProps) do
					if not beamProp then
						continue
					end

					if Graph.IsStatic(beamProp) then
						if visualPart then
							visualPart[k] = Graph.GetStaticValue(beamProp, visualPart[k])
						end
					else
						animatedProps[k] = {
							Sequence = beamProp,
							Seed = Graph.GenerateSeed(beamProp)
						}
					end
				end

				state.AnimatedProps = animatedProps

				if visualPart then
					state._baseWidth0 = visualPart.Width0
					state._baseWidth1 = visualPart.Width1
					state._baseCurveSize0 = visualPart.CurveSize0
					state._baseCurveSize1 = visualPart.CurveSize1
					state._baseTextureLength = visualPart.TextureLength
					state._baseSegments = visualPart.Segments
				end

				if animatedProps.TextureSpeed and visualPart then
					visualPart.TextureSpeed = 0
				end

				if data.GraphBlender then
					local graphStates, colorStates = Graph.CollectGraphStates(data.GraphBlender)
					state.TransStates = graphStates
					state.ColorStates = colorStates
					local transMergedTimes = {}

					for i = 1, #graphStates - 1 do
						transMergedTimes[i] = Graph.PrecomputeMergedTimes(
							graphStates[i].Graph,
							graphStates[i + 1].Graph
						)
					end

					local colorMergedTimes = {}

					for i = 1, #colorStates - 1 do
						colorMergedTimes[i] = Graph.PrecomputeMergedColorTimes(
							colorStates[i].Graph,
							colorStates[i + 1].Graph
						)
					end

					state.TransMergedTimes = transMergedTimes
					state.ColorMergedTimes = colorMergedTimes

					if #graphStates > 0 and visualPart then
						visualPart.Transparency = graphStates[1].Graph
					end

					if #colorStates > 0 and visualPart then
						visualPart.Color = colorStates[1].Graph
					end
				end
			end

			if data.PLRange then
				state.PLRange = data.PLRange
			end

			if data.PLBrightness then
				state.PLBrightness = data.PLBrightness
			end

			if data.PLColor then
				state.PLColor = data.PLColor
			end
		end

		if state.Type ~= "Lightning" and state.Type ~= "Rocks" and state.Type ~= "CameraShake" and state.Type ~= "Rope" and state.AnimateItem and state.AnimateItem.Parent and state.VisualPart and state.VisualPart.Parent then
			if state.Type == "Model" then
				local success, result = pcall(function()
					return state.AnimateItem:GetPivot()
				end)

				if success and result then
					state.VisualPart:PivotTo(result)
				end
			elseif state.AnimateItem:IsA("BasePart") then
				state.VisualPart.CFrame = state.AnimateItem.CFrame
			elseif state.AnimateItem:IsA("Attachment") then
				state.VisualPart.CFrame = CFrame.new()
			end
		end

		if state.AnimateItem and state.VisualPart and state.VisualPart.Parent then
			if state.Type == "Lightning" or state.Type == "Rocks" or state.Type == "Rope" then
				local data2 = object:GetData(state.AnimateItem)

				if data2 and data2.RenderTemplate then
					NestedEmit.walk(object, data2.RenderTemplate, state.VisualPart, state._nestedAlive, nil)
				end
			else
				for _, descendant in state.VisualPart:GetDescendants() do
					if descendant:GetAttribute("Transformed") then
						object:EnableEmit(descendant, descendant.Parent)
					end
				end
			end
		end

		object:_fireAnimateCycleRestartEvents(state)
	end
end