local function freezeConstraints(folder)
	local descendants = {}
	local v = {}

	for _, descendant in folder:GetDescendants() do
		if not descendant:IsA("Constraint") or descendant:IsA("RigidConstraint") or not descendant.Attachment0 or not descendant.Attachment0.Parent then
			continue
		end

		if not (descendant.Attachment1 and descendant.Attachment1.Parent) then
			continue
		end

		descendant.Enabled = false
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = descendant.Attachment0.Parent
		weldConstraint.Part1 = descendant.Attachment1.Parent
		weldConstraint.Parent = descendant.Parent
		table.insert(descendants, descendant)
		table.insert(v, weldConstraint)
	end

	return function()
		for _, v2 in descendants do
			if v2.Parent then
				v2.Enabled = true
			end
		end

		for _, v2 in v do
			if v2.Parent then
				v2:Destroy()
			end
		end
	end
end

local function EMPTY_FUNCTION() end

local function freezeSwordConstraints(character)
	if not character then
		return EMPTY_FUNCTION
	end

	if typeof(character) == "Instance" then
		if character:IsA("Player") then
			character = character.Character
		end
	else
		character = character.Character
	end

	if not character then
		return EMPTY_FUNCTION
	end

	local currentlyEquippedSword = character:GetAttribute("CurrentlyEquippedSword")
	local child = currentlyEquippedSword and character:FindFirstChild(currentlyEquippedSword)

	if child then
		return (freezeConstraints(child))
	end

	return EMPTY_FUNCTION
end

return freezeSwordConstraints