local function EmitOnce(instance)
	local timeScale = instance.TimeScale

	if timeScale <= 0 then
		return 0
	end

	local rate = instance.Rate
	local emitCount = instance:GetAttribute("EmitCount")

	if type(emitCount) == "number" then
		rate = emitCount
	end

	local v = math.floor(rate)
	local v2 = rate - v

	if v2 > 0 and math.random() < v2 then
		v += 1
	end

	if v < 1 then
		return 0
	end

	local emitDelay = instance:GetAttribute("EmitDelay")
	local v3 = type(emitDelay) ~= "number" and 0 or emitDelay

	if v3 == 1e999 then
		return 0
	end

	local v4 = math.max(v3, 0)
	task.delay(v4, function()
		instance:Emit(v)
	end)
	return v4 + instance.Lifetime.Max / timeScale
end

return EmitOnce