local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local TrailGraphBlender = require(script.Parent.TrailGraphBlender)
local Pool = require(script.Parent.Pool)
local Flipbook = require(script.Parent.Flipbook)
return function(p)
	local v = {
		"Brightness",
		"LightEmission",
		"LightInfluence",
		"TextureLength",
		"MinLength",
		"MaxLength"
	}

	local function _writeBlenderState(visualPart, p2, list, p3, p4, state, p5)
		if not list or #list == 0 then
			return
		end

		if #list == 1 then
			visualPart[p2] = list[1].Graph
			return
		end

		local v2 = state[p4] or 1
		local v3 = p5 < list[v2].Time and 1 or v2
		local v4 = #list - 1

		for i = v3, #list - 1 do
			if not (list[i].Time <= p5 and p5 <= list[i + 1].Time) then
				continue
			end

			v4 = i
			break
		end

		state[p4] = v4
		local v5 = list[v4]
		local v6 = list[v4 + 1] or list[#list]
		local v7 = v6.Time - v5.Time
		local v8 = not (v7 > 0) and 0 or (p5 - v5.Time) / v7 or 0
		local v9 = p3 and p3[v4]

		if v9 then
			if p2 == "Color" then
				visualPart.Color = Graph.LerpColorGraphFast(v5.Graph, v6.Graph, v8, v9)
			else
				visualPart[p2] = Graph.LerpGraphFast(v5.Graph, v6.Graph, v8, v9)
			end
		end
	end

	function p.UpdateTrail(_, state, p2, p3)
		local v2 = math.min(math.max((p3 - state.StartTime) / state.LifeTime, 0), 1)
		local v3

		if state._tsOverride == nil or not (p3 < (state._tsOverrideUntil or 0)) then
			v3 = not state.Graphs.Timescale and 1 or Graph.QueryPointsWithTime(
				v2,
				state.Graphs.Timescale,
				state.Seeds.Timescale
			) or 1
		else
			v3 = state._tsOverride
		end

		local v4 = p2 * v3
		local lifeTime = state.LifeTime
		local v5 = (state._effectiveElapsed or 0) + (state._timeFrozen and 0 or v4)
		local effectiveElapsed = v5 < 0 and 0 or v5

		if lifeTime < effectiveElapsed then
			effectiveElapsed = lifeTime
		end

		state._effectiveElapsed = effectiveElapsed
		local v7 = lifeTime <= effectiveElapsed
		local v8 = effectiveElapsed <= 0
		local v9 = effectiveElapsed / lifeTime

		if not (state.VisualPart and state.VisualPart.Parent) then
			return true
		end

		local v10 = v2 >= 1 and (v7 or v8)
		local v11 = math.min(math.max(v9, 0), 1)

		if not state.SkipColor then
			_writeBlenderState(
				state.VisualPart,
				"WidthScale",
				state.WidthStates,
				state.WidthMergedTimes,
				"_lastWidthIdx",
				state,
				v11
			)
			_writeBlenderState(
				state.VisualPart,
				"Color",
				state.ColorStates,
				state.ColorMergedTimes,
				"_lastColorIdx",
				state,
				v11
			)
		end

		if not state.SkipTransparency then
			_writeBlenderState(
				state.VisualPart,
				"Transparency",
				state.TransStates,
				state.TransMergedTimes,
				"_lastTransIdx",
				state,
				v11
			)
		end

		if not (state.TotalKeyFrames > 0) then
			return v10
		end

		local currentStep = math.floor(v11 * state.TotalKeyFrames)

		if currentStep == state.CurrentStep then
			return v10
		end

		state.CurrentStep = currentStep
		local v13 = state.CurrentStep / state.TotalKeyFrames

		for _, v14 in ipairs(v) do
			local graph = state.Graphs[v14]

			if graph then
				state.VisualPart[v14] = Graph.QueryPointsWithTime(v13, graph, state.Seeds[v14])
			end
		end

		return v10
	end

	local function _collectStatesAndMergedTimes(graphBlender)
		local states, v2, v3 = TrailGraphBlender.CollectStates(graphBlender)
		local result = {}
		local result2 = {}
		local result3 = {}

		for i = 1, #states - 1 do
			result[i] = TrailGraphBlender.PrecomputeMergedTimes(states[i].Graph, states[i + 1].Graph)
		end

		for i = 1, #v2 - 1 do
			result2[i] = TrailGraphBlender.PrecomputeMergedTimes(v2[i].Graph, v2[i + 1].Graph)
		end

		for i = 1, #v3 - 1 do
			result3[i] = TrailGraphBlender.PrecomputeMergedColorTimes(v3[i].Graph, v3[i + 1].Graph)
		end

		return states, v2, v3, result, result2, result3
	end

	local function _buildScalarGraphs(data)
		local result = {
			Timescale = data.TEmitTimescale
		}
		local result2 = {
			Timescale = Graph.GenerateSeed(data.TEmitTimescale)
		}

		for _, v2 in ipairs(v) do
			local v3 = data["TEmit" .. v2] or data[v2]

			if not v3 then
				continue
			end

			result[v2] = v3
			result2[v2] = Graph.GenerateSeed(v3)
		end

		return result, result2
	end

	function p.EmitTrail(object, sourceItem, link, p4)
		if not (sourceItem and sourceItem.Parent) then
			return
		end

		local data = object:GetData(sourceItem)

		if not (data and data.RenderTemplate) then
			return
		end

		local visualPart = Pool.acquireOrClone(data.RenderTemplate, "TrailEmitter", data.Pool)
		visualPart.Archivable = false
		visualPart.Enabled = true

		if p4 and p4._parentCloneMap then
			local _parentCloneMap = p4._parentCloneMap

			if visualPart.Attachment0 and _parentCloneMap[visualPart.Attachment0] then
				visualPart.Attachment0 = _parentCloneMap[visualPart.Attachment0]
			end

			if visualPart.Attachment1 and _parentCloneMap[visualPart.Attachment1] then
				visualPart.Attachment1 = _parentCloneMap[visualPart.Attachment1]
			end
		end

		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local trailLife = data.TrailLife or data.Lifetime
		local randomValueFromRange2 = Range.RandomValueFromRange(trailLife)
		visualPart.Lifetime = randomValueFromRange2 <= 0 and 0.001 or randomValueFromRange2
		local widthStates, transStates, colorStates, widthMergedTimes, transMergedTimes, colorMergedTimes = _collectStatesAndMergedTimes(data.GraphBlender)

		if #widthStates > 0 then
			visualPart.WidthScale = widthStates[1].Graph
		end

		if #transStates > 0 then
			visualPart.Transparency = transStates[1].Graph
		end

		if #colorStates > 0 then
			visualPart.Color = colorStates[1].Graph
		end

		local graphs, seeds = _buildScalarGraphs(data)

		for _, v12 in ipairs(v) do
			if graphs[v12] then
				visualPart[v12] = Graph.QueryPointsWithTime(0, graphs[v12], seeds[v12])
			end
		end

		visualPart.Parent = data.EmitParent or object:GetFolder()
		local v12 = {
			Type = "TrailEmitter",
			VisualPart = visualPart,
			Link = link,
			Events = data.Events,
			StartTime = os.clock(),
			TotalKeyFrames = math.max(1, data.TotalKeyFrames),
			CurrentStep = 0,
			LifeTime = lifeTime,
			PartLife = data.PartLife or 0,
			WidthStates = widthStates,
			TransStates = transStates,
			ColorStates = colorStates,
			WidthMergedTimes = widthMergedTimes,
			TransMergedTimes = transMergedTimes,
			ColorMergedTimes = colorMergedTimes,
			Graphs = graphs,
			Seeds = seeds,
			_effectiveElapsed = Graph.InitialEffectiveElapsed(data.TEmitTimescale, seeds.Timescale, lifeTime),
			_sourceItem = sourceItem
		}
		p._seedTsOverride(v12, sourceItem)

		if data.Pool ~= false then
			v12._sourceRT = data.RenderTemplate
			v12._poolKind = "TrailEmitter"
		end

		object:_registerEmit(v12, p4)

		if data.TrailFlipbookMode and data.TrailFlipbooks then
			local sortedBeamTextures = Flipbook.GetSortedBeamTextures(data.TrailFlipbooks)

			if #sortedBeamTextures > 0 then
				local v13 = {
					FlipbookMode = data.TrailFlipbookMode,
					FlipbookFramerate = data.TrailFlipbookFramerate,
					FlipbookStartRandom = data.TrailFlipbookStartRandom,
					FlipbookReverse = data.TrailFlipbookReverse
				}
				Flipbook.FlipBeam(v12, v13, sortedBeamTextures, visualPart, lifeTime)
			end
		end
	end

	function p.EmitTrailAnimate(object, p2, link, p4)
		if not (p2 and p2.Parent) or object.ActiveAnimates[p2] then
			return
		end

		local data = object:GetData(p2)

		if not (data and data.RenderTemplate) then
			return
		end

		local renderTemplate = data.RenderTemplate
		local trailEmitterSnapshot = {
			Lifetime = renderTemplate.Lifetime,
			Brightness = renderTemplate.Brightness,
			LightEmission = renderTemplate.LightEmission,
			LightInfluence = renderTemplate.LightInfluence,
			TextureLength = renderTemplate.TextureLength,
			MinLength = renderTemplate.MinLength,
			MaxLength = renderTemplate.MaxLength,
			Texture = renderTemplate.Texture,
			TextureMode = renderTemplate.TextureMode,
			FaceCamera = renderTemplate.FaceCamera,
			WidthScale = renderTemplate.WidthScale,
			Transparency = renderTemplate.Transparency,
			Color = renderTemplate.Color,
			Enabled = renderTemplate.Enabled
		}
		renderTemplate.Enabled = true
		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local trailLife = data.TrailLife or data.Lifetime
		local randomValueFromRange2 = Range.RandomValueFromRange(trailLife)
		renderTemplate.Lifetime = randomValueFromRange2 <= 0 and 0.001 or randomValueFromRange2
		local widthStates, transStates, colorStates, widthMergedTimes, transMergedTimes, colorMergedTimes = _collectStatesAndMergedTimes(data.GraphBlender)

		if #widthStates > 0 then
			renderTemplate.WidthScale = widthStates[1].Graph
		end

		if #transStates > 0 then
			renderTemplate.Transparency = transStates[1].Graph
		end

		if #colorStates > 0 then
			renderTemplate.Color = colorStates[1].Graph
		end

		local graphs, seeds = _buildScalarGraphs(data)

		for _, v12 in ipairs(v) do
			if graphs[v12] then
				renderTemplate[v12] = Graph.QueryPointsWithTime(0, graphs[v12], seeds[v12])
			end
		end

		local v12 = {
			Type = "TrailEmitter",
			VisualPart = renderTemplate,
			Link = link,
			Events = data.Events,
			StartTime = os.clock(),
			TotalKeyFrames = math.max(1, data.TotalKeyFrames),
			CurrentStep = 0,
			LifeTime = lifeTime,
			PartLife = data.PartLife or 0,
			IsAnimate = true,
			AnimateItem = p2,
			TrailEmitterSnapshot = trailEmitterSnapshot,
			WidthStates = widthStates,
			TransStates = transStates,
			ColorStates = colorStates,
			WidthMergedTimes = widthMergedTimes,
			TransMergedTimes = transMergedTimes,
			ColorMergedTimes = colorMergedTimes,
			Graphs = graphs,
			Seeds = seeds,
			_effectiveElapsed = Graph.InitialEffectiveElapsed(data.TEmitTimescale, seeds.Timescale, lifeTime),
			_sourceItem = p2
		}
		p._seedTsOverride(v12, p2)
		object.ActiveAnimates[p2] = v12
		object:_registerEmit(v12, p4)

		if data.TrailFlipbookMode and data.TrailFlipbooks then
			local sortedBeamTextures = Flipbook.GetSortedBeamTextures(data.TrailFlipbooks)

			if #sortedBeamTextures > 0 then
				local v13 = {
					FlipbookMode = data.TrailFlipbookMode,
					FlipbookFramerate = data.TrailFlipbookFramerate,
					FlipbookStartRandom = data.TrailFlipbookStartRandom,
					FlipbookReverse = data.TrailFlipbookReverse
				}
				Flipbook.FlipBeam(v12, v13, sortedBeamTextures, renderTemplate, lifeTime)
			end
		end
	end
end