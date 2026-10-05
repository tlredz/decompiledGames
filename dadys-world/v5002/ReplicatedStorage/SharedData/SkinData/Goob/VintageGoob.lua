local VintageGoob = {
	Name = "Vintage Goob",
	Mastery = true,
	OverwriteAnimations = {},
	FaceTextures = {
		Normal = "rbxassetid://72652255688674",
		Blink = "rbxassetid://79218710145536",
		Hurt = "rbxassetid://105685406289957"
	},
	USE_SKIN_MODEL = false
}

function VintageGoob.ApplySkin(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			descendant.TextureID = VintageGoob.FaceTextures.Normal
		elseif descendant:IsA("RopeConstraint") then
			descendant.Color = BrickColor.new("Really black")
		end
	end
end

function VintageGoob.BlinkSequence(callback, p)
	local v = {
		"rbxassetid://74785551805702",
		VintageGoob.FaceTextures.Blink,
		"rbxassetid://134122256013366",
		VintageGoob.FaceTextures.Normal
	}

	for i = 1, #v do
		callback(p, v[i], VintageGoob.FaceTextures.Hurt)
		task.wait(i == 2 and 0.2 or 0.1)
	end
end

function VintageGoob.UseAbility(instance, folder)
	local mesh = folder:WaitForChild("LeftHand"):WaitForChild("Mesh")
	local mesh2 = folder:WaitForChild("RightHand"):WaitForChild("Mesh")
	mesh.MeshId = instance:WaitForChild("LeftHand").MeshId
	mesh2.MeshId = instance:WaitForChild("RightHand").MeshId
	mesh.TextureId = instance:WaitForChild("LeftHand").TextureID
	mesh2.TextureId = instance:WaitForChild("RightHand").TextureID

	for _, ropeConstraint in pairs(folder:GetDescendants()) do
		if ropeConstraint:IsA("RopeConstraint") then
			ropeConstraint.Color = BrickColor.new("Really black")
		end
	end
end

return VintageGoob