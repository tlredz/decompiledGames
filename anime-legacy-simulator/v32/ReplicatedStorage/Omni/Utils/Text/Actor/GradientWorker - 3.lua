local color = Color3.new(1, 1, 1)
local color2 = Color3.new(0, 0, 1)
local color3 = Color3.new(1, 1, 1)
local color4 = Color3.new(0, 0, 1)
script:GetActor():BindToMessageParallel("Update", function(instance, list, p: string, data, data2)
	local now = tick()
	local flag = false
	local v = {}
	local v2 = {}

	if p == "Wave" then
		local v3 = #list
		local time = data.Time or 3
		local v4 = now % time / time
		local baseColor = data.BaseColor or color
		local waveColor = data.WaveColor or color2

		for k in list do
			v[k] = {
				TextColor3 = waveColor:Lerp(baseColor, math.sin((k / v3 - v4) * 3.141592653589793 * 2) * 0.5 + 0.5)
			}
		end
	elseif p == "Sparkling" then
		local time = data.Time or 3
		local v3 = math.sin(now % time / time * 3.141592653589793 * 2) * 0.5 + 0.5
		local baseColor = data.BaseColor or color3
		local lerped = (data.SparkColor or color4):Lerp(baseColor, v3)

		for k in list do
			v[k] = {
				TextColor3 = lerped
			}
		end
	elseif p == "Jitter" then
		local intensity = data.Intensity or 0.1
		local v3 = (math.random() - 0.5) * intensity * 2
		local v4 = (math.random() - 0.5) * intensity * 2

		for k in list do
			v[k] = {
				Offset = Vector2.new(v3, v4)
			}
		end
	end

	if data2.Name == "Fade" then
		local time = data2.Params.Time or 1
		local v3 = now - data2.Time
		local count = #data2.Characters
		local v4 = math.min(1, v3 / (time * count))
		local v5 = 1 / count

		for k in data2.Characters do
			local v6 = 1 - math.min(1, math.max(0, v4 - (k - 1) * v5) / v5)
			v2[k] = {
				TextTransparency = v6,
				StrokeTransparency = v6
			}
		end

		if v4 == 1 then
			flag = true
		end
	elseif data2.Name == "FadeUp" then
		local time = data2.Params.Time or 1
		local v3 = now - data2.Time
		local count = #data2.Characters
		local v4 = math.min(1, v3 / (time * count))
		local v5 = 1 / count
		local amount = data2.Params.Amount or 1

		for k in data2.Characters do
			local v6 = 1 - math.min(1, math.max(0, v4 - (k - 1) * v5) / v5)
			local v7 = amount * v6
			v2[k] = {
				Offset = Vector2.new(0, v7),
				TextTransparency = v6,
				StrokeTransparency = v6
			}
		end

		if v4 == 1 then
			flag = true
		end
	end

	task.synchronize()

	if instance:GetAttribute("TextGeneration") ~= data2.Generation then
		return
	end

	if instance:GetAttribute("Appeared") == true then
		table.clear(v2)
		flag = false
	end

	local v3 = {}
	local v4 = {}

	for k, character in data2.Characters do
		v3[character] = k
	end

	for k, v5 in v do
		local v6 = list[k]

		if not v6 then
			continue
		end

		local v7 = v3[v6]

		if v7 then
			v4[v7] = v5
		end
	end

	for k, v5 in v2 do
		local v6 = v4[k]

		if v6 then
			for k2, offset in v5 do
				if k2 == "Offset" then
					local offset2 = v6.Offset

					if offset2 then
						v6.Offset = offset2 + offset
					else
						v6.Offset = offset
					end
				else
					v6[k2] = offset
				end
			end
		else
			v4[k] = v5
		end
	end

	for k, v5 in v4 do
		local character = data2.Characters[k]

		if not character then
			continue
		end

		for k2, transparency in v5 do
			if k2 == "StrokeTransparency" then
				local uIStroke = character:FindFirstChildWhichIsA("UIStroke")

				if uIStroke then
					uIStroke.Transparency = transparency
				end
			elseif k2 == "Offset" then
				local X = character.AbsoluteSize.X
				local Y = character.AbsoluteSize.Y
				local originalPosition = character:GetAttribute("OriginalPosition")

				if not originalPosition then
					originalPosition = character.Position
					character:SetAttribute("OriginalPosition", originalPosition)
				end

				character.Position = originalPosition + UDim2.fromOffset(X * transparency.X, Y * transparency.Y)
			else
				character[k2] = transparency
			end
		end
	end

	if flag then
		instance:SetAttribute("Appeared", true)
	end
end)