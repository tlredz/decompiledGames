local module = require("../mod/lerp")
local module2 = require("../mod/tween")
local module3 = require("../mod/utility")
local random = Random.new()
return {
	emit = function(p, instance, list)
		local name = instance.Name
		local attribute = module3.getAttribute(instance, "EmitDelay", 0)
		local attribute2 = module3.getAttribute(instance, "ResetOnFinish", true)
		local rangeAttribute = module3.getRangeAttribute(
			instance,
			"Duration",
			NumberRange.new(1, 1),
			NumberRange.new(0, 1e999)
		)

		if attribute > 0 then
			task.wait(attribute)
		end

		local _END_VALUE = instance:GetAttribute("_END_VALUE")
		local _START_VALUE = instance:GetAttribute("_START_VALUE")
		local success, result = pcall(function()
			return p[name]
		end)
		local v = _START_VALUE or result
		local typeName = typeof(v)

		if not success or typeName ~= typeof(_END_VALUE) then
			return
		end

		local number = random:NextNumber(rangeAttribute.Min, rangeAttribute.Max)
		local attribute3 = module3.getAttribute(instance, "Speed_Start", 1)
		local attribute4 = module3.getAttribute(instance, "Speed_End", 1)
		local lerped = attribute3
		local v2

		if attribute3 == attribute4 then
			v2 = nil
		else
			v2 = module2.fromParams(
				module3.getAttribute(instance, "Speed_Curve", module3.default_bezier),
				module3.getAttribute(instance, "Speed_Duration", 0.1),
				function(p2, p3)
					lerped = module3.lerp(attribute3, attribute4, p2)
					return p3
				end
			)
			table.insert(list, v2)
		end

		local v3 = module[typeName] or module.Other
		table.insert(
			list,
			module2.fromParams(
				module3.getAttribute(instance, "Easing_Curve", module3.linear_bezier),
				number,
				function(p2, p3)
					p[name] = v3(v, _END_VALUE, p2)
					return p3 * lerped
				end,
				v2,
				nil,
				nil,
				module3.RENDER_PRIORITY + list.depth
			)
		)

		if attribute2 then
			table.insert(list, function()
				p[name] = v
			end)
		end

		module2.timer(number, function(p2, p3)
			if lerped > 0 or p3 > 0 and v2 and v2.Connected then
				return p2 * lerped
			end

			return nil
		end, v2, list)
	end
}