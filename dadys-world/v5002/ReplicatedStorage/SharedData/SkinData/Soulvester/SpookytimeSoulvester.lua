local color = Color3.fromRGB(240, 210, 245)
return {
	Name = "Spooky-Time Soulvester",
	TowerName = "Soulvester",
	Description = "No description yet",
	Mastery = false,
	OverwriteAnimations = {
		Quirk = "rbxassetid://84777493690244",
		Walk = "rbxassetid://138233470362787",
		Idle = "rbxassetid://75996937631745",
		Decode = "rbxassetid://84846112540119",
		Run = "rbxassetid://77971463430772",
		Ability_loop = "rbxassetid://91081968676640",
		Ability = "rbxassetid://85031273170115"
	},
	FaceTextures = {
		Hurt = "rbxassetid://116356279814767",
		Normal = "rbxassetid://127551379186711",
		Blink = "rbxassetid://110733795888945"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance, _)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
		local toonLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ToonLight")
		local extraLight = humanoidRootPart and humanoidRootPart:FindFirstChild("ExtraLight")
		local pointLight = toonLight and toonLight:FindFirstChild("PointLight")
		local pointLight2 = extraLight and extraLight:FindFirstChild("PointLight")

		if pointLight then
			pointLight.Color = color
		end

		if pointLight2 then
			pointLight2.Color = color
		end
	end
}