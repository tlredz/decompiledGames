local module = require("../mod/tween")
local module2 = require("../mod/utility")
local random = Random.new()

local function getLegacyWidths(p, p2: number)
	return
		module2.getAttribute(p, "Width0", p.Width0, true) * p2,
		module2.getAttribute(p, "Width1", p.Width1, true) * p2,
		module2.getAttribute(p, "StartWidth0", p.Width0, true) * p2,
		module2.getAttribute(p, "StartWidth1", p.Width1, true) * p2
end

return {
	emit = function(p, p2, list, p3: number)
		local legacyWidths, v, v2, v3 = getLegacyWidths(p, p3)
		local attribute = module2.getAttribute(p, "Width0_Start", v2)
		local attribute2 = module2.getAttribute(p, "Width0_End", legacyWidths)
		local attribute3 = module2.getAttribute(p, "Width1_Start", v3)
		local attribute4 = module2.getAttribute(p, "Width1_End", v)
		local attribute5 = module2.getAttribute(p, "EmitDelay", 0)
		local attribute6 = module2.getAttribute(p, "Duration", 1, true)
		local attribute7 = module2.getAttribute(p, "EndTransparencyScale", 1, true)
		local rangeAttribute = module2.getRangeAttribute(
			p,
			"EffectDuration",
			NumberRange.new(attribute6, attribute6),
			NumberRange.new(0, 1e999)
		)
		local number = random:NextNumber(rangeAttribute.Min, rangeAttribute.Max)
		local attribute8 = module2.getAttribute(p, "Transparency_Scale_Start", 1)
		local attribute9 = module2.getAttribute(p, "Transparency_Scale_End", attribute7)
		local attribute10 = module2.getAttribute(p, "Speed_Start", 1)
		local attribute11 = module2.getAttribute(p, "Speed_End", 1)
		local textureSpeed = p2.TextureSpeed
		task.wait(attribute5)
		p2.Enabled = true
		local lerped = 1
		local v4

		if attribute10 == attribute11 then
			v4 = nil
		else
			v4 = module.fromParams(
				module2.getAttribute(p, "Speed_Curve", module2.default_bezier),
				module2.getAttribute(p2, "Speed_Duration", 0.1),
				function(p4, p5)
					lerped = module2.lerp(attribute10, attribute11, p4)
					p2.TextureSpeed = textureSpeed * lerped
					return p5
				end
			)
			table.insert(list, v4)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setTScale(p4: number)
			p2.Transparency = module2.scaleNumberSequence(p.Transparency, function(p5, p6)
				return p5 + (p4 > 1 and 1 - p5 or -p5) * (p4 > 1 and p4 - 1 or 1 - p4), p6
			end)
		end

		if attribute8 == attribute9 then
			if attribute8 ~= 1 then
				setTScale(attribute8) -- equivalent call inferred; original call site unknown
			end
		else
			table.insert(
				list,
				module.fromParams(
					module2.getAttribute(p, "Transparency_Scale_Curve", module2.default_bezier),
					number,
					function(p4, p5)
						setTScale(module2.lerp(attribute8, attribute9, p4)) -- equivalent call inferred; original call site unknown
						return p5 * lerped
					end,
					v4
				)
			)
		end

		if attribute == attribute2 then
			p2.Width0 = attribute
		else
			table.insert(
				list,
				module.fromParams(
					module2.getAttribute(p, "Width0_Curve", module2.default_bezier),
					number,
					function(p4, p5)
						p2.Width0 = module2.lerp(attribute, attribute2, p4)
						return p5 * lerped
					end,
					v4
				)
			)
		end

		if attribute3 == attribute4 then
			p2.Width1 = attribute3
		else
			table.insert(
				list,
				module.fromParams(
					module2.getAttribute(p, "Width1_Curve", module2.default_bezier),
					number,
					function(p4, p5)
						p2.Width1 = module2.lerp(attribute3, attribute4, p4)
						return p5 * lerped
					end,
					v4
				)
			)
		end

		module.timer(number, function(p4, p5)
			if lerped > 0 or p5 > 0 and v4 and v4.Connected then
				return p4 * lerped
			end

			return nil
		end, v4, list)
	end
}