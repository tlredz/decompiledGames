local module = require("../mod/attributes")
local module2 = require("../mod/lerp")
local module3 = require("../mod/tween")
require("../types")
local module4 = require("../mod/utility")
local module5 = require("../obj/Bezier")
local random = Random.new()

local function getBezier(weightCurve: string)
	local v = module3.bezier_cache[weightCurve]

	if v then
		return v
	end

	local success, result = pcall(function()
		return module4.deserializePath(weightCurve)
	end)

	if not success then
		return nil
	end

	v = module5.new(result, 0)
	module3.bezier_cache[weightCurve] = v
	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sampleWeighted(object)
	return 1 - object:getEase((random:NextNumber())).y
end

return {
	emit = function(p, _, flag: boolean)
		local target = module4.getTarget(p)

		if not target then
			return
		end

		local name = p.Name
		local v = module.get(p, "_START_VALUE", nil)
		local v2 = module.get(p, "_END_VALUE", nil)

		if v == nil or v2 == nil then
			return
		end

		local typeName = typeof(v)

		if typeName ~= typeof(v2) then
			return
		end

		local bezier = getBezier(module.get(p, "Weight_Curve", module4.linear_bezier))

		if not bezier then
			return
		end

		local result

		if flag then
			result = module.get(target, name, nil)
		else
			local success
			success, result = pcall(function()
				return target[name]
			end)

			if not success then
				return
			end
		end

		local v3 = (module2[typeName] or module2.Other)(v, v2, sampleWeighted(bezier))
		local resetOnFinish = module.get(p, "ResetOnFinish", true)

		if flag then
			module.set(target, name, v3)
		else
			target[name] = v3
		end

		if resetOnFinish then
			task.defer(function()
				if flag then
					module.set(target, name, result)
				else
					target[name] = result
				end
			end)
		end
	end
}