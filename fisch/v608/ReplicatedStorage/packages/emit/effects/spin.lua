local createVector = vector.create
local module = require("../mod/tween")
local module2 = require("../mod/utility")
return {
	emit = function(instance, list)
		local v = module2.getAttribute(instance, "SpinRotation", createVector(0, 0, 0), true) * module2.DEG_TO_RAD
		local attribute = module2.getAttribute(instance, "Scale_Start", 1, true)
		local attribute2 = module2.getAttribute(instance, "Scale_End", 1, true)

		if v == createVector(0, 0, 0) and attribute == 1 and attribute2 == 1 then
			return
		end

		local attribute3 = module2.getAttribute(instance, "EmitDelay", 0)
		local attribute4 = module2.getAttribute(instance, "SyncPosition", false)
		local attribute5 = module2.getAttribute(instance, "SpinDuration", 0.5)
		local attribute6 = module2.getAttribute(instance, "SpinSpeed_Duration", 0.1)
		local attribute7 = module2.getAttribute(instance, "SpinSpeed_Start", 0)
		local attribute8 = module2.getAttribute(instance, "SpinSpeed_End", 1)
		local lerped = attribute7
		task.wait(attribute3)
		local v2

		if attribute7 == attribute8 then
			v2 = nil
		else
			v2 = module.fromParams(
				module2.getAttribute(instance, "SpinSpeed_Curve", module2.default_bezier),
				attribute6,
				function(p, p2)
					lerped = module2.lerp(attribute7, attribute8, p)
					return p2
				end
			)
			table.insert(list, v2)
		end

		local pivot = instance:GetPivot()
		local scale = instance:GetScale()

		if attribute == attribute2 then
			instance:ScaleTo(attribute)
		else
			table.insert(
				list,
				module.fromParams(
					module2.getAttribute(instance, "Scale_Curve", module2.default_bezier),
					attribute5,
					function(p, p2)
						instance:ScaleTo(module2.lerp(attribute, attribute2, p))
						return p2
					end
				)
			)
		end

		local attachment = instance:FindFirstAncestorOfClass("Attachment") or instance:FindFirstAncestorWhichIsA("BasePart")
		table.insert(list, function()
			instance:PivotTo(attachment and (attachment:IsA("Attachment") and attachment.WorldCFrame or attachment.CFrame) or pivot)
			instance:ScaleTo(scale)
		end)
		local v3 = v * attribute5
		module.timer(attribute5, function(p, p2)
			local v5 = v3 * math.clamp(p2 / attribute5, 0, 1)
			local v6

			if attachment and attribute4 then
				v6 = attachment:IsA("Attachment") and attachment.WorldCFrame or attachment.CFrame
			else
				v6 = pivot
			end

			instance:PivotTo(v6 * CFrame.fromOrientation(v5.x, v5.y, v5.z))

			if lerped > 0 or p2 > 0 and v2.Connected then
				return p * lerped
			end

			return nil
		end, v2, list, module2.RENDER_PRIORITY + list.depth)
	end
}