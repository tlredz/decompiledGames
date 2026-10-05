local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Holly Lace",
	TowerName = "Bobette",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Idle = "rbxassetid://98063482752077",
		Decode = "rbxassetid://118670366936538",
		Quirk = "rbxassetid://125658523991907",
		Walk = "rbxassetid://105027812301637",
		Run = "rbxassetid://116414341447466",
		["sitting wave"] = "rbxassetid://138411684891910",
		["sitting idle"] = "rbxassetid://140698909029198"
	},
	FaceTextures = {
		Normal = "rbxassetid://95640390912394",
		Blink = "rbxassetid://124750157555888",
		Hurt = "rbxassetid://115485626561630"
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
			clone.Bow.Color = Color3.fromRGB(139, 169, 85)
			clone.Box.Color = Color3.fromRGB(138, 35, 69)
		end
	end
}