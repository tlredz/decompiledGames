return function()
	local Workspace = game:GetService("Workspace")
	local worldOrigin = Workspace:FindFirstChild("WorldOrigin")

	if worldOrigin then
		local clone = worldOrigin:Clone()

		for _, child in clone:GetChildren() do
			if child.Name == "PlayerAccessoriesProxy" then
				child:Destroy()
			end
		end

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("BaseScript") or descendant:IsA("ModuleScript") then
				descendant:Destroy()
			else
				for _, tag in descendant:GetTags() do
					descendant:RemoveTag(tag)
				end

				if descendant:IsA("BasePart") then
					descendant.CanCollide = false
					descendant.Anchored = true
				end

				for k, _ in pairs(descendant:GetAttributes()) do
					descendant:SetAttribute(k, nil)
				end
			end
		end

		clone.Parent = workspace
		worldOrigin.Parent = nil
	end
end