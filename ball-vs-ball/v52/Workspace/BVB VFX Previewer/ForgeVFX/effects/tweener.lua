local module = require("../mod/attributes")
local module2 = require("../mod/lerp")
local module3 = require("../mod/tween")
require("../types")
local module4 = require("../mod/utility")
local random = Random.new()
return {
	emit = function(p, list, flag: boolean)
		local target = module4.getTarget(p)

		if not target then
			return
		end

		local name = p.Name
		local emitDelay = module.get(p, "EmitDelay", 0)
		local resetOnFinish = module.get(p, "ResetOnFinish", true)
		local range = module.getRange(p, "Duration", NumberRange.new(1, 1), NumberRange.new(0, 1e999))

		if emitDelay > 0 then
			task.wait(emitDelay)
		end

		local v = module.get(p, "_END_VALUE", nil)
		local v2 = module.get(p, "_START_VALUE", nil)
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

		local v3 = v2 or result
		local typeName = typeof(v3)

		if typeName ~= typeof(v) then
			return
		end

		local number = random:NextNumber(range.Min, range.Max)
		local speedStart = module.get(p, "Speed_Start", 1)
		local speedEnd = module.get(p, "Speed_End", 1)
		local lerped = speedStart
		local v4

		if speedStart == speedEnd then
			v4 = nil
		else
			v4 = module3.fromParams(
				module.get(p, "Speed_Curve", module4.default_bezier),
				module.get(p, "Speed_Duration", 0.1),
				function(p2, p3)
					lerped = module4.lerp(speedStart, speedEnd, p2)
					return p3
				end
			)
			table.insert(list, v4)
		end

		local v5 = module2[typeName] or module2.Other
		local v6

		if flag then
			v6 = function(p2, p3)
				module.set(target, name, v5(v3, v, p2))
				return p3 * lerped
			end
		else
			v6 = function(p2, p3)
				target[name] = v5(v3, v, p2)
				return p3 * lerped
			end
		end

		table.insert(
			list,
			module3.fromParams(
				module.get(p, "Easing_Curve", module4.linear_bezier),
				number,
				v6,
				v4,
				nil,
				nil,
				module4.RENDER_PRIORITY + list.depth
			)
		)

		if resetOnFinish then
			table.insert(list, function()
				if flag then
					module.set(target, name, v3)
				else
					target[name] = v3
				end
			end)
		end

		module3.timer(number, function(p2, p3)
			if lerped > 0 or p3 > 0 and v4 and v4.Connected then
				return p2 * lerped
			end

			return nil
		end, v4, list)
	end
}