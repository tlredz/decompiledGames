return {
	Colors = {
		[0] = Color3.fromRGB(255, 255, 255),
		[200] = Color3.fromRGB(255, 173, 42),
		[1000] = Color3.fromRGB(85, 255, 127),
		[3000] = Color3.fromRGB(85, 170, 255),
		[10000] = Color3.fromRGB(255, 240, 70),
		[50000] = Color3.fromRGB(153, 85, 255),
		[100000] = Color3.fromRGB(0, 255, 255),
		[1000000] = Color3.fromRGB(255, 219, 90),
		[2000000] = Color3.fromRGB(255, 160, 206)
	},
	GetColorForReputation = function(p, p2: number)
		local v = 0

		for k, _ in next, p.Colors, nil do
			if k <= p2 and v < k then
				v = k
			end
		end

		return p.Colors[v]
	end
}