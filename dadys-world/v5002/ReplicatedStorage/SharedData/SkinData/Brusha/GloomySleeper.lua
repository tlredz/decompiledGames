local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Gloomy Sleeper",
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
		Normal = "rbxassetid://134398763923866",
		Blink = "rbxassetid://118249574491510",
		Hurt = "rbxassetid://85474521879426"
	},
	PaintInfo = {
		Colors = { Color3.fromRGB(108, 88, 129), Color3.fromRGB(0, 220, 226), Color3.fromRGB(221, 130, 155) },
		Sequence = {
			{
				Image = "rbxassetid://109910607417731",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://73338194693237",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://132604921404624",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://87466078750810",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://85344203806879",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://111536099272063",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://87123937207247",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://118556174032227",
				Color = Color3.fromRGB(255, 255, 255)
			}
		}
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(folder, instance)
		folder:SetAttribute("PaintingTexture", "rbxassetid://73920383880337")

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:IsA("MeshPart") then
				if descendant.Material == Enum.Material.Neon then
					descendant.Color = Color3.fromRGB(100, 100, 120)
				end
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 170)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
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
		clone4.Texture = "rbxassetid://73920383880337"
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