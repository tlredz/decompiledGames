local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local Pool = require(script.Parent.Pool)
return function(p)
	function p.UpdateHighlight(_, state, p2, p3)
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

		if not (state.VisualPart and state.VisualPart.Parent) or state.TotalKeyFrames <= 0 then
			return true
		end

		local v9 = v >= 1 and (v6 or v7)
		local currentStep = math.floor(math.min(math.max(v8, 0), 1) * state.TotalKeyFrames)

		if currentStep == state.CurrentStep then
			return v9
		end

		state.CurrentStep = currentStep
		local v11 = state.CurrentStep / state.TotalKeyFrames

		if state.Graphs.HLFillColor and not state.SkipColor then
			state.VisualPart.FillColor = Graph.QueryColorPointWithTime(v11, state.Graphs.HLFillColor)
		end

		if state.Graphs.HLFillTransparency and not state.SkipTransparency then
			state.VisualPart.FillTransparency = Graph.QueryPointsWithTime(
				v11,
				state.Graphs.HLFillTransparency,
				state.Seeds.HLFillTransparency
			)
		end

		if state.Graphs.HLOutlineColor and not state.SkipColor then
			state.VisualPart.OutlineColor = Graph.QueryColorPointWithTime(v11, state.Graphs.HLOutlineColor)
		end

		if state.Graphs.HLOutlineTransparency and not state.SkipTransparency then
			state.VisualPart.OutlineTransparency = Graph.QueryPointsWithTime(
				v11,
				state.Graphs.HLOutlineTransparency,
				state.Seeds.HLOutlineTransparency
			)
		end

		return v9
	end

	local function _resolveAdornee(data, instance, instance2)
		if data.Adornee then
			return data.Adornee
		end

		if instance2 then
			if instance2:IsA("BasePart") or instance2:IsA("Model") then
				return instance2
			end

			if instance2:IsA("Attachment") then
				local parent = instance2.Parent

				if parent and (parent:IsA("BasePart") or parent:IsA("Model")) then
					return parent
				end
			end
		end

		local adornee = instance.Adornee

		if adornee then
			return adornee
		end

		local parent = instance.Parent

		if parent and (parent:IsA("BasePart") or parent:IsA("Model")) then
			return parent
		end

		return nil
	end

	function p.EmitHighlight(object, sourceItem, p3, p4)
		if not (sourceItem and sourceItem.Parent) then
			return
		end

		local data = object:GetData(sourceItem)

		if not (data and data.RenderTemplate) then
			return
		end

		local visualPart = Pool.acquireOrClone(data.RenderTemplate, "Highlight", data.Pool)
		visualPart.Archivable = false
		visualPart.Enabled = true

		if data.HLDepthMode then
			visualPart.DepthMode = data.HLDepthMode
		end

		visualPart.Adornee = _resolveAdornee(data, sourceItem, p3)
		local emitParent = data.EmitParent or p3 or sourceItem.Parent
		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local hLFillTransparency = not data.HLFillTransparency and {} or Graph.GenerateSeed(data.HLFillTransparency) or {}
		local hLOutlineTransparency = not data.HLOutlineTransparency and {} or Graph.GenerateSeed(data.HLOutlineTransparency) or {}
		local seed = Graph.GenerateSeed(data.HLTimescale)

		if data.HLFillColor then
			visualPart.FillColor = Graph.QueryColorPointWithTime(0, data.HLFillColor)
		end

		if data.HLFillTransparency then
			visualPart.FillTransparency = Graph.QueryPointsWithTime(0, data.HLFillTransparency, hLFillTransparency)
		end

		if data.HLOutlineColor then
			visualPart.OutlineColor = Graph.QueryColorPointWithTime(0, data.HLOutlineColor)
		end

		if data.HLOutlineTransparency then
			visualPart.OutlineTransparency = Graph.QueryPointsWithTime(
				0,
				data.HLOutlineTransparency,
				hLOutlineTransparency
			)
		end

		visualPart.Parent = emitParent
		local v5 = {
			Type = "Highlight",
			VisualPart = visualPart,
			Events = data.Events,
			StartTime = os.clock(),
			TotalKeyFrames = math.max(1, data.TotalKeyFrames),
			CurrentStep = 0,
			LifeTime = lifeTime,
			PartLife = data.PartLife or 0,
			Graphs = {
				HLFillColor = data.HLFillColor,
				HLFillTransparency = data.HLFillTransparency,
				HLOutlineColor = data.HLOutlineColor,
				HLOutlineTransparency = data.HLOutlineTransparency,
				Timescale = data.HLTimescale
			},
			Seeds = {
				HLFillTransparency = hLFillTransparency,
				HLOutlineTransparency = hLOutlineTransparency,
				Timescale = seed
			},
			_effectiveElapsed = Graph.InitialEffectiveElapsed(data.HLTimescale, seed, lifeTime),
			_sourceItem = sourceItem
		}
		p._seedTsOverride(v5, sourceItem)

		if data.Pool ~= false then
			v5._sourceRT = data.RenderTemplate
			v5._poolKind = "Highlight"
		end

		object:_registerEmit(v5, p4)
	end

	function p.EmitHighlightAnimate(object, instance, _, p2)
		if not (instance and instance.Parent) or object.ActiveAnimates[instance] then
			return
		end

		local data = object:GetData(instance)

		if not (data and data.RenderTemplate) then
			return
		end

		local renderTemplate = data.RenderTemplate
		local highlightSnapshot = {
			FillColor = renderTemplate.FillColor,
			FillTransparency = renderTemplate.FillTransparency,
			OutlineColor = renderTemplate.OutlineColor,
			OutlineTransparency = renderTemplate.OutlineTransparency,
			DepthMode = renderTemplate.DepthMode,
			Adornee = renderTemplate.Adornee,
			Enabled = renderTemplate.Enabled
		}
		renderTemplate.Enabled = true

		if data.HLDepthMode then
			renderTemplate.DepthMode = data.HLDepthMode
		end

		local adornee

		if data.Adornee then
			adornee = data.Adornee
		else
			adornee = instance.Adornee

			if not adornee then
				adornee = instance.Parent

				if not (adornee and (adornee:IsA("BasePart") or adornee:IsA("Model"))) then
					adornee = nil
				end
			end
		end

		renderTemplate.Adornee = adornee
		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local hLFillTransparency = not data.HLFillTransparency and {} or Graph.GenerateSeed(data.HLFillTransparency) or {}
		local hLOutlineTransparency = not data.HLOutlineTransparency and {} or Graph.GenerateSeed(data.HLOutlineTransparency) or {}
		local seed = Graph.GenerateSeed(data.HLTimescale)
		local v5 = {
			Type = "Highlight",
			VisualPart = renderTemplate,
			Events = data.Events,
			StartTime = os.clock(),
			TotalKeyFrames = math.max(1, data.TotalKeyFrames),
			CurrentStep = 0,
			LifeTime = lifeTime,
			PartLife = data.PartLife or 0,
			IsAnimate = true,
			AnimateItem = instance,
			HighlightSnapshot = highlightSnapshot,
			Graphs = {
				HLFillColor = data.HLFillColor,
				HLFillTransparency = data.HLFillTransparency,
				HLOutlineColor = data.HLOutlineColor,
				HLOutlineTransparency = data.HLOutlineTransparency,
				Timescale = data.HLTimescale
			},
			Seeds = {
				HLFillTransparency = hLFillTransparency,
				HLOutlineTransparency = hLOutlineTransparency,
				Timescale = seed
			},
			_effectiveElapsed = Graph.InitialEffectiveElapsed(data.HLTimescale, seed, lifeTime),
			_sourceItem = instance
		}
		p._seedTsOverride(v5, instance)
		object.ActiveAnimates[instance] = v5
		object:_registerEmit(v5, p2)
	end
end