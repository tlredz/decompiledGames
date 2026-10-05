local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Autumn Palette",
	Cost = 600,
	DandyStore = true,
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
		Normal = "rbxassetid://139495609427032",
		Blink = "rbxassetid://109316879033709",
		Hurt = "rbxassetid://109680573399689"
	},
	PaintInfo = {
		Colors = { Color3.fromRGB(89, 21, 11), Color3.fromRGB(97, 52, 45), Color3.fromRGB(182, 65, 54) },
		Sequence = {
			{
				Image = "rbxassetid://132414593481502",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://105291508417864",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://83537219982221",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://112951612984973",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://107154674815201",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://79871314110830",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://139947664336429",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://127080092594663",
				Color = Color3.fromRGB(255, 255, 255)
			}
		}
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(folder, instance)
		folder:SetAttribute("PaintingTexture", "rbxassetid://95523592318284")

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("MeshPart") then
				if descendant.Material == Enum.Material.Neon then
					descendant.Color = Color3.fromRGB(85, 124, 99)
				end
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 124, 99)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 124, 99))
				})
			end
		end

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
		local primaryPart2 = folder.PrimaryPart
		clone:PivotTo(primaryPart2.CFrame * objectSpace)
		clone3:PivotTo(primaryPart2.CFrame * objectSpace2)
		clone5.Parent = primaryPart2
		clone4.Parent = folder:WaitForChild("Notebook_Geo")
		clone4.Texture = "rbxassetid://95523592318284"
		clone.RingRanger.WeldConstraint.Part1 = primaryPart2
		clone3.WeldConstraint.Part1 = primaryPart2
		clone3.AlignPosition.Attachment1 = clone5
		clone.Parent = folder
		clone3.Parent = folder
		local ringRangerModel = clone2:WaitForChild("RingRangerModel")
		ringRangerModel.Value = clone3
		local notebookArtImage = clone2:WaitForChild("NotebookArtImage")
		notebookArtImage.Value = clone4
		clone2.Parent = folder
	end
}