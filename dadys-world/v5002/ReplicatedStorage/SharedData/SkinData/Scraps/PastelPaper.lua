local PastelPaper = {}
PastelPaper.Name = "Pastel Paper"
PastelPaper.Cost = 600
PastelPaper.DandyStore = true
PastelPaper.OverwriteAnimations = {
	Run = "rbxassetid://126340761548707",
	Walk = "rbxassetid://134085120961208",
	Idle = "rbxassetid://129578418631996",
	Quirk = "rbxassetid://107332393429650",
	Decode = "rbxassetid://92401905088892",
	Ability = "rbxassetid://87920638004220"
}
PastelPaper.FaceTextures = {
	Normal = "rbxassetid://73958066179412",
	Blink = "rbxassetid://132369234170860",
	Hurt = "rbxassetid://96951626555560"
}
PastelPaper.USE_SKIN_MODEL = true

function PastelPaper.ApplySkin(_) end

function PastelPaper.UseAbility(instance, folder)
	for _, ropeConstraint in pairs(folder:GetDescendants()) do
		if ropeConstraint:IsA("RopeConstraint") then
			ropeConstraint.Color = BrickColor.new("Lily white")
		end
	end

	local mesh = folder:WaitForChild("Base"):WaitForChild("Tail"):WaitForChild("Mesh")
	mesh.MeshId = instance:WaitForChild("Tail").MeshId
	mesh.TextureId = instance:WaitForChild("Tail").TextureID
end

return PastelPaper