local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GardenBouquet = {}
GardenBouquet.Name = "Garden Bouquet"
GardenBouquet.TowerName = "Scraps"
GardenBouquet.Cost = 600
GardenBouquet.Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Easter2026_W5
GardenBouquet.Easter = true
GardenBouquet.HolidaySkin = true
GardenBouquet.OverwriteAnimations = {
	Run = "rbxassetid://112111022093091",
	Walk = "rbxassetid://103105474019093",
	Idle = "rbxassetid://134272548635232",
	Quirk = "rbxassetid://128830992461003",
	Decode = "rbxassetid://76886834369462",
	Ability = "rbxassetid://81986487044485"
}
GardenBouquet.FaceTextures = {
	Normal = "rbxassetid://90105966127792",
	Blink = "rbxassetid://105304809898164",
	Hurt = "rbxassetid://140178030031205"
}
GardenBouquet.USE_SKIN_MODEL = true

function GardenBouquet.ApplySkin(_) end

function GardenBouquet.UseAbility(instance, folder)
	for _, ropeConstraint in pairs(folder:GetDescendants()) do
		if ropeConstraint:IsA("RopeConstraint") then
			ropeConstraint.Color = BrickColor.new("Dark nougat")
		end
	end

	local mesh = folder:WaitForChild("Base"):WaitForChild("Tail"):WaitForChild("Mesh")
	mesh.MeshId = instance:WaitForChild("Tail").MeshId
	mesh.TextureId = instance:WaitForChild("Tail").TextureID
end

return GardenBouquet