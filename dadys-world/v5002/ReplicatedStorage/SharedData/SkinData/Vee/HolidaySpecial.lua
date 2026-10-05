return {
	Name = "Holiday Special",
	TowerName = "Vee",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = DateTime.fromUniversalTime(2025, 12, 19, 20, 0, 0),
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Run = "rbxassetid://98824744790938",
		Walk = "rbxassetid://87260553445030",
		Idle = "rbxassetid://111890465304655",
		Quirk = "rbxassetid://117293831788233",
		Decode = "rbxassetid://97175042031688",
		Ability = "rbxassetid://110039560769001"
	},
	FaceTextures = {
		Normal = "rbxassetid://81841752761425",
		Hurt = "rbxassetid://93638698188647",
		Blink = "rbxassetid://86595457734291"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(instance, instance2)
		local clone = instance2:WaitForChild("Head"):WaitForChild("StaticScreen"):Clone()
		clone.Parent = instance:WaitForChild("Head")
		clone.RigidConstraint.Attachment0 = instance:WaitForChild("RootPart"):WaitForChild("root"):WaitForChild("torso"):WaitForChild("chest"):WaitForChild("head"):WaitForChild("HeadBoneAttachment")
	end
}