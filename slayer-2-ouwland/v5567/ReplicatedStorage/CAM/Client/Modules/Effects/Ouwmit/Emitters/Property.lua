local utilities = script.Parent.Parent.Utilities
local Tween = require(utilities.Tween)
local OuwmitUtility = require(utilities.OuwmitUtility)
local Lerp = require(utilities.Lerp)
local random = Random.new()
local getTarget = OuwmitUtility.GetTarget
return function(p, instance, flag: boolean?, p2)
	if instance == nil then
		return
	end

	local v = getTarget(instance) or p

	if v == nil then
		return
	end

	local name = instance.Name
	local durationScale = OuwmitUtility.DurationScale(p2)
	local v2 = OuwmitUtility.GetAttribute(instance, "EmitDelay", 0) * durationScale
	local attribute = OuwmitUtility.GetAttribute(instance, "ResetOnFinish", true)
	local rangeAttribute = OuwmitUtility.GetRangeAttribute(
		instance,
		"Duration",
		NumberRange.new(1, 1),
		NumberRange.new(0, 1e999)
	)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function write(p3)
		if flag then
			v:SetAttribute(name, p3)
		else
			v[name] = p3
		end
	end

	local function Do()
		if not v:IsDescendantOf(game) then
			return
		end

		local _END_VALUE = instance:GetAttribute("_END_VALUE")

		if _END_VALUE == nil then
			local success, result = pcall(function()
				return instance.Value
			end)

			if success then
				_END_VALUE = result
			end
		end

		local _START_VALUE = instance:GetAttribute("_START_VALUE")
		local result

		if flag then
			result = v:GetAttribute(name)
		else
			local success
			success, result = pcall(function()
				return v[name]
			end)

			if not success then
				return
			end
		end

		if _START_VALUE ~= nil then
			result = _START_VALUE
		end

		local typeName = typeof(result)

		if typeName ~= typeof(_END_VALUE) then
			return
		end

		local v3 = random:NextNumber(rangeAttribute.Min, rangeAttribute.Max) * durationScale
		local attribute2 = OuwmitUtility.GetAttribute(instance, "Speed_Start", 1)
		local attribute3 = OuwmitUtility.GetAttribute(instance, "Speed_End", 1)
		local lerped = attribute2
		local v4 = attribute2 == attribute3

		if attribute2 ~= attribute3 then
			Tween.new(
				OuwmitUtility.GetAttribute(instance, "Speed_Curve", OuwmitUtility.default_bezier),
				OuwmitUtility.GetAttribute(instance, "Speed_Duration", 0.1) * durationScale,
				function(p3, p4)
					lerped = OuwmitUtility.lerp(attribute2, attribute3, p3)
					return p4
				end,
				function()
					v4 = true
				end
			)
		end

		local v5 = Lerp[typeName] or Lerp.Other
		Tween.new(
			OuwmitUtility.GetAttribute(instance, "Easing_Curve", OuwmitUtility.linear_bezier),
			v3,
			function(p3, p4)
				if not v:IsDescendantOf(game) then
					return nil
				end

				write(v5(result, _END_VALUE, p3)) -- equivalent call inferred; original call site unknown

				if lerped ~= 0 or not v4 then
					return p4 * lerped
				end

				if attribute then
					write(result) -- equivalent call inferred; original call site unknown
				end

				return nil
			end,
			attribute and function()
				if not v:IsDescendantOf(game) then
					return
				end

				write(result) -- equivalent call inferred; original call site unknown
			end or nil
		)
	end

	if v2 == nil or not (v2 > 0) then
		Do()
	else
		task.delay(v2, Do)
	end
end