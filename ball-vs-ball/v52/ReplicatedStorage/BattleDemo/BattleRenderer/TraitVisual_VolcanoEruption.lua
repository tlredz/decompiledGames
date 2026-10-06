local function setEntryFade(p, p2: number)
	for _, beam in p.beams do
		local numberSequenceKeypoints = {}

		for _, keypoint in beam.original.Keypoints do
			table.insert(
				numberSequenceKeypoints,
				NumberSequenceKeypoint.new(
					keypoint.Time,
					keypoint.Value + (1 - keypoint.Value) * p2,
					keypoint.Envelope * (1 - p2)
				)
			)
		end

		beam.beam.Transparency = NumberSequence.new(numberSequenceKeypoints)
	end
end

local TraitVisualVolcanoEruption = {}
TraitVisualVolcanoEruption.__index = TraitVisualVolcanoEruption

function TraitVisualVolcanoEruption.new(ctx)
	local self = setmetatable({}, TraitVisualVolcanoEruption)
	self._ctx = ctx
	self.flameEntries = {}
	self.warningEntries = {}
	self.lastPhase = {}
	return self
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playEntrySound(_ensureEntry)
	local sound = _ensureEntry.root:FindFirstChild("音效")

	if sound and sound:IsA("Sound") then
		sound:Stop()
		sound:Play()
	end
end

local function emitFlameVfx(_ensureEntry)
	local firstChild = _ensureEntry.model:FindFirstChild("装饰")
	local vFXTemplate = firstChild and firstChild:FindFirstChild("VFXTemplate")

	if not vFXTemplate then
		return
	end

	for _, emitter in ipairs(vFXTemplate:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")
		emitter:Emit(typeof(emitCount) ~= "number" and 1 or math.max(0, (math.floor(emitCount))))
	end
end

local function setEntryVisible(state, flag: boolean)
	if state.fadeStartedAt then
		state.fadeStartedAt = nil
		setEntryFade(state, 0)
	end

	if state.visible == flag then
		return
	end

	state.visible = flag
	local firstChild = state.model:FindFirstChild("装饰")
	local vFXTemplate = firstChild and firstChild:FindFirstChild("VFXTemplate")

	for _, effect in ipairs(state.model:GetDescendants()) do
		if not (effect:IsA("Beam") or effect:IsA("ParticleEmitter") and not (vFXTemplate and effect:IsDescendantOf(vFXTemplate))) then
			continue
		end

		effect.Enabled = flag
	end
end

function TraitVisualVolcanoEruption:_ensureEntry(p2, p3, p4: string, p5: number, p6: string)
	local v = p2[p4]

	if not v then
		v = {}
		p2[p4] = v
	end

	local v2 = v[p5]

	if v2 then
		return v2
	end

	local templateModel, root = self._ctx.cloneTemplateModel(p3, string.format("%s_%s%d", p4, p6, p5))
	local attachment = root:FindFirstChild("头")
	assert(attachment and attachment:IsA("Attachment"), string.format("火山素材 '%s' 的碰撞箱缺少 头 Attachment", p3.model.Name))
	local beams = {}

	for _, beam in ipairs(templateModel:GetDescendants()) do
		if beam:IsA("Beam") then
			table.insert(beams, {
				beam = beam,
				original = beam.Transparency
			})
		end
	end

	local v5 = {
		model = templateModel,
		root = root,
		head = attachment,
		visible = true,
		beams = beams,
		direction = nil,
		length = 0,
		fadeStartedAt = nil
	}
	setEntryVisible(v5, false)
	v[p5] = v5
	return v5
end

local function hideFrom(p, p2: string, p3: number)
	local v = p[p2]

	if not v then
		return
	end

	for k, v2 in v do
		if p3 <= k then
			setEntryVisible(v2, false)
		end
	end
end

function TraitVisualVolcanoEruption:_poseEntry(p2, vector: Vector3, vector2: Vector3)
	local magnitude = (vector2 - vector).Magnitude

	if magnitude <= 0.05 then
		return false
	end

	p2.model:PivotTo(CFrame.lookAt(vector, vector2, self._ctx.arenaNormal))
	p2.head.Position = Vector3.new(0, 0, -magnitude)
	return true
end

function TraitVisualVolcanoEruption:_placeEntry(p, vector: Vector3, vector2: Vector3)
	setEntryVisible(p, self:_poseEntry(p, vector, vector2))
end

function TraitVisualVolcanoEruption:_updateFlameFade(data)
	local flameEntry = self.flameEntries[data.id]

	if not flameEntry then
		return
	end

	local _ctx = self._ctx
	local flameFadeDuration = _ctx.flameFadeDuration
	local now = os.clock()
	local v = nil

	for _, v2 in flameEntry do
		if not v2.visible then
			continue
		end

		if flameFadeDuration <= 0 or v2.direction == nil then
			setEntryVisible(v2, false)
		else
			if not v2.fadeStartedAt then
				v2.fadeStartedAt = now
			end

			local v3 = (now - v2.fadeStartedAt) / flameFadeDuration

			if v3 >= 1 then
				setEntryVisible(v2, false)
			else
				v = v or _ctx.getBallMarkerHeight(data.id)
				local direction = v2.direction
				local v4 = data.position + direction * data.radius
				self:_poseEntry(v2, _ctx.worldFromArena(v4, v), (_ctx.worldFromArena(v4 + direction * v2.length, v)))
				setEntryFade(v2, v3)
			end
		end
	end
end

function TraitVisualVolcanoEruption:update(data)
	local _ctx = self._ctx
	local volcanoEruption = data.traits and data.traits.VolcanoEruption
	local phase = volcanoEruption and volcanoEruption.phase
	local flames = volcanoEruption and volcanoEruption.flames or {}
	local v

	if phase == "Windup" then
		v = _ctx.warningTemplateBundle ~= nil
	else
		v = false
	end

	local v2 = phase == "Erupting"
	local v3 = phase ~= self.lastPhase[data.id]
	self.lastPhase[data.id] = phase

	if not v then
		local warningEntry = self.warningEntries[data.id]

		if warningEntry then
			for k, v4 in warningEntry do
				if k >= 1 then
					setEntryVisible(v4, false)
				end
			end
		end
	end

	if not v2 then
		self:_updateFlameFade(data)
	end

	if not (v or v2) then
		return
	end

	local ballMarkerHeight = _ctx.getBallMarkerHeight(data.id)

	for k, flame in flames do
		local direction = flame.direction
		local v4 = data.position + direction * data.radius
		local worldFromArena = _ctx.worldFromArena(v4, ballMarkerHeight)

		if v then
			local warningTemplateBundle = _ctx.warningTemplateBundle
			local _ensureEntry = self:_ensureEntry(
				self.warningEntries,
				warningTemplateBundle,
				data.id,
				k,
				"VolcanoWarning"
			)
			self:_placeEntry(
				_ensureEntry,
				worldFromArena,
				(_ctx.worldFromArena(v4 + direction * (flame.maxLength or 0), ballMarkerHeight))
			)

			if k == 1 and v3 then
				playEntrySound(_ensureEntry) -- equivalent call inferred; original call site unknown
			end
		else
			local flameTemplateBundle = _ctx.flameTemplateBundle
			local _ensureEntry = self:_ensureEntry(self.flameEntries, flameTemplateBundle, data.id, k, "VolcanoFlame")
			local worldFromArena2 = _ctx.worldFromArena(v4 + direction * (flame.length or 0), ballMarkerHeight)
			local length = flame.length or 0
			_ensureEntry.direction = direction
			_ensureEntry.length = length
			self:_placeEntry(_ensureEntry, worldFromArena, worldFromArena2)

			if v3 then
				if k == 1 then
					playEntrySound(_ensureEntry) -- equivalent call inferred; original call site unknown
				end

				emitFlameVfx(_ensureEntry)
			end
		end
	end

	local warningEntries

	if v then
		warningEntries = self.warningEntries
	else
		warningEntries = self.flameEntries
	end

	local id = data.id
	local v4 = #flames + 1
	local warningEntry = warningEntries[id]

	if not warningEntry then
		return
	end

	for k, v5 in warningEntry do
		if v4 <= k then
			setEntryVisible(v5, false)
		end
	end
end

function TraitVisualVolcanoEruption:cleanupBall(p: string)
	for _, v in { self.flameEntries, self.warningEntries } do
		local v2 = v[p]

		if v2 then
			for _, v3 in v2 do
				v3.model:Destroy()
			end
		end

		v[p] = nil
	end

	self.lastPhase[p] = nil
end

function TraitVisualVolcanoEruption:reset()
	local v = {}

	for k in self.flameEntries do
		v[k] = true
	end

	for k in self.warningEntries do
		v[k] = true
	end

	for k in v do
		self:cleanupBall(k)
	end
end

return TraitVisualVolcanoEruption