local VintageShelly = {}
VintageShelly.Name = "Vintage Shelly"
VintageShelly.Mastery = true

function VintageShelly.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = "rbxassetid://98216947942614"
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	hurtTexture.Texture = "rbxassetid://111753035258128"
	local normalTexture = config:WaitForChild("NormalTexture")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	normalTexture.Texture = "rbxassetid://98216947942614"
	blinkTexture.Texture = "rbxassetid://116580338370410"
end

function VintageShelly.UseAbility(instance)
	instance:WaitForChild("Head"):WaitForChild("Attachment"):WaitForChild("ParticleEmitter"):Emit(2)
end

return VintageShelly