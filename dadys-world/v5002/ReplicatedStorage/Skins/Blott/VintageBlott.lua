return {
	Name = "Vintage Blot",
	Mastery = true,
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") then
				part.TextureID = "rbxassetid://80398903223351"
			end

			if not (part.Name == "LeftFoot" or part.Name == "RightFoot") then
				continue
			end

			part.TextureID = ""
			part.Color = Color3.new(0, 0, 0)
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://85255709382407"
		local normalTexture = config:WaitForChild("NormalTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://80398903223351"
		blinkTexture.Texture = "rbxassetid://102442514304595"
	end
}