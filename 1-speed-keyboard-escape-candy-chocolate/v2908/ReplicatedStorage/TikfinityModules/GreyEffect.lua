local Lighting = game:GetService("Lighting")
local count = 0
return {
	Run = function(_)
		count += 1
		local v = count
		local tikfinityGreyEffect = Lighting:FindFirstChild("TikfinityGreyEffect")

		if tikfinityGreyEffect then
			tikfinityGreyEffect:Destroy()
		end

		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "TikfinityGreyEffect"
		colorCorrectionEffect.Saturation = -1
		colorCorrectionEffect.Parent = Lighting
		task.delay(5, function()
			if count == v and colorCorrectionEffect.Parent then
				colorCorrectionEffect:Destroy()
			end
		end)
	end
}