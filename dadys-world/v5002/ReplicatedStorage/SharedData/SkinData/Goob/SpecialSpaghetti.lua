local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpecialSpaghetti = {
	Name = "Special Spaghetti",
	Creator = 125597721,
	Cost = 600,
	DandyStore = true,
	OverwriteAnimations = {
		Run = "rbxassetid://122049167943521",
		Walk = "rbxassetid://80575668298605",
		Idle = "rbxassetid://73747645695432",
		Quirk = "rbxassetid://116117556022601",
		Decode = "rbxassetid://80142292252154",
		Ability = "rbxassetid://77747170232741"
	},
	FaceTextures = {
		Normal = "rbxassetid://138764204907728",
		Blink = "rbxassetid://110717724663938",
		Hurt = "rbxassetid://138768484041548"
	},
	USE_SKIN_MODEL = true
}

function SpecialSpaghetti.BlinkSequence(callback, p)
	local v = {
		"rbxassetid://100246009982195",
		SpecialSpaghetti.FaceTextures.Blink,
		"rbxassetid://95807951856693",
		SpecialSpaghetti.FaceTextures.Normal
	}

	for i = 1, #v do
		callback(p, v[i], SpecialSpaghetti.FaceTextures.Hurt)
		task.wait(i == 2 and 0.2 or 0.1)
	end
end

function SpecialSpaghetti.ApplySkin(folder)
	for _, ropeConstraint in pairs(folder:GetDescendants()) do
		if ropeConstraint:IsA("RopeConstraint") then
			ropeConstraint.Color = BrickColor.new("Buttermilk")
		end
	end

	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsGame() then
		SpecialSpaghetti.OverwriteAnimations.Ability = "rbxassetid://102238050523441"
	end
end

function SpecialSpaghetti.UseAbility(instance, folder)
	local mesh = folder:WaitForChild("LeftHand"):WaitForChild("Mesh")
	local mesh2 = folder:WaitForChild("RightHand"):WaitForChild("Mesh")
	mesh.MeshId = instance:WaitForChild("LeftHand").MeshId
	mesh2.MeshId = instance:WaitForChild("RightHand").MeshId
	mesh.TextureId = instance:WaitForChild("LeftHand").TextureID
	mesh2.TextureId = instance:WaitForChild("RightHand").TextureID

	for _, ropeConstraint in pairs(folder:GetDescendants()) do
		if ropeConstraint:IsA("RopeConstraint") then
			ropeConstraint.Color = BrickColor.new("Buttermilk")
		end
	end
end

return SpecialSpaghetti