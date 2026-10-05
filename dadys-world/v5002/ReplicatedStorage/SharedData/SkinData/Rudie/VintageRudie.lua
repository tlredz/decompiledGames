local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VintageRudie = {
	Name = "Vintage Rudie",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://92994092090592",
		Hurt = "rbxassetid://113785447525723",
		Blink = "rbxassetid://139975153263997"
	},
	USE_SKIN_MODEL = false
}

function VintageRudie.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") and part.Name ~= "Nose" then
			part.TextureID = VintageRudie.FaceTextures.Normal
		end
	end

	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if not Universe:IsGame() then
		return
	end

	local nose = folder:WaitForChild("Nose", 5)

	if nose then
		nose.Color = Color3.new(1, 1, 1)
		nose:SetAttribute("BlackoutColor", Color3.new(1, 1, 1))

		for _, light in pairs(nose:GetDescendants()) do
			if light:IsA("PointLight") or light:IsA("SpotLight") then
				light.Color = Color3.new(1, 1, 1)
			end
		end
	else
		warn("[VintageRudie] Nose part not found - skipping nose customization")
	end

	local humanoidRootPart = folder:WaitForChild("HumanoidRootPart")

	for _, light in pairs(humanoidRootPart:GetDescendants()) do
		if light:IsA("PointLight") or light:IsA("SpotLight") then
			light.Color = Color3.new(1, 1, 1)
		end
	end
end

return VintageRudie