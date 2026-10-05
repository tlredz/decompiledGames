local VintageShelly = {
	Name = "Vintage Shelly",
	Mastery = true,
	OverwriteAnimations = {
		Walk = "rbxassetid://73020193119336",
		Idle = "rbxassetid://100849345213447",
		Ability = "rbxassetid://112530194612519",
		Run = "rbxassetid://77057435398906",
		Quirk = "rbxassetid://134568535005501",
		Decode = "rbxassetid://125231549786789"
	},
	FaceTextures = {
		Normal = "rbxassetid://98216947942614",
		Blink = "rbxassetid://116580338370410",
		Hurt = "rbxassetid://111753035258128"
	},
	USE_SKIN_MODEL = false
}

function VintageShelly.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = VintageShelly.FaceTextures.Normal
		end
	end
end

function VintageShelly.UseAbility(instance)
	instance:WaitForChild("Head"):WaitForChild("Attachment"):WaitForChild("ParticleEmitter"):Emit(2)
end

return VintageShelly