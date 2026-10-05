local v = {
	Brightness = 0,
	Contrast = -2,
	Saturation = -1,
	TintColor = Color3.fromRGB(255, 255, 255)
}
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
colorCorrectionEffect.Brightness = 0
colorCorrectionEffect.Contrast = -2
colorCorrectionEffect.Saturation = 0
colorCorrectionEffect.TintColor = Color3.new(1, 1, 1)

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local function Routine(p, fn)
	local lastTime = tick()
	local v2 = false

	while tick() - lastTime < p do
		local v3 = tick() - lastTime

		if fn(v3, v3 / p) then
			v2 = true
			break
		else
			RunService.RenderStepped:Wait()
		end
	end

	if not v2 then
		fn(p, 1)
	end
end

return function(p)
	local duration = p.Duration
	local clone = colorCorrectionEffect:Clone()
	clone.Parent = Lighting
	Routine(duration * 0.2, function(_, p2)
		for k, v2 in next, v, nil do
			if type(clone[k]) == "number" then
				clone[k] = 0 + (v2 - 0) * p2
			else
				clone[k] = Color3.new(1, 1, 1):lerp(v2, p2)
			end
		end
	end)
	wait(duration * 0.6)
	Routine(duration * 0.2, function(_, p2)
		for k, v2 in next, v, nil do
			if type(clone[k]) == "number" then
				clone[k] = v2 + (0 - v2) * p2
			else
				clone[k] = v2:lerp(Color3.new(1, 1, 1), p2)
			end
		end
	end)
	clone:Destroy()
end