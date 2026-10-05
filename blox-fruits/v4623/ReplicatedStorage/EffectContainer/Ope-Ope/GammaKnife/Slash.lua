local currentCamera = workspace.CurrentCamera
local v = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value, function(_)
	local now = tick()

	for k, v2 in next, v, nil do
		local v3 = now - v2.Start

		if v2.Duration < v3 or not v2.Part.Parent then
			v2.BBG:Destroy()
			table.remove(v, k)
		else
			local v4 = math.clamp((v2.Part.Position - currentCamera.CFrame.p).Magnitude, 1, v2.Scale)
			local v5 = math.min(v3 / v2.Duration, 1)
			v2.BBG.Image.Rotation = v2.BBG.Image.Rotation % 360 + v2.Spd * v2.Direction
			v2.BBG.Size = UDim2.new(0, v4 * (1 - v5) * v2.Scale * 0.25, 0, v4 * v5 ^ 0.75 * v2.Scale)
			v2.BBG.Image.ImageColor3 = v2.Color[1]:Lerp(v2.Color[2], v5)
		end
	end
end)
return function(list)
	local v2, _, v3, v4 = unpack(list)
	local v5 = math.clamp(v2.Size.Magnitude * 5, 5, 15)

	if not v2.Parent then
		return
	end

	local color = typeof(v4) == "Color3" and { v4, v4 } or v4
	local clone = script.SlashBBG:Clone()
	clone.Image.Rotation = math.random(360)
	clone.Image.ImageColor3 = color[1] or Color3.new(1, 1, 1)
	clone.Parent = v2
	clone.Adornee = v2
	table.insert(v, {
		Duration = v3 or 0.2,
		Part = v2,
		BBG = clone,
		Scale = v5 or 10,
		Color = color,
		Direction = math.random(2) == 1 and 1 or -1,
		Spd = math.random(),
		Start = tick()
	})
end