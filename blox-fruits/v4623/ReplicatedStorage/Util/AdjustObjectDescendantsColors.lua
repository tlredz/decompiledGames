local GetColorPropertiesFor = require(game.ReplicatedStorage.Util.GetColorPropertiesFor)
local ColorSequenceUtil = require(game.ReplicatedStorage.Util.ColorSequenceUtil)

local function round(p, p2)
	return math.floor((p + p2 / 2) / p2) * p2
end

local function getDefaultColor(instance, p, p2, flag: boolean)
	local v = "DefaultColor_" .. p .. (flag == true and "_Attribute" or "")
	local attribute = instance:GetAttribute(v)

	if not attribute then
		instance:SetAttribute(v, p2)
		attribute = p2
	end

	return attribute
end

local function _getObjectColorProperties(p)
	local colorPropertiesFor = GetColorPropertiesFor(p)
	local result = {}

	for _, v2 in ipairs(colorPropertiesFor) do
		local _ = p[v2]
		table.insert(result, v2)
	end

	if #result == 0 then
		return nil
	end

	return result
end

local function transformOnlyHue(sequence: Color3, color: Color3)
	local v = math.max(1, sequence.R, sequence.G, sequence.B)
	local v2 = math.floor(sequence.R / v * 255) % 256
	local v3 = math.floor(sequence.G / v * 255) % 256
	local v4 = math.floor(sequence.B / v * 255) % 256
	local color2 = Color3.fromRGB(v2, v3, v4)
	local v5 = math.max(1, color.R, color.G, color.B)
	local v6 = math.floor(color.R / v5 * 255) % 256
	local v7 = math.floor(color.G / v5 * 255) % 256
	local v8 = math.floor(color.B / v5 * 255) % 256
	local color3 = Color3.fromRGB(v6, v7, v8)
	local _, v9, v10 = color2:ToHSV()
	local v11 = v10 * v
	local HSV = color3:ToHSV()
	return Color3.fromHSV(HSV, v9, v11)
end

local function vertexColorToColor3(vector: Vector3)
	local v = math.max(1, vector.X, vector.Y, vector.Z)
	local v2 = math.floor(vector.X / v * 255) % 256
	local v3 = math.floor(vector.Y / v * 255) % 256
	local v4 = math.floor(vector.Z / v * 255) % 256
	local HSV, v5, v6 = Color3.fromRGB(v2, v3, v4):ToHSV()
	return Color3.fromHSV(HSV, v5, v6 * v)
end

local function color3ToVertexColor(color: Color3)
	return (Vector3.new(color.R, color.G, color.B))
end

local function resampleSequence(p, p2, p3, p4, callback)
	local mergeKeypointTimes = ColorSequenceUtil.mergeKeypointTimes(p3, p4)
	local colorSequenceKeypoints = table.create(#mergeKeypointTimes)

	for _, mergeKeypointTime in ipairs(mergeKeypointTimes) do
		local eval = ColorSequenceUtil.eval(p3, mergeKeypointTime)
		table.insert(
			colorSequenceKeypoints,
			ColorSequenceKeypoint.new(mergeKeypointTime, callback(p, eval, eval, p2, mergeKeypointTime))
		)
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local function applyColorTransformationToProperty(instance, p, sequence, callback, callback2)
	if typeof(sequence) == "Color3" then
		local v = "DefaultColor_" .. p .. ""
		local attribute = instance:GetAttribute(v)

		if not attribute then
			instance:SetAttribute(v, sequence)
			attribute = sequence
		end

		local v2 = callback(instance, sequence, attribute, p)
		instance[p] = v2

		if p == "TintColor" then
			instance.TintColor = transformOnlyHue(sequence, v2)
		end
	elseif typeof(sequence) == "ColorSequence" then
		local v = "DefaultColor_" .. p .. "_Sequence"
		local attribute = instance:GetAttribute(v)

		if typeof(attribute) ~= "ColorSequence" then
			attribute = nil
		end

		if attribute == nil then
			local colorSequenceKeypoints = {}
			local flag = false

			for _, keypoint in ipairs(sequence.Keypoints) do
				local attribute2 = instance:GetAttribute("DefaultColor_" .. p .. "_" .. tostring(math.floor((keypoint.Time + 0.005) / 0.01) * 0.01):gsub(
					"%.",
					"_"
				))

				if typeof(attribute2) == "Color3" then
					flag = true
				else
					attribute2 = keypoint.Value
				end

				table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(keypoint.Time, attribute2))
			end

			if flag then
				attribute = ColorSequence.new(colorSequenceKeypoints)
			end
		end

		local v2 = attribute or sequence
		local v3

		if callback2 then
			v3 = callback2(instance, p, v2)
		end

		if v3 == nil and attribute == nil then
			local keypoints = sequence.Keypoints
			local colorSequenceKeypoints = {}

			for _, keypoint in ipairs(keypoints) do
				local v4 = p .. "_" .. tostring(math.floor((keypoint.Time + 0.005) / 0.01) * 0.01):gsub("%.", "_")
				local value = keypoint.Value
				local v5 = "DefaultColor_" .. v4 .. ""
				local attribute2 = instance:GetAttribute(v5)

				if attribute2 then
					value = attribute2
				else
					instance:SetAttribute(v5, value)
				end

				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(
						keypoint.Time,
						callback(instance, keypoint.Value, value, p, keypoint.Time)
					)
				)
			end

			instance[p] = ColorSequence.new(colorSequenceKeypoints)
		else
			if instance:GetAttribute(v) == nil then
				instance:SetAttribute(v, v2)
			end

			instance[p] = resampleSequence(instance, p, v2, v3, callback)
		end
	elseif typeof(sequence) == "Vector3" then
		local v = "DefaultColor_" .. p .. ""
		local attribute = instance:GetAttribute(v)

		if not attribute then
			instance:SetAttribute(v, sequence)
			attribute = sequence
		end

		local color = callback(instance, vertexColorToColor3(sequence), vertexColorToColor3(attribute), p)
		instance[p] = Vector3.new(color.R, color.G, color.B)
	end
end

local function applyColorTransformationToProperty_NoDefaultColors(p, p2, sequence, callback, callback2)
	if typeof(sequence) == "Color3" then
		local v = callback(p, sequence, sequence, p2)
		p[p2] = v

		if p2 == "TintColor" then
			p.TintColor = transformOnlyHue(sequence, v)
		end
	elseif typeof(sequence) == "ColorSequence" then
		local v

		if callback2 then
			v = callback2(p, p2, sequence)
		end

		if v ~= nil then
			p[p2] = resampleSequence(p, p2, sequence, v, callback)
			return
		end

		local keypoints = sequence.Keypoints
		local colorSequenceKeypoints = {}

		for _, keypoint in ipairs(keypoints) do
			local value = keypoint.Value
			table.insert(
				colorSequenceKeypoints,
				ColorSequenceKeypoint.new(keypoint.Time, callback(p, value, value, p2, keypoint.Time))
			)
		end

		p[p2] = ColorSequence.new(colorSequenceKeypoints)
	elseif typeof(sequence) == "Vector3" then
		local color = callback(p, vertexColorToColor3(sequence), vertexColorToColor3(sequence), p2)
		p[p2] = Vector3.new(color.R, color.G, color.B)
	end
end

local function AdjustObjectDescendantsColors(folder, callback, flag: boolean?, list, callback2)
	if list then
		local v

		if flag == true then
			v = applyColorTransformationToProperty
		else
			v = applyColorTransformationToProperty_NoDefaultColors
		end

		for _, v2 in ipairs(list) do
			local obj = v2.obj

			if not (obj.Parent ~= nil or obj == folder) then
				continue
			end

			for _, v3 in ipairs(v2.props) do
				v(obj, v3, obj[v3], callback, callback2)
			end
		end
	else
		local descendants = folder:GetDescendants()

		if flag == true then
			for _, descendant in ipairs(descendants) do
				local colorPropertiesFor = GetColorPropertiesFor(descendant)

				for _, v2 in ipairs(colorPropertiesFor) do
					applyColorTransformationToProperty(descendant, v2, descendant[v2], callback, callback2)
				end
			end

			local colorPropertiesFor2 = GetColorPropertiesFor(folder)

			for _, v2 in ipairs(colorPropertiesFor2) do
				applyColorTransformationToProperty(folder, v2, folder[v2], callback, callback2)
			end
		else
			for _, descendant in ipairs(descendants) do
				local colorPropertiesFor = GetColorPropertiesFor(descendant)

				for _, v2 in ipairs(colorPropertiesFor) do
					applyColorTransformationToProperty_NoDefaultColors(
						descendant,
						v2,
						descendant[v2],
						callback,
						callback2
					)
				end
			end

			local colorPropertiesFor2 = GetColorPropertiesFor(folder)

			for _, v2 in ipairs(colorPropertiesFor2) do
				applyColorTransformationToProperty_NoDefaultColors(folder, v2, folder[v2], callback, callback2)
			end
		end
	end
end

return AdjustObjectDescendantsColors