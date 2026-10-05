local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Figure Painter",
	TowerName = "Brusha",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W3,
	Christmas = true,
	HolidaySkin = true,
	ApplySkin = function(instance)
		instance:SetAttribute("PaintingTexture", "rbxassetid://104569967910856")
		local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local config = instance:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://107439465718965"
		hurtTexture.Texture = "rbxassetid://97557684082275"
		normalTexture.Texture = "rbxassetid://125888824724607"
		local v = {
			Head = "Head_Geo"
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