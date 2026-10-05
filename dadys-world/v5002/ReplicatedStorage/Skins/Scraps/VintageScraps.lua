local VintageScraps = {}
VintageScraps.Name = "Vintage Scraps"

function VintageScraps.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = "rbxassetid://17661517579"
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	hurtTexture.Texture = "rbxassetid://17661520899"
	local normalTexture = config:WaitForChild("NormalTexture")
	normalTexture.Texture = "rbxassetid://17661517579"
end

function VintageScraps.UseAbility(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			descendant.TextureID = "rbxassetid://17661517579"
		elseif descendant:IsA("RopeConstraint") then
			descendant.Color = BrickColor.new("Fossil")
		end
	end
end

return VintageScraps