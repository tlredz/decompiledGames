local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RudieBlueBell = {}
RudieBlueBell.Name = "BlueBell Rudie"
RudieBlueBell.TowerName = "Rudie"
RudieBlueBell.Description = "Rudie dressed in festive blue bells for the holidays"
RudieBlueBell.Mastery = false
RudieBlueBell.Cost = 600
RudieBlueBell.Christmas = true
RudieBlueBell.HolidaySkin = true
RudieBlueBell.OverwriteAnimations = {
	Walk = "rbxassetid://89752421989409",
	Idle = "rbxassetid://80667484406688",
	Decode = "rbxassetid://95207747046768",
	Run = "rbxassetid://139414767968411",
	Quirk = "rbxassetid://81015322214585",
	Ability = "rbxassetid://82114603220952"
}
RudieBlueBell.FaceTextures = {
	Normal = "rbxassetid://93083268903119",
	Blink = "rbxassetid://120058044247679",
	Hurt = "rbxassetid://104051737949847"
}
RudieBlueBell.USE_SKIN_MODEL = true

function RudieBlueBell.OnLoad(callback, p)
	task.spawn(callback, p)
end

function RudieBlueBell.ApplySkin(instance)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsLobby() then
		return
	end

	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")

	for _, light in pairs(humanoidRootPart:GetDescendants()) do
		if light:IsA("PointLight") or light:IsA("SpotLight") then
			light.Color = Color3.fromRGB(16, 77, 196)
		end
	end

	local nose = instance:WaitForChild("Nose", 5)

	if not nose then
		warn("[RudieBlueBell] Nose part not found - skipping nose customization")
		return
	end

	nose.Transparency = 1
	nose.Color = Color3.new(0.360784, 0.615686, 1)
	nose.Size = Vector3.new(nose.Size.X, 0.4, nose.Size.Z)

	for _, light in pairs(nose:GetDescendants()) do
		if light:IsA("PointLight") or light:IsA("SpotLight") then
			light.Color = Color3.new(0.360784, 0.615686, 1)
		end
	end
end

return RudieBlueBell