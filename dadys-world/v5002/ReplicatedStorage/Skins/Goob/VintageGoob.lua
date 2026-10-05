local VintageGoob = {}
VintageGoob.Name = "Vintage Goob"

function VintageGoob.ApplySkin(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			descendant.TextureID = "rbxassetid://17676097246"
		elseif descendant:IsA("RopeConstraint") then
			descendant.Color = BrickColor.new("Really black")
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	hurtTexture.Texture = "rbxassetid://17676099941"
	local normalTexture = config:WaitForChild("NormalTexture")
	normalTexture.Texture = "rbxassetid://17676097246"
end

function VintageGoob.UseAbility(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			descendant.TextureID = "rbxassetid://17676097246"
		elseif descendant:IsA("RopeConstraint") then
			descendant.Color = BrickColor.new("Really black")
		end
	end
end

return VintageGoob