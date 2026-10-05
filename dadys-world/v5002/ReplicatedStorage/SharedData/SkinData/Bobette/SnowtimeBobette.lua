local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Snow-Time Bobette",
	OverwriteAnimations = {
		Idle = "rbxassetid://90870259393779",
		Decode = "rbxassetid://84862410244893",
		Quirk = "rbxassetid://91672510912388",
		Walk = "rbxassetid://101536434500318",
		Run = "rbxassetid://81736071559873",
		["sitting wave"] = "rbxassetid://87372045272969",
		["sitting idle"] = "rbxassetid://122595722012121"
	},
	FaceTextures = {
		Normal = "rbxassetid://105052389256905",
		Blink = "rbxassetid://99943181332472",
		Hurt = "rbxassetid://76839654606099"
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
			clone.Bow.Color = Color3.fromRGB(110, 82, 205)
			clone.Box.Color = Color3.fromRGB(215, 219, 224)
		end
	end
}