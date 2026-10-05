local createVector = vector.create
local utilities = script.Parent.Parent.Utilities
local OuwmitUtility = require(utilities.OuwmitUtility)
local Tween = require(utilities.Tween)
local Animator = require(utilities.Animator)
return function(instance, p)
	local v = OuwmitUtility.GetAttribute(instance, "SpinRotation", createVector(0, 0, 0)) * OuwmitUtility.DEG_TO_RAD
	local attribute = OuwmitUtility.GetAttribute(instance, "Scale_Start", 1)
	local attribute2 = OuwmitUtility.GetAttribute(instance, "Scale_End", 1)

	if v == createVector(0, 0, 0) and attribute == 1 and attribute2 == 1 then
		return
	end

	local durationScale = OuwmitUtility.DurationScale(p)
	local v2 = OuwmitUtility.GetAttribute(instance, "EmitDelay", 0) * durationScale
	local v3 = OuwmitUtility.GetAttribute(instance, "ResetDelay", 0) * durationScale
	local attribute3 = OuwmitUtility.GetAttribute(instance, "ResetOnFinish", true)
	local attribute4 = OuwmitUtility.GetAttribute(instance, "SyncPosition", false)
	local v4 = math.max(OuwmitUtility.GetAttribute(instance, "SpinDuration", 0.5) * durationScale, 0.001)
	local v5 = OuwmitUtility.GetAttribute(instance, "SpinSpeed_Duration", 0.1) * durationScale
	local attribute5 = OuwmitUtility.GetAttribute(instance, "SpinSpeed_Start", 0)
	local attribute6 = OuwmitUtility.GetAttribute(instance, "SpinSpeed_End", 1)
	local originCFrame = OuwmitUtility.OriginCFrame

	local function run()
		local lerped = attribute5
		local pivot = instance:GetPivot()
		local scale = instance:GetScale()
		local attachment = instance:FindFirstAncestorOfClass("Attachment") or instance:FindFirstAncestorWhichIsA("BasePart")
		local v6 = nil
		local v7, v8

		if attribute5 == attribute6 then
			v7 = nil
			v8 = false
		else
			v8 = true
			v7 = Tween.new(
				OuwmitUtility.GetAttribute(instance, "SpinSpeed_Curve", OuwmitUtility.default_bezier),
				v5,
				function(p2, p3)
					lerped = OuwmitUtility.lerp(attribute5, attribute6, p2)
					return p3
				end,
				function()
					v8 = false
				end
			)
		end

		if attribute == attribute2 then
			instance:ScaleTo(attribute)
		else
			v6 = Tween.new(
				OuwmitUtility.GetAttribute(instance, "Scale_Curve", OuwmitUtility.default_bezier),
				v4,
				function(p2, p3)
					instance:ScaleTo(OuwmitUtility.lerp(attribute, attribute2, p2))
					return p3
				end
			)
		end

		local v9 = v * v4
		local total = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getOrigin()
			if attachment and attribute4 then
				return originCFrame(attachment)
			end

			return pivot
		end

		local fn
		local flag = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function restore()
			if not attribute3 then
				return
			end

			if instance:IsDescendantOf(game) then
				instance:PivotTo(attachment and originCFrame(attachment) or pivot)
				instance:ScaleTo(scale)
			end
		end

		local function finish()
			if flag then
				return
			end

			flag = true
			Animator.Remove(fn)

			if v7 ~= nil then
				v7()
			end

			if v6 ~= nil then
				v6()
			end

			if v3 > 0 then
				task.delay(v3, restore)
				return
			end

			restore() -- equivalent call inferred; original call site unknown
		end

		fn = function(p2)
			if instance:IsDescendantOf(game) then
				if lerped == 0 and not v8 then
					finish()
					return
				end

				total += p2 * lerped
				local v10 = math.clamp(total / v4, 0, 1)
				local v11 = v9 * v10
				local origin = getOrigin() -- equivalent call inferred; original call site unknown
				instance:PivotTo(origin * CFrame.fromOrientation(v11.x, v11.y, v11.z))

				if v10 >= 1 then
					finish()
				end
			else
				flag = true
				Animator.Remove(fn)

				if v7 ~= nil then
					v7()
				end

				if v6 ~= nil then
					v6()
				end
			end
		end

		Animator.Add(fn)
	end

	if v2 > 0 then
		task.delay(v2, run)
	else
		run()
	end
end