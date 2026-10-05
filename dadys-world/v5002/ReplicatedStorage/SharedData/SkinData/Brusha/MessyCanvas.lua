local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Messy Canvas",
	TowerName = "Brusha",
	OverwriteAnimations = {
		Decode = "rbxassetid://117148221972939",
		Run = "rbxassetid://102829338491617",
		Walk = "rbxassetid://124535736069224",
		PaintStart = "rbxassetid://100877973979582",
		Quirk = "rbxassetid://118996920054143",
		Idle = "rbxassetid://114441817403913",
		Paint = "rbxassetid://136989683733742",
		PaintEnd = "rbxassetid://118429213594901"
	},
	FaceTextures = {
		Blink = "rbxassetid://94821556520303",
		Hurt = "rbxassetid://106770711148949",
		Normal = "rbxassetid://123153532348428"
	},
	PaintInfo = {
		Colors = {
			Color3.fromRGB(253, 253, 253),
			Color3.fromRGB(170, 87, 140),
			Color3.fromRGB(127, 32, 77),
			Color3.fromRGB(75, 36, 93)
		},
		Sequence = {
			{
				Image = "rbxassetid://96499300493672",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://90345686375116",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://103893941612400",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://107326662091962",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://127107986025532",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://78354692163736",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://105185842751352",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://114223028918928",
				Color = Color3.fromRGB(255, 255, 255)
			}
		}
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(parent, instance)
		parent:SetAttribute("PaintingTexture", "rbxassetid://89307892866078")
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
		clone4.Texture = "rbxassetid://89307892866078"
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