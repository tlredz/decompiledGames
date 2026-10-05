local module = require("../util")
local v = { "Eyes" }
local BasicProperties = {}

function BasicProperties.MutateModel(p, data)
	local random = Random.new(p.HashSeed)
	local handleColorBehavior

	handleColorBehavior = function(color: Color3, color2)
		if color2 == module.ORIGINAL_COLOR then
			return color
		end

		if not data.PreserveColorHSV and not data.ColorRandomRGB and not data.ColorRandomHSV and (typeof(color2) ~= "table" or not table.find(
			color2,
			module.ORIGINAL_COLOR
		)) then
			return color2
		end

		if typeof(color2) == "table" then
			local result = table.create(#color2)

			for _, v2 in color2 do
				if v2 == module.ORIGINAL_COLOR then
					table.insert(result, color)
				else
					table.insert(result, handleColorBehavior(color, v2, data))
				end
			end

			return result
		else
			if data.PreserveColorHSV then
				local HSV, v2, v3 = color:ToHSV()
				local HSV2, v4, v5 = color2:ToHSV()
				color2 = Color3.fromHSV(
					math.lerp(HSV2, HSV, data.PreserveColorHSV[1] or 0),
					math.lerp(v4, v2, data.PreserveColorHSV[2] or 0),
					(math.lerp(v5, v3, data.PreserveColorHSV[3] or 0))
				)
			end

			if data.ColorRandomRGB then
				local v2 = data.ColorRandomRGB[1] or 0
				local v3 = data.ColorRandomRGB[2] or 0
				local v4 = data.ColorRandomRGB[3] or 0
				local clone = random:Clone()
				color2 = Color3.fromRGB(
					math.clamp(color2.R * 255 + clone:NextInteger(0, v2), 0, 255),
					math.clamp(color2.G * 255 + clone:NextInteger(0, v3), 0, 255),
					(math.clamp(color2.B * 255 + clone:NextInteger(0, v4), 0, 255))
				)
			end

			if not data.ColorRandomHSV then
				return color2
			end

			local v2 = data.ColorRandomHSV[1] or 0
			local v3 = data.ColorRandomHSV[2] or 0
			local v4 = data.ColorRandomHSV[3] or 0
			local clone = random:Clone()
			local HSV, v5, v6 = color2:ToHSV()
			color2 = Color3.fromHSV(
				(HSV + clone:NextNumber(0, v2)) % 1,
				math.clamp(v5 + clone:NextNumber(0, v3), 0, 1),
				(math.clamp(v6 + clone:NextNumber(0, v4), 0, 1))
			)
			return color2
		end
	end

	for _, part in p.Model:GetDescendants() do
		if not part:IsA("BasePart") or table.find(data.IgnoreNames or v, part.Name) then
			continue
		end

		if not (part.Transparency < 1 or data.NameOverrides and data.NameOverrides[part.Name]) then
			continue
		end

		local v2 = not data.NameOverrides and {} or data.NameOverrides[part.Name] or {}
		local colorSets = v2.ColorSets or data.ColorSets
		local transparencySets = v2.TransparencySets or data.TransparencySets
		local materials = v2.Materials or data.Materials
		local reflectance = v2.Reflectance or data.Reflectance
		local v3 = nil
		local v4 = nil
		random:NextNumber()

		if colorSets and #colorSets > 0 then
			local colorSet = colorSets[random:Clone():NextInteger(1, #colorSets)]
			local color = handleColorBehavior(part.Color, colorSets[colorSet])
			local surfaceAppearance = part:FindFirstChildOfClass("SurfaceAppearance")
			local dataModelMesh = part:FindFirstChildWhichIsA("DataModelMesh")

			if typeof(color) == "Color3" then
				part.Color = color

				if surfaceAppearance then
					surfaceAppearance.Color = color
				end

				if dataModelMesh then
					dataModelMesh.VertexColor = Vector3.new(color.R, color.G, color.B)
				end
			else
				part.Color = color[1]

				if surfaceAppearance then
					surfaceAppearance.Color = color[1]
				end

				if dataModelMesh then
					dataModelMesh.VertexColor = Vector3.new(color[1].R, color[1].G, color[1].B)
				end

				v3 = color
			end
		end

		if transparencySets and #transparencySets > 0 then
			local transparencySet = transparencySets[transparencySets[random:Clone():NextInteger(1, #transparencySets)]]

			if typeof(transparencySet) == "number" then
				part.Transparency = transparencySet
			else
				part.Transparency = transparencySet[1]
				v4 = transparencySet
			end
		end

		if materials then
			if typeof(materials) == "EnumItem" then
				part.Material = materials
			elseif typeof(materials) == "table" and #materials > 0 then
				part.Material = materials[materials[random:Clone():NextInteger(1, #materials)]]
			end
		end

		if reflectance then
			if typeof(reflectance) == "number" then
				part.Reflectance = reflectance
			elseif typeof(reflectance) == "table" and #reflectance > 0 then
				part.Reflectance = reflectance[reflectance[random:Clone():NextInteger(1, #reflectance)]]
			end
		end

		if not (v3 or v4) then
			continue
		end

		local fadeTime = data.FadeTime or 1

		if typeof(fadeTime) == "table" then
			fadeTime = random:NextNumber(fadeTime[1], fadeTime[2])
		end

		module.colorPulse(part, fadeTime, v3, v4)
	end
end

function BasicProperties:new()
	self.Type = "BasicProperties"
	return self
end

return BasicProperties