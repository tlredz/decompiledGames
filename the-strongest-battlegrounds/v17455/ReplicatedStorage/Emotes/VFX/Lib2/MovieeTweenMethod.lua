return function(instance, _)
	local info = instance:FindFirstChild("info")
	local goal = instance:FindFirstChild("goal")
	local tweens = {}

	if not info then
		warn("no info")
		return
	end

	if not goal then
		warn("no goal")
		return
	end

	local function createinfo(folder)
		local attributes = folder:FindFirstChild("info") and folder:FindFirstChild("info"):GetAttributes() or info:GetAttributes()
		return TweenInfo.new(
			attributes.time,
			Enum.EasingStyle[attributes.style],
			Enum.EasingDirection[attributes.direction],
			tonumber(attributes.Repeat),
			attributes.reverse,
			(tonumber(attributes.delay))
		)
	end

	for _, folder in goal:GetChildren() do
		if not folder:IsA("Folder") then
			return
		end

		local v2 = createinfo(folder)
		local attributes

		if folder.Name == "Part" or folder.Name == "MeshPart" then
			attributes = folder:GetAttributes()
		else
			attributes = false
		end

		if attributes then
			attributes.CFrame = instance.CFrame * attributes.CFrame
		end

		local tweenService = game.TweenService
		local v3 = instance:FindFirstChildOfClass(folder.Name) or instance

		if instance:FindFirstChildOfClass(folder.Name) or not attributes then
			attributes = folder:GetAttributes()
		end

		local v4 = tweenService:Create(v3, v2, attributes)
		tweens[folder.Name .. "Tween"] = v4
	end

	return {
		tweens = tweens,
		play = function()
			for _, v2 in tweens do
				v2:Play()
			end
		end
	}
end