local module = require("../mod/attributes")
local module2 = require("../mod/tween")
require("../types")
local module3 = require("../mod/utility")
return {
	emit = function(state, object, list)
		if state.Enabled then
			state.Enabled = false
		end

		local emitDelay = module.get(state, "EmitDelay", 0)
		local emitCount = module.get(state, "EmitCount", 1)
		local emitDuration = module.get(state, "EmitDuration", 0)
		local v = emitDuration > 0
		task.wait(emitDelay)

		if v then
			object.Enabled = true
		end

		local timeScaleDuration = module.get(state, "TimeScale_Duration", 0.1)
		local timeScaleStart = module.get(state, "TimeScale_Start", object.TimeScale, true)
		local timeScaleEnd = module.get(state, "TimeScale_End", object.TimeScale, true)
		local v2 = nil

		if timeScaleStart == timeScaleEnd then
			if timeScaleStart ~= object.TimeScale then
				object.TimeScale = timeScaleStart
			end
		else
			v2 = module2.fromParams(
				module.get(state, "TimeScale_Curve", module3.default_bezier),
				timeScaleDuration,
				function(value, p)
					object.TimeScale = module3.lerp(timeScaleStart, timeScaleEnd, (math.clamp(value, 0, 1)))
					return p
				end
			)
			table.insert(list, v2)
		end

		module3.onCancel(list, function()
			if v then
				object.Enabled = false
			end

			object:Clear()
		end)
		object:Emit(emitCount)

		if v then
			task.wait(emitDuration)
			object.Enabled = false
		end

		module2.timer(state.Lifetime.Max, function(p, p2)
			if state.TimeScale > 0 or p2 > 0 and v2 and v2.Connected then
				return p * state.TimeScale
			end

			return nil
		end, v2, list)
	end
}