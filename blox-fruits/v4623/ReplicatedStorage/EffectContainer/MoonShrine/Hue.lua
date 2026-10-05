workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
require(ReplicatedStorage:WaitForChild("Effect"))
local _ = Util.Debris
local _ = Util.BoatTween
local v = {
	TintColor = Color3.fromRGB(210, 215, 255),
	Contrast = 0.1,
	Saturation = 0.1
}

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local colorCorrectionEffect = nil
local v2 = false
local v3 = "in"
local lastTime = os.clock()

local function trigger()
	lastTime = os.clock()

	if not v2 then
		v2 = true

		while v2 ~= false and colorCorrectionEffect do
			local v4 = os.clock() - lastTime
			local v5 = math.min(1, v4 / 0.5)

			if v3 == "in" then
				colorCorrectionEffect.TintColor = colorCorrectionEffect.TintColor:Lerp(v.TintColor, v5)
				local v6 = colorCorrectionEffect
				local saturation = colorCorrectionEffect.Saturation
				v6.Saturation = saturation + (0.1 - saturation) * v5
				local v7 = colorCorrectionEffect
				local contrast = colorCorrectionEffect.Contrast
				v7.Contrast = contrast + (0.1 - contrast) * v5
			else
				colorCorrectionEffect.TintColor = colorCorrectionEffect.TintColor:Lerp(
					Color3.fromRGB(255, 255, 255),
					v5
				)
				local v6 = colorCorrectionEffect
				local saturation = colorCorrectionEffect.Saturation
				v6.Saturation = saturation + (0 - saturation) * v5
				local v7 = colorCorrectionEffect
				local contrast = colorCorrectionEffect.Contrast
				v7.Contrast = contrast + (0 - contrast) * v5

				if v4 >= 0.5 then
					colorCorrectionEffect:Destroy()
					colorCorrectionEffect = nil
					v3 = "in"
					v2 = false
				end
			end

			RunService.RenderStepped:Wait()
		end
	end
end

return function(p)
	if p.Action == "FadeIn" then
		v3 = "in"
	else
		v3 = "out"
	end

	if colorCorrectionEffect == nil then
		colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Parent = Lighting
		colorCorrectionEffect.Name = "MoonShrineCC"
	end

	trigger()
end