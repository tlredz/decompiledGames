local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
return {
	Name = "Figure Painter",
	TowerName = "Brusha",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage2.SharedData.ReleaseTimes).Christmas2025_W3,
	Christmas = true,
	HolidaySkin = true,
	OverwriteAnimations = {
		Decode = "rbxassetid://137606735770200",
		Idle = "rbxassetid://120995305446330",
		Paint = "rbxassetid://136989683733742",
		PaintEnd = "rbxassetid://129092207051880",
		PaintStart = "rbxassetid://97174260659481",
		Quirk = "rbxassetid://140672190679079",
		Run = "rbxassetid://92652433020704",
		Walk = "rbxassetid://88042548060423"
	},
	FaceTextures = {
		Normal = "rbxassetid://125888824724607",
		Blink = "rbxassetid://107439465718965",
		Hurt = "rbxassetid://97557684082275"
	},
	PaintInfo = {
		Colors = { Color3.fromRGB(172, 201, 47), Color3.fromRGB(89, 147, 11), Color3.fromRGB(216, 83, 40) },
		Sequence = {
			{
				Image = "rbxassetid://81266689782900",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://123779776816457",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://87508610261080",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://74864431686470",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://135462522610759",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://136669378794721",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://138952250423861",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://75895108341415",
				Color = Color3.fromRGB(255, 255, 255)
			}
		}
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(parent, instance)
		parent:SetAttribute("PaintingTexture", "rbxassetid://104569967910856")
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
		clone4.Texture = "rbxassetid://104569967910856"
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