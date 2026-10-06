require("@game/ReplicatedStorage/Omni")
return {
	Update = function(p: number, _: number, items)
		if p < 0.5 then
			local v = p * 2

			for _, item in items do
				local v2 = math.clamp((item.Distance + v - 1) / 0.25, 0, 1)
				item.Instance.BackgroundTransparency = 1 - v2
			end
		else
			local v = (p - 0.5) * 2

			for _, item in items do
				local backgroundTransparency = math.clamp((v - (1 - item.Distance)) / 0.25, 0, 1)
				item.Instance.BackgroundTransparency = backgroundTransparency
			end
		end
	end
}