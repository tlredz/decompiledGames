local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Holly Jolly",
	TowerName = "Rudie",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://126571375059088",
		Walk = "rbxassetid://103353377870705",
		Idle = "rbxassetid://84923951517820",
		Quirk = "rbxassetid://112719669537862",
		Decode = "rbxassetid://98490827237336",
		Ability = "rbxassetid://137600181789909"
	},
	FaceTextures = {
		Normal = "rbxassetid://96516093645594",
		Blink = "rbxassetid://119387049952357",
		Hurt = "rbxassetid://80307347391509"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance, _)
		local Universe = require(ReplicatedStorage.SharedUtils.Universe)

		if not Universe:IsGame() then
			return
		end

		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")

		for _, light in pairs(humanoidRootPart:GetDescendants()) do
			if light:IsA("PointLight") or light:IsA("SpotLight") then
				light.Color = Color3.fromRGB(213, 39, 37)
			end
		end

		local nose = instance:WaitForChild("Nose", 5)
		local root = instance:WaitForChild("RootPart"):WaitForChild("root")

		if not nose then
			warn("[HollyJolly] Nose part not found - skipping nose customization")
			return
		end

		local lights = {}

		for _, light in pairs(nose:GetDescendants()) do
			if not (light:IsA("PointLight") or light:IsA("SpotLight")) then
				continue
			end

			light.Color = Color3.fromRGB(213, 39, 37)
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