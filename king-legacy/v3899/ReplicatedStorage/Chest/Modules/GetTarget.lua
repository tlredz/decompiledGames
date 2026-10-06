local GetTarget = {}

function GetTarget.getnearesttarget(p, value, p2)
	local magnitude = value or 25
	local v = nil

	for _, descendant in pairs(workspace:GetDescendants()) do
		if not (descendant:FindFirstChildOfClass("Humanoid") and descendant:FindFirstChild("HumanoidRootPart") and (descendant:FindFirstChild("HumanoidRootPart").Position - p).Magnitude <= magnitude) then
			continue
		end

		if not (descendant:FindFirstChildOfClass("Humanoid").Name ~= "FAKEHumanoid" and descendant.Name ~= p2.Name) then
			continue
		end

		magnitude = (descendant:FindFirstChild("HumanoidRootPart").Position - p).Magnitude
		v = descendant
	end

	return v
end

function GetTarget.getalltarget(p, value, p2)
	local v = value or 25
	local descendants = {}

	for _, descendant in pairs(workspace:GetDescendants()) do
		if not (descendant:FindFirstChildOfClass("Humanoid") and descendant:FindFirstChild("HumanoidRootPart") and (descendant:FindFirstChild("HumanoidRootPart").Position - p).Magnitude <= v) then
			continue
		end

		if not (descendant:FindFirstChildOfClass("Humanoid").Name ~= "FAKEHumanoid" and descendant.Name ~= p2.Name) then
			continue
		end

		descendants[#descendants + 1] = descendant
	end

	return descendants
end

return GetTarget