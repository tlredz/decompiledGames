local createVector = vector.create
local EventsPayload = {
	build = function(data, eventName, p2, worldCFrame)
		local position

		if worldCFrame then
			position = worldCFrame.Position or nil
		end

		local now = os.clock()
		local v = not data.StartTime and 0 or math.max(0, now - data.StartTime) or 0
		local lifeTime = data.LifeTime or 0
		local lifeProgress = not (lifeTime > 0) and 0 or math.min(1, v / lifeTime) or 0
		local timeRemaining = math.max(0, lifeTime - v)
		local speedMultiplier = data.SpeedMultiplier or 1
		local v4 = {
			SourceItem = data._sourceItem,
			Source = data._sourceItem,
			Particle = data.VisualPart,
			RenderTemplate = data.VisualPart,
			WorldCFrame = worldCFrame,
			WorldPosition = position,
			LifeProgress = lifeProgress,
			TimeRemaining = timeRemaining,
			StartTime = data.StartTime,
			LifeTime = lifeTime,
			SpeedMultiplier = speedMultiplier,
			ChainDepth = not data.EventChainCtx and 0 or data.EventChainCtx.Depth or 0,
			EmitCount = p2 and p2.EmitCount,
			_eventName = eventName
		}

		if eventName == "OnEmit" then
			v4.EmitPosition = position
			v4.EmitIndex = p2 and p2.EmitIndex
		elseif eventName == "OnDeath" then
			v4.DeathPosition = position

			if data.StartTime then
				v4.Age = math.max(0, now - data.StartTime)
				return v4
			end

			v4.Age = data.LifeTime
		elseif eventName == "OnDestruction" then
			v4.DeathPosition = position

			if data._lingerStartTime then
				v4.LingerElapsed = math.max(0, now - data._lingerStartTime)
				return v4
			else
				v4.LingerElapsed = 0
			end
		end

		return v4
	end,
	applyColor = function(state, p)
		if typeof(p) ~= "Color3" then
			return
		end

		state.SkipColor = true
		local visualPart = state.VisualPart

		if not (visualPart and visualPart.Parent) then
			return
		end

		local type2 = state.Type

		if type2 == "Part" or type2 == "Model" then
			if visualPart:IsA("BasePart") then
				pcall(function()
					visualPart.Color = p
				end)
			end

			local surfaceAppearance = visualPart.FindFirstChildOfClass and visualPart:FindFirstChildOfClass("SurfaceAppearance")

			if surfaceAppearance then
				pcall(function()
					surfaceAppearance.Color = p
				end)
			end
		elseif type2 == "Beam" or type2 == "TrailEmitter" or type2 == "BeamNative" then
			pcall(function()
				visualPart.Color = ColorSequence.new(p)
			end)
		elseif type2 == "PointLight" then
			pcall(function()
				visualPart.Color = p
			end)
		elseif type2 == "Highlight" then
			pcall(function()
				visualPart.FillColor = p
			end)
			pcall(function()
				visualPart.OutlineColor = p
			end)
		elseif type2 == "ImageLabel" then
			pcall(function()
				visualPart.ImageColor3 = p
			end)
		elseif type2 == "Screen" then
			if state.Kind == "ColorCorrection" then
				pcall(function()
					visualPart.TintColor = p
				end)
			elseif state.Kind == "Atmosphere" then
				pcall(function()
					visualPart.Color = p
				end)
			end
		else
			local _rig = (type2 == "Lightning" or type2 == "Rocks" or type2 == "Rope") and state._rig

			if _rig then
				local partCount = _rig.partCount or _rig.chunkCap
				pcall(function()
					for i = 1, partCount do
						_rig.parts[i].Color = p
					end
				end)
			end
		end
	end,
	applyTransparency = function(state, value)
		if type(value) ~= "number" then
			return
		end

		local v = math.max(0, (math.min(1, value)))
		state.SkipTransparency = true
		local visualPart = state.VisualPart

		if not (visualPart and visualPart.Parent) then
			return
		end

		local type2 = state.Type

		if type2 == "Part" or type2 == "Model" then
			if visualPart:IsA("BasePart") then
				pcall(function()
					visualPart.Transparency = v
				end)
			end

			local decal = visualPart.FindFirstChildOfClass and visualPart:FindFirstChildOfClass("Decal")

			if decal then
				pcall(function()
					decal.Transparency = v
				end)
			end
		elseif type2 == "Beam" or type2 == "TrailEmitter" or type2 == "BeamNative" then
			pcall(function()
				visualPart.Transparency = NumberSequence.new(v)
			end)
		elseif type2 == "PointLight" then
			local _baseBrightness = state._baseBrightness or visualPart.Brightness
			state._baseBrightness = _baseBrightness
			pcall(function()
				visualPart.Brightness = _baseBrightness * (1 - v)
			end)
		elseif type2 == "Highlight" then
			pcall(function()
				visualPart.FillTransparency = v
			end)
			pcall(function()
				visualPart.OutlineTransparency = v
			end)
		elseif type2 == "ImageLabel" then
			pcall(function()
				visualPart.ImageTransparency = v
			end)
		elseif type2 == "Lightning" or type2 == "Rocks" or type2 == "Rope" then
			state._curTrans = v
			local _rig = state._rig

			if _rig then
				local partCount = _rig.partCount or _rig.chunkCap
				pcall(function()
					for i = 1, partCount do
						_rig.parts[i].Transparency = v
					end
				end)
			end
		end
	end,
	attachSkipSetters = function(p, p2)
		function p.SetSkipColor(p3)
			p2.SkipColor = p3 == true
		end

		function p.SetSkipTransparency(p3)
			p2.SkipTransparency = p3 == true
		end

		function p.SetSkipSize(p3)
			p2.SkipSize = p3 == true
		end
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function _clearSettleState(p)
	p._settleEngaged = false
	p._restTimer = 0
	p._settleRotDamp = 1
	p._settleContactPos = nil
	p._settleSpawnHalf = nil
	p._lastHitNormal = nil
	p._collisionStopped = false
	p._displacementMirrorX = nil
	p._displacementMirrorY = nil
	p._displacementMirrorZ = nil
end

function EventsPayload:applyTeleport(cframe)
	if typeof(cframe) ~= "CFrame" then
		return
	end

	_clearSettleState(self) -- equivalent call inferred; original call site unknown
	local visualPart = self.VisualPart

	if not (visualPart and visualPart.Parent) then
		return
	end

	local type2 = self.Type

	if type2 == "Part" then
		pcall(function()
			visualPart.CFrame = cframe
		end)
	elseif type2 == "Attachment" then
		local parent = visualPart.Parent

		if parent and parent:IsA("BasePart") then
			pcall(function()
				visualPart.CFrame = parent.CFrame:ToObjectSpace(cframe)
			end)
		else
			pcall(function()
				visualPart.CFrame = cframe
			end)
		end
	elseif type2 == "Model" then
		pcall(function()
			visualPart:PivotTo(cframe)
		end)
	else
		return
	end

	if type2 == "Attachment" then
		local parent = visualPart.Parent

		if parent and parent:IsA("BasePart") then
			self.LocalCF = parent.CFrame:ToObjectSpace(cframe)
		else
			self.LocalCF = cframe
		end
	else
		local link = self.Link

		if link and link.Parent then
			local worldCFrame

			if link:IsA("Attachment") then
				worldCFrame = link.WorldCFrame
			elseif link:IsA("Model") then
				worldCFrame = link:GetPivot()
			else
				worldCFrame = link.CFrame
			end

			self.LocalCF = worldCFrame:ToObjectSpace(cframe)
		else
			self.LocalCF = cframe
		end
	end

	self._localWorldCF = self.LocalCF

	if type2 == "Attachment" then
		self._postUpdateCF = visualPart.CFrame
	elseif type2 == "Model" then
		self._postUpdateCF = visualPart:GetPivot()
	else
		self._postUpdateCF = cframe
	end

	self.CurrentPosition = cframe.Position
	self.LastHitCheckPos = cframe.Position
	self._lastOrientPos = nil
end

function EventsPayload:applyAddSpin(p2)
	if typeof(p2) ~= "Vector3" then
		return
	end

	self._spinRate = (self._spinRate or createVector(0, 0, 0)) + p2
end

function EventsPayload:applyAddImpulse(p2)
	if typeof(p2) ~= "Vector3" then
		return
	end

	_clearSettleState(self) -- equivalent call inferred; original call site unknown
	self._accelVel = (self._accelVel or createVector(0, 0, 0)) + p2
end

function EventsPayload:applyFreezeTime(p2)
	self._timeFrozen = p2 == true
	self._freezeTimeExplicit = p2 == true
end

function EventsPayload:applyPause(duration)
	if type(duration) ~= "number" or duration <= 0 then
		return
	end

	self._timeFrozen = true
	local pauseGen = (self._pauseGen or 0) + 1
	self._pauseGen = pauseGen
	task.delay(duration, function()
		if self._pauseGen == pauseGen and not self._freezeTimeExplicit then
			self._timeFrozen = false
		end
	end)
end

function EventsPayload:applySetSize(size)
	self.SkipSize = true
	local visualPart = self.VisualPart

	if not (visualPart and visualPart.Parent) then
		return
	end

	local type2 = self.Type

	if type2 == "Part" or type2 == "Model" then
		if typeof(size) == "Vector3" and visualPart:IsA("BasePart") then
			pcall(function()
				visualPart.Size = size
			end)
		elseif typeof(size) == "Vector3" and type2 == "Model" then
			pcall(function()
				visualPart:ScaleTo((math.max(0.001, size.X)))
			end)
		end
	elseif type2 == "ImageLabel" and typeof(size) == "UDim2" then
		pcall(function()
			visualPart.Size = size
		end)
	end
end

function EventsPayload:applySetVelocity(p2)
	if p2 == nil then
		self._speedOverride = nil
		return
	end

	if typeof(p2) ~= "Vector3" then
		return
	end

	_clearSettleState(self) -- equivalent call inferred; original call site unknown
	local magnitude = p2.Magnitude

	if magnitude < 0.0001 then
		self.SpeedMultiplier = 0
		self._speedOverride = 0
	else
		self.BaseDirection = p2 / magnitude
		self._speedOverride = magnitude
	end
end

function EventsPayload:applyResurrect()
	self._killedManually = false
	self._forceDead = false
end

function EventsPayload:attachAdvancedSetters(p2)
	function self.AddSpin(p3)
		EventsPayload.applyAddSpin(p2, p3)
	end

	function self.AddImpulse(p3)
		EventsPayload.applyAddImpulse(p2, p3)
	end

	function self.FreezeTime(p3)
		EventsPayload.applyFreezeTime(p2, p3)
	end

	function self.Pause(p3)
		EventsPayload.applyPause(p2, p3)
	end

	function self.SetSize(p3)
		EventsPayload.applySetSize(p2, p3)
	end

	function self.SetVelocity(p3)
		EventsPayload.applySetVelocity(p2, p3)
	end

	function self.Resurrect()
		EventsPayload.applyResurrect(p2)
	end
end

return EventsPayload