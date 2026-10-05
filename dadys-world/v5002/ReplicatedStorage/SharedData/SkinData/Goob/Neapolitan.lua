local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Neapolitan = {
	Name = "Neapolitan",
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
		Normal = "rbxassetid://137238295457228",
		Blink = "rbxassetid://123537734089773",
		Hurt = "rbxassetid://99315725741709"
	},
	USE_SKIN_MODEL = true
}

function Neapolitan.BlinkSequence(callback, p)
	local v = {
		"rbxassetid://132792595237543",
		Neapolitan.FaceTextures.Blink,
		"rbxassetid://129460977700965",
		Neapolitan.FaceTextures.Normal
	}

	for i = 1, #v do
		callback(p, v[i], Neapolitan.FaceTextures.Hurt)
		task.wait(i == 2 and 0.2 or 0.1)
	end
end

function Neapolitan.ApplySkin(instance)
	local Universe = require(ReplicatedStorage.SharedUtils.Universe)

	if Universe:IsGame() then
		Neapolitan.OverwriteAnimations.Ability = "rbxassetid://102238050523441"
		task.spawn(function()
			local rootPart = instance:WaitForChild("RootPart", 5)
			local rootx = rootPart and rootPart:WaitForChild("root.x", 5)
			local spine_01x = rootx and rootx:WaitForChild("spine_01.x", 5)
			local spine_02x = spine_01x and spine_01x:WaitForChild("spine_02.x", 5)
			local neckx = spine_02x and spine_02x:WaitForChild("neck.x", 5)
			local headx = neckx and neckx:WaitForChild("head.x", 5)

			if not headx then
				return
			end

			local latchedAttachment = headx:WaitForChild("LatchedAttachment", 5)

			if not latchedAttachment then
				return
			end

			latchedAttachment.CFrame = CFrame.new(-1, 2.2, -0.5) * CFrame.Angles(0, -1.9198621771937625, 0) * CFrame.Angles(
				1.9198621771937625,
				0,
				-3.141592653589793
			)
		end)
	end
end

function Neapolitan.UseAbility(instance, instance2)
	local mesh = instance2:WaitForChild("LeftHand"):WaitForChild("Mesh")
	local mesh2 = instance2:WaitForChild("RightHand"):WaitForChild("Mesh")
	mesh.MeshId = instance:WaitForChild("LeftHand").MeshId
	mesh2.MeshId = instance:WaitForChild("RightHand").MeshId
	mesh.TextureId = instance:WaitForChild("LeftHand").TextureID
	mesh2.TextureId = instance:WaitForChild("RightHand").TextureID
end

return Neapolitan