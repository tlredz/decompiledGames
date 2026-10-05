local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local v = pcall(function()
	return Selection:Get()
end)
local preRender = RunService:IsClient() and RunService.PreRender or RunService.Heartbeat
local TypeRegistry = require(script.Parent.TypeRegistry)
local Particles = require(script.Parent.Particles)
local Events = require(script.Parent.Events)
local Pool = require(script.Parent.Pool)
local EvenCycle = require(script.Parent.EvenCycle)
return function(state)
	local function cancelAnimation(data, p)
		local activeAnimate = data.ActiveAnimates[p]

		if not activeAnimate then
			return
		end

		if (activeAnimate.Type == "Beam" or activeAnimate.Type == "Highlight" or activeAnimate.Type == "TrailEmitter") and activeAnimate.VisualPart and activeAnimate.VisualPart.Parent then
			local beamSnapshot = activeAnimate.BeamSnapshot or activeAnimate.HighlightSnapshot or activeAnimate.TrailEmitterSnapshot

			if beamSnapshot then
				pcall(function()
					for k, v2 in pairs(beamSnapshot) do
						activeAnimate.VisualPart[k] = v2
					end
				end)
			end

			activeAnimate.VisualPart.Enabled = false
		end

		if activeAnimate.InitialAnchorCF and activeAnimate.VisualPart and activeAnimate.VisualPart.Parent then
			if activeAnimate.Type == "Model" then
				activeAnimate.VisualPart:PivotTo(activeAnimate.InitialAnchorCF)

				if activeAnimate.InitialScale then
					pcall(function()
						activeAnimate.VisualPart:ScaleTo(activeAnimate.InitialScale)
					end)
				end
			elseif activeAnimate.Type ~= "Beam" then
				activeAnimate.VisualPart.CFrame = activeAnimate.InitialAnchorCF
			end
		end

		if (activeAnimate.Type == "Part" or activeAnimate.Type == "Attachment") and activeAnimate.VisualPart and activeAnimate.VisualPart.Parent then
			pcall(function()
				activeAnimate.VisualPart.Transparency = 1
				local decal = activeAnimate.HasDecal and activeAnimate.VisualPart:FindFirstChildOfClass("Decal")

				if decal then
					decal.Transparency = 1
				end
			end)
		end

		if (activeAnimate.Type == "Screen" or activeAnimate.Type == "ImageLabel" or activeAnimate.Type == "Lightning" or activeAnimate.Type == "Rocks" or activeAnimate.Type == "Rope") and activeAnimate.VisualPart then
			pcall(function()
				activeAnimate.VisualPart:Destroy()
			end)
		end

		if activeAnimate._scaleMapKeys and data._parentScaleMap then
			for _, _scaleMapKey in ipairs(activeAnimate._scaleMapKeys) do
				data._parentScaleMap[_scaleMapKey] = nil
			end
		end

		for i = #data.ActiveEmits, 1, -1 do
			if data.ActiveEmits[i] ~= activeAnimate then
				continue
			end

			local count = #data.ActiveEmits

			if i < count then
				data.ActiveEmits[i] = data.ActiveEmits[count]
			end

			data.ActiveEmits[count] = nil
			break
		end

		data.ActiveAnimates[p] = nil
	end

	function state._cancelAnimation(p, p2)
		cancelAnimation(p, p2)
	end

	local function haltEmission(object, folder, p)
		if state.ActiveLoops[folder] then
			task.cancel(state.ActiveLoops[folder])
			state.ActiveLoops[folder] = nil
		end

		local activeChainLoop = state.ActiveChainLoops[folder]

		if activeChainLoop then
			for _, v2 in ipairs(activeChainLoop) do
				pcall(task.cancel, v2)
			end

			state.ActiveChainLoops[folder] = nil
		end

		folder:SetAttribute("AnimateLoop", false)
		local v2 = (folder:GetAttribute("_emitGen") or 0) + 1
		pcall(function()
			folder:SetAttribute("_emitGen", v2)
		end)

		if p then
			cancelAnimation(object, folder)
		end

		local config = TypeRegistry.getConfig(folder)

		if config then
			config:SetAttribute("Enabled", false)
		end

		pcall(function()
			folder:SetAttribute("_PartIclePlaying", nil)
		end)
		EvenCycle.clear(object._evenCycleStore, folder:GetAttribute("_EvenCycleId") or folder)

		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:GetAttribute("Transformed") then
				if p then
					object:Disable(descendant)
				else
					object:SoftDisable(descendant)
				end
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
				if p then
					Particles.CancelNative(descendant)
				else
					local v3 = descendant
					pcall(function()
						v3.Enabled = false
					end)
				end
			elseif descendant:IsA("Beam") or descendant:IsA("Highlight") then
				local v3 = descendant
				pcall(function()
					v3.Enabled = false
				end)
			end
		end
	end

	function state:Disable(p)
		if not p then
			return
		end

		local ChangeHistoryService

		if v then
			local RunService2 = game:GetService("RunService")
			ChangeHistoryService = RunService2:IsEdit() and game:GetService("ChangeHistoryService") or nil
		end

		if ChangeHistoryService then
			ChangeHistoryService:SetWaypoint("Part-Icles: Before Disable")
		end

		haltEmission(self, p, true)
		local activeEmits = self.ActiveEmits

		for i = #activeEmits, 1, -1 do
			local activeEmit = activeEmits[i]

			if not (activeEmit and activeEmit._sourceItem == p) then
				continue
			end

			if activeEmit.VisualPart and activeEmit.VisualPart.Parent then
				self:_releaseOrDestroy(activeEmit, activeEmit.VisualPart)
			end

			if activeEmit._scaleMapKeys and self._parentScaleMap then
				for _, _scaleMapKey in ipairs(activeEmit._scaleMapKeys) do
					self._parentScaleMap[_scaleMapKey] = nil
				end
			end

			local count = #activeEmits

			if i < count then
				activeEmits[i] = activeEmits[count]
			end

			activeEmits[count] = nil
		end

		if self._lingerByItem and self._lingerByItem[p] then
			for _, v2 in ipairs(self._lingerByItem[p]) do
				if not v2 then
					continue
				end

				local v3 = false
				local v4 = v2
				pcall(function()
					v3 = v4:GetAttribute("_lingerCounted") == true
				end)

				if v3 then
					self._lingerVisualCount = math.max(0, (self._lingerVisualCount or 0) - 1)
					local v5 = v2
					pcall(function()
						v5:SetAttribute("_lingerCounted", nil)
					end)
				end

				if not v2.Parent then
					continue
				end

				local v5 = v2
				pcall(function()
					v5:Destroy()
				end)
			end

			self._lingerByItem[p] = nil
		end

		if ChangeHistoryService then
			ChangeHistoryService:SetWaypoint("Part-Icles: Disable")
		end
	end

	local function _hasTransformedAncestor(effect, folder)
		local parent = effect.Parent

		while parent and parent ~= folder do
			if parent:GetAttribute("Transformed") then
				return true
			else
				parent = parent.Parent
			end
		end

		return false
	end

	function state:AbsoluteEnable(folder, p)
		if not folder then
			return
		end

		if folder:GetAttribute("Transformed") then
			pcall(function()
				folder:SetAttribute("_PartIclePlaying", true)
			end)
			local config = TypeRegistry.getConfig(folder)

			if config then
				config:SetAttribute("Enabled", true)
			end

			self:Enable(folder, nil, 1e999)
		elseif folder:IsA("ParticleEmitter") or folder:IsA("Trail") or folder:IsA("Beam") then
			if p then
				return
			end

			pcall(function()
				folder.Enabled = true
			end)
		else
			local v2

			if folder:IsA("BasePart") or folder:IsA("Attachment") then
				v2 = not p
			else
				v2 = folder:IsA("Model") and not p
			end

			if v2 then
				for _, effect in ipairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					if effect:GetAttribute("Transformed") or _hasTransformedAncestor(effect, folder) then
						continue
					end

					local v3 = effect
					pcall(function()
						v3.Enabled = true
					end)
				end
			end

			local v3 = v2 or p

			for _, part in folder:GetChildren() do
				if not (not folder:IsA("BasePart") or not part:IsA("BasePart") or part:GetAttribute("Transformed")) then
					continue
				end

				self:AbsoluteEnable(part, v3)
			end
		end
	end

	function state:SoftDisable(p2)
		if not p2 then
			return
		end

		local ChangeHistoryService

		if v then
			local RunService2 = game:GetService("RunService")
			ChangeHistoryService = RunService2:IsEdit() and game:GetService("ChangeHistoryService") or nil
		end

		if ChangeHistoryService then
			ChangeHistoryService:SetWaypoint("Part-Icles: Before Soft Disable")
		end

		haltEmission(self, p2, false)

		if ChangeHistoryService then
			ChangeHistoryService:SetWaypoint("Part-Icles: Soft Disable")
		end
	end

	function state:AbsoluteDisable(folder, p)
		if not folder then
			return
		end

		if folder:GetAttribute("Transformed") then
			self:SoftDisable(folder)
		elseif folder:IsA("ParticleEmitter") or folder:IsA("Trail") or folder:IsA("Beam") then
			if p then
				return
			end

			pcall(function()
				folder.Enabled = false
			end)
		else
			local v2

			if folder:IsA("BasePart") or folder:IsA("Attachment") then
				v2 = not p
			else
				v2 = folder:IsA("Model") and not p
			end

			if v2 then
				for _, effect in ipairs(folder:GetDescendants()) do
					if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam")) then
						continue
					end

					if effect:GetAttribute("Transformed") or _hasTransformedAncestor(effect, folder) then
						continue
					end

					local v3 = effect
					pcall(function()
						v3.Enabled = false
					end)
				end
			end

			local v3 = v2 or p

			for _, part in folder:GetChildren() do
				if not (not folder:IsA("BasePart") or not part:IsA("BasePart") or part:GetAttribute("Transformed")) then
					continue
				end

				self:AbsoluteDisable(part, v3)
			end
		end
	end

	function state:EmitAnimate(instance, p, p2)
		self:_warnIfNotActivated("EmitAnimate")

		if (instance:IsA("BlurEffect") or instance:IsA("BloomEffect") or instance:IsA("ColorCorrectionEffect") or instance:IsA("Atmosphere") or instance:IsA("ImageLabel") or state._isLightning(instance) or state._isCameraShake(instance) or state._isRocks(instance) or state._isRope(instance)) and self.ActiveAnimates[instance] then
			return
		end

		cancelAnimation(self, instance)

		if instance:IsA("Beam") then
			self:EmitBeamAnimate(instance, p, p2)
		elseif instance:IsA("Trail") and instance:FindFirstChild("PartIcleProperties") then
			self:EmitTrailAnimate(instance, p, p2)
		elseif instance:IsA("Highlight") then
			self:EmitHighlightAnimate(instance, p, p2)
		elseif instance:IsA("Attachment") then
			self:EmitAttachmentAnimate(instance, p, p2)
		elseif instance:IsA("Model") then
			self:EmitModelAnimate(instance, p, p2)
		elseif instance:IsA("BlurEffect") then
			self:EmitBlurAnimate(instance, p, p2)
		elseif instance:IsA("BloomEffect") then
			self:EmitBloomAnimate(instance, p, p2)
		elseif instance:IsA("ColorCorrectionEffect") then
			self:EmitColorCorrectionAnimate(instance, p, p2)
		elseif instance:IsA("Atmosphere") then
			self:EmitAtmosphereAnimate(instance, p, p2)
		elseif instance:IsA("ImageLabel") then
			self:EmitImageLabelAnimate(instance, p, p2)
		elseif state._isLightning(instance) then
			self:EmitLightningAnimate(instance, p, p2)
		elseif state._isCameraShake(instance) then
			self:EmitCameraShakeAnimate(instance, p, p2)
		elseif state._isRocks(instance) then
			self:EmitRocksAnimate(instance, p, p2)
		elseif state._isRope(instance) then
			self:EmitRopeAnimate(instance, p, p2)
		elseif instance:IsA("BasePart") then
			self:EmitPartAnimate(instance, p, p2)
		end
	end

	function state:EnableEmit(instance, p, data)
		self:_warnIfNotActivated("EnableEmit")
		local emissionMode = instance:GetAttribute("EmissionMode") or "Emit"
		local emitCount = instance:GetAttribute("EmitCount")
		local v2 = emitCount == nil and 1 or emitCount
		local v3 = v2 <= 0 and data and data.EventDriven and 1 or v2
		local emitDelay = instance:GetAttribute("EmitDelay") or 0
		local v4 = Particles.parseDuration(instance:GetAttribute("EmitDuration")) or 0

		if emissionMode ~= "Animate" and v3 <= 0 and v4 <= 0 then
			return
		end

		local v5 = data and data.ChainCtx ~= nil
		local v6 = data and data._parentAlive ~= nil
		local v7 = v5 or v6 or v4 <= 0

		if not (v5 or v6) then
			EvenCycle.ensureIds(instance)
		end

		local v8

		if v7 then
			v8 = nil
		else
			v8 = (instance:GetAttribute("_emitGen") or 0) + 1
			pcall(function()
				instance:SetAttribute("_emitGen", v8)
			end)
		end

		local _engineGen = self._engineGen or 0

		local function genStillCurrent()
			if self.Connection == nil or (self._engineGen or 0) ~= _engineGen or not instance.Parent or not v7 and (instance:GetAttribute("_emitGen") or 0) ~= v8 then
				return false
			end

			return not (data and data._parentAlive and not data._parentAlive[1])
		end

		if emissionMode == "Animate" then
			local function doAnimate()
				local v9

				if self.Connection == nil or (self._engineGen or 0) ~= _engineGen or not instance.Parent or not v7 and (instance:GetAttribute("_emitGen") or 0) ~= v8 then
					v9 = false
				else
					v9 = (not data or not data._parentAlive or data._parentAlive[1]) and true or false
				end

				if not v9 then
					return
				end

				if v4 > 0 then
					instance:SetAttribute("AnimateLoop", true)
					task.delay(v4, function()
						local v10

						if self.Connection == nil or (self._engineGen or 0) ~= _engineGen or not instance.Parent or not v7 and (instance:GetAttribute("_emitGen") or 0) ~= v8 then
							v10 = false
						else
							v10 = (not data or not data._parentAlive or data._parentAlive[1]) and true or false
						end

						if not v10 then
							return
						end

						if instance:GetAttribute("AnimateLoop") then
							instance:SetAttribute("AnimateLoop", false)
						end
					end)
				end

				self:EmitAnimate(instance, p, data)
			end

			if emitDelay > 0 then
				task.delay(emitDelay, doAnimate)
			else
				doAnimate()
			end
		else
			local config = TypeRegistry.getConfig(instance)

			local function doEmit()
				local v9

				if self.Connection == nil or (self._engineGen or 0) ~= _engineGen or not instance.Parent or not v7 and (instance:GetAttribute("_emitGen") or 0) ~= v8 then
					v9 = false
				else
					v9 = (not data or not data._parentAlive or data._parentAlive[1]) and true or false
				end

				if not v9 then
					return
				end

				local evenFlags, v10 = EvenCycle.evenFlags(config)
				local v11, v12, v13, v14

				if evenFlags or v10 then
					local _EvenCycleId = instance:GetAttribute("_EvenCycleId") or instance
					local rate = config and config:GetAttribute("Rate") or 10
					v11, v12, v13, v14 = EvenCycle.advance(
						self._evenCycleStore,
						_EvenCycleId,
						config,
						rate,
						evenFlags,
						v10
					)
				else
					v11 = 1
					v12 = 0
					v13 = 1
					v14 = 0
				end

				for i = 1, v3 do
					self:Emit(instance, p, Events.withEvenOffset(data, i, v3, v11, v12, v13, v14))
				end

				if v4 > 0 then
					if v5 or v6 then
						self:Enable(instance, p, v4, data)
						return
					end

					instance:SetAttribute("_PartIclePlaying", true)

					if config then
						config:SetAttribute("Enabled", true)
					end

					self:Enable(instance, p, v4, data)
					task.delay(v4, function()
						local v15

						if self.Connection == nil or (self._engineGen or 0) ~= _engineGen or not instance.Parent or not v7 and (instance:GetAttribute("_emitGen") or 0) ~= v8 then
							v15 = false
						else
							v15 = (not data or not data._parentAlive or data._parentAlive[1]) and true or false
						end

						if not v15 then
							return
						end

						if config and config.Parent then
							config:SetAttribute("Enabled", false)
						end

						instance:SetAttribute("_PartIclePlaying", nil)
					end)
				end
			end

			if emitDelay > 0 then
				task.delay(emitDelay, doEmit)
			else
				doEmit()
			end
		end
	end

	function state:Enable(instance, p, value, data)
		self:_warnIfNotActivated("Enable")
		local data2 = self:GetData(instance)

		if not data2 then
			return
		end

		if (instance:GetAttribute("EmissionMode") or "Emit") == "Animate" then
			instance:SetAttribute("AnimateLoop", true)
			self:EmitAnimate(instance, p, data)
		else
			local v2 = value or 1e999
			local config = TypeRegistry.getConfig(instance)
			local v3 = data and data.ChainCtx ~= nil
			local v4 = data and data._parentAlive ~= nil
			local _playToken = data and data._playToken
			local v5 = _playToken ~= nil
			local v6 = v3 or v4 or v5
			local _engineGen = self._engineGen or 0

			local function loopBody()
				local lastTime = os.clock()
				local v7 = 0
				local _EvenCycleId = instance:GetAttribute("_EvenCycleId")

				if not _EvenCycleId then
					_EvenCycleId = instance
				end

				while (not v6 or (self._engineGen or 0) == _engineGen) and (not v4 or not data._parentAlive or data._parentAlive[1]) and (not v5 or _playToken.Alive) do
					if instance and instance.Parent and not (v2 <= os.clock() - lastTime) then
						if not (v6 or data2.CheckEnabled()) then
							state.ActiveLoops[instance] = nil
							break
						end

						local v9 = preRender:Wait()

						if isStudio and v and not state._focused and (#Selection:Get() == 0 or state._unfocusedAt > 0 and os.clock() - state._unfocusedAt > 600) then
							v7 = 0
							continue
						else
							local rate = config and config:GetAttribute("Rate") or 10

							if rate <= 0 then
								v7 = 0
								continue
							else
								local v10 = 1 / rate
								v7 += v9
								local v11 = (data2.PosXEven or data2.PosYEven or data2.PosZEven) == true
								local v12

								if (data2.RotXEven or data2.RotYEven or data2.RotZEven) == true then
									v12 = true
								else
									v12 = false
								end

								while v10 <= v7 do
									v7 -= v10

									if v11 or v12 then
										local v13, v14, v15, v16 = EvenCycle.advance(
											self._evenCycleStore,
											_EvenCycleId,
											config,
											rate,
											v11,
											v12
										)
										self:Emit(instance, p, Events.withEvenOffset(data, 1, 1, v13, v14, v15, v16))
									else
										self:Emit(instance, p, data)
									end
								end

								continue
							end
						end
					end

					if v6 then
						break
					end

					state.ActiveLoops[instance] = nil
					break
				end
			end

			if v6 then
				local thread = task.spawn(function()
					loopBody()
					local thread2 = coroutine.running()
					local activeChainLoop = state.ActiveChainLoops[instance]

					if not activeChainLoop then
						return
					end

					for i = #activeChainLoop, 1, -1 do
						if activeChainLoop[i] ~= thread2 then
							continue
						end

						table.remove(activeChainLoop, i)
						break
					end

					if #activeChainLoop == 0 then
						state.ActiveChainLoops[instance] = nil
					end
				end)
				local threads = state.ActiveChainLoops[instance]

				if not threads then
					threads = {}
					state.ActiveChainLoops[instance] = threads
				end

				table.insert(threads, thread)

				if v5 then
					table.insert(_playToken.Loops, thread)
				end
			else
				if state.ActiveLoops[instance] then
					task.cancel(state.ActiveLoops[instance])
				end

				state.ActiveLoops[instance] = task.spawn(loopBody)
			end
		end
	end

	local v2 = {}
	local v3 = false

	function state:EnableEmitAt(instance, eventOriginCF, options)
		if not (instance and instance.Parent and eventOriginCF) then
			return
		end

		if instance:IsA("BasePart") or instance:IsA("Attachment") or instance:IsA("Model") then
			if (instance:GetAttribute("EmissionMode") or "Emit") == "Animate" then
				if not v3 then
					v3 = true
					warn("[Part-Icles] EnableEmitAt does not support Animate-mode targets in v1; use EmitMode=AtTarget for Animate sources. Emit skipped.")
				end
			else
				local v4 = options or {}

				if v4.Link ~= nil then
					self:SetLink(instance, v4.Link, v4.LinkMode or "Weld")
				end

				if v4.EmitParent ~= nil then
					self:SetEmitParent(instance, v4.EmitParent)
				end

				self:EnableEmit(instance, nil, {
					ChainCtx = v4.ChainCtx,
					EventOriginCF = eventOriginCF,
					EventOriginResolver = v4.OriginResolver,
					UseFullOrigin = v4.UseFullOrigin ~= false,
					IgnoreLink = v4.IgnoreLink == true,
					EventDriven = v4.EventDriven == true
				})
			end
		else
			local className = instance.ClassName

			if not v2[className] then
				v2[className] = true
				warn(("[Part-Icles] EnableEmitAt does not support %s targets (origin override is BasePart/Attachment/Model only). Emit skipped."):format(className))
			end
		end
	end

	function state._fireOnDeath(p, data)
		if data.Events and data.Events.OnDeath and (not data._killedManually or data._fireOnDeathOverride) then
			Events.fire(p, data, "OnDeath", data.EventChainCtx, nil)
		end
	end

	function state._fireOnDestruction(p, p2, p3)
		if p2.Events and p2.Events.OnDestruction and p3 and p3.Parent then
			Events.fire(p, p2, "OnDestruction", p2.EventChainCtx, nil)
		end
	end

	function state:_releaseOrDestroy(state2, instance)
		if state2._extraLights then
			for _, _extraLight in ipairs(state2._extraLights) do
				local v4 = _extraLight
				pcall(function()
					v4:Destroy()
				end)
			end

			state2._extraLights = nil
		end

		if not (instance and instance.Parent) then
			return
		end

		if state2.IsAnimate or not (state2._sourceRT and state2._poolKind) then
			pcall(function()
				instance:Destroy()
			end)
			return
		end

		local rate = nil
		local _sourceItem = state2._sourceItem

		if _sourceItem and _sourceItem.Parent then
			local config = TypeRegistry.getConfig(_sourceItem)

			if config then
				rate = config:GetAttribute("Rate")
			end
		end

		Pool.release(instance, state2._sourceRT, state2._poolKind, rate)
	end

	function state:_makeAliveCheck()
		local _engineGen = self._engineGen or 0
		return function()
			return self.Connection ~= nil and (self._engineGen or 0) == _engineGen
		end
	end

	function state._fireAnimateCycleRestartEvents(p, state2)
		if state2.Events and state2.Events.OnHit then
			state2.LastHitCheckPos = Events.getWorldPosition(state2)
			state2.LastHitCheckTime = nil
		end

		if state2.Events and state2.Events.OnEmit then
			local payload = Events.makePayload(p, state2, "OnEmit", {
				ChainCtx = state2.EventChainCtx,
				EmitIndex = nil
			})
			Events.fire(p, state2, "OnEmit", state2.EventChainCtx, payload)
		end
	end

	function state._killParticle(_, state2, options)
		state2._killedManually = true
		state2._fireOnDeathOverride = (options or {}).fireOnDeath == true
		state2._forceDead = true
		state2.PartLife = 0
		local _sourceItem = state2.IsAnimate and state2._sourceItem

		if _sourceItem then
			pcall(function()
				_sourceItem:SetAttribute("AnimateLoop", false)
				local config = TypeRegistry.getConfig(_sourceItem)

				if config then
					config:SetAttribute("Enabled", false)
				end
			end)
		end
	end
end