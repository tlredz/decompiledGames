local RunService = game:GetService("RunService")
local Graph = require(script.Parent.Graph)
local Range = require(script.Parent.Range)
local PartConstants = require(script.Parent.PartConstants)
local Apply = require(script.Apply)
local v = false
return function(p)
	function p._isCameraShake(part)
		return part:IsA("BasePart") and part:GetAttribute("IsCameraShake") == true
	end

	local function buildPData(sourceItem, data, lifeTime, p4)
		local seeds = {
			ShakeAmplitude = Graph.GenerateSeed(data.ShakeAmplitude),
			ShakeRotAmplitude = Graph.GenerateSeed(data.ShakeRotAmplitude),
			Timescale = Graph.GenerateSeed(data.Timescale)
		}
		local v3 = {
			Type = "CameraShake",
			VisualPart = nil,
			Events = data.Events,
			StartTime = os.clock(),
			TotalKeyFrames = math.max(1, data.TotalKeyFrames),
			CurrentStep = -1,
			LifeTime = lifeTime,
			PartLife = 0,
			_sourceItem = sourceItem,
			Graphs = {
				ShakeAmplitude = data.ShakeAmplitude,
				ShakeRotAmplitude = data.ShakeRotAmplitude,
				Timescale = data.Timescale
			},
			Seeds = seeds,
			_effectiveElapsed = Graph.InitialEffectiveElapsed(data.Timescale, seeds.Timescale, lifeTime),
			_shakeFreq = data.ShakeFrequency or 10,
			_falloff = data.ShakeFalloff or 0,
			_shakeSeed = math.random() * 997 + 0.5,
			_lastOriginPos = sourceItem.Position
		}

		if not p4 then
			return v3
		end

		local v4

		if p4.EventOriginResolver then
			v4 = p4.EventOriginResolver()
		end

		local v5 = v4 or p4.EventOriginCF

		if v5 then
			v3._originOverride = v5.Position
		end

		return v3
	end

	function p.EmitCameraShake(object, sourceItem, parentLink, p3)
		if not (sourceItem and sourceItem.Parent) then
			return
		end

		if RunService:IsClient() then
			local data = object:GetData(sourceItem)

			if not data then
				return
			end

			local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
			local pData = buildPData(sourceItem, data, randomValueFromRange <= 0 and 0.001 or randomValueFromRange, p3)
			pData._parentLink = parentLink
			p._seedTsOverride(pData, sourceItem)
			object:_registerEmit(pData, p3)
		elseif not v then
			v = true
			warn("[Part-Icles] CameraShake ignored on the server (no camera).")
		end
	end

	function p.EmitCameraShakeAnimate(object, animateItem, parentLink, p2)
		if not (animateItem and animateItem.Parent) or object.ActiveAnimates[animateItem] or not RunService:IsClient() then
			return
		end

		local data = object:GetData(animateItem)

		if not data then
			return
		end

		local randomValueFromRange = Range.RandomValueFromRange(data.Lifetime)
		local pData = buildPData(animateItem, data, randomValueFromRange <= 0 and 0.001 or randomValueFromRange, p2)
		pData._parentLink = parentLink
		pData.IsAnimate = true
		pData.AnimateItem = animateItem
		p._seedTsOverride(pData, animateItem)
		object.ActiveAnimates[animateItem] = pData
		object:_registerEmit(pData, p2)
	end

	function p.UpdateCameraShake(_, state, p2, p3)
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

		if state.TotalKeyFrames <= 0 then
			return true
		end

		local v7

		if v2 >= 1 then
			v7 = lifeTime <= effectiveElapsed or effectiveElapsed <= 0
		else
			v7 = false
		end

		if v7 then
			return true
		end

		local _originOverride = state._originOverride

		if not _originOverride then
			local _parentLink = state._parentLink

			if _parentLink and _parentLink.Parent then
				_originOverride = PartConstants.resolveLinkCFrame(_parentLink).Position
			else
				local _sourceItem = state._sourceItem
				_originOverride = _sourceItem and _sourceItem.Parent and _sourceItem.Position or state._lastOriginPos
			end
		end

		state._lastOriginPos = _originOverride
		local currentStep = math.floor(math.min(math.max(effectiveElapsed / lifeTime, 0), 1) * state.TotalKeyFrames)

		if currentStep ~= state.CurrentStep then
			state.CurrentStep = currentStep
			local v9 = currentStep / state.TotalKeyFrames
			state._curAmp = not state.Graphs.ShakeAmplitude and 0 or Graph.QueryPointsWithTime(
				v9,
				state.Graphs.ShakeAmplitude,
				state.Seeds.ShakeAmplitude
			) or 0
			state._curRotAmp = not state.Graphs.ShakeRotAmplitude and 0 or Graph.QueryPointsWithTime(
				v9,
				state.Graphs.ShakeRotAmplitude,
				state.Seeds.ShakeRotAmplitude
			) or 0
		end

		local _falloff = state._falloff
		local v9

		if _falloff > 0 then
			local currentCamera = workspace.CurrentCamera
			v9 = not currentCamera and 0 or math.clamp(
				1 - (currentCamera.CFrame.Position - _originOverride).Magnitude / _falloff,
				0,
				1
			)
		else
			v9 = 1
		end

		local v10 = (state._curAmp or 0) * v9
		local v11 = math.rad(state._curRotAmp or 0) * v9

		if v10 ~= 0 or v11 ~= 0 then
			local v12 = effectiveElapsed * state._shakeFreq
			local _shakeSeed = state._shakeSeed
			Apply.accumulate(
				v10 * math.noise(v12, _shakeSeed, 0.17),
				v10 * math.noise(v12, _shakeSeed, 137.7),
				v10 * math.noise(v12, _shakeSeed, 291.3),
				v11 * math.noise(v12, _shakeSeed, 431.1),
				v11 * math.noise(v12, _shakeSeed, 557.5),
				v11 * math.noise(v12, _shakeSeed, 683.9)
			)
		end

		return false
	end

	function p._refreshCameraShakeAnimate(_, p2, p3)
		p2.Link = nil
		p2._shakeFreq = p3.ShakeFrequency or 10
		p2._falloff = p3.ShakeFalloff or 0
		p2._curAmp = nil
		p2._curRotAmp = nil
		p2.CurrentStep = -1
	end
end