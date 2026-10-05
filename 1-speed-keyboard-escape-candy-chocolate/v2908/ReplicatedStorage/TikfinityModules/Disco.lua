local Disco = {}
local Lighting = game:GetService("Lighting")
game:GetService("Debris")
local _ = {
	DURATION = 3,
	FLASH_INTERVAL = 0.15
}
local v = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 100, 255),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(255, 0, 255),
	Color3.fromRGB(0, 255, 255),
	Color3.fromRGB(255, 128, 0)
}

function Disco.Run(_)
	task.spawn(function()
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "TikfinityDisco"
		colorCorrectionEffect.Parent = Lighting
		local lastTime = os.clock()
		local v2 = 1

		while os.clock() - lastTime < 3 do
			colorCorrectionEffect.TintColor = v[v2]
			v2 = v2 % #v + 1
			task.wait(0.15)
		end

		colorCorrectionEffect:Destroy()
	end)
end

return Disco