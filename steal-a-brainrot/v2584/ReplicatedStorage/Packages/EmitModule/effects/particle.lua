local module = require("../mod/tween")
local module2 = require("../mod/utility")
return {
	emit = function(state, object, list)
		if state.Enabled then
			state.Enabled = false
		end

		local attribute = module2.getAttribute(state, "EmitDelay", 0)
		local attribute2 = module2.getAttribute(state, "EmitCount", 1)
		local attribute3 = module2.getAttribute(state, "EmitDuration", 0)
		local v = attribute3 > 0
		task.wait(attribute)

		if v then
			object.Enabled = true
		end

		local attribute4 = module2.getAttribute(state, "TimeScale_Duration", 0.1)
		local attribute5 = module2.getAttribute(state, "TimeScale_Start", object.TimeScale)
		local attribute6 = module2.getAttribute(state, "TimeScale_End", object.TimeScale)
		local v2 = nil

		if attribute5 == attribute6 then
			if attribute5 ~= 1 then
				object.TimeScale = attribute5
			end
		else
			v2 = module.fromParams(
				module2.getAttribute(state, "TimeScale_Curve", module2.default_bezier),
				attribute4,
				function(value, p)
					object.TimeScale = module2.lerp(attribute5, attribute6, (math.clamp(value, 0, 1)))
					return p
				end
			)
			table.insert(list, v2)
		end

		object:Emit(attribute2)

		if v then
			task.wait(attribute3)
			object.Enabled = false
		end

		module.timer(state.Lifetime.Max, function(p, p2)
			if state.TimeScale > 0 or p2 > 0 and v2 and v2.Connected then
				return p * state.TimeScale
			end

			return nil
		end, v2, list)
	end
}