local Graph = require(script.Parent.Graph)
local Duration = {}

local function resolveDuration(emitDuration)
	if emitDuration == nil then
		return 0
	end

	if typeof(emitDuration) == "number" then
		return emitDuration
	end

	local v = {}

	for k in tostring(emitDuration):gmatch("[^,]+") do
		local v2 = tonumber(k:match("^%s*(.-)%s*$"))

		if v2 then
			table.insert(v, v2)
		end
	end

	if #v == 0 then
		return 0
	end

	if #v == 1 then
		return v[1]
	end

	return (math.max(v[1], v[2]))
end

function Duration.computeTrueLifetime(p, p2, options)
	if not p or p <= 0 then
		return 0
	end

	if not p2 then
		return p
	end

	if Graph.IsStatic(p2) then
		local staticValue = Graph.GetStaticValue(p2, 1)

		if staticValue == 1 then
			return p
		elseif staticValue == 0 then
			return nil
		end

		if staticValue > 0 then
			return p / staticValue
		end

		return p / -staticValue
	else
		local v = options or {}
		local v2 = Graph.QueryPointsWithTime(0, p2, v) < 0
		local v3 = p / 200
		local v4 = v2 and p or 0
		local total = 0

		for i = 1, 200 do
			local v6 = v4 + Graph.QueryPointsWithTime(i / 200, p2, v) * v3

			if not v2 and p <= v6 then
				return total + (p - v4) / (v6 - v4) * v3
			end

			if v2 and v6 <= 0 then
				return total + v4 / (v4 - v6) * v3
			end

			total += v3
			v4 = v6
		end

		local pointsWithTime = Graph.QueryPointsWithTime(1, p2, v)

		if v2 then
			if pointsWithTime >= 0 then
				return nil
			end

			return total + v4 / -pointsWithTime
		elseif pointsWithTime <= 0 then
			return nil
		else
			return total + (p - v4) / pointsWithTime
		end
	end
end

function Duration.computeItemLifecycle(effect)
	if effect:GetAttribute("Transformed") then
		local partIcleProperties = effect:FindFirstChild("PartIcleProperties")
		local emitDelay = effect:GetAttribute("EmitDelay") or 0
		local duration = resolveDuration(effect:GetAttribute("EmitDuration"))
		local emitCount = effect:GetAttribute("EmitCount")
		local v = emitCount == nil and 1 or emitCount
		local emissionMode = effect:GetAttribute("EmissionMode") or "Emit"
		local animateLoop = effect:GetAttribute("AnimateLoop") == true

		if emissionMode == "Animate" and animateLoop and duration <= 0 then
			return {
				emitDelay = emitDelay,
				emitDur = 0,
				lifecycle = 0,
				infinite = true
			}
		end

		if not (v > 0 or duration > 0) and emissionMode ~= "Animate" then
			return nil
		end

		local lifetime = partIcleProperties and partIcleProperties:GetAttribute("Lifetime")
		local max = 0

		if typeof(lifetime) == "NumberRange" then
			max = lifetime.Max
		elseif type(lifetime) == "number" then
			max = lifetime
		end

		local timescale = partIcleProperties and partIcleProperties:GetAttribute("Timescale")
		local trueLifetime = Duration.computeTrueLifetime(max, timescale, nil)

		if trueLifetime == nil then
			return {
				emitDelay = emitDelay,
				emitDur = duration,
				lifecycle = 0,
				infinite = true
			}
		end

		local partLife = partIcleProperties and partIcleProperties:GetAttribute("PartLife") or 0

		if emissionMode == "Animate" and duration < trueLifetime then
			duration = trueLifetime
		end

		return {
			emitDelay = emitDelay,
			emitDur = duration,
			lifecycle = trueLifetime + partLife,
			infinite = false
		}
	elseif effect:IsA("ParticleEmitter") then
		local emitCount = effect:GetAttribute("EmitCount")
		local v = emitCount == nil and 1 or emitCount
		local emitDelay = tonumber(effect:GetAttribute("EmitDelay")) or 0
		local emitDuration = tonumber(effect:GetAttribute("EmitDuration")) or 0

		if v <= 0 and emitDuration <= 0 then
			return nil
		end

		local lifetime = effect.Lifetime
		return {
			emitDelay = emitDelay,
			emitDur = emitDuration,
			lifecycle = typeof(lifetime) ~= "NumberRange" and 0 or lifetime.Max or 0,
			infinite = false
		}
	elseif effect:IsA("Trail") then
		local emitDelay = effect:GetAttribute("EmitDelay") or 0
		local duration = resolveDuration(effect:GetAttribute("EmitDuration"))

		if duration <= 0 then
			return nil
		end

		return {
			emitDelay = emitDelay,
			emitDur = duration,
			lifecycle = effect.Lifetime or 0,
			infinite = false
		}
	else
		if not effect:IsA("Beam") then
			return nil
		end

		local emitDelay = tonumber(effect:GetAttribute("EmitDelay")) or 0
		local emitDuration = tonumber(effect:GetAttribute("EmitDuration")) or 0

		if emitDuration <= 0 then
			return nil
		end

		return {
			emitDelay = emitDelay,
			emitDur = emitDuration,
			lifecycle = 0,
			infinite = false
		}
	end
end

function Duration.computeMaxDuration(instance, value)
	if not instance then
		return 0
	end

	local v = value or 0
	local itemLifecycle = Duration.computeItemLifecycle(instance)
	local v2 = 0
	local flag = false

	if itemLifecycle then
		if itemLifecycle.infinite then
			return nil
		end

		v2 = v + itemLifecycle.emitDelay + itemLifecycle.emitDur + itemLifecycle.lifecycle
		v += itemLifecycle.emitDelay
		instance:GetAttribute("Transformed")
	elseif instance:GetAttribute("Transformed") then
		flag = true
	end

	if flag then
		return v2
	end

	for _, folder in ipairs(instance:GetChildren()) do
		if folder.Name == "RenderTemplate" then
			for _, descendant in ipairs(folder:GetDescendants()) do
				if not descendant:GetAttribute("Transformed") then
					continue
				end

				local maxDuration = Duration.computeMaxDuration(descendant, v)

				if maxDuration == nil then
					return nil
				end

				if v2 < maxDuration then
					v2 = maxDuration
				end
			end
		else
			local maxDuration = Duration.computeMaxDuration(folder, v)

			if maxDuration == nil then
				return nil
			end

			if v2 < maxDuration then
				v2 = maxDuration
			end
		end
	end

	return v2
end

return Duration