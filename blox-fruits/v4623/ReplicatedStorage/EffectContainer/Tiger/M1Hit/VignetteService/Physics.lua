local Physics = {
	joint = {}
}

function Physics.joint.new(part, p, C0, p2)
	local weld = Instance.new("Weld")
	weld.Part0 = part
	weld.Part1 = p

	if C0 then
		weld.C0 = C0
		weld.C1 = p2 or CFrame.new()
	else
		weld.C0 = CFrame.new()
		weld.C1 = p.CFrame:toObjectSpace(part.CFrame)
	end

	weld.Parent = p
	return weld
end

function Physics.joint.combine(instance, p)
	for _, part in ipairs(instance:GetChildren()) do
		if (part:IsA("BasePart") or part:IsA("UnionOperation")) and part ~= p then
			Physics.joint.new(part, p)
			part.Anchored = false
		end

		p.Anchored = false
	end
end

return Physics