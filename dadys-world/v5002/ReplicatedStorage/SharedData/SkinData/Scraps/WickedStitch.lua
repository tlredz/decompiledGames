local WickedStitch = {}
WickedStitch.Name = "Wicked Stitch"
WickedStitch.TowerName = "Scraps"
WickedStitch.Description = "No description yet"
WickedStitch.Mastery = false
WickedStitch.Cost = 1200
WickedStitch.Requirement1 = { "Pumpkins", 1200 }
WickedStitch.Requirement2 = { "Coin", 1200 }
WickedStitch.Halloween = true
WickedStitch.HolidaySkin = true
WickedStitch.HolidayYear = 2026
WickedStitch.GeneratorOffset = {
	Y = 0,
	Z = -0.52
}
WickedStitch.OverwriteAnimations = {
	Run = "rbxassetid://112111022093091",
	Walk = "rbxassetid://74989384115106",
	Idle = "rbxassetid://87710531074917",
	Quirk = "rbxassetid://128830992461003",
	Decode = "rbxassetid://111587414440780",
	Ability = "rbxassetid://81986487044485"
}
WickedStitch.FaceTextures = {
	Normal = "rbxassetid://87788629518896",
	Blink = "rbxassetid://112640201483211",
	Hurt = "rbxassetid://137044058968777"
}
WickedStitch.USE_SKIN_MODEL = true

function WickedStitch.ApplySkin(_) end

function WickedStitch.UseAbility(instance, folder)
	for _, ropeConstraint in pairs(folder:GetDescendants()) do
		if ropeConstraint:IsA("RopeConstraint") then
			ropeConstraint.Color = BrickColor.new("Earth blue")
		end
	end

	local mesh = folder:WaitForChild("Base"):WaitForChild("Tail"):WaitForChild("Mesh")
	mesh.MeshId = instance:WaitForChild("Tail").MeshId
	mesh.TextureId = instance:WaitForChild("Tail").TextureID
end

return WickedStitch