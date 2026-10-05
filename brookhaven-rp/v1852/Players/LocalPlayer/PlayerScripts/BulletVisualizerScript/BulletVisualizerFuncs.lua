return {
	GetHitSurfaceCFrame = function(p, instance)
		if instance == nil or p == nil then
			return
		end

		local v = {
			{ "Back", instance.CFrame * CFrame.new(0, 0, instance.Size.z) },
			{ "Bottom", instance.CFrame * CFrame.new(0, -instance.Size.y, 0) },
			{ "Front", instance.CFrame * CFrame.new(0, 0, -instance.Size.z) },
			{ "Left", instance.CFrame * CFrame.new(-instance.Size.x, 0, 0) },
			{ "Right", instance.CFrame * CFrame.new(instance.Size.x, 0, 0) },
			{ "Top", instance.CFrame * CFrame.new(0, instance.Size.y, 0) }
		}
		local v2 = 1e999
		local v3 = nil

		for _, v4 in pairs(v) do
			local magnitude = (p - v4[2].p).magnitude

			if not (magnitude < v2) then
				continue
			end

			v3 = v4
			v2 = magnitude
		end

		return v3[2]
	end
}