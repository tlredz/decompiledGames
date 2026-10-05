local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Snow-Time Rudie",
	OverwriteAnimations = {
		Ability = "rbxassetid://137600181789909",
		Decode = "rbxassetid://84834433996914",
		Idle = "rbxassetid://139770126065010",
		Quirk = "rbxassetid://116613163942290",
		Run = "rbxassetid://77888976497689",
		Walk = "rbxassetid://118601536168197"
	},
	FaceTextures = {
		Normal = "rbxassetid://125360385362710",
		Hurt = "rbxassetid://133951190642871",
		Blink = "rbxassetid://135933830465931"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance)
		local Universe = require(ReplicatedStorage.SharedUtils.Universe)

		if not Universe:IsGame() then
			return
		end

		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")

		for _, light in pairs(humanoidRootPart:GetDescendants()) do
			if light:IsA("PointLight") or light:IsA("SpotLight") then
				light.Color = Color3.fromRGB(166, 236, 238)
			end
		end

		local nose = instance:WaitForChild("Nose", 5)
		local root = instance:WaitForChild("RootPart"):WaitForChild("root")

		if not nose then
			warn("[SnowtimeRudie] Nose part not found - skipping nose customization")
			return
		end

		local lights = {}

		for _, light in pairs(nose:GetDescendants()) do
			if not (light:IsA("PointLight") or light:IsA("SpotLight")) then
				continue
			end

			light.Color = Color3.fromRGB(166, 236, 238)
			lights[#lights + 1] = light
		end

		local attachment = nose:WaitForChild("Attachment", 3)
		local torso = root and root:FindFirstChild("torso")
		local chest = torso and torso:FindFirstChild("chest")
		local head = chest and chest:FindFirstChild("head")

		if attachment and head then
			attachment.CFrame = CFrame.new(-1, -1.7, 0) * CFrame.Angles(-1.5707963267948966, 0, 0)
			attachment.Parent = head
		else
			for _, v in pairs(lights) do
				v.Shadow = false
			end
		end
	end
}