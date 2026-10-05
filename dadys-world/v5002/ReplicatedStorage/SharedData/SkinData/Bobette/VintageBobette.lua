local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VintageBobette = {
	Name = "Vintage Bobette",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://120977154618047",
		Blink = "rbxassetid://95417895707284",
		Hurt = "rbxassetid://117800185600198"
	},
	USE_SKIN_MODEL = false
}

function VintageBobette.ApplySkin(folder)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)
	local box, bow, ringRanger

	if not Universe:IsLobby() then
		local present = folder:WaitForChild("Present")
		box = present:WaitForChild("Box")
		bow = present:WaitForChild("Bow")
		ringRanger = folder:WaitForChild("RingRanger")
		bow.Color = Color3.new(0, 0, 0)
		box.Color = Color3.new(1, 1, 1)
	end

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") and part ~= box and part ~= bow and part ~= ringRanger then
			part.TextureID = VintageBobette.FaceTextures.Normal
		end
	end
end

return VintageBobette