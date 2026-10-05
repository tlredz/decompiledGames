local Particles = {}

local function alive(p)
	return p and p.Parent ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function delayIfAlive(p, emitDelay, fn)
	task.delay(emitDelay or 0.001, function()
		if p and p.Parent ~= nil then
			fn()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setEnabledForDuration(p, emitDuration)
	if not p or p.Parent == nil then
		return
	end

	p.Enabled = true
	task.wait(emitDuration)

	if p and p.Parent ~= nil then
		p.Enabled = false
	end
end

function Particles:Emit()
	if not self or self.Parent == nil then
		return
	end

	for _, emitter in self:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local v = emitter

		local function fn()
			v:Emit(v:GetAttribute("EmitCount"))
		end

		delayIfAlive(emitter, emitter:GetAttribute("EmitDelay"), fn) -- equivalent call inferred; original call site unknown
	end
end

function Particles.EnableEmit(folder)
	task.spawn(function()
		if not folder or folder.Parent == nil then
			return
		end

		for _, effect in folder:GetDescendants() do
			if effect:IsA("ParticleEmitter") then
				if effect:GetAttribute("EmitCount") then
					local v2 = effect

					local function fn()
						v2:Emit(v2:GetAttribute("EmitCount"))
					end

					delayIfAlive(effect, effect:GetAttribute("EmitDelay"), fn) -- equivalent call inferred; original call site unknown
				end

				if effect:GetAttribute("EmitDuration") then
					local v2 = effect

					local function fn()
						setEnabledForDuration(v2, v2:GetAttribute("EmitDuration")) -- equivalent call inferred; original call site unknown
					end

					delayIfAlive(effect, effect:GetAttribute("EmitDelay"), fn) -- equivalent call inferred; original call site unknown
				end
			elseif effect:IsA("Trail") and effect:GetAttribute("EmitDuration") then
				local v2 = effect

				local function fn()
					setEnabledForDuration(v2, v2:GetAttribute("EmitDuration")) -- equivalent call inferred; original call site unknown
				end

				delayIfAlive(effect, effect:GetAttribute("EmitDelay"), fn) -- equivalent call inferred; original call site unknown
			end
		end
	end)
end

function Particles.EmitTrail(instance)
	if instance:GetAttribute("EmitDuration") then
		local function fn()
			setEnabledForDuration(instance, instance:GetAttribute("EmitDuration")) -- equivalent call inferred; original call site unknown
		end

		delayIfAlive(instance, instance:GetAttribute("EmitDelay"), fn) -- equivalent call inferred; original call site unknown
	end
end

function Particles:EnableEmitSingle()
	task.spawn(function()
		if not self or self.Parent == nil then
			return
		end

		if self:IsA("Trail") then
			if self:GetAttribute("EmitDuration") then
				local function fn()
					setEnabledForDuration(self, self:GetAttribute("EmitDuration")) -- equivalent call inferred; original call site unknown
				end

				delayIfAlive(self, self:GetAttribute("EmitDelay"), fn) -- equivalent call inferred; original call site unknown
			end
		elseif self:IsA("ParticleEmitter") then
			if self:GetAttribute("EmitCount") then
				local function fn()
					self:Emit(self:GetAttribute("EmitCount"))
				end

				delayIfAlive(self, self:GetAttribute("EmitDelay"), fn) -- equivalent call inferred; original call site unknown
			end

			if self:GetAttribute("EmitDuration") then
				local function fn()
					setEnabledForDuration(self, self:GetAttribute("EmitDuration")) -- equivalent call inferred; original call site unknown
				end

				delayIfAlive(self, self:GetAttribute("EmitDelay"), fn) -- equivalent call inferred; original call site unknown
			end
		end
	end)
end

function Particles.EnableEmitChildrenAndRepeatForAttachments(instance)
	task.spawn(function()
		if not instance or instance.Parent == nil then
			return
		end

		for _, attachment in instance:GetChildren() do
			Particles.EnableEmitSingle(attachment)

			if attachment:IsA("Attachment") then
				Particles.EnableEmitChildrenAndRepeatForAttachments(attachment)
			end
		end
	end)
end

return Particles