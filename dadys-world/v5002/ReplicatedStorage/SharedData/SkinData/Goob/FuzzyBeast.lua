local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Universe = require(ReplicatedStorage.SharedUtils.Universe)
local FuzzyBeast = {
	Name = "Fuzzy Beast",
	TowerName = "Goob",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	HolidayYear = 2026,
	OverwriteAnimations = {
		Run = "rbxassetid://87517878513976",
		Walk = "rbxassetid://127465150688465",
		Idle = "rbxassetid://128975220665906",
		Quirk = "rbxassetid://137126324389253",
		Decode = "rbxassetid://80142292252154",
		Ability = "rbxassetid://91322437190614"
	}
}

if Universe:IsGame() then
	FuzzyBeast.OverwriteAnimations.Ability = "rbxassetid://102238050523441"
end

FuzzyBeast.FaceTextures = {
	Normal = "rbxassetid://129321885857219",
	Blink = "rbxassetid://82393899784284",
	Hurt = "rbxassetid://137428651919360"
}
FuzzyBeast.USE_SKIN_MODEL = true

function FuzzyBeast.BlinkSequence(callback, p)
	local v = {
		"rbxassetid://111704942600546",
		FuzzyBeast.FaceTextures.Blink,
		"rbxassetid://101540179372133",
		FuzzyBeast.FaceTextures.Normal
	}

	for i = 1, #v do
		callback(p, v[i], FuzzyBeast.FaceTextures.Hurt)
		task.wait(i == 2 and 0.2 or 0.1)
	end
end

function FuzzyBeast.ApplySkin(_) end

function FuzzyBeast.UseAbility(instance, instance2)
	local mesh = instance2:WaitForChild("LeftHand"):WaitForChild("Mesh")
	local mesh2 = instance2:WaitForChild("RightHand"):WaitForChild("Mesh")
	mesh.MeshId = instance:WaitForChild("LeftHand").MeshId
	mesh2.MeshId = instance:WaitForChild("RightHand").MeshId
	mesh.TextureId = instance:WaitForChild("LeftHand").TextureID
	mesh2.TextureId = instance:WaitForChild("RightHand").TextureID
end

return FuzzyBeast