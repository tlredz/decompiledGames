local function restCFrames(folder)
	local result = {}
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return result
	end

	local v = {}

	for _, motor6D in ipairs(folder:GetDescendants()) do
		if not (motor6D:IsA("Motor6D") and motor6D.Part0 and motor6D.Part1) then
			continue
		end

		local motor6Ds = v[motor6D.Part0]

		if not motor6Ds then
			motor6Ds = {}
			v[motor6D.Part0] = motor6Ds
		end

		table.insert(motor6Ds, motor6D)
	end

	result[humanoidRootPart] = CFrame.identity
	local part1s = { humanoidRootPart }
	local v2 = 1

	while v2 <= #part1s do
		local v3 = part1s[v2]
		v2 += 1

		for _, v4 in ipairs(v[v3] or {}) do
			local part1 = v4.Part1

			if not part1 or result[part1] then
				continue
			end

			result[part1] = result[v3] * v4.C0 * v4.C1:Inverse()
			table.insert(part1s, part1)
		end
	end

	return result
end

return function(player)
	local character = player.Character

	if not player.Muscle or not character or not character:IsA("Model") or character:FindFirstChild("PowerUpMuscle") then
		return
	end

	local muscle = script.Parent:FindFirstChild("Muscle")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not (muscle and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return
	end

	local lowerTorso = muscle:FindFirstChild("LowerTorso")
	local lowerTorso2 = character:FindFirstChild("LowerTorso")

	if not (lowerTorso and lowerTorso:IsA("BasePart") and lowerTorso2 and lowerTorso2:IsA("BasePart")) then
		return
	end

	local vector = Vector3.new(humanoidRootPart.Size.X / 2, humanoidRootPart.Size.Y / 2, humanoidRootPart.Size.Z)
	local v = restCFrames(character)
	local v2 = v[lowerTorso2]
	local folder = Instance.new("Folder")
	folder.Name = "PowerUpMuscle"
	local v3 = {}

	for _, part in ipairs(muscle:GetChildren()) do
		local part2 = character:FindFirstChild(part.Name)

		if not (part:IsA("BasePart") and part2 and part2:IsA("BasePart")) then
			continue
		end

		local full = part.Size * vector
		local clone = part:Clone()
		clone.Size = full * 0.06
		clone.Anchored = false
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.Massless = true
		clone:SetAttribute("FullSize", full)
		clone.Color = part2.Color
		local identity = CFrame.identity
		local cframe = v[part2]

		if v2 and cframe then
			local v5 = lowerTorso.CFrame:Inverse() * part.CFrame
			identity = cframe:Inverse() * v2 * CFrame.new(v5.Position * vector) * v5.Rotation
		end

		local weld = Instance.new("Weld")
		weld.Name = "MuscleWeld"
		weld.Part0 = part2
		weld.Part1 = clone
		weld.C0 = identity
		weld.Parent = clone
		clone.Parent = folder
		table.insert(v3, {
			part = clone,
			full = full
		})
	end

	if #v3 == 0 then
		folder:Destroy()
		return
	end

	folder.Parent = character
	task.delay(1.2, function()
		for _, v4 in ipairs(v3) do
			if v4.part.Parent then
				v4.part.Size = v4.full
			end
		end
	end)
end