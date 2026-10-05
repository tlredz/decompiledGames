local v = {
	Disable = function(p)
		local engine = p.engine
		local token = p.token
		token.Alive = false

		for _, loop in ipairs(token.Loops) do
			pcall(task.cancel, loop)
		end

		token.Loops = {}
		local activeEmits = engine.ActiveEmits

		for i = #activeEmits, 1, -1 do
			local activeEmit = activeEmits[i]

			if not (activeEmit and activeEmit._playToken == token) then
				continue
			end

			if activeEmit.VisualPart and activeEmit.VisualPart.Parent then
				engine:_releaseOrDestroy(activeEmit, activeEmit.VisualPart)
			end

			if activeEmit._scaleMapKeys and engine._parentScaleMap then
				for _, _scaleMapKey in ipairs(activeEmit._scaleMapKeys) do
					engine._parentScaleMap[_scaleMapKey] = nil
				end
			end

			local count = #activeEmits

			if i < count then
				activeEmits[i] = activeEmits[count]
			end

			activeEmits[count] = nil
		end

		for _, clone in ipairs(token.Clones) do
			if not (clone and clone.Parent) then
				continue
			end

			local v2 = clone
			pcall(function()
				v2:Destroy()
			end)
		end

		token.Clones = {}
	end,
	SoftDisable = function(p)
		local token = p.token
		token.Alive = false

		for _, loop in ipairs(token.Loops) do
			pcall(task.cancel, loop)
		end

		token.Loops = {}
	end,
	SetTimescale = function(p, tsOverride, value, p2)
		if typeof(tsOverride) ~= "number" then
			return
		end

		local engine = p.engine
		local token = p.token
		local v2

		if p2 == true then
			v2 = 1e999
		elseif typeof(value) == "number" and value > 0 then
			v2 = os.clock() + value
		else
			token.TsOverride = nil
			token.TsUntil = nil
		end

		if v2 == nil or not tsOverride then
			tsOverride = nil
		end

		token.TsOverride = tsOverride
		token.TsUntil = v2
		local activeEmits = engine.ActiveEmits

		for i = 1, #activeEmits do
			local activeEmit = activeEmits[i]

			if not (activeEmit and activeEmit._playToken == token) then
				continue
			end

			activeEmit._tsOverride = token.TsOverride
			activeEmit._tsOverrideUntil = v2
		end
	end,
	GetParticles = function(p)
		local activeEmits = p.engine.ActiveEmits
		local visualParts = {}

		for i = 1, #activeEmits do
			local activeEmit = activeEmits[i]

			if activeEmit and activeEmit._playToken == p.token and activeEmit.VisualPart then
				visualParts[#visualParts + 1] = activeEmit.VisualPart
			end
		end

		return visualParts
	end,
	GetPDatas = function(p)
		local activeEmits = p.engine.ActiveEmits
		local activeEmits2 = {}

		for i = 1, #activeEmits do
			local activeEmit = activeEmits[i]

			if activeEmit and activeEmit._playToken == p.token then
				activeEmits2[#activeEmits2 + 1] = activeEmit
			end
		end

		return activeEmits2
	end,
	IsAlive = function(p)
		local activeEmits = p.engine.ActiveEmits

		for i = 1, #activeEmits do
			if activeEmits[i] and activeEmits[i]._playToken == p.token then
				return true
			end
		end

		for _, loop in ipairs(p.token.Loops) do
			if coroutine.status(loop) ~= "dead" then
				return true
			end
		end

		return false
	end
}
local v2 = {
	__index = function(p, p2)
		if p2 == "Active" then
			return v.IsAlive(p)
		end

		return v[p2]
	end
}
return {
	new = function(engine, token)
		return (setmetatable({
			engine = engine,
			token = token,
			Duration = token.Duration
		}, v2))
	end
}