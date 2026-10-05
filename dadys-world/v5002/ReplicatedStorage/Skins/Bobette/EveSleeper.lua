local CollectionService = game:GetService("CollectionService")
return {
	Name = "Eve Sleeper",
	HolidaySkin = true,
	ApplySkin = function(folder)
		local present = folder:WaitForChild("Present")
		local v = present:waitForChild("Box")
		local v2 = present:waitForChild("Bow")
		local ringRanger = folder:WaitForChild("RingRanger")

		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") and part ~= v and part ~= v2 and part ~= ringRanger then
				part.TextureID = "rbxassetid://127851419016918"
			end
		end

		v2.Color = Color3.new(1, 0.37254901960784315, 0.6862745098039216)
		v.Color = Color3.new(0.36470588235294116, 0.8196078431372549, 1)
		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://122132801977974"
		local normalTexture = config:WaitForChild("NormalTexture")
		normalTexture.Texture = "rbxassetid://127851419016918"
		local blinkTexture = config:WaitForChild("BlinkTexture")
		blinkTexture.Texture = "rbxassetid://117871232198660"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local weld = Instance.new("Weld")
			local child = folder:WaitForChild(part.Name)
			CollectionService:removeTag(child, "SkinPart")
			part.Parent = child
			weld.Parent = part
			weld.Part0 = part
			weld.Part1 = child
			part.Anchored = false
			child.Transparency = 1
			child:AddTag("StayTransparent")
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}