local module = require("../mod/attributes")
local module2 = require("../mod/tween")
require("../types")
local module3 = require("../mod/utility")
local module4 = require("../mod/common/flipbook")
local module5 = require("../pkg/Promise")
local random = Random.new()

local function getLegacyWidths(data, p: number)
	return
		module.get(data, "Width0", data.Width0, true) * p,
		module.get(data, "Width1", data.Width1, true) * p,
		module.get(data, "StartWidth0", data.Width0, true) * p,
		module.get(data, "StartWidth1", data.Width1, true) * p
end

return {
	emit = function(ref, state, list, p: number)
		local v = list.effects.prepareEmitOnFinish(state, list)
		local legacyWidths, v2, v3, v4 = getLegacyWidths(ref, p)
		local width0Start = module.get(ref, "Width0_Start", v3)
		local width0End = module.get(ref, "Width0_End", legacyWidths)
		local width1Start = module.get(ref, "Width1_Start", v4)
		local width1End = module.get(ref, "Width1_End", v2)
		local curveSize0Start = module.get(ref, "CurveSize0_Start", state.CurveSize0)
		local curveSize0End = module.get(ref, "CurveSize0_End", state.CurveSize0)
		local curveSize1Start = module.get(ref, "CurveSize1_Start", state.CurveSize1)
		local curveSize1End = module.get(ref, "CurveSize1_End", state.CurveSize1)
		local emitDelay = module.get(ref, "EmitDelay", 0)
		local duration = module.get(ref, "Duration", 1, true)
		local endTransparencyScale = module.get(ref, "EndTransparencyScale", 1, true)
		local range = module.getRange(
			ref,
			"EffectDuration",
			NumberRange.new(duration, duration),
			NumberRange.new(0, 1e999)
		)
		local lengthScaleStart = module.get(ref, "Length_Scale_Start", NumberRange.new(1, 1))
		local lengthScaleEnd = module.get(ref, "Length_Scale_End", NumberRange.new(1, 1))
		local lengthTextureStart = module.get(ref, "Length_Texture_Start", ref.TextureLength)
		local lengthTextureEnd = module.get(ref, "Length_Texture_End", ref.TextureLength)
		local number = random:NextNumber(range.Min, range.Max)
		local number2 = random:NextNumber(lengthScaleEnd.Min, lengthScaleEnd.Max)
		local number3 = random:NextNumber(lengthScaleStart.Min, lengthScaleStart.Max)
		local transparencyScaleStart = module.get(ref, "Transparency_Scale_Start", 1)
		local transparencyScaleEnd = module.get(ref, "Transparency_Scale_End", endTransparencyScale)
		local speedTextureStart = module.get(ref, "Speed_Texture_Start", ref.TextureSpeed)
		local speedTextureEnd = module.get(ref, "Speed_Texture_End", ref.TextureSpeed)
		local speedStart = module.get(ref, "Speed_Start", 1)
		local speedEnd = module.get(ref, "Speed_End", 1)
		local textureSpeed = state.TextureSpeed
		task.wait(emitDelay)
		state.Enabled = true
		local finisheds = {}
		local lerped = 1
		local speedTween = nil
		table.insert(finisheds, list.effects.emitNested(state, list.depth + 1, list).Finished)

		if speedTextureStart ~= speedTextureEnd then
			module2.fromParams(module.get(ref, "Speed_Texture_Curve", module3.default_bezier), number, function(p2, p3)
				textureSpeed = module3.lerp(speedTextureStart, speedTextureEnd, p2)
				state.TextureSpeed = textureSpeed * lerped
				return p3
			end)
		end

		if speedStart ~= speedEnd then
			speedTween = module2.fromParams(
				module.get(ref, "Speed_Curve", module3.default_bezier),
				module.get(state, "Speed_Duration", 0.1),
				function(p2, p3)
					lerped = module3.lerp(speedStart, speedEnd, p2)
					state.TextureSpeed = textureSpeed * lerped
					return p3
				end
			)
			table.insert(list, speedTween)
		end

		local keypoints = ref.Transparency.Keypoints
		local count = #keypoints
		local numberSequenceKeypoints = table.create(count)
		local v6 = table.create(count)

		for k, keypoint in keypoints do
			v6[k] = {
				time = keypoint.Time,
				value = keypoint.Value,
				envelope = keypoint.Envelope
			}
		end

		local v7 = nil

		local function setTScale(p2: number)
			if v7 and math.abs(p2 - v7) < 0.001 then
				return
			end

			v7 = p2
			local v8 = p2 > 1 and p2 - 1 or 1 - p2

			for k, v9 in v6 do
				local value = v9.value
				local v10 = p2 > 1 and 1 - value or -value
				numberSequenceKeypoints[k] = NumberSequenceKeypoint.new(v9.time, value + v10 * v8, v9.envelope)
			end

			state.Transparency = NumberSequence.new(numberSequenceKeypoints)
		end

		local attachment0 = state.Attachment0
		local attachment1 = state.Attachment1
		local cFrame = attachment0 and attachment0.CFrame
		local cFrame2 = attachment1 and attachment1.CFrame

		local function setLengthScale(p2: number)
			if not (cFrame and cFrame2) then
				return
			end

			local v8 = (cFrame2.Position - cFrame.Position) * 0.5
			local v9 = cFrame.Position + v8
			local v10 = v8 * p2
			attachment0.CFrame = CFrame.new(v9 - v10) * (cFrame - cFrame.Position)
			attachment1.CFrame = CFrame.new(v9 + v10) * (cFrame2 - cFrame2.Position)
		end

		table.insert(list, function()
			setLengthScale(1)
		end)

		if transparencyScaleStart == transparencyScaleEnd then
			if transparencyScaleStart ~= 1 then
				setTScale(transparencyScaleStart)
			end
		else
			table.insert(
				list,
				module2.fromParams(
					module.get(ref, "Transparency_Scale_Curve", module3.default_bezier),
					number,
					function(p2, p3)
						setTScale(module3.lerp(transparencyScaleStart, transparencyScaleEnd, p2))
						return p3 * lerped
					end,
					speedTween
				)
			)
		end

		if lengthTextureStart ~= lengthTextureEnd then
			table.insert(
				list,
				module2.fromParams(
					module.get(ref, "Length_Texture_Curve", module3.default_bezier),
					number,
					function(p2, p3)
						state.TextureLength = module3.lerp(lengthTextureStart, lengthTextureEnd, p2)
						return p3 * lerped
					end,
					speedTween
				)
			)
		end

		if number3 == number2 then
			if lengthTextureStart ~= 1 then
				setLengthScale(number3)
			end
		else
			table.insert(
				list,
				module2.fromParams(
					module.get(ref, "Length_Scale_Curve", module3.default_bezier),
					number,
					function(p2, p3)
						setLengthScale(module3.lerp(number3, number2, p2))
						return p3 * lerped
					end,
					speedTween
				)
			)
		end

		if width0Start == width0End then
			state.Width0 = width0Start
		else
			table.insert(
				list,
				module2.fromParams(module.get(ref, "Width0_Curve", module3.default_bezier), number, function(p2, p3)
					state.Width0 = module3.lerp(width0Start, width0End, p2)
					return p3 * lerped
				end, speedTween)
			)
		end

		if width1Start == width1End then
			state.Width1 = width1Start
		else
			table.insert(
				list,
				module2.fromParams(module.get(ref, "Width1_Curve", module3.default_bezier), number, function(p2, p3)
					state.Width1 = module3.lerp(width1Start, width1End, p2)
					return p3 * lerped
				end, speedTween)
			)
		end

		if curveSize0Start == curveSize0End then
			state.Width0 = width0Start
		else
			table.insert(
				list,
				module2.fromParams(module.get(ref, "CurveSize0_Curve", module3.default_bezier), number, function(p2, p3)
					state.CurveSize0 = module3.lerp(curveSize0Start, curveSize0End, p2)
					return p3 * lerped
				end, speedTween)
			)
		end

		if curveSize1Start == curveSize1End then
			state.Width1 = width1Start
		else
			table.insert(
				list,
				module2.fromParams(module.get(ref, "CurveSize1_Curve", module3.default_bezier), number, function(p2, p3)
					state.CurveSize1 = module3.lerp(curveSize1Start, curveSize1End, p2)
					return p3 * lerped
				end, speedTween)
			)
		end

		local flipbookData = module4.getFlipbookData(ref)
		local v8

		if flipbookData then
			local v9 = {
				ref = ref,
				frames = flipbookData,
				speedTween = speedTween,
				effectDuration = number,
				curve = module.get(ref, "Flipbook_Change_Curve", module3.linear_bezier),
				duration = module.get(ref, "Flipbook_Change_Duration", number),
				getSpeed = function()
					return lerped
				end,
				setTexture = function(texture)
					state.Texture = texture
				end
			}
			v8 = module4.getChangeDuration(v9)
			table.insert(list, module2.fromParams(v9.curve, v8, module4.createUpdateCallback(v9), speedTween))
		else
			v8 = 0
		end

		module2.timer(math.max(number, v8), function(p2, p3)
			if lerped > 0 or p3 > 0 and speedTween and speedTween.Connected then
				return p2 * lerped
			end

			return nil
		end, speedTween, list)

		if v then
			table.insert(
				finisheds,
				list.effects.emitOnFinish(v, state.Parent or workspace.Terrain, list.depth + 1, list).Finished
			)
		end

		module5.all(finisheds):await()
	end
}