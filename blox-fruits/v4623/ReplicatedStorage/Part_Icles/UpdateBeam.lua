local Graph = require(script.Parent.Graph)
local PartConstants = require(script.Parent.PartConstants)
return function(p)
	function p.UpdateBeam(_, state, p2, p3)
		local v = math.min(math.max((p3 - state.StartTime) / state.LifeTime, 0), 1)
		local v2

		if state._tsOverride == nil or not (p3 < (state._tsOverrideUntil or 0)) then
			v2 = not state.Graphs.Timescale and 1 or Graph.QueryPointsWithTime(
				v,
				state.Graphs.Timescale,
				state.Seeds.Timescale
			) or 1
		else
			v2 = state._tsOverride
		end

		local v3 = p2 * v2
		local lifeTime = state.LifeTime
		local v4 = (state._effectiveElapsed or 0) + (state._timeFrozen and 0 or v3)
		local effectiveElapsed = v4 < 0 and 0 or v4

		if lifeTime < effectiveElapsed then
			effectiveElapsed = lifeTime
		end

		state._effectiveElapsed = effectiveElapsed
		local v6 = lifeTime <= effectiveElapsed
		local v7 = effectiveElapsed <= 0
		local v8 = effectiveElapsed / lifeTime

		if not (state.VisualPart and state.VisualPart.Parent) then
			return true
		end

		local v9 = v >= 1 and (v6 or v7)
		local v10 = math.min(math.max(v8, 0), 1)
		local transStates = state.TransStates
		local colorStates = state.ColorStates

		if not state.SkipTransparency then
			if transStates and #transStates >= 2 then
				local _lastTransIdx = state._lastTransIdx or 1
				local v11 = v10 < transStates[_lastTransIdx].Time and 1 or _lastTransIdx
				local lastTransIdx = #transStates - 1

				for i = v11, #transStates - 1 do
					if not (transStates[i].Time <= v10 and v10 <= transStates[i + 1].Time) then
						continue
					end

					lastTransIdx = i
					break
				end

				state._lastTransIdx = lastTransIdx
				local transState = transStates[lastTransIdx]
				local v13 = transStates[lastTransIdx + 1] or transStates[#transStates]
				local v14 = v13.Time - transState.Time
				local v15 = not (v14 > 0) and 0 or (v10 - transState.Time) / v14 or 0
				local transMergedTime = state.TransMergedTimes[lastTransIdx]

				if transMergedTime then
					state.VisualPart.Transparency = Graph.LerpGraphFast(
						transState.Graph,
						v13.Graph,
						v15,
						transMergedTime
					)
				else
					state.VisualPart.Transparency = Graph.LerpGraph(transState.Graph, v13.Graph, v15)
				end
			elseif transStates and #transStates == 1 then
				state.VisualPart.Transparency = transStates[1].Graph
			end
		end

		if not state.SkipColor then
			if colorStates and #colorStates >= 2 then
				local _lastColorIdx = state._lastColorIdx or 1
				local v11 = v10 < colorStates[_lastColorIdx].Time and 1 or _lastColorIdx
				local lastColorIdx = #colorStates - 1

				for i = v11, #colorStates - 1 do
					if not (colorStates[i].Time <= v10 and v10 <= colorStates[i + 1].Time) then
						continue
					end

					lastColorIdx = i
					break
				end

				state._lastColorIdx = lastColorIdx
				local colorState = colorStates[lastColorIdx]
				local v13 = colorStates[lastColorIdx + 1] or colorStates[#colorStates]
				local v14 = v13.Time - colorState.Time
				local v15 = not (v14 > 0) and 0 or (v10 - colorState.Time) / v14 or 0
				local colorMergedTime = state.ColorMergedTimes[lastColorIdx]

				if colorMergedTime then
					state.VisualPart.Color = Graph.LerpColorGraphFast(colorState.Graph, v13.Graph, v15, colorMergedTime)
				else
					state.VisualPart.Color = Graph.LerpColorGraph(colorState.Graph, v13.Graph, v15)
				end
			elseif colorStates and #colorStates == 1 then
				state.VisualPart.Color = colorStates[1].Graph
			end
		end

		local textureSpeed = state.AnimatedProps.TextureSpeed

		if textureSpeed then
			local integrateUpTo = Graph.IntegrateUpTo(v10, textureSpeed.Sequence, textureSpeed.Seed)
			state.VisualPart:SetTextureOffset(-integrateUpTo * state.LifeTime % 1)
		end

		for k, animatedProp in pairs(state.AnimatedProps) do
			if k == "TextureSpeed" then
				continue
			end

			local pointsWithTime = Graph.QueryPointsWithTime(v10, animatedProp.Sequence, animatedProp.Seed)

			if k == "Segments" then
				pointsWithTime = math.max(20, (math.round(pointsWithTime)))
			end

			state.VisualPart[k] = pointsWithTime
		end

		if not state.ParentScale then
			return v9
		end

		local parentScale = state.ParentScale
		local parentScaleFactor = PartConstants.getParentScaleFactor(parentScale, p3, Graph)
		local visualPart = state.VisualPart
		local animatedProps = state.AnimatedProps
		visualPart.Width0 = (animatedProps.Width0 and visualPart.Width0 or state._baseWidth0) * parentScaleFactor
		visualPart.Width1 = (animatedProps.Width1 and visualPart.Width1 or state._baseWidth1) * parentScaleFactor
		visualPart.CurveSize0 = (animatedProps.CurveSize0 and visualPart.CurveSize0 or state._baseCurveSize0) * parentScaleFactor
		visualPart.CurveSize1 = (animatedProps.CurveSize1 and visualPart.CurveSize1 or state._baseCurveSize1) * parentScaleFactor

		if parentScale.ScaleTextureLength ~= false then
			visualPart.TextureLength = (animatedProps.TextureLength and visualPart.TextureLength or state._baseTextureLength) * parentScaleFactor
		end

		visualPart.Segments = math.max(
			20,
			(math.round((animatedProps.Segments and visualPart.Segments or state._baseSegments) * parentScaleFactor))
		)
		return v9
	end
end