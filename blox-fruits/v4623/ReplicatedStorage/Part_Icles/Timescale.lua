return function(p)
	function p:_seedTsOverride(instance)
		if not instance then
			return
		end

		self._tsOverride = instance:GetAttribute("_tsOverride")
		self._tsOverrideUntil = instance:GetAttribute("_tsOverrideUntil")
	end

	local function _setNativePE(emitter, timeScale, duration, p2)
		if emitter:GetAttribute("_origTimeScale") == nil then
			pcall(function()
				emitter:SetAttribute("_origTimeScale", emitter.TimeScale)
			end)
		end

		pcall(function()
			emitter.TimeScale = timeScale
		end)
		local v = (emitter:GetAttribute("_tsGen") or 0) + 1
		pcall(function()
			emitter:SetAttribute("_tsGen", v)
		end)

		if p2 == true then
			return
		end

		task.delay(duration, function()
			if not (emitter.Parent and emitter:GetAttribute("_tsGen") == v) then
				return
			end

			local _origTimeScale = emitter:GetAttribute("_origTimeScale")

			if _origTimeScale ~= nil then
				pcall(function()
					emitter.TimeScale = _origTimeScale
				end)
				pcall(function()
					emitter:SetAttribute("_origTimeScale", nil)
				end)
			end

			pcall(function()
				emitter:SetAttribute("_tsGen", nil)
			end)
		end)
	end

	local function _clearNativePE(emitter)
		local _origTimeScale = emitter:GetAttribute("_origTimeScale")

		if _origTimeScale ~= nil then
			pcall(function()
				emitter.TimeScale = _origTimeScale
			end)
			pcall(function()
				emitter:SetAttribute("_origTimeScale", nil)
			end)
		end

		local v = (emitter:GetAttribute("_tsGen") or 0) + 1
		pcall(function()
			emitter:SetAttribute("_tsGen", v)
		end)
		pcall(function()
			emitter:SetAttribute("_tsGen", nil)
		end)
	end

	function p:SetTimescale(emitter, tsOverride, value, p2)
		if not (emitter and typeof(tsOverride) == "number") then
			return
		end

		if p2 == true then
			value = nil
		elseif typeof(value) ~= "number" or not (value > 0) then
			self:ClearTimescale(emitter)
			return
		end

		if emitter:IsA("ParticleEmitter") then
			_setNativePE(emitter, tsOverride, value, p2)
			return
		end

		local tsOverrideUntil = p2 == true and 1e999 or os.clock() + value
		pcall(function()
			emitter:SetAttribute("_tsOverride", tsOverride)
			emitter:SetAttribute("_tsOverrideUntil", tsOverrideUntil)
		end)
		local activeEmits = self.ActiveEmits

		for i = 1, #activeEmits do
			local activeEmit = activeEmits[i]

			if not (activeEmit and activeEmit._sourceItem == emitter) then
				continue
			end

			activeEmit._tsOverride = tsOverride
			activeEmit._tsOverrideUntil = tsOverrideUntil
		end
	end

	function p:ClearTimescale(emitter)
		if not emitter then
			return
		end

		if emitter:IsA("ParticleEmitter") then
			_clearNativePE(emitter)
			return
		end

		pcall(function()
			emitter:SetAttribute("_tsOverride", nil)
			emitter:SetAttribute("_tsOverrideUntil", nil)
		end)
		local activeEmits = self.ActiveEmits

		for i = 1, #activeEmits do
			local activeEmit = activeEmits[i]

			if not (activeEmit and activeEmit._sourceItem == emitter) then
				continue
			end

			activeEmit._tsOverride = nil
			activeEmit._tsOverrideUntil = nil
		end
	end

	function p:AbsoluteSetTimescale(instance, p2, p3, p4)
		if not instance then
			return
		end

		if instance:GetAttribute("Transformed") then
			self:SetTimescale(instance, p2, p3, p4)
			return
		end

		if instance:IsA("ParticleEmitter") then
			self:SetTimescale(instance, p2, p3, p4)
			return
		end

		for _, part in instance:GetChildren() do
			if not (not instance:IsA("BasePart") or not part:IsA("BasePart") or part:GetAttribute("Transformed")) then
				continue
			end

			self:AbsoluteSetTimescale(part, p2, p3, p4)
		end
	end

	function p:AbsoluteClearTimescale(instance)
		if not instance then
			return
		end

		if instance:GetAttribute("Transformed") then
			self:ClearTimescale(instance)
			return
		end

		if instance:IsA("ParticleEmitter") then
			self:ClearTimescale(instance)
			return
		end

		for _, part in instance:GetChildren() do
			if not (not instance:IsA("BasePart") or not part:IsA("BasePart") or part:GetAttribute("Transformed")) then
				continue
			end

			self:AbsoluteClearTimescale(part)
		end
	end
end