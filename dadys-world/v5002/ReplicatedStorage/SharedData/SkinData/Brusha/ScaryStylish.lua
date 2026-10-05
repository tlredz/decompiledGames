local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Scary Stylish",
	TowerName = "Brusha",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Halloween = true,
	HolidaySkin = true,
	HolidayYear = 2025,
	OverwriteAnimations = {
		Decode = "rbxassetid://137606735770200",
		Idle = "rbxassetid://133490586091463",
		Paint = "rbxassetid://136989683733742",
		PaintEnd = "rbxassetid://129092207051880",
		PaintStart = "rbxassetid://97174260659481",
		Quirk = "rbxassetid://100574825804471",
		Run = "rbxassetid://92652433020704",
		Walk = "rbxassetid://88042548060423"
	},
	FaceTextures = {
		Normal = "rbxassetid://135952933684257",
		Blink = "rbxassetid://85387390140302",
		Hurt = "rbxassetid://102075867115318"
	},
	PaintInfo = {
		Colors = { Color3.fromRGB(177, 43, 149), Color3.fromRGB(216, 89, 26), Color3.fromRGB(176, 220, 49) },
		Sequence = {
			{
				Image = "rbxassetid://94435725106761",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://100427503317240",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://86514439201344",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://137785646674503",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://131121017177835",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://138716146137221",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://97732975146280",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://135977020016926",
				Color = Color3.fromRGB(255, 255, 255)
			}
		}
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(parent, instance)
		parent:SetAttribute("PaintingTexture", "rbxassetid://132477664989824")
		local Universe = require(ReplicatedStorage.SharedUtils.Universe)

		if Universe:IsLobby() then
			return
		end

		local clone = instance:WaitForChild("RingRangerParent"):Clone()
		local clone2 = instance:WaitForChild("QuickLinks"):Clone()
		local clone3 = instance:WaitForChild("RingRanger"):Clone()
		local clone4 = instance:WaitForChild("Notebook_Geo"):WaitForChild("Decal"):Clone()
		local primaryPart = instance.PrimaryPart
		local objectSpace = clone:GetPivot():ToObjectSpace(primaryPart.CFrame)
		local objectSpace2 = clone3:GetPivot():ToObjectSpace(primaryPart.CFrame)
		local clone5 = primaryPart:WaitForChild("RootPartAttachment"):Clone()
		local primaryPart2 = parent.PrimaryPart
		clone:PivotTo(primaryPart2.CFrame * objectSpace)
		clone3:PivotTo(primaryPart2.CFrame * objectSpace2)
		clone5.Parent = primaryPart2
		clone4.Parent = parent:WaitForChild("Notebook_Geo")
		clone4.Texture = "rbxassetid://132477664989824"
		clone.RingRanger.WeldConstraint.Part1 = primaryPart2
		clone3.WeldConstraint.Part1 = primaryPart2
		clone3.AlignPosition.Attachment1 = clone5
		clone.Parent = parent
		clone3.Parent = parent
		local ringRangerModel = clone2:WaitForChild("RingRangerModel")
		ringRangerModel.Value = clone3
		local notebookArtImage = clone2:WaitForChild("NotebookArtImage")
		notebookArtImage.Value = clone4
		clone2.Parent = parent
	end
}