local utilities = script.Parent.Parent.Utilities
local OuwmitUtility = require(utilities.OuwmitUtility)
require(utilities.Types)
local Tween = require(utilities.Tween)

local function getLegacyWidths(instance)
	return
		OuwmitUtility.GetAttribute(instance, "Width0", instance.Width0),
		OuwmitUtility.GetAttribute(instance, "Width1", instance.Width1),
		OuwmitUtility.GetAttribute(instance, "StartWidth0", instance.Width0),
		(OuwmitUtility.GetAttribute(instance, "StartWidth1", instance.Width1))
end

local object = setmetatable({}, {
	__mode = "k"
})
local numberRange = NumberRange.new(1, 1)
local Beam = {}

function Beam.Cancel(p)
	local v = object[p]

	if v == nil then
		return
	end

	object[p] = nil

	for k in pairs(v) do
		k()
	end
end

function Beam.Emit(instance, p)
	local attachment0 = instance.Attachment0
	local attachment1 = instance.Attachment1

	if attachment0 == nil or attachment1 == nil then
		return nil
	end

	local parent = p ~= nil and p.Parent or instance.Parent

	if parent == nil then
		return nil
	end

	local legacyWidths, v, v2, v3 = getLegacyWidths(instance)
	local attribute = OuwmitUtility.GetAttribute(instance, "Width0_Start", v2)
	local attribute2 = OuwmitUtility.GetAttribute(instance, "Width0_End", legacyWidths)
	local attribute3 = OuwmitUtility.GetAttribute(instance, "Width1_Start", v3)
	local attribute4 = OuwmitUtility.GetAttribute(instance, "Width1_End", v)
	local attribute5 = OuwmitUtility.GetAttribute(instance, "CurveSize0_Start", instance.CurveSize0)
	local attribute6 = OuwmitUtility.GetAttribute(instance, "CurveSize0_End", instance.CurveSize0)
	local attribute7 = OuwmitUtility.GetAttribute(instance, "CurveSize1_Start", instance.CurveSize1)
	local attribute8 = OuwmitUtility.GetAttribute(instance, "CurveSize1_End", instance.CurveSize1)
	local durationScale = OuwmitUtility.DurationScale(p)
	local v4 = OuwmitUtility.GetAttribute(instance, "EmitDelay", 0) * durationScale
	local v5 = math.max(tonumber(OuwmitUtility.GetAttribute(instance, "Duration", 1)) or 0, 0)
	local attribute9 = OuwmitUtility.GetAttribute(instance, "EndTransparencyScale", 1)
	local effectDuration = instance:GetAttribute("EffectDuration")

	if typeof(effectDuration) ~= "NumberRange" then
		effectDuration = NumberRange.new(v5, v5)
	end

	local v6 = math.max(OuwmitUtility.GetRandomNumberInRange(effectDuration.Min, effectDuration.Max), 0)
	local v7 = v6 * durationScale
	local rangeAttribute = OuwmitUtility.GetRangeAttribute(instance, "Length_Scale_Start", numberRange)
	local rangeAttribute2 = OuwmitUtility.GetRangeAttribute(instance, "Length_Scale_End", numberRange)
	local randomNumberInRange = OuwmitUtility.GetRandomNumberInRange(rangeAttribute.Min, rangeAttribute.Max)
	local randomNumberInRange2 = OuwmitUtility.GetRandomNumberInRange(rangeAttribute2.Min, rangeAttribute2.Max)
	local v8 = rangeAttribute ~= numberRange or rangeAttribute2 ~= numberRange
	local attribute10 = OuwmitUtility.GetAttribute(instance, "Length_Texture_Start", instance.TextureLength)
	local attribute11 = OuwmitUtility.GetAttribute(instance, "Length_Texture_End", instance.TextureLength)
	local attribute12 = OuwmitUtility.GetAttribute(instance, "Transparency_Scale_Start", 1)
	local attribute13 = OuwmitUtility.GetAttribute(instance, "Transparency_Scale_End", attribute9)
	local attribute14 = OuwmitUtility.GetAttribute(instance, "Speed_Texture_Start", instance.TextureSpeed)
	local attribute15 = OuwmitUtility.GetAttribute(instance, "Speed_Texture_End", instance.TextureSpeed)
	local attribute16 = OuwmitUtility.GetAttribute(instance, "Speed_Start", 1)
	local attribute17 = OuwmitUtility.GetAttribute(instance, "Speed_End", 1)
	local transparency = instance.Transparency
	local clone = instance:Clone()
	clone.Name = "--"
	clone.Attachment0 = attachment0
	clone.Attachment1 = attachment1
	local clone2, clone3

	if v8 then
		clone2 = attachment0:Clone()
		clone3 = attachment1:Clone()
		clone2.Name = "_OuwmitTempAttachment"
		clone3.Name = "_OuwmitTempAttachment"
		clone2:AddTag("__forge_excludeFromEmit")
		clone3:AddTag("__forge_excludeFromEmit")

		for _, child in ipairs(clone2:GetChildren()) do
			child:Destroy()
		end

		for _, child in ipairs(clone3:GetChildren()) do
			child:Destroy()
		end

		clone.Attachment0 = clone2
		clone.Attachment1 = clone3
		clone2.Parent = attachment0.Parent
		clone3.Parent = attachment1.Parent
	else
		clone2 = nil
		clone3 = nil
	end

	clone.Parent = parent
	local v9 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function track(p2)
		if p2 ~= nil then
			table.insert(v9, p2)
		end
	end

	local flag = false
	local v10 = nil

	local function stopRun()
		if flag then
			return
		end

		flag = true
		local v11 = object[instance]

		if v11 ~= nil then
			v11[v10] = nil

			if next(v11) == nil then
				object[instance] = nil
			end
		end

		for _, v12 in ipairs(v9) do
			v12()
		end

		if clone2 ~= nil then
			clone2:Destroy()
		end

		if clone3 ~= nil then
			clone3:Destroy()
		end

		clone:Destroy()
	end

	v10 = stopRun
	local v11 = object[instance]

	if v11 == nil then
		v11 = {}
		object[instance] = v11
	end

	v11[v10] = true

	local function Emit()
		if flag then
			return
		end

		if clone.Parent == nil then
			stopRun()
			return
		end

		clone.Enabled = true
		local lerped = 1
		local v12 = attribute16 == attribute17
		local textureSpeed = clone.TextureSpeed

		if attribute16 ~= attribute17 then
			track(Tween.new(
				OuwmitUtility.GetAttribute(instance, "Speed_Curve", OuwmitUtility.default_bezier),
				OuwmitUtility.GetAttribute(instance, "Speed_Duration", 0.1) * durationScale,
				function(p2, p3)
					lerped = OuwmitUtility.lerp(attribute16, attribute17, p2)
					clone.TextureSpeed = textureSpeed * lerped
					return p3
				end,
				function()
					v12 = true
				end
			)) -- equivalent call inferred; original call site unknown
		end

		if attribute14 ~= attribute15 then
			track(Tween.new(
				OuwmitUtility.GetAttribute(instance, "Speed_Texture_Curve", OuwmitUtility.default_bezier),
				v7,
				function(p2, p3)
					textureSpeed = OuwmitUtility.lerp(attribute14, attribute15, p2)
					clone.TextureSpeed = textureSpeed * lerped
					return p3
				end
			)) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setTScale(p2: number)
			clone.Transparency = OuwmitUtility.scaleNumberSequence(transparency, function(p3, p4)
				return p3 + (p2 > 1 and 1 - p3 or -p3) * (p2 > 1 and p2 - 1 or 1 - p2), p4
			end)
		end

		if attribute12 == attribute13 then
			if attribute12 ~= 1 then
				setTScale(attribute12) -- equivalent call inferred; original call site unknown
			end
		else
			track(Tween.new(
				OuwmitUtility.GetAttribute(instance, "Transparency_Scale_Curve", OuwmitUtility.default_bezier),
				v7,
				function(p2, p3)
					setTScale(OuwmitUtility.lerp(attribute12, attribute13, p2)) -- equivalent call inferred; original call site unknown

					if lerped == 0 and v12 then
						return nil
					end

					return p3 * lerped
				end
			)) -- equivalent call inferred; original call site unknown
		end

		if attribute10 ~= attribute11 then
			track(Tween.new(
				OuwmitUtility.GetAttribute(instance, "Length_Texture_Curve", OuwmitUtility.default_bezier),
				v7,
				function(p2, p3)
					clone.TextureLength = OuwmitUtility.lerp(attribute10, attribute11, p2)

					if lerped == 0 and v12 then
						return nil
					end

					return p3 * lerped
				end
			)) -- equivalent call inferred; original call site unknown
		end

		if clone2 ~= nil and clone3 ~= nil then
			local cFrame = clone2.CFrame
			local cFrame2 = clone3.CFrame
			local v13 = (cFrame2.Position - cFrame.Position) * 0.5
			local v14 = cFrame.Position + v13

			-- equivalent calls inferred from this helper; original call sites unknown
			local function setLengthScale(p2: number)
				local v15 = v13 * p2
				clone2.CFrame = CFrame.new(v14 - v15) * (cFrame - cFrame.Position)
				clone3.CFrame = CFrame.new(v14 + v15) * (cFrame2 - cFrame2.Position)
			end

			if randomNumberInRange == randomNumberInRange2 then
				if attribute10 ~= 1 then
					setLengthScale(randomNumberInRange) -- equivalent call inferred; original call site unknown
				end
			else
				track(Tween.new(
					OuwmitUtility.GetAttribute(instance, "Length_Scale_Curve", OuwmitUtility.default_bezier),
					v7,
					function(p2, p3)
						setLengthScale(OuwmitUtility.lerp(randomNumberInRange, randomNumberInRange2, p2)) -- equivalent call inferred; original call site unknown

						if lerped == 0 and v12 then
							return nil
						end

						return p3 * lerped
					end
				)) -- equivalent call inferred; original call site unknown
			end
		end

		if attribute == attribute2 then
			clone.Width0 = attribute
		else
			track(Tween.new(
				OuwmitUtility.GetAttribute(instance, "Width0_Curve", OuwmitUtility.default_bezier),
				v7,
				function(p2, p3)
					clone.Width0 = OuwmitUtility.lerp(attribute, attribute2, p2)

					if lerped == 0 and v12 then
						return nil
					end

					return p3 * lerped
				end
			)) -- equivalent call inferred; original call site unknown
		end

		if attribute3 == attribute4 then
			clone.Width1 = attribute3
		else
			track(Tween.new(
				OuwmitUtility.GetAttribute(instance, "Width1_Curve", OuwmitUtility.default_bezier),
				v7,
				function(p2, p3)
					clone.Width1 = OuwmitUtility.lerp(attribute3, attribute4, p2)

					if lerped == 0 and v12 then
						return nil
					end

					return p3 * lerped
				end
			)) -- equivalent call inferred; original call site unknown
		end

		if attribute5 ~= attribute6 then
			track(Tween.new(
				OuwmitUtility.GetAttribute(instance, "CurveSize0_Curve", OuwmitUtility.default_bezier),
				v7,
				function(p2, p3)
					clone.CurveSize0 = OuwmitUtility.lerp(attribute5, attribute6, p2)

					if lerped == 0 and v12 then
						return nil
					end

					return p3 * lerped
				end
			)) -- equivalent call inferred; original call site unknown
		end

		if attribute7 ~= attribute8 then
			track(Tween.new(
				OuwmitUtility.GetAttribute(instance, "CurveSize1_Curve", OuwmitUtility.default_bezier),
				v7,
				function(p2, p3)
					clone.CurveSize1 = OuwmitUtility.lerp(attribute7, attribute8, p2)

					if lerped == 0 and v12 then
						return nil
					end

					return p3 * lerped
				end
			)) -- equivalent call inferred; original call site unknown
		end

		local flipbookFrames, v13 = OuwmitUtility.GetFlipbookFrames(instance)
		local v14

		if flipbookFrames == nil then
			v14 = 0
		else
			v14 = OuwmitUtility.GetAttribute(instance, "Flipbook_Change_Duration", v6) * durationScale

			if OuwmitUtility.GetAttribute(instance, "SyncDuration", false) then
				v14 = v7
			end

			track(Tween.new(
				OuwmitUtility.GetAttribute(instance, "Flipbook_Change_Curve", OuwmitUtility.linear_bezier),
				v14,
				function(p2, p3)
					clone.Texture = `{v13}{flipbookFrames[math.max(math.round(#flipbookFrames * p2), 1)]}`

					if lerped == 0 and v12 then
						return nil
					end

					return p3 * lerped
				end
			)) -- equivalent call inferred; original call site unknown
		end

		local v15 = math.max(v7, v14)
		track(Tween.new(OuwmitUtility.linear_bezier, v15, function(_, p2)
			if clone.Parent == nil then
				stopRun()
				return nil
			end

			if lerped ~= 0 or not v12 then
				return p2 * lerped
			end

			stopRun()
			return nil
		end, stopRun)) -- equivalent call inferred; original call site unknown
	end

	if v4 == nil or not (v4 > 0) then
		Emit()
	else
		task.delay(v4, Emit)
	end

	return clone
end

return Beam