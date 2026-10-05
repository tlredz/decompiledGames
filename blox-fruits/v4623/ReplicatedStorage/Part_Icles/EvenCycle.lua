local EvenCycle = {
	resolve = function(instance, attributeName, value)
		local attribute = instance and instance:GetAttribute(attributeName)

		if typeof(attribute) ~= "NumberRange" or attribute.Min == 0 and attribute.Max == 0 then
			return (math.max(1, (math.floor(value or 12))))
		end

		local v = attribute.Min + (attribute.Max - attribute.Min) * math.random()
		local v2 = math.floor(v + (v >= 0 and 0.5 or -0.5))

		if v2 == 0 then
			return (math.max(1, (math.floor(value or 12))))
		end

		return v2
	end
}

function EvenCycle.step(p, resolved, p2, p3, p4)
	local v = math.abs(resolved)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reroll()
		resolved = EvenCycle.resolve(p2, p3, p4)
		v = math.abs(resolved)

		if resolved > 0 then
			p = 1
		else
			p = v
		end
	end

	if v == 0 or p == 0 then
		reroll() -- equivalent call inferred; original call site unknown
	elseif resolved > 0 then
		p += 1

		if v < p then
			reroll() -- equivalent call inferred; original call site unknown
		end
	else
		p -= 1

		if p < 1 then
			reroll() -- equivalent call inferred; original call site unknown
		end
	end

	return p, resolved, v
end

function EvenCycle.evenFlags(instance)
	if instance then
		return
			(instance:GetAttribute("PosXEven") or instance:GetAttribute("PosYEven") or instance:GetAttribute("PosZEven")) == true,
			(instance:GetAttribute("RotXEven") or instance:GetAttribute("RotYEven") or instance:GetAttribute("RotZEven")) == true
	end

	return false, false
end

function EvenCycle:advance(p2, p3, p4, p5, p6)
	local v = self[p2]

	if not v then
		v = {
			0,
			0,
			0,
			0
		}
		self[p2] = v
	end

	local v2 = 0
	local v3 = 0
	local v4, v5

	if p5 and EvenCycle.isSet(p3, "PositionEvenCycle") then
		local v6, v7
		v6, v7, v4 = EvenCycle.step(v[1], v[2], p3, "PositionEvenCycle", p4)
		v[1] = v6
		v[2] = v7
		v5 = v[1]
	else
		v5 = 0
		v4 = 0
	end

	if p6 and EvenCycle.isSet(p3, "RotationEvenCycle") then
		local v6, v7
		v6, v7, v3 = EvenCycle.step(v[3], v[4], p3, "RotationEvenCycle", p4)
		v[3] = v6
		v[4] = v7
		v2 = v[3]
	end

	return v5, v4, v2, v3
end

function EvenCycle.isSet(instance, attributeName)
	local attribute = instance and instance:GetAttribute(attributeName)
	return typeof(attribute) == "NumberRange" and (attribute.Min ~= 0 or attribute.Max ~= 0)
end

function EvenCycle:clear(p2)
	if self and p2 ~= nil then
		self[p2] = nil
	end
end

function EvenCycle.ensureIds(instance)
	if instance:GetAttribute("_EvenCycleId") then
		return
	end

	local HttpService = game:GetService("HttpService")
	pcall(function()
		instance:SetAttribute("_EvenCycleId", HttpService:GenerateGUID(false))
	end)
	local renderTemplate = instance:FindFirstChild("RenderTemplate")

	if not renderTemplate then
		return
	end

	for _, descendant in ipairs(renderTemplate:GetDescendants()) do
		if not descendant:GetAttribute("Transformed") or descendant:GetAttribute("_EvenCycleId") then
			continue
		end

		local v = descendant
		pcall(function()
			v:SetAttribute("_EvenCycleId", HttpService:GenerateGUID(false))
		end)
	end
end

return EvenCycle