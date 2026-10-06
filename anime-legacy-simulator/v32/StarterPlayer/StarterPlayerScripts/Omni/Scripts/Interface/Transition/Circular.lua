require("@game/ReplicatedStorage/Omni")
local Circular = {}

function Circular.In(p: number, items)
	if p < 0.5 then
		local v = p * 2

		for _, item in items do
			local v2 = math.clamp(v - (item.Distance - item.Distance * 0.25), 0, 0.25) / 0.25
			item.Instance.Size = UDim2.fromScale(item.Size * v2, item.Size * v2)
			item.Instance.BackgroundTransparency = 0
		end
	else
		local v = (p - 0.5) * 2

		for _, item in items do
			local v2 = math.clamp(v - (item.Distance - item.Distance * 0.25), 0, 0.25) / 0.25
			item.Instance.Size = UDim2.fromScale(item.Size * (1 - v2), item.Size * (1 - v2))
			item.Instance.BackgroundTransparency = 0
		end
	end
end

function Circular.Out(p: number, items)
	if p < 0.5 then
		local v = p * 2

		for _, item in items do
			local v2 = math.clamp(1 - (item.Distance - item.Distance * 0.25) - v, 0, 0.25) / 0.25
			item.Instance.Size = UDim2.fromScale(item.Size * (1 - v2), item.Size * (1 - v2))
			item.Instance.BackgroundTransparency = 0
		end
	else
		local v = (p - 0.5) * 2

		for _, item in items do
			local v2 = math.clamp(1 - (item.Distance - item.Distance * 0.25) - v, 0, 0.25) / 0.25
			item.Instance.Size = UDim2.fromScale(item.Size * v2, item.Size * v2)
			item.Instance.BackgroundTransparency = 0
		end
	end
end

return Circular