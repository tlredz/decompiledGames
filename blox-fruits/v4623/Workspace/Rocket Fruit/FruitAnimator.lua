local function handleFruitEffects(folder)
	local track = nil

	if folder:FindFirstChild("Idle") then
		local animationController = folder:FindFirstChild("AnimationController")

		if animationController then
			track = animationController:LoadAnimation(folder.Idle)
		end
	end

	if not folder:IsDescendantOf(workspace) then
		repeat
			folder.Parent.AncestryChanged:Wait()
		until folder:IsDescendantOf(workspace)
	end

	if track then
		track:Play()
	end

	for _, script2 in pairs(folder:GetDescendants()) do
		if script2:IsA("Script") or script2:IsA("LocalScript") then
			script2.Enabled = true
		end
	end
end

if script.Parent:FindFirstChild("Fruit") then
	handleFruitEffects(script.Parent.Fruit)
end