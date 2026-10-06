local createVector = vector.create
local module = require("../mod/attributes")
local module2 = require("../mod/tween")
require("../types")
local module3 = require("../mod/utility")
return {
	emit = function(instance, list)
		if module3.isSpinModelStatic(instance) then
			return
		end

		local v = module.get(instance, "SpinRotation", createVector(0, 0, 0)) * module3.DEG_TO_RAD
		local scaleStart = module.get(instance, "Scale_Start", 1)
		local scaleEnd = module.get(instance, "Scale_End", 1)
		local emitDelay = module.get(instance, "EmitDelay", 0)
		local resetDelay = module.get(instance, "ResetDelay", 0)
		local resetOnFinish = module.get(instance, "ResetOnFinish", true)
		local syncPosition = module.get(instance, "SyncPosition", false)
		local spinDuration = module.get(instance, "SpinDuration", 0.5)
		local spinSpeedDuration = module.get(instance, "SpinSpeed_Duration", 0.1)
		local spinSpeedStart = module.get(instance, "SpinSpeed_Start", 0)
		local spinSpeedEnd = module.get(instance, "SpinSpeed_End", 1)
		local lerped = spinSpeedStart
		task.wait(emitDelay)
		local v2

		if spinSpeedStart == spinSpeedEnd then
			v2 = nil
		else
			v2 = module2.fromParams(
				module.get(instance, "SpinSpeed_Curve", module3.default_bezier),
				spinSpeedDuration,
				function(p, p2)
					lerped = module3.lerp(spinSpeedStart, spinSpeedEnd, p)
					return p2
				end
			)
			table.insert(list, v2)
		end

		local pivot = instance:GetPivot()
		local scale = instance:GetScale()

		if scaleStart == scaleEnd then
			instance:ScaleTo(scaleStart)
		else
			table.insert(
				list,
				module2.fromParams(
					module.get(instance, "Scale_Curve", module3.default_bezier),
					spinDuration,
					function(p, p2)
						instance:ScaleTo(module3.lerp(scaleStart, scaleEnd, p))
						return p2
					end
				)
			)
		end

		local attachment = instance:FindFirstAncestorOfClass("Attachment") or instance:FindFirstAncestorWhichIsA("BasePart")

		if resetOnFinish then
			table.insert(list, function()
				instance:PivotTo(attachment and module3.getTransformedOriginExtents(attachment) or pivot)
				instance:ScaleTo(scale)
			end)
		end

		local v3 = v * spinDuration
		module2.timer(spinDuration + resetDelay, function(p, p2)
			local v5 = v3 * math.clamp(p2 / spinDuration, 0, 1)
			local v6

			if attachment and syncPosition then
				v6 = module3.getTransformedOriginExtents(attachment)
			else
				v6 = pivot
			end

			instance:PivotTo(v6 * CFrame.fromOrientation(v5.x, v5.y, v5.z))

			if lerped > 0 or p2 > 0 and v2.Connected then
				return p * lerped
			end

			return nil
		end, v2, list, module3.RENDER_PRIORITY + list.depth)
	end
}