return function(part)
	local function weldBetween(part2, part3)
		local manualWeld = Instance.new("ManualWeld", part2)
		manualWeld.C0 = part2.CFrame:inverse() * part3.CFrame
		manualWeld.Part0 = part2
		manualWeld.Part1 = part3
		part2.Anchored = false
		part3.Anchored = false
		part2.CanCollide = false
		part3.CanCollide = false
		return manualWeld
	end

	for _, child in pairs(part:GetChildren()) do
		if child:IsA("BasePart") then
			local manualWeld = Instance.new("ManualWeld", child)
			manualWeld.C0 = child.CFrame:inverse() * part.CFrame
			manualWeld.Part0 = child
			manualWeld.Part1 = part
			child.Anchored = false
			part.Anchored = false
			child.CanCollide = false
			part.CanCollide = false
		end

		if not child:IsA("Model") then
			continue
		end

		for _, part2 in pairs(part:GetChildren()) do
			if not part2:IsA("BasePart") then
				continue
			end

			local manualWeld = Instance.new("ManualWeld", part2)
			manualWeld.C0 = part2.CFrame:inverse() * part.CFrame
			manualWeld.Part0 = part2
			manualWeld.Part1 = part
			part2.Anchored = false
			part.Anchored = false
			part2.CanCollide = false
			part.CanCollide = false
		end
	end
end