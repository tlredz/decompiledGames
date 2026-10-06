local v = {
	Single = {
		Color3 = { "Decal", "Texture" },
		Color = {
			"Part",
			"Union",
			"MeshPart",
			"SpotLight",
			"PointLight",
			"SurfaceLight",
			"SurfaceAppearance"
		}
	},
	Sequence = {
		Color = { "Beam", "Trail", "ParticleEmitter" }
	}
}

local function warp(p: number)
	return (p % 1 + 1) % 1
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function multiplyHue(HSV: number, HSV2: number)
	return ((HSV + (HSV2 - 0.5) * 1) % 1 + 1) % 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function multiplyChannel(p: number, p2: number)
	local v2 = p2 * 2 - 1

	if v2 >= 0 then
		return (math.clamp(p + (1 - p) * v2, 0, 1))
	end

	return (math.clamp(p - p * math.abs(v2), 0, 1))
end

local function normalizeColor(color: Color3)
	local R = color.R
	local G = color.G
	local B = color.B
	local v2 = math.max(1, R, G, B)
	return v2, Color3.new(R / v2, G / v2, B / v2)
end

local function multiplyRGB(color: Color3, p: number)
	return Color3.new(color.R * p, color.G * p, color.B * p)
end

local function recolorObj(part, color: Color3, p: string, flag: boolean)
	if not flag and part:IsA("BasePart") then
		return
	end

	local HSV, v2, v3 = color:ToHSV()

	for _, v4 in v do
		for k, list in v4 do
			if not table.find(list, part.ClassName) then
				continue
			end

			local v5 = part[k]

			if p == "multiply" then
				if typeof(v5) == "Color3" then
					local R = v5.R
					local G = v5.G
					local B = v5.B
					local v6 = math.max(1, R, G, B)
					local HSV2, v7, v8 = Color3.new(R / v6, G / v6, B / v6):ToHSV()
					local v9 = multiplyHue(HSV2, HSV)
					local v10 = multiplyChannel(v7, v2) -- equivalent call inferred; original call site unknown
					local v11 = multiplyChannel(v8, v3) -- equivalent call inferred; original call site unknown
					local color2 = Color3.fromHSV(v9, v10, v11)
					part[k] = Color3.new(color2.R * v6, color2.G * v6, color2.B * v6)
				elseif typeof(v5) == "ColorSequence" then
					local colorSequenceKeypoints = {}

					for _, keypoint in v5.Keypoints do
						local value = keypoint.Value
						local R = value.R
						local G = value.G
						local B = value.B
						local v6 = math.max(1, R, G, B)
						local HSV2, v7, v8 = Color3.new(R / v6, G / v6, B / v6):ToHSV()
						local v9 = multiplyHue(HSV2, HSV)
						local v10 = multiplyChannel(v7, v2) -- equivalent call inferred; original call site unknown
						local v11 = multiplyChannel(v8, v3) -- equivalent call inferred; original call site unknown
						table.insert(
							colorSequenceKeypoints,
							ColorSequenceKeypoint.new(keypoint.Time, multiplyRGB(Color3.fromHSV(v9, v10, v11), v6))
						)
					end

					part[k] = ColorSequence.new(colorSequenceKeypoints)
				end
			elseif typeof(v5) == "Color3" then
				local R = v5.R
				local G = v5.G
				local B = v5.B
				local v6 = math.max(1, R, G, B)
				Color3.new(R / v6, G / v6, B / v6)
				part[k] = Color3.new(color.R * v6, color.G * v6, color.B * v6)
			elseif typeof(v5) == "ColorSequence" then
				part[k] = ColorSequence.new(color)
			end
		end
	end
end

local function recolor(color: Color3, p: string, ...)
	for _, folder in { ... } do
		recolorObj(folder, color, p, true)

		for _, descendant in folder:GetDescendants() do
			recolorObj(descendant, color, p, false)
		end
	end
end

return recolor