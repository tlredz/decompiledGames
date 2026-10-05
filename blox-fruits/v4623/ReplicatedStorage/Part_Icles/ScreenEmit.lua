local Lighting = game:GetService("Lighting")
local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
return function(p)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function resolveScreenParent(data, _)
		if data.EmitParent then
			return data.EmitParent
		end

		return Lighting
	end

	local function buildGraphs(p2, data)
		if p2 == "Blur" then
			return {
				BlurSize = data.BlurSize,
				Timescale = data.Timescale
			}
		elseif p2 == "Bloom" then
			return {
				BloomIntensity = data.BloomIntensity,
				BloomSize = data.BloomSize,
				BloomThreshold = data.BloomThreshold,
				Timescale = data.Timescale
			}
		elseif p2 == "CC" then
			return {
				CCBrightness = data.CCBrightness,
				CCContrast = data.CCContrast,
				CCSaturation = data.CCSaturation,
				CCTintColor = data.CCTintColor,
				Timescale = data.Timescale
			}
		elseif p2 == "Atmosphere" then
			return {
				AtmDensity = data.AtmDensity,
				AtmOffset = data.AtmOffset,
				AtmGlare = data.AtmGlare,
				AtmHaze = data.AtmHaze,
				AtmColor = data.AtmColor,
				AtmDecay = data.AtmDecay,
				Timescale = data.AtmTimescale
			}
		end

		return {}
	end

	local function buildSeeds(graphs)
		local result = {}

		for k, item in pairs(graphs) do
			if typeof(item) == "NumberSequence" then
				result[k] = Graph.GenerateSeed(item)
			end
		end

		return result
	end

	local function writeSample(p2, p3, graphs, seeds, p4, p5, p6)
		if p2 == "Blur" and graphs.BlurSize then
			p3.Size = Graph.QueryPointsWithTime(p4, graphs.BlurSize, seeds.BlurSize)
		elseif p2 == "Bloom" then
			if graphs.BloomIntensity then
				p3.Intensity = Graph.QueryPointsWithTime(p4, graphs.BloomIntensity, seeds.BloomIntensity)
			end

			if graphs.BloomSize then
				p3.Size = Graph.QueryPointsWithTime(p4, graphs.BloomSize, seeds.BloomSize)
			end

			if graphs.BloomThreshold then
				p3.Threshold = Graph.QueryPointsWithTime(p4, graphs.BloomThreshold, seeds.BloomThreshold)
			end
		elseif p2 == "CC" then
			if graphs.CCBrightness and not p6 then
				p3.Brightness = Graph.QueryPointsWithTime(p4, graphs.CCBrightness, seeds.CCBrightness)
			end

			if graphs.CCContrast then
				p3.Contrast = Graph.QueryPointsWithTime(p4, graphs.CCContrast, seeds.CCContrast)
			end

			if graphs.CCSaturation then
				p3.Saturation = Graph.QueryPointsWithTime(p4, graphs.CCSaturation, seeds.CCSaturation)
			end

			if graphs.CCTintColor and not p5 then
				p3.TintColor = Graph.QueryColorPointWithTime(p4, graphs.CCTintColor)
			end
		elseif p2 == "Atmosphere" then
			if graphs.AtmDensity then
				p3.Density = Graph.QueryPointsWithTime(p4, graphs.AtmDensity, seeds.AtmDensity)
			end

			if graphs.AtmOffset then
				p3.Offset = Graph.QueryPointsWithTime(p4, graphs.AtmOffset, seeds.AtmOffset)
			end

			if graphs.AtmGlare then
				p3.Glare = Graph.QueryPointsWithTime(p4, graphs.AtmGlare, seeds.AtmGlare)
			end

			if graphs.AtmHaze then
				p3.Haze = Graph.QueryPointsWithTime(p4, graphs.AtmHaze, seeds.AtmHaze)
			end

			if graphs.AtmColor and not p5 then
				p3.Color = Graph.QueryColorPointWithTime(p4, graphs.AtmColor)
			end

			if graphs.AtmDecay and not p5 then
				p3.Decay = Graph.QueryColorPointWithTime(p4, graphs.AtmDecay)
			end
		end
	end

	local function kindHasEnabled(p2)
		return p2 ~= "Atmosphere"
	end

	local function emitClone(object, kind, sourceItem, _, p4)
		local data = object:GetData(sourceItem)

		if not (data and data.RenderTemplate) then
			return
		end

		local clone = data.RenderTemplate:Clone()
		clone.Archivable = false

		if kind ~= "Atmosphere" then
			clone.Enabled = true
		end

		clone:SetAttribute("_PartIcleEmit", true)
		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local graphs = buildGraphs(kind, data)
		local seeds = buildSeeds(graphs)
		writeSample(kind, clone, graphs, seeds, 0)
		local screenParent = resolveScreenParent(data) -- equivalent call inferred; original call site unknown
		clone.Parent = screenParent
		local v2 = {
			Type = "Screen",
			Kind = kind,
			VisualPart = clone,
			Events = data.Events,
			StartTime = os.clock(),
			TotalKeyFrames = math.max(1, data.TotalKeyFrames or 100),
			CurrentStep = 0,
			LifeTime = lifeTime,
			PartLife = data.PartLife or 0,
			Graphs = graphs,
			Seeds = seeds,
			_effectiveElapsed = Graph.InitialEffectiveElapsed(graphs.Timescale, seeds.Timescale, lifeTime),
			_sourceItem = sourceItem
		}
		p._seedTsOverride(v2, sourceItem)
		object:_registerEmit(v2, p4)
	end

	local function emitAnimateInternal(object, kind, p3, _, p4)
		if object.ActiveAnimates[p3] then
			return
		end

		local data = object:GetData(p3)

		if not (data and data.RenderTemplate) then
			return
		end

		local clone = data.RenderTemplate:Clone()
		clone.Archivable = false

		if kind ~= "Atmosphere" then
			clone.Enabled = true
		end

		clone:SetAttribute("_PartIcleEmit", true)
		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local lifeTime = randomValueFromRange <= 0 and 0.001 or randomValueFromRange
		local graphs = buildGraphs(kind, data)
		local seeds = buildSeeds(graphs)
		writeSample(kind, clone, graphs, seeds, 0)
		local screenParent = resolveScreenParent(data) -- equivalent call inferred; original call site unknown
		clone.Parent = screenParent
		local v2 = {
			Type = "Screen",
			Kind = kind,
			VisualPart = clone,
			Events = data.Events,
			StartTime = os.clock(),
			TotalKeyFrames = math.max(1, data.TotalKeyFrames or 100),
			CurrentStep = 0,
			LifeTime = lifeTime,
			PartLife = data.PartLife or 0,
			Graphs = graphs,
			Seeds = seeds,
			_effectiveElapsed = Graph.InitialEffectiveElapsed(graphs.Timescale, seeds.Timescale, lifeTime),
			IsAnimate = true,
			AnimateItem = p3,
			_sourceItem = p3
		}
		p._seedTsOverride(v2, p3)
		object.ActiveAnimates[p3] = v2
		object:_registerEmit(v2, p4)
	end

	function p.EmitBlur(p2, sourceItem, p4, p5)
		emitClone(p2, "Blur", sourceItem, p4, p5)
	end

	function p.EmitBloom(p2, sourceItem, p4, p5)
		emitClone(p2, "Bloom", sourceItem, p4, p5)
	end

	function p.EmitColorCorrection(p2, sourceItem, p4, p5)
		emitClone(p2, "CC", sourceItem, p4, p5)
	end

	function p.EmitAtmosphere(p2, sourceItem, p4, p5)
		emitClone(p2, "Atmosphere", sourceItem, p4, p5)
	end

	function p.EmitBlurAnimate(p2, p3, p4, p5)
		emitAnimateInternal(p2, "Blur", p3, p4, p5)
	end

	function p.EmitBloomAnimate(p2, p3, p4, p5)
		emitAnimateInternal(p2, "Bloom", p3, p4, p5)
	end

	function p.EmitColorCorrectionAnimate(p2, p3, p4, p5)
		emitAnimateInternal(p2, "CC", p3, p4, p5)
	end

	function p.EmitAtmosphereAnimate(p2, p3, p4, p5)
		emitAnimateInternal(p2, "Atmosphere", p3, p4, p5)
	end

	function p.UpdateScreen(_, state, p2, p3)
		if not (state.VisualPart and state.VisualPart.Parent) or state.TotalKeyFrames <= 0 then
			return true
		end

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
		local v9 = v >= 1 and (v6 or v7)
		local v10 = v8 > 1 and 1 or v8
		local currentStep = math.floor((v10 < 0 and 0 or v10) * state.TotalKeyFrames)

		if currentStep ~= state.CurrentStep then
			state.CurrentStep = currentStep
			local v12 = state.CurrentStep / state.TotalKeyFrames
			writeSample(
				state.Kind,
				state.VisualPart,
				state.Graphs,
				state.Seeds,
				v12,
				state.SkipColor,
				state.SkipTransparency
			)
		end

		return v9
	end
end