local VintageBrusha = {
	Name = "Vintage Brusha",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://127470696147948",
		Blink = "rbxassetid://120478298089445",
		Hurt = "rbxassetid://78021387864362"
	},
	PaintInfo = {
		Colors = { Color3.fromRGB(110, 110, 100), Color3.fromRGB(51, 51, 51), Color3.fromRGB(0, 0, 0) },
		Sequence = {
			{
				Image = "rbxassetid://71010549160699",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://72955803535565",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://118583026782850",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://107000114649755",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://75802727612430",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://99277454131639",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://123430338667005",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://84587237833432",
				Color = Color3.fromRGB(255, 255, 255)
			}
		}
	},
	USE_SKIN_MODEL = false
}

function VintageBrusha.ApplySkin(folder)
	folder:SetAttribute("PaintingTexture", "rbxassetid://91627552432293")

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			if descendant.Material == Enum.Material.Neon or descendant.Material == Enum.Material.SmoothPlastic then
				descendant.Color = Color3.fromRGB(155, 155, 155)
			else
				descendant.TextureID = VintageBrusha.FaceTextures.Normal
			end
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
			})
		end
	end
end

return VintageBrusha