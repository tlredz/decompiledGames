local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Eve Sleeper",
	TowerName = "Bobette",
	Description = "Bobette all cozy for Christmas Eve",
	Mastery = false,
	Cost = 600,
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Idle = "rbxassetid://121960921916341",
		Decode = "rbxassetid://72425276030716",
		Quirk = "rbxassetid://123797291224009",
		Walk = "rbxassetid://108971895466704",
		Run = "rbxassetid://98111731270842",
		["sitting wave"] = "rbxassetid://113260134852958",
		["sitting idle"] = "rbxassetid://135757794031874"
	},
	FaceTextures = {
		Normal = "rbxassetid://127851419016918",
		Hurt = "rbxassetid://122132801977974",
		Blink = "rbxassetid://117871232198660"
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
			clone.Bow.Color = Color3.new(1, 0.37254901960784315, 0.6862745098039216)
			clone.Box.Color = Color3.new(0.36470588235294116, 0.8196078431372549, 1)
		end
	end
}