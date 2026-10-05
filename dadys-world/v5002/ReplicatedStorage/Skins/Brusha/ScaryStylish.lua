return {
	Name = "Scary Stylish",
	TowerName = "Brusha",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		instance:SetAttribute("PaintingTexture", "rbxassetid://132477664989824")
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://85387390140302"
		hurtTexture.Texture = "rbxassetid://102075867115318"
		normalTexture.Texture = "rbxassetid://135952933684257"
		local v = {
			Head = "Head_Geo",
			LegLeg = "LeftLeg"
		}

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local weld = Instance.new("Weld")
			local child = instance:WaitForChild(v[part.Name] or part.Name)
			local decal = child:FindFirstChild("Decal")

			if decal then
				decal.Parent = part
			end

			part.Parent = child
			weld.Parent = part
			weld.Part0 = part
			weld.Part1 = child
			part.Anchored = false
			child.Transparency = 1
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}