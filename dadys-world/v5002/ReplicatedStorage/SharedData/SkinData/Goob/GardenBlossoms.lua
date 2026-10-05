local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GardenBlossoms = {
	Name = "Garden Blossoms",
	TowerName = "Goob",
	Cost = 600
}
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
GardenBlossoms.Unlocks = require(ReplicatedStorage2.SharedData.ReleaseTimes).Easter2026_W5
GardenBlossoms.Easter = true
GardenBlossoms.HolidaySkin = true
GardenBlossoms.OverwriteAnimations = {
	Walk = "rbxassetid://80575668298605",
	Run = "rbxassetid://122049167943521",
	Quirk = "rbxassetid://116117556022601",
	Idle = "rbxassetid://73747645695432",
	Decode = "rbxassetid://80142292252154",
	Ability = "rbxassetid://102238050523441"
}
GardenBlossoms.FaceTextures = {
	Hurt = "rbxassetid://78344389004889",
	Normal = "rbxassetid://86457897322340",
	Blink = "rbxassetid://87549568439632"
}
GardenBlossoms.USE_SKIN_MODEL = true

function GardenBlossoms.BlinkSequence(callback, p)
	local v = {
		"rbxassetid://113447973993952",
		GardenBlossoms.FaceTextures.Blink,
		"rbxassetid://118622038289154",
		GardenBlossoms.FaceTextures.Normal
	}

	for i = 1, #v do
		callback(p, v[i], GardenBlossoms.FaceTextures.Hurt)
		task.wait(i == 2 and 0.2 or 0.1)
	end
end

function GardenBlossoms.ApplySkin(_)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsGame() then
		GardenBlossoms.OverwriteAnimations.Ability = "rbxassetid://102238050523441"
	end
end

function GardenBlossoms.UseAbility(instance, folder)
	local mesh = folder:WaitForChild("LeftHand"):WaitForChild("Mesh")
	local mesh2 = folder:WaitForChild("RightHand"):WaitForChild("Mesh")
	mesh.MeshId = instance:WaitForChild("LeftHand").MeshId
	mesh2.MeshId = instance:WaitForChild("RightHand").MeshId
	mesh.TextureId = instance:WaitForChild("LeftHand").TextureID
	mesh2.TextureId = instance:WaitForChild("RightHand").TextureID

	for _, ropeConstraint in pairs(folder:GetDescendants()) do
		if ropeConstraint:IsA("RopeConstraint") then
			ropeConstraint.Color = BrickColor.new("Dark nougat")
		end
	end
end

return GardenBlossoms