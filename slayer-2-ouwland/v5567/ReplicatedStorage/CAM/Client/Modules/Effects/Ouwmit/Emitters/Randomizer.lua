local utilities = script.Parent.Parent.Utilities
local OuwmitUtility = require(utilities.OuwmitUtility)
local Lerp = require(utilities.Lerp)
local Bezier = require(utilities.Bezier)
local random = Random.new()
local getTarget = OuwmitUtility.GetTarget
return function(instance, flag: boolean)
	if instance == nil then
		return
	end

	local target = getTarget(instance)

	if target == nil then
		return
	end

	local name = instance.Name
	local _START_VALUE = instance:GetAttribute("_START_VALUE")
	local _END_VALUE = instance:GetAttribute("_END_VALUE")

	if _START_VALUE == nil or _END_VALUE == nil then
		return
	end

	local typeName = typeof(_START_VALUE)

	if typeName ~= typeof(_END_VALUE) then
		return
	end

	local attribute = OuwmitUtility.GetAttribute(instance, "Weight_Curve", OuwmitUtility.linear_bezier)
	local success, result = pcall(OuwmitUtility.deserializePath, attribute)

	if not success then
		return
	end

	local v = 1 - Bezier.new(result, 0):getEase(random:NextNumber()).y
	local result2

	if flag then
		result2 = target:GetAttribute(name)
	else
		local success2
		success2, result2 = pcall(function()
			return target[name]
		end)

		if not success2 then
			return
		end
	end

	local v2 = (Lerp[typeName] or Lerp.Other)(_START_VALUE, _END_VALUE, v)

	if flag then
		target:SetAttribute(name, v2)
	else
		target[name] = v2
	end

	if OuwmitUtility.GetAttribute(instance, "ResetOnFinish", true) then
		task.defer(function()
			if not target:IsDescendantOf(game) then
				return
			end

			if flag then
				target:SetAttribute(name, result2)
			else
				target[name] = result2
			end
		end)
	end
end