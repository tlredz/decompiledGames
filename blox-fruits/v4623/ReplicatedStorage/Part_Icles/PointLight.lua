local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local Pool = require(script.Parent.Pool)
return function(p)
	function p.UpdatePointLight(_, state, p2, p3)
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

		if not (state.VisualPart and state.VisualPart.Parent) or state.TotalKeyFrames <= 0 or state._parentAlive and not state._parentAlive[1] then
			return true
		end

		local v9 = v >= 1 and (v6 or v7)
		local currentStep = math.floor(math.min(math.max(v8, 0), 1) * state.TotalKeyFrames)

		if currentStep == state.CurrentStep then
			return v9
		end

		state.CurrentStep = currentStep
		local v11 = state.CurrentStep / state.TotalKeyFrames
		local brightness = nil
		local color = nil
		local range

		if state.Graphs.PLRange then
			range = Graph.QueryPointsWithTime(v11, state.Graphs.PLRange, state.Seeds.PLRange)
			state.VisualPart.Range = range
		end

		if state.Graphs.PLBrightness and not state.SkipTransparency then
			brightness = Graph.QueryPointsWithTime(v11, state.Graphs.PLBrightness, state.Seeds.PLBrightness)
			state.VisualPart.Brightness = brightness
		end

		if state.Graphs.PLColor and not state.SkipColor then
			color = Graph.QueryColorPointWithTime(v11, state.Graphs.PLColor)
			state.VisualPart.Color = color
		end

		local _extraLights = state._extraLights

		if not _extraLights then
			return v9
		end

		for i = 1, #_extraLights do
			local _extraLight = _extraLights[i]

			if range then
				_extraLight.Range = range
			end

			if brightness then
				_extraLight.Brightness = brightness
			end

			if color then
				_extraLight.Color = color
			end
		end

		return v9
	end

	function p.EmitPointLight(object, sourceItem, p3, p4)
		if not (sourceItem and sourceItem.Parent) then
			return
		end

		local data = object:GetData(sourceItem)

		if not (data and data.RenderTemplate) then
			return
		end

		local visualPart = Pool.acquireOrClone(data.RenderTemplate, "PointLight", data.Pool)
		visualPart.Archivable = false
		visualPart.Enabled = true

		if data.Shadows ~= nil then
			visualPart.Shadows = data.Shadows
		end

		local emitParent = data.EmitParent or p3 or sourceItem.Parent
		local v2 = nil

		if emitParent and emitParent:IsA("Model") then
			local parts = nil

			for _, part in ipairs(emitParent:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				parts = parts or {}
				parts[#parts + 1] = part
			end

			if parts then
				if emitParent:GetAttribute("_lightningBolt") then
					emitParent = parts[1]
					v2 = parts
				else
					emitParent = parts[math.ceil(#parts / 2)]
				end
			end
		end

		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local pLRange = not data.PLRange and {} or Graph.GenerateSeed(data.PLRange) or {}
		local pLBrightness = not data.PLBrightness and {} or Graph.GenerateSeed(data.PLBrightness) or {}
		local seed = Graph.GenerateSeed(data.PLTimescale)

		if data.PLRange then
			visualPart.Range = Graph.QueryPointsWithTime(0, data.PLRange, pLRange)
		end

		if data.PLBrightness then
			visualPart.Brightness = Graph.QueryPointsWithTime(0, data.PLBrightness, pLBrightness)
		end

		if data.PLColor then
			visualPart.Color = Graph.QueryColorPointWithTime(0, data.PLColor)
		end

		visualPart.Parent = emitParent
		local clones

		if v2 and #v2 > 1 then
			visualPart.Archivable = true
			clones = table.create(#v2 - 1)

			for i = 2, #v2 do
				local clone = visualPart:Clone()
				clone.Archivable = false
				clone.Parent = v2[i]
				clones[i - 1] = clone
			end

			visualPart.Archivable = false
		end

		local v6 = {
			Type = "PointLight",
			VisualPart = visualPart,
			Events = data.Events,
			StartTime = os.clock(),
			TotalKeyFrames = math.max(1, data.TotalKeyFrames),
			CurrentStep = 0,
			LifeTime = lifeTime,
			PartLife = data.PartLife or 0,
			Graphs = {
				PLRange = data.PLRange,
				PLBrightness = data.PLBrightness,
				PLColor = data.PLColor,
				Timescale = data.PLTimescale
			},
			Seeds = {
				PLRange = pLRange,
				PLBrightness = pLBrightness,
				Timescale = seed
			},
			_effectiveElapsed = Graph.InitialEffectiveElapsed(data.PLTimescale, seed, lifeTime),
			_sourceItem = sourceItem,
			_extraLights = clones
		}

		if p4 and p4._parentAlive and not data.EmitParent then
			v6._parentAlive = p4._parentAlive
		end

		p._seedTsOverride(v6, sourceItem)

		if data.Pool ~= false then
			v6._sourceRT = data.RenderTemplate
			v6._poolKind = "PointLight"
		end

		object:_registerEmit(v6, p4)
	end
end