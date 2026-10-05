local VintageBobette = {
	Name = "Vintage Bobette"
}
game:GetService("CollectionService")

function VintageBobette.ApplySkin(folder)
	local present = folder:WaitForChild("Present")
	local v = present:waitForChild("Box")
	local v2 = present:waitForChild("Bow")
	v2.Color = Color3.new(0, 0, 0)
	v.Color = Color3.new(1, 1, 1)
	local ringRanger = folder:WaitForChild("RingRanger")

	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") and part ~= v and part ~= v2 and part ~= ringRanger then
			part.TextureID = "rbxassetid://120977154618047"
		end
	end

	local config = folder:WaitForChild("Config")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local normalTexture = config:WaitForChild("NormalTexture")
	blinkTexture.Texture = "rbxassetid://95417895707284"
	hurtTexture.Texture = "rbxassetid://117800185600198"
	normalTexture.Texture = "rbxassetid://120977154618047"
end

return VintageBobette