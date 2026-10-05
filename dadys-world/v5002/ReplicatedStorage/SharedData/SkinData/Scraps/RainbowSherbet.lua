local RainbowSherbet = {}
RainbowSherbet.Name = "Rainbow Sherbet"
RainbowSherbet.Cost = 600
RainbowSherbet.DandyStore = true
RainbowSherbet.OverwriteAnimations = {
	Run = "rbxassetid://112111022093091",
	Walk = "rbxassetid://103105474019093",
	Idle = "rbxassetid://134272548635232",
	Quirk = "rbxassetid://128830992461003",
	Decode = "rbxassetid://76886834369462",
	Ability = "rbxassetid://81986487044485"
}
RainbowSherbet.FaceTextures = {
	Normal = "rbxassetid://138894858465346",
	Blink = "rbxassetid://100135022127471",
	Hurt = "rbxassetid://119339548409887"
}
RainbowSherbet.USE_SKIN_MODEL = true

function RainbowSherbet.ApplySkin(_) end

function RainbowSherbet.UseAbility(instance, folder)
	for _, ropeConstraint in pairs(folder:GetDescendants()) do
		if ropeConstraint:IsA("RopeConstraint") then
			ropeConstraint.Color = BrickColor.new("Lily white")
		end
	end

	local mesh = folder:WaitForChild("Base"):WaitForChild("Tail"):WaitForChild("Mesh")
	mesh.MeshId = instance:WaitForChild("Tail").MeshId
	mesh.TextureId = instance:WaitForChild("Tail").TextureID
end

return RainbowSherbet