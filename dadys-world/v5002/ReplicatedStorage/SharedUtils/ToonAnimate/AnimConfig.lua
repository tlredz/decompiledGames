local AnimConfig = {
	BASE_KEYS = {
		idle = true,
		quirk = true,
		walk = true,
		run = true,
		sprint = true
	}
}

function AnimConfig.parseAnimName(value: string)
	local match, v = value:match("^(%a+)_(%d+)$")
	local v2

	if match then
		v2 = tonumber(v)
	else
		match = value
		v2 = 1
	end

	local lower = match:lower()

	if not (#lower > 9) or lower:sub(1, 9) ~= "transform" then
		return lower, v2, nil
	end

	local v3 = lower:sub(10)

	if AnimConfig.BASE_KEYS[v3] then
		return v3, v2, "transform"
	end

	return lower, v2, nil
end

function AnimConfig.isValidAnimationId(value: string?)
	if not (typeof(value) == "string" and value ~= "rbxassetid://0") then
		return false
	end

	return value:match("^rbxassetid://%d+$") ~= nil or value:match("^https://www%.roblox%.com/asset/%?id=%d+$") ~= nil
end

function AnimConfig.buildAnimNames(instance)
	local result = {}

	for _, animation in ipairs(instance:GetChildren()) do
		if not animation:IsA("Animation") then
			continue
		end

		local animName, v, v2 = AnimConfig.parseAnimName(animation.Name)

		if v2 or not AnimConfig.BASE_KEYS[animName] or not AnimConfig.isValidAnimationId(animation.AnimationId) then
			continue
		end

		result[animName] = result[animName] or {}
		result[animName][v] = {
			id = animation.AnimationId,
			weight = 10
		}
	end

	return result
end

function AnimConfig.buildAnimNamesByVariant(instance)
	local result = {
		base = {}
	}

	for _, animation in ipairs(instance:GetChildren()) do
		if not animation:IsA("Animation") then
			continue
		end

		local animName, v, v2 = AnimConfig.parseAnimName(animation.Name)

		if not (AnimConfig.BASE_KEYS[animName] and AnimConfig.isValidAnimationId(animation.AnimationId)) then
			continue
		end

		local v3 = v2 or "base"
		result[v3] = result[v3] or {}
		result[v3][animName] = result[v3][animName] or {}
		result[v3][animName][v] = {
			id = animation.AnimationId,
			weight = 10
		}
	end

	return result
end

function AnimConfig.resolveVariant(p)
	if p then
		return "transform"
	end

	return "base"
end

function AnimConfig.sumWeights(list)
	local total = 0

	for _, v in ipairs(list) do
		total += v.weight or 1
	end

	return total
end

function AnimConfig.rollIndex(p, callback)
	if not p or p.totalWeight <= 0 then
		return 1
	end

	local v = callback(1, p.totalWeight)
	local total = 0

	for i = 1, #p do
		total += p[i].weight or 1

		if v <= total then
			return i
		end
	end

	return 1
end

return AnimConfig