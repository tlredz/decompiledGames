local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Golden Bristles",
	TowerName = "Brusha",
	OverwriteAnimations = {
		PaintEnd = "rbxassetid://124484888585907",
		Paint = "rbxassetid://136989683733742",
		Idle = "rbxassetid://126803784296577",
		Quirk = "rbxassetid://79604226239009",
		Walk = "rbxassetid://72965148166443",
		PaintStart = "rbxassetid://126585703166409",
		Run = "rbxassetid://118872688736900",
		Decode = "rbxassetid://71700265710077"
	},
	FaceTextures = {
		Hurt = "rbxassetid://116616486303077",
		Normal = "rbxassetid://107694503822432",
		Blink = "rbxassetid://74233723823292"
	},
	PaintInfo = {
		Colors = { Color3.fromRGB(229, 62, 24), Color3.fromRGB(251, 172, 59), Color3.fromRGB(243, 149, 43) },
		Sequence = {
			{
				Image = "rbxassetid://131792126942269",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://102743310063298",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://78743585051485",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://100421260892474",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://109130330804540",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://82928466500210",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://118308553545061",
				Color = Color3.fromRGB(255, 255, 255)
			},
			{
				Image = "rbxassetid://75519600501986",
				Color = Color3.fromRGB(255, 255, 255)
			}
		}
	},
	USE_SKIN_MODEL = true,
	ApplySkin = function(parent, instance)
		parent:SetAttribute("PaintingTexture", "rbxassetid://130337451798753")
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
		clone4.Texture = "rbxassetid://130337451798753"
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