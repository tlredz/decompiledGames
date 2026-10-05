local Particles = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function alive(instance)
	return instance and instance.Parent and instance:IsDescendantOf(game)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function delay_for(p, emitDelay, fn)
	task.delay(emitDelay or 0.001, function()
		if alive(p) then
			fn()
		end
	end)
end

local function emit_one(emitter)
	if emitter:IsA("ParticleEmitter") and emitter:GetAttribute("EmitCount") then
		local function fn()
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		delay_for(emitter, emitter:GetAttribute("EmitDelay"), fn) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enable_for_duration(instance)
	local emitDuration = instance:GetAttribute("EmitDuration")

	if emitDuration then
		local function fn()
			instance.Enabled = true
			task.wait(emitDuration)

			if alive(instance) then
				instance.Enabled = false
			end
		end

		delay_for(instance, instance:GetAttribute("EmitDelay"), fn) -- equivalent call inferred; original call site unknown
	end
end

function Particles:Emit()
	if alive(self) then
		for _, descendant in self:GetDescendants() do
			emit_one(descendant)
		end
	end
end

function Particles.EnableEmit(folder)
	task.spawn(function()
		if not alive(folder) then
			return
		end

		for _, effect in folder:GetDescendants() do
			if effect:IsA("ParticleEmitter") then
				emit_one(effect)
				enable_for_duration(effect) -- equivalent call inferred; original call site unknown
			elseif effect:IsA("Trail") then
				enable_for_duration(effect) -- equivalent call inferred; original call site unknown
			end
		end
	end)
end

function Particles.EmitTrail(instance)
	enable_for_duration(instance) -- equivalent call inferred; original call site unknown
end

function Particles.EnableEmitSingle(effect)
	task.spawn(function()
		if not alive(effect) then
			return
		end

		if effect:IsA("Trail") then
			enable_for_duration(effect) -- equivalent call inferred; original call site unknown
		elseif effect:IsA("ParticleEmitter") then
			emit_one(effect)
			enable_for_duration(effect) -- equivalent call inferred; original call site unknown
		end
	end)
end

function Particles.EnableEmitChildrenAndRepeatForAttachments(instance)
	task.spawn(function()
		if not alive(instance) then
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