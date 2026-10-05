return {
	Btn = 1,
	SortOrder = 2,
	Desc = "Reverse the colors and see the world in a new view",
	Callback = function(p)
		if p == true then
			local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Saturation = -2
			colorCorrectionEffect.Name = "InvertCC"
			colorCorrectionEffect.Parent = game.Lighting
		else
			local invertCC = game.Lighting:FindFirstChild("InvertCC")

			if invertCC then
				invertCC:Destroy()
			end
		end
	end
}