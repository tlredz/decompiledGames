local CutesyCalico = {}
CutesyCalico.Name = "Crafty Calico"
CutesyCalico.Cost = 600
CutesyCalico.DandyStore = true
CutesyCalico.OverwriteAnimations = {
	Ability = "rbxassetid://98850654767227",
	Run = "rbxassetid://82813052342403",
	Idle = "rbxassetid://103468485013722",
	Walk = "rbxassetid://117628460805009",
	Decode = "rbxassetid://115536096607769",
	Quirk = "rbxassetid://84633768528538"
}
CutesyCalico.FaceTextures = {
	Blink = "rbxassetid://82476267229185",
	Hurt = "rbxassetid://74155715616857",
	Normal = "rbxassetid://117954267436125"
}
CutesyCalico.USE_SKIN_MODEL = true

function CutesyCalico.ApplySkin(_) end

function CutesyCalico.UseAbility(instance, folder)
	for _, ropeConstraint in pairs(folder:GetDescendants()) do
		if ropeConstraint:IsA("RopeConstraint") then
			ropeConstraint.Color = BrickColor.new("Lily white")
		end
	end

	local mesh = folder:WaitForChild("Base"):WaitForChild("Tail"):WaitForChild("Mesh")
	mesh.MeshId = instance:WaitForChild("Tail").MeshId
	mesh.TextureId = instance:WaitForChild("Tail").TextureID
end

return CutesyCalico