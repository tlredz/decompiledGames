local VintageScraps = {
	Name = "Vintage Scraps",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://76741729863078",
		Blink = "rbxassetid://106681119524959",
		Hurt = "rbxassetid://75321884934972"
	},
	USE_SKIN_MODEL = false
}

function VintageScraps.ApplySkin(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			descendant.TextureID = VintageScraps.FaceTextures.Normal
		elseif descendant:IsA("RopeConstraint") then
			descendant.Color = BrickColor.new("Fossil")
		end
	end
end

function VintageScraps.UseAbility(instance, folder)
	for _, ropeConstraint in pairs(folder:GetDescendants()) do
		if ropeConstraint:IsA("RopeConstraint") then
			ropeConstraint.Color = BrickColor.new("Fossil")
		end
	end

	local mesh = folder:WaitForChild("Base"):WaitForChild("Tail"):WaitForChild("Mesh")
	mesh.TextureId = instance:WaitForChild("Tail").TextureID
end

return VintageScraps