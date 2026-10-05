return function(items, p: string)
	local v = tonumber(p)

	if v == nil then
		return
	end

	for _, item in pairs(items) do
		if item.Character == nil then
			continue
		end

		local humanoid = item.Character:FindFirstChild("Humanoid")

		if humanoid == nil then
			continue
		end

		item.Character:SetAttribute("MaxHealthOverride", v)
		humanoid.MaxHealth = v
		humanoid.Health = v
	end
end