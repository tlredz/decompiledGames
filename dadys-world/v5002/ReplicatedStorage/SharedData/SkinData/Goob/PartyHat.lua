local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PartyHat = {
	Name = "Fun Partygoer",
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
		Normal = "rbxassetid://123253832816232",
		Blink = "rbxassetid://98091512483620",
		Hurt = "rbxassetid://100068767758938"
	},
	USE_SKIN_MODEL = true
}

function PartyHat.BlinkSequence(callback, p)
	local v = {
		"rbxassetid://71152563435390",
		PartyHat.FaceTextures.Blink,
		"rbxassetid://117854661636330",
		PartyHat.FaceTextures.Normal
	}

	for i = 1, #v do
		callback(p, v[i], PartyHat.FaceTextures.Hurt)
		task.wait(i == 2 and 0.2 or 0.1)
	end
end

function PartyHat.ApplySkin(_)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsGame() then
		PartyHat.OverwriteAnimations.Ability = "rbxassetid://102238050523441"
	end
end

function PartyHat.UseAbility(instance, instance2)
	local mesh = instance2:WaitForChild("LeftHand"):WaitForChild("Mesh")
	local mesh2 = instance2:WaitForChild("RightHand"):WaitForChild("Mesh")
	mesh.MeshId = instance:WaitForChild("LeftHand").MeshId
	mesh2.MeshId = instance:WaitForChild("RightHand").MeshId
	mesh.TextureId = instance:WaitForChild("LeftHand").TextureID
	mesh2.TextureId = instance:WaitForChild("RightHand").TextureID
end

return PartyHat