local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Golden Bauble",
	TowerName = "Bobette",
	Description = "No description yet",
	Mastery = false,
	OverwriteAnimations = {
		Idle = "rbxassetid://72807060438402",
		Decode = "rbxassetid://94412938598381",
		Quirk = "rbxassetid://123797291224009",
		Walk = "rbxassetid://108971895466704",
		Run = "rbxassetid://139284003030505",
		["sitting wave"] = "rbxassetid://83047090534901",
		["sitting idle"] = "rbxassetid://111882105163825"
	},
	FaceTextures = {
		Normal = "rbxassetid://75731732007656",
		Blink = "rbxassetid://124345688417036",
		Hurt = "rbxassetid://106966719262850"
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(parent, instance)
		local Universe = require(ReplicatedStorage.SharedUtils.Universe)

		if not Universe:IsLobby() then
			local clone = instance:WaitForChild("Present"):Clone()
			local clone2 = instance:WaitForChild("RingRangerParent"):Clone()
			local clone3 = instance:WaitForChild("QuickLinks"):Clone()
			local clone4 = instance:WaitForChild("RingRanger"):Clone()
			local primaryPart = instance.PrimaryPart
			local objectSpace = clone:GetPivot():ToObjectSpace(primaryPart.CFrame)
			local objectSpace2 = clone2:GetPivot():ToObjectSpace(primaryPart.CFrame)
			local objectSpace3 = clone4:GetPivot():ToObjectSpace(primaryPart.CFrame)
			local clone5 = primaryPart:WaitForChild("RootPartAttachment"):Clone()
			local primaryPart2 = parent.PrimaryPart
			clone:PivotTo(primaryPart2.CFrame * objectSpace + createVector(0, 1.3, 0))
			clone2:PivotTo(primaryPart2.CFrame * objectSpace2)
			clone4:PivotTo(primaryPart2.CFrame * objectSpace3)
			clone5.Parent = primaryPart2
			clone.Bow.WeldConstraint.Part1 = primaryPart2
			clone.Box.WeldConstraint.Part1 = primaryPart2
			clone2.RingRanger.WeldConstraint.Part1 = primaryPart2
			clone4.WeldConstraint.Part1 = primaryPart2
			clone4.AlignPosition.Attachment1 = clone5
			clone.Parent = parent
			clone2.Parent = parent
			clone4.Parent = parent
			local boxParticlesLocation = clone3:WaitForChild("BoxParticles"):WaitForChild("BoxParticlesLocation")
			boxParticlesLocation.Value = clone.Box.ParticleAttachment
			local ringRangerModel = clone3:WaitForChild("RingRangerModel")
			ringRangerModel.Value = clone4
			clone3.Parent = parent
			clone.Bow.Color = Color3.fromRGB(237, 198, 76)
			clone.Box.Color = Color3.fromRGB(194, 49, 34)
		end
	end
}