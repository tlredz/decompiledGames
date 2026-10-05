local createVector = vector.create
return function(folder)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0.2)
	local v = {
		Transparency = 1,
		Color = Color3.fromRGB(255, 255, 255)
	}
	local v2 = {
		Transparency = 1
	}

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("CharacterAppearance") then
			descendant:Destroy()
		end

		if descendant:IsA("Decal") then
			local TweenService = game:GetService("TweenService")
			TweenService:Create(descendant, tweenInfo, v2):Play()
		end

		if descendant:FindFirstChild("Mesh") then
			descendant.Mesh.TextureId = ""
			descendant.Mesh.VertexColor = createVector(175, 221, 255)
		end

		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.BrickColor = BrickColor.new("Pastel light blue")

			if descendant:IsA("MeshPart") then
				descendant.TextureID = ""
			end

			local TweenService = game:GetService("TweenService")
			TweenService:Create(descendant, tweenInfo, v):Play()
			local clone = script.Frost:Clone()
			clone.Parent = descendant
			clone.Enabled = true
			spawn(function()
				wait(0.25)
				clone.Enabled = false
			end)
		end

		if not descendant:IsA("BasePart") then
			continue
		end

		local PhysicsService = game:GetService("PhysicsService")
		PhysicsService:SetPartCollisionGroup(descendant, "AnchoredRagdolls")
	end
end